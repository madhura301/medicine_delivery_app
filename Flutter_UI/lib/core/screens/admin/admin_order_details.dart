// Admin Order Details Page
// Shows complete information about a specific order

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:pharmaish/shared/models/order_assignment_history_model.dart';
import 'package:pharmaish/shared/widgets/order_assignment_history_widget.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:pharmaish/config/environment_config.dart';
import 'package:pharmaish/shared/models/order_model.dart';

class AdminOrderDetailsPage extends StatefulWidget {
  final OrderModel order;

  const AdminOrderDetailsPage({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<AdminOrderDetailsPage> createState() => _AdminOrderDetailsPageState();
}

class _AdminOrderDetailsPageState extends State<AdminOrderDetailsPage> {
  late Dio _dio;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isLoadingCustomer = true;
  String? _customerError;
  // Detailed data
  Map<String, dynamic>? _customerData;
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

  /// Converts a relative file path from the backend into a full loadable URL.
  String _resolveFileUrl(String rawUrl) {
  if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) return rawUrl;
  // Strip leading slash if present
  final clean = rawUrl.replaceAll(r'\', '/').replaceAll(RegExp(r'^/'), '');
  // Base URL without /api suffix
  final base = AppConstants.apiBaseUrl.replaceAll(RegExp(r'/api/?$'), '');
  return '$base/$clean';
}

  /// Opens a full-screen image viewer with pinch-to-zoom.
  void _openFullScreen(String rawUrl, String title) {
    final url = _resolveFileUrl(rawUrl);
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => _FullScreenImagePage(imageUrl: url, title: title)),
    );
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
      await _refreshOrder(); // Load complete order first!
      // Load customer and delivery details
      await Future.wait([
        _loadCustomerDetails(),
        _loadDeliveryAddress(),
      ]);

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

  Future<void> _loadCustomerDetails() async {
    setState(() {
      _isLoadingCustomer = true;
      _customerError = null;
    });

    try {
      final customerId = _currentOrder.customerId;

      // ✅ Log customer ID
      AppLogger.info('=== LOADING CUSTOMER ===');
      AppLogger.info('Customer ID: $customerId');
      AppLogger.info('Customer ID type: ${customerId.runtimeType}');
      AppLogger.info('Customer ID length: ${customerId.length}');

      // ✅ Log auth token status
      final token = await StorageService.getAuthToken();
      if (token != null) {
        AppLogger.info('Auth token present: ${token.substring(0, 20)}...');
      } else {
        AppLogger.error('❌ NO AUTH TOKEN FOUND!');
      }

      // ✅ Log full URL
      final url = '/Customers/$customerId';
      final fullUrl = '${_dio.options.baseUrl}$url';
      AppLogger.info('Request URL: $fullUrl');

      // ✅ Make the request
      final response = await _dio.get(url);

      AppLogger.info('✅ Customer response: ${response.statusCode}');
      AppLogger.info(
          'Response data keys: ${(response.data as Map).keys.toList()}');

      if (response.statusCode == 200) {
        setState(() {
          _customerData = response.data;
          _isLoadingCustomer = false;
        });
        AppLogger.info('✅ Customer loaded successfully');
      } else {
        setState(() {
          _customerError =
              'Failed to load customer (Status: ${response.statusCode})';
          _isLoadingCustomer = false;
        });
      }
    } on DioException catch (e) {
      AppLogger.error('❌ DioException loading customer');
      AppLogger.error('Status code: ${e.response?.statusCode}');
      AppLogger.error('Response data: ${e.response?.data}');
      AppLogger.error('Error type: ${e.type}');
      AppLogger.error('Message: ${e.message}');
      AppLogger.error('Request: ${e.requestOptions.uri}');
      AppLogger.error('Request headers: ${e.requestOptions.headers}');

      setState(() {
        _customerError = e.response?.statusCode == 404
            ? 'Customer not found'
            : e.response?.statusCode == 401
                ? 'Authentication required. Please login again.'
                : e.response?.statusCode == 403
                    ? 'Access denied. You don\'t have permission.'
                    : 'Failed to load customer details (${e.response?.statusCode ?? 'network error'})';
        _isLoadingCustomer = false;
      });
    } catch (e) {
      AppLogger.error('❌ Unexpected error loading customer details: $e');
      setState(() {
        _customerError = 'An error occurred while retrieving the customer';
        _isLoadingCustomer = false;
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

// ADD these two new methods right after:
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

          // Customer Information Section
          _buildSection(
            'Customer Details',
            Icons.person,
            Colors.green,
            _buildCustomerInfo(),
          ),

          // Chemist Information Section (if assigned)
          if (_currentOrder.medicalStoreId != null)
            _buildSection(
              'Chemist/Pharmacy Details',
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
              _buildDeliveryInfoFromHistory(),
            ),

          // ✨ NEW: Assignment History Widget
          _buildAssignmentHistorySection(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

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
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasDeliveryAssignment() {
    return _currentOrder.assignmentHistory
        .any((h) => h.assignTo == AssignTo.delivery);
  }

  Widget _buildDeliveryInfoFromHistory() {
    // Get the latest delivery assignment
    final deliveryAssignments = _currentOrder.assignmentHistory
        .where((h) => h.assignTo == AssignTo.delivery)
        .toList();

    if (deliveryAssignments.isEmpty) {
      return const Text('No delivery information available');
    }

    // Sort by assignedOn descending to get the latest
    deliveryAssignments.sort((a, b) => b.assignedOn.compareTo(a.assignedOn));
    final latestDelivery = deliveryAssignments.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Delivery Person', latestDelivery.assigneeName ?? 'N/A'),
        _buildInfoRow('Status', latestDelivery.status.displayName),
        _buildInfoRow(
          'Assigned On',
          DateFormat('MMM dd, yyyy - hh:mm a')
              .format(latestDelivery.assignedOn.toLocal()),
        ),
        if (latestDelivery.updatedOn != null)
          _buildInfoRow(
            'Updated On',
            DateFormat('MMM dd, yyyy - hh:mm a')
                .format(latestDelivery.updatedOn!.toLocal()),
          ),
        if (latestDelivery.rejectNote != null &&
            latestDelivery.rejectNote!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
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
                          'Rejection Reason:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          latestDelivery.rejectNote!,
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
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
    } else if (statusLower.contains('completed')) {
      statusColor = Colors.blue;
      statusIcon = Icons.done_all;
      statusText = 'Completed';
    } else if (statusLower.contains('delivery')) {
      statusColor = Colors.purple;
      statusIcon = Icons.local_shipping;
      statusText = 'Out for Delivery';
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.info;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor, statusColor.withOpacity(0.7)],
        ),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order Status',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    IconData icon,
    Color color,
    Widget content,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
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
        _buildDetailRow(
          'Order Date',
          DateFormat('MMM dd, yyyy - hh:mm a').format(_currentOrder.createdOn),
        ),
        _buildDetailRow(
          'Order Type',
          _currentOrder.orderInputTypeDisplayName ?? 'N/A',
        ),
        if (_currentOrder.totalAmount != null)
          _buildDetailRow(
            'Total Amount',
            '₹${_currentOrder.totalAmount!.toStringAsFixed(2)}',
            valueStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        // REPLACE WITH:
        if (_isLoadingAddress)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(children: [
              SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 8),
              Text('Loading delivery address...',
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
            ]),
          )
        else if (_addressData != null)
          _buildDetailRow('Delivery Address', _formatAddress(_addressData!))
        else
          _buildDetailRow('Delivery Address', 'Not available'),
      ],
    );
  }

  Widget _buildCustomerInfo() {
    // Show loading state
    if (_isLoadingCustomer) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show error state
    if (_customerError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text(
                _customerError!,
                style: TextStyle(color: Colors.red.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _loadCustomerDetails,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show data if loaded successfully
    if (_customerData == null) {
      return const Center(
        child: Text('No customer data available'),
      );
    }

    final firstName = _customerData!['customerFirstName'] ?? '';
    final lastName = _customerData!['customerLastName'] ?? '';
    final email = _customerData!['emailId'] ?? '';
    final mobile = _customerData!['mobileNumber'] ?? '';
    final customerNumber = _customerData!['customerNumber']?.toString();

    return Column(
      children: [
        // ✨ NEW: Customer Number (if available)
        if (customerNumber != null && customerNumber.isNotEmpty)
          _buildDetailRow('Customer ID', customerNumber),
        _buildDetailRow('Name', '$firstName $lastName'),
        if (email.isNotEmpty) _buildDetailRow('Email', email),
        _buildDetailRow('Mobile', mobile),
      ],
    );
  }

  // REPLACE WITH:
  Widget _buildChemistInfo() {
    if (_chemistData == null) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: Row(children: [
          SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 8),
          Text('Loading pharmacy details...'),
        ]),
      );
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

// ADD this new helper method right after _buildChemistInfo:
  String _formatAddress(Map<String, dynamic> addr) {
    final parts = <String>[];
    void add(String key) {
      final v = (addr[key] ?? '').toString().trim();
      if (v.isNotEmpty) parts.add(v);
    }

    add('address');
    add('addressLine1');
    add('addressLine2');
    add('addressLine3');
    final city = (addr['city'] ?? '').toString().trim();
    final state = (addr['state'] ?? '').toString().trim();
    final pincode =
        (addr['pincode'] ?? addr['postalCode'] ?? '').toString().trim();
    final last = [city, state, pincode].where((s) => s.isNotEmpty).join(' - ');
    if (last.isNotEmpty) parts.add(last);
    return parts.isEmpty ? 'Address on file' : parts.join('\n');
  }

  Widget _buildPrescriptionSection() {
    final rawUrl = _currentOrder.prescriptionFileUrl;
    if (rawUrl == null) {
      return const Text('No prescription attached');
    }
    final imageUrl = _resolveFileUrl(rawUrl);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _openFullScreen(rawUrl, 'Prescription'),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              loadingBuilder: (ctx, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: 200,
                  color: Colors.grey[100],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (ctx, error, stack) {
                AppLogger.error(
                    'Prescription image load error: $error | url: $imageUrl');
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.broken_image,
                          size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      const Text('Failed to load image'),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          imageUrl,
                          style:
                              const TextStyle(fontSize: 10, color: Colors.grey),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => _openFullScreen(rawUrl, 'Prescription'),
          icon: const Icon(Icons.zoom_in),
          label: const Text('View Full Size'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBillSection() {
    final rawUrl = _currentOrder.billFileUrl;
    if (rawUrl == null) {
      return const Text('No bill uploaded yet');
    }
    final imageUrl = _resolveFileUrl(rawUrl);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _openFullScreen(rawUrl, 'Bill'),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              loadingBuilder: (ctx, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: 200,
                  color: Colors.grey[100],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (ctx, error, stack) {
                AppLogger.error(
                    'Bill image load error: $error | url: $imageUrl');
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.broken_image,
                          size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      const Text('Failed to load bill image'),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          imageUrl,
                          style:
                              const TextStyle(fontSize: 10, color: Colors.grey),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => _openFullScreen(rawUrl, 'Bill'),
          icon: const Icon(Icons.zoom_in),
          label: const Text('View Full Size'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildAssignmentHistorySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: OrderAssignmentHistoryWidget(
        order: _currentOrder,
        isAdminView: true, // Admin sees full details
      ),
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

// =============================================================================
// FULL SCREEN IMAGE VIEWER
// Supports pinch-to-zoom, double-tap zoom, and pan.
// =============================================================================

class _FullScreenImagePage extends StatefulWidget {
  final String imageUrl;
  final String title;

  const _FullScreenImagePage({required this.imageUrl, required this.title});

  @override
  State<_FullScreenImagePage> createState() => _FullScreenImagePageState();
}

class _FullScreenImagePageState extends State<_FullScreenImagePage>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformCtrl;
  TapDownDetails? _doubleTapDetails;
  late AnimationController _animCtrl;
  Animation<Matrix4>? _animation;

  @override
  void initState() {
    super.initState();
    _transformCtrl = TransformationController();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() {
        if (_animation != null) {
          _transformCtrl.value = _animation!.value;
        }
      });
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _onDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _onDoubleTap() {
    final position = _doubleTapDetails!.localPosition;
    final isZoomedIn = _transformCtrl.value.getMaxScaleOnAxis() > 1.0;

    final Matrix4 end = isZoomedIn
        ? Matrix4.identity()
        : (Matrix4.identity()
          ..translate(-position.dx * 2, -position.dy * 2)
          ..scale(3.0));

    _animation = Matrix4Tween(
      begin: _transformCtrl.value,
      end: end,
    ).animate(CurveTween(curve: Curves.easeInOut).animate(_animCtrl));

    _animCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out_map, color: Colors.white),
            tooltip: 'Reset zoom',
            onPressed: () {
              _animation = Matrix4Tween(
                begin: _transformCtrl.value,
                end: Matrix4.identity(),
              ).animate(CurveTween(curve: Curves.easeOut).animate(_animCtrl));
              _animCtrl.forward(from: 0);
            },
          ),
        ],
      ),
      body: Center(
        child: GestureDetector(
          onDoubleTapDown: _onDoubleTapDown,
          onDoubleTap: _onDoubleTap,
          child: InteractiveViewer(
            transformationController: _transformCtrl,
            minScale: 0.5,
            maxScale: 6.0,
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (ctx, child, progress) {
                if (progress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (ctx, error, stack) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.broken_image,
                      color: Colors.white54, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      widget.imageUrl,
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
