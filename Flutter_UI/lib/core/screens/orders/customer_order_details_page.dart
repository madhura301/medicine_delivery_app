// File: lib/core/screens/orders/customer_order_details_page.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:pharmaish/shared/models/order_assignment_history_model.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/consent_manager.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:pharmaish/config/environment_config.dart';
import 'package:pharmaish/shared/models/order_model.dart';
import 'package:pharmaish/shared/widgets/authenticated_image.dart';
import 'package:pharmaish/shared/widgets/order_assignment_history_widget.dart';

class CustomerOrderDetailsPage extends StatefulWidget {
  final OrderModel order;

  const CustomerOrderDetailsPage({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<CustomerOrderDetailsPage> createState() =>
      _CustomerOrderDetailsPageState();
}

class _CustomerOrderDetailsPageState extends State<CustomerOrderDetailsPage> {
  late Dio _dio;
  bool _isLoading = true;
  String? _errorMessage;

  // Detailed data
  Map<String, dynamic>? _chemistData;
  Map<String, dynamic>? _addressData;
  bool _isLoadingAddress = false;
  Map<String, dynamic>? _deliveryData;

  late OrderModel _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _setupDio();
    _checkConsentAndLoadOrderDetails();
  }

  Future<void> _checkConsentAndLoadOrderDetails() async {
    // Check if user is a pharmacist
    final token = await StorageService.getAuthToken();
    if (token != null) {
      final userInfo = StorageService.decodeJwtToken(token);
      final role = StorageService.extractUserRole(userInfo);

      // Only show disclaimer for pharmacists/chemists
      if (role == 'Chemist') {
        // Check if already shown for this order
        final hasAccepted =
            await PharmacistConsentManager.hasAcceptedOrderDisclaimer(
                _currentOrder.orderId ?? '');

        if (!hasAccepted && mounted) {
          // Show Data Handling & Liability Disclaimer
          final accepted = await PharmacistConsentManager
              .showDataHandlingLiabilityDisclaimer(
            context,
            orderId: _currentOrder.orderId,
            customerId: _currentOrder.customerId,
          );

          if (!accepted) {
            // User declined - go back
            if (mounted) {
              Navigator.pop(context);
            }
            return;
          }
        }
      }
    }

    // Proceed to load order details
    _loadOrderDetails();
  }

  void _setupDio() {
    _dio = Dio();
    _dio.options.baseUrl = AppConstants.apiBaseUrl;
    _dio.options.connectTimeout = EnvironmentConfig.timeoutDuration;
    _dio.options.receiveTimeout = EnvironmentConfig.timeoutDuration;

    if (EnvironmentConfig.shouldLog) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        logPrint: (object) => AppLogger.info('API: $object'),
      ));
    }

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  Future<void> _refreshOrder() async {
    try {
      final response = await _dio.get('/Orders/${widget.order.orderId}');
      if (response.statusCode == 200) {
        final updatedOrder = OrderModel.fromJson(response.data);
        setState(() {
          _currentOrder = updatedOrder;
        });
      }
    } catch (e) {
      AppLogger.error('Error refreshing order: $e');
    }
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _refreshOrder(); // ✅ Load complete order first!
      // Load chemist and delivery address
      await Future.wait([
        if (_currentOrder.medicalStoreId != null) _loadChemistDetails(),
        _loadDeliveryAddress(),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error loading order details: $e');
      setState(() {
        _errorMessage = 'Failed to load complete order details';
        _isLoading = false;
      });
    }
  }

// REPLACE WITH:
  Future<void> _loadChemistDetails() async {
    try {
      final response =
          await _dio.get('/MedicalStores/${_currentOrder.medicalStoreId}');
      if (response.statusCode == 200) {
        setState(() {
          _chemistData =
              _normaliseCasing(response.data as Map<String, dynamic>);
        });
      }
    } catch (e) {
      AppLogger.error('Error loading chemist details: $e');
    }
  }

  Future<void> _loadDeliveryAddress() async {
    try {
      setState(() => _isLoadingAddress = true);
      final orderResp = await _dio.get('/Orders/${_currentOrder.orderId}');
      if (orderResp.statusCode != 200) return;
      final orderJson = orderResp.data as Map<String, dynamic>;
      final addressId = orderJson['customerAddressId']?.toString() ??
          orderJson['CustomerAddressId']?.toString();
      if (addressId == null || addressId.isEmpty) return;

      final addrResp = await _dio.get('/CustomerAddresses/$addressId');
      if (addrResp.statusCode == 200) {
        setState(() {
          _addressData =
              _normaliseCasing(addrResp.data as Map<String, dynamic>);
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      AppLogger.error('Error loading delivery address: $e');
      setState(() => _isLoadingAddress = false);
    }
  }

  Map<String, dynamic> _normaliseCasing(Map<String, dynamic> raw) {
    return raw.map((k, v) {
      final camel = k[0].toLowerCase() + k.substring(1);
      return MapEntry(camel, v);
    });
  }

// ────────────────────────────────────────────────────────────────────────────
// Check if order has delivery assignment
// ────────────────────────────────────────────────────────────────────────────
  bool _hasDeliveryAssignment() {
    return _currentOrder.assignmentHistory
        .any((h) => h.assignTo == AssignTo.delivery);
  }

// ────────────────────────────────────────────────────────────────────────────
// Display labeled information
// ────────────────────────────────────────────────────────────────────────────
  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

// ────────────────────────────────────────────────────────────────────────────
// Build delivery info from assignment history
// ────────────────────────────────────────────────────────────────────────────
  Widget _buildDeliveryInfoFromHistory() {
    // Get all delivery assignments
    final deliveryAssignments = _currentOrder.assignmentHistory
        .where((h) => h.assignTo == AssignTo.delivery)
        .toList();

    if (deliveryAssignments.isEmpty) {
      return Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No delivery information available',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      );
    }

    // Sort by assignedOn descending to get the latest
    deliveryAssignments.sort((a, b) => b.assignedOn.compareTo(a.assignedOn));
    final latestDelivery = deliveryAssignments.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          'Delivery Person',
          latestDelivery.assigneeName ?? 'N/A',
          icon: Icons.person,
        ),
        _buildInfoRow(
          'Status',
          latestDelivery.status.displayName,
          icon: Icons.info,
        ),
        _buildInfoRow(
          'Assigned On',
          DateFormat('MMM dd, yyyy • hh:mm a')
              .format(latestDelivery.assignedOn.toLocal()),
          icon: Icons.access_time,
        ),
        if (latestDelivery.updatedOn != null)
          _buildInfoRow(
            'Updated On',
            DateFormat('MMM dd, yyyy • hh:mm a')
                .format(latestDelivery.updatedOn!.toLocal()),
            icon: Icons.update,
          ),

        // Rejection reason (if rejected)
        if (latestDelivery.status == AssignmentStatus.rejected &&
            latestDelivery.rejectNote != null &&
            latestDelivery.rejectNote!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery Issue:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        latestDelivery.rejectNote!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.red.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order #${_currentOrder.orderNumber ?? (_currentOrder.orderId.length > 8 ? _currentOrder.orderId.substring(0, 8) : _currentOrder.orderId)}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadOrderDetails,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.black),
            )
          : _errorMessage != null
              ? _buildErrorView()
              : _buildContent(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadOrderDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Banner
          _buildStatusBanner(),

          // Order Information Section
          _buildSection(
            'Order Information',
            Icons.receipt_long,
            Colors.blue,
            _buildOrderInfo(),
          ),

          // Delivery Address Section
          _buildSection(
            'Delivery Address',
            Icons.location_on,
            Colors.green,
            _buildDeliveryAddress(),
          ),

          // Chemist Information Section (if assigned)
          if (_currentOrder.medicalStoreId != null)
            _buildSection(
              'Assigned Pharmacy',
              Icons.local_pharmacy,
              Colors.purple,
              _buildChemistInfo(),
            ),

          // Prescription Section
          if (_currentOrder.prescriptionFileUrl != null)
            _buildSection(
              'Prescription',
              Icons.medical_services,
              Colors.red,
              _buildPrescriptionSection(),
            ),

          // Bill Section
          if (_currentOrder.billFileUrl != null)
            _buildSection(
              'Bill',
              Icons.receipt,
              Colors.orange,
              _buildBillSection(),
            ),

          // Delivery Information
          if (_hasDeliveryAssignment())
            _buildSection(
              'Delivery Information',
              Icons.delivery_dining,
              Colors.teal,
              _buildDeliveryInfoFromHistory(), // New method
            ),

          // ✨ Assignment History (Customer view - simplified)
          OrderAssignmentHistoryWidget(
            order: _currentOrder,
            isAdminView: false, // Customer sees simplified view
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    Color statusColor;
    IconData statusIcon;
    String statusText = _currentOrder.status;

    final statusLower = _currentOrder.status.toLowerCase();
    if (statusLower.contains('pending') || statusLower.contains('assigned')) {
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
      statusText = 'Pending';
    } else if (statusLower.contains('accepted')) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Accepted';
    } else if (statusLower.contains('rejected')) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      statusText = 'Rejected';
    } else if (statusLower.contains('bill')) {
      statusColor = Colors.blue;
      statusIcon = Icons.receipt;
      statusText = 'Bill Uploaded';
    } else if (statusLower.contains('paid')) {
      statusColor = Colors.purple;
      statusIcon = Icons.payment;
      statusText = 'Paid';
    } else if (statusLower.contains('delivery')) {
      statusColor = Colors.teal;
      statusIcon = Icons.delivery_dining;
      statusText = 'Out for Delivery';
    } else if (statusLower.contains('completed')) {
      statusColor = Colors.green.shade700;
      statusIcon = Icons.check_circle_outline;
      statusText = 'Completed';
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.info;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        border: Border(
          bottom: BorderSide(color: statusColor, width: 2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Status',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      String title, IconData icon, Color color, Widget content) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Column(
      children: [
        _buildDetailRow('Order ID', _currentOrder.orderId),
        if (_currentOrder.orderNumber != null)
          _buildDetailRow('Order Number', _currentOrder.orderNumber!),
        _buildDetailRow('Order Type', _currentOrder.orderTypeDisplayName),
        _buildDetailRow(
          'Created On',
          DateFormat('MMM dd, yyyy - hh:mm a')
              .format(_currentOrder.createdOn.toLocal()),
        ),
        if (_currentOrder.totalAmount != null)
          _buildDetailRow(
            'Total Amount',
            '₹${_currentOrder.totalAmount!.toStringAsFixed(2)}',
            valueStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
      ],
    );
  }

// REPLACE WITH:
  Widget _buildDeliveryAddress() {
    if (_isLoadingAddress) {
      return const Row(children: [
        SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2)),
        SizedBox(width: 8),
        Text('Loading address...',
            style: TextStyle(fontSize: 13, color: Colors.grey)),
      ]);
    }

    if (_addressData == null) {
      return const Text('Address not available',
          style: TextStyle(color: Colors.grey));
    }

    String g(String key) => (_addressData![key] ?? '').toString().trim();

    final parts = <String>[];
    void add(String key) {
      final v = g(key);
      if (v.isNotEmpty) parts.add(v);
    }

    add('address');
    add('addressLine1');
    add('addressLine2');
    add('addressLine3');
    final city = g('city');
    final state = g('state');
    final pincode = g('pincode').isNotEmpty ? g('pincode') : g('postalCode');
    final last = [city, state, pincode].where((s) => s.isNotEmpty).join(' - ');
    if (last.isNotEmpty) parts.add(last);

    if (parts.isEmpty) {
      return const Text('Address on file',
          style: TextStyle(color: Colors.grey));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parts
          .map((line) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(line, style: const TextStyle(fontSize: 14)),
              ))
          .toList(),
    );
  }

  // REPLACE WITH:
  Widget _buildChemistInfo() {
    if (_chemistData == null) {
      return const Row(children: [
        SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2)),
        SizedBox(width: 8),
        Text('Loading pharmacy details...'),
      ]);
    }

    String g(String key) => (_chemistData![key] ?? '').toString();

    final storeName = g('medicalName');
    final ownerFirst = g('ownerFirstName');
    final ownerLast = g('ownerLastName');
    final mobile = g('mobileNumber');
    final addr1 = g('addressLine1');
    final addr2 = g('addressLine2');
    final city = g('city');
    final state = g('state');
    final postal = g('postalCode');

    final addressParts = [addr1, addr2, city, state, postal]
        .where((p) => p.isNotEmpty)
        .join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Store Name', storeName.isNotEmpty ? storeName : 'N/A'),
        _buildDetailRow(
            'Owner',
            '${ownerFirst} ${ownerLast}'.trim().isNotEmpty
                ? '${ownerFirst} ${ownerLast}'.trim()
                : 'N/A'),
        _buildDetailRow('Mobile', mobile.isNotEmpty ? mobile : 'N/A'),
        if (addressParts.isNotEmpty) _buildDetailRow('Address', addressParts),
      ],
    );
  }

  Widget _buildPrescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_currentOrder.prescriptionFileUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AuthNetworkImage(
              url: getOrderInputFileUrl(_currentOrder.orderId),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Failed to load prescription'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () => downloadPrescriptionImage(
                context,
                orderId: _currentOrder.orderId,
                prescriptionFileUrl: _currentOrder.prescriptionFileUrl,
              ),
              icon: const Icon(Icons.download),
              label: const Text('Download'),
            ),
          ),
        ] else
          const Text('No prescription uploaded'),
      ],
    );
  }

  Widget _buildBillSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_currentOrder.billFileUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AuthNetworkImage(
              url: getOrderBillFileUrl(_currentOrder.orderId),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Failed to load bill'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () => downloadBillFile(
                context,
                orderId: _currentOrder.orderId,
                billFileUrl: _currentOrder.billFileUrl,
              ),
              icon: const Icon(Icons.download),
              label: const Text('Download'),
            ),
          ),
        ] else
          const Text('Bill not yet uploaded'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ??
                  const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
