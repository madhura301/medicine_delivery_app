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
      final hasAccepted = await PharmacistConsentManager.hasAcceptedOrderDisclaimer(
        _currentOrder.orderId ?? ''
      );
      
      if (!hasAccepted && mounted) {
        // Show Data Handling & Liability Disclaimer
        final accepted = await PharmacistConsentManager.showDataHandlingLiabilityDisclaimer(
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
      await _refreshOrder();  // ✅ Load complete order first!
      // Load chemist details if assigned
      if (_currentOrder.medicalStoreId != null) {
        await _loadChemistDetails();
      }

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

  Future<void> _loadChemistDetails() async {
    try {
      final response =
          await _dio.get('/MedicalStores/${_currentOrder.medicalStoreId}');
      if (response.statusCode == 200) {
        setState(() {
          _chemistData = response.data;
        });
      }
    } catch (e) {
      AppLogger.error('Error loading chemist details: $e');
    }
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

  Widget _buildDeliveryAddress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_currentOrder.shippingAddressLine1 != null)
          Text(_currentOrder.shippingAddressLine1!,
              style: const TextStyle(fontSize: 14)),
        if (_currentOrder.shippingAddressLine2 != null &&
            _currentOrder.shippingAddressLine2!.isNotEmpty)
          Text(_currentOrder.shippingAddressLine2!,
              style: const TextStyle(fontSize: 14)),
        if (_currentOrder.shippingArea != null)
          Text(_currentOrder.shippingArea!,
              style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          '${_currentOrder.shippingCity ?? ''}, ${_currentOrder.shippingPincode ?? ''}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildChemistInfo() {
    if (_chemistData == null) {
      return const Text('Loading pharmacy details...');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Store Name', _chemistData!['storeName'] ?? 'N/A'),
        if (_chemistData!['mobileNumber'] != null)
          _buildDetailRow('Contact', _chemistData!['mobileNumber']),
        if (_chemistData!['addressLine1'] != null)
          _buildDetailRow('Address', _chemistData!['addressLine1']),
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
            child: Image.network(
              _currentOrder.prescriptionFileUrl!,
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
            child: Image.network(
              _currentOrder.billFileUrl!,
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
