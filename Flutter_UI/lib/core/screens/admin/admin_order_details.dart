// Admin Order Details Page
// Shows complete information about a specific order

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
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

  // Detailed data
  Map<String, dynamic>? _customerData;
  Map<String, dynamic>? _chemistData;
  Map<String, dynamic>? _deliveryData;
  List<Map<String, dynamic>> _orderHistory = [];

  @override
  void initState() {
    super.initState();
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

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load customer details
      await _loadCustomerDetails();

      // Load chemist details if assigned
      if (widget.order.medicalStoreId != null) {
        await _loadChemistDetails();
      }

      // Load delivery details if available
      await _loadDeliveryDetails();

      // Load order history
      await _loadOrderHistory();

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
    try {
      final response = await _dio.get('/Customers/${widget.order.customerId}');
      if (response.statusCode == 200) {
        setState(() {
          _customerData = response.data;
        });
      }
    } catch (e) {
      AppLogger.error('Error loading customer details: $e');
    }
  }

  Future<void> _loadChemistDetails() async {
    try {
      final response =
          await _dio.get('/MedicalStores/${widget.order.medicalStoreId}');
      if (response.statusCode == 200) {
        setState(() {
          _chemistData = response.data;
        });
      }
    } catch (e) {
      AppLogger.error('Error loading chemist details: $e');
    }
  }

  Future<void> _loadDeliveryDetails() async {
    try {
      // Try to get delivery information
      final response = await _dio.get('/Deliveries/order/${widget.order.orderId}');
      if (response.statusCode == 200) {
        setState(() {
          _deliveryData = response.data;
        });
      }
    } catch (e) {
      AppLogger.info('No delivery data available: $e');
    }
  }

  Future<void> _loadOrderHistory() async {
    try {
      final response = await _dio.get(
          '/OrderAssignmentHistory/order/${widget.order.orderId}');
      if (response.statusCode == 200) {
        setState(() {
          _orderHistory = List<Map<String, dynamic>>.from(response.data);
        });
      }
    } catch (e) {
      AppLogger.info('No order history available: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order #${widget.order.orderNumber ?? (widget.order.orderId.length > 8 ? widget.order.orderId.substring(0, 8) : widget.order.orderId)}',
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
          if (widget.order.medicalStoreId != null)
            _buildSection(
              'Chemist/Pharmacy Details',
              Icons.local_pharmacy,
              Colors.purple,
              _buildChemistInfo(),
            ),

          // Prescription Section
          if (widget.order.prescriptionFileUrl != null)
            _buildSection(
              'Prescription',
              Icons.medical_services,
              Colors.red,
              _buildPrescriptionSection(),
            ),

          // Bill Section
          if (widget.order.billFileUrl != null)
            _buildSection(
              'Bill',
              Icons.receipt,
              Colors.orange,
              _buildBillSection(),
            ),

          // Delivery Information
          if (_deliveryData != null)
            _buildSection(
              'Delivery Information',
              Icons.delivery_dining,
              Colors.teal,
              _buildDeliveryInfo(),
            ),

          // Order History
          if (_orderHistory.isNotEmpty)
            _buildSection(
              'Order History',
              Icons.history,
              Colors.indigo,
              _buildOrderHistory(),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    Color statusColor;
    IconData statusIcon;
    String statusText = widget.order.status;

    final statusLower = widget.order.status.toLowerCase();
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
        _buildDetailRow('Order ID', widget.order.orderId),
        if (widget.order.orderNumber != null)
          _buildDetailRow('Order Number', widget.order.orderNumber!),
        _buildDetailRow(
          'Order Date',
          DateFormat('MMM dd, yyyy - hh:mm a').format(widget.order.createdOn),
        ),
        _buildDetailRow(
          'Order Type',
          widget.order.orderInputTypeDisplayName ?? 'N/A',
        ),
        if (widget.order.totalAmount != null)
          _buildDetailRow(
            'Total Amount',
            '₹${widget.order.totalAmount!.toStringAsFixed(2)}',
            valueStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        if (widget.order.shippingAddressLine1 != null)
          _buildDetailRow(
            'Delivery Address',
            '${widget.order.shippingAddressLine1}\n'
            '${widget.order.shippingAddressLine2 ?? ''}\n'
            '${widget.order.shippingCity ?? ''}, ${widget.order.shippingArea ?? ''} - ${widget.order.shippingPincode ?? ''}',
          ),
      ],
    );
  }

  Widget _buildCustomerInfo() {
    if (_customerData == null) {
      return const Text('Loading customer details...');
    }

    final firstName = _customerData!['customerFirstName'] ?? '';
    final lastName = _customerData!['customerLastName'] ?? '';
    final email = _customerData!['emailId'] ?? '';
    final mobile = _customerData!['mobileNumber'] ?? '';

    return Column(
      children: [
        _buildDetailRow('Name', '$firstName $lastName'),
        _buildDetailRow('Email', email),
        _buildDetailRow('Mobile', mobile),
      ],
    );
  }

  Widget _buildChemistInfo() {
    if (_chemistData == null) {
      return const Text('Loading chemist details...');
    }

    final storeName = _chemistData!['medicalName'] ?? '';
    final ownerFirst = _chemistData!['ownerFirstName'] ?? '';
    final ownerLast = _chemistData!['ownerLastName'] ?? '';
    final mobile = _chemistData!['mobileNumber'] ?? '';
    final address = _chemistData!['addressLine1'] ?? '';
    final city = _chemistData!['city'] ?? '';
    final state = _chemistData!['state'] ?? '';

    return Column(
      children: [
        _buildDetailRow('Store Name', storeName),
        _buildDetailRow('Owner', '$ownerFirst $ownerLast'),
        _buildDetailRow('Mobile', mobile),
        _buildDetailRow('Address', '$address, $city, $state'),
      ],
    );
  }

  Widget _buildPrescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.order.prescriptionFileUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.order.prescriptionFileUrl!,
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
                        Text('Failed to load prescription image'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Open image in full screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening full screen - Coming Soon')),
              );
            },
            icon: const Icon(Icons.zoom_in),
            label: const Text('View Full Size'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
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
        if (widget.order.billFileUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.order.billFileUrl!,
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
                        Text('Failed to load bill image'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Open image in full screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening full screen - Coming Soon')),
              );
            },
            icon: const Icon(Icons.zoom_in),
            label: const Text('View Full Size'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
          ),
        ] else
          const Text('No bill uploaded yet'),
      ],
    );
  }

  Widget _buildDeliveryInfo() {
    if (_deliveryData == null) {
      return const Text('No delivery information available');
    }

    return Column(
      children: [
        if (_deliveryData!['deliveryBoyName'] != null)
          _buildDetailRow('Delivery Person', _deliveryData!['deliveryBoyName']),
        if (_deliveryData!['deliveryBoyMobile'] != null)
          _buildDetailRow('Contact', _deliveryData!['deliveryBoyMobile']),
        if (_deliveryData!['assignedOn'] != null)
          _buildDetailRow(
            'Assigned On',
            DateFormat('MMM dd, yyyy - hh:mm a')
                .format(DateTime.parse(_deliveryData!['assignedOn'])),
          ),
        if (_deliveryData!['completedOn'] != null)
          _buildDetailRow(
            'Completed On',
            DateFormat('MMM dd, yyyy - hh:mm a')
                .format(DateTime.parse(_deliveryData!['completedOn'])),
          ),
      ],
    );
  }

  Widget _buildOrderHistory() {
    return Column(
      children: _orderHistory.map((history) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.history,
                color: Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history['action'] ?? 'Status Change',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (history['assignedOn'] != null)
                      Text(
                        DateFormat('MMM dd, yyyy - hh:mm a')
                            .format(DateTime.parse(history['assignedOn'])),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {TextStyle? valueStyle}) {
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