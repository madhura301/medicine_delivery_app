// Chemist Delivery Management Screen
// Shows orders assigned to delivery boys (OutForDelivery status)
// Allows chemist to complete delivery with OTP verification

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:pharmaish/shared/models/order_model.dart';
import 'package:pharmaish/core/screens/delivery/complete_delivery_screen.dart';

class ChemistDeliveryManagement extends StatefulWidget {
  const ChemistDeliveryManagement({super.key});

  @override
  State<ChemistDeliveryManagement> createState() =>
      _ChemistDeliveryManagementState();
}

class _ChemistDeliveryManagementState extends State<ChemistDeliveryManagement> {
  List<OrderModel> _outForDeliveryOrders = [];
  bool _isLoading = true;
  String? _errorMessage;
  late Dio _dio;
  String? _medicalStoreId;

  // Customer cache
  final Map<String, Map<String, String>> _customerCache = {};
  // Delivery boy cache
  final Map<int, String> _deliveryBoyCache = {};

  @override
  void initState() {
    super.initState();
    _setupDio();
    _loadMedicalStoreId();
  }

  void _setupDio() {
    _dio = Dio();
    _dio.options.baseUrl = AppConstants.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

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

  Future<void> _loadMedicalStoreId() async {
    try {
      final userId = await StorageService.getUserId();
      if (userId != null) {
        setState(() {
          _medicalStoreId = userId;
        });
        await _loadOutForDeliveryOrders();
      }
    } catch (e) {
      AppLogger.error('Error loading medical store ID: $e');
      setState(() {
        _errorMessage = 'Failed to load store information';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadOutForDeliveryOrders() async {
    if (_medicalStoreId == null) {
      setState(() {
        _errorMessage = 'Medical store ID not found';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      AppLogger.info('Fetching out-for-delivery orders for medical store: $_medicalStoreId');

      // GET /api/Orders/medicalstore/{medicalStoreId}
      // Filter for OutForDelivery status on client side
      final response = await _dio.get('/Orders/medicalstore/$_medicalStoreId');

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> ordersList;

        if (data is List) {
          ordersList = data;
        } else if (data is Map && data.containsKey('data')) {
          ordersList = data['data'] as List;
        } else {
          ordersList = [];
        }

        AppLogger.info('Received ${ordersList.length} active orders');

        final allOrders = ordersList.map((json) {
          return OrderModel.fromJson(json);
        }).toList();

        // Filter for OutForDelivery status
        final outForDeliveryOrders = allOrders.where((order) {
          return order.status.toLowerCase().contains('outfordelivery') ||
                 order.status.toLowerCase().contains('out for delivery');
        }).toList();

        AppLogger.info('Filtered ${outForDeliveryOrders.length} out-for-delivery orders');

        // Sort by created date (oldest first - FIFO)
        outForDeliveryOrders.sort((a, b) => a.createdOn.compareTo(b.createdOn));

        // Load additional info
        await _loadCustomerInfo(outForDeliveryOrders);

        setState(() {
          _outForDeliveryOrders = outForDeliveryOrders;
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      AppLogger.error('Error loading orders: ${e.message}');

      String errorMsg = 'Failed to load orders';
      if (e.response?.statusCode == 401) {
        errorMsg = 'Authentication failed. Please login again.';
      } else if (e.response?.statusCode == 404) {
        // No orders is not an error
        setState(() {
          _outForDeliveryOrders = [];
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _errorMessage = errorMsg;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Unexpected error: $e');
      setState(() {
        _errorMessage = 'An unexpected error occurred';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCustomerInfo(List<OrderModel> orders) async {
    for (var order in orders) {
      if (!_customerCache.containsKey(order.customerId)) {
        try {
          final response = await _dio.get('/Customers/${order.customerId}');
          if (response.statusCode == 200) {
            final customerData = response.data;
            _customerCache[order.customerId] = {
              'name':
                  '${customerData['customerFirstName'] ?? ''} ${customerData['customerLastName'] ?? ''}'
                      .trim(),
              'email': customerData['emailId']?.toString() ?? '',
              'phone': customerData['mobileNumber']?.toString() ?? '',
            };
          }
        } catch (e) {
          _customerCache[order.customerId] = {
            'name': 'Customer',
            'email': '',
            'phone': '',
          };
        }
      }
    }
  }

  String getCustomerName(OrderModel order) {
    return _customerCache[order.customerId]?['name'] ?? 'Customer';
  }

  String? getCustomerPhone(OrderModel order) {
    final phone = _customerCache[order.customerId]?['phone'];
    return (phone != null && phone.isNotEmpty) ? phone : null;
  }

  void _navigateToCompleteDelivery(OrderModel order) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompleteDeliveryScreen(
          order: order,
          customerName: getCustomerName(order),
          customerPhone: getCustomerPhone(order),
        ),
      ),
    );

    if (result == true) {
      // Reload orders after successful completion
      _loadOutForDeliveryOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Out for Delivery',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadOutForDeliveryOrders,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.local_shipping, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Orders Out for Delivery',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_outForDeliveryOrders.length} active deliveries',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.black),
            SizedBox(height: 16),
            Text('Loading deliveries...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error Loading Deliveries',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadOutForDeliveryOrders,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_outForDeliveryOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No Active Deliveries',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Orders assigned to delivery will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOutForDeliveryOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _outForDeliveryOrders.length,
        itemBuilder: (context, index) {
          final order = _outForDeliveryOrders[index];
          return _buildOrderCard(order, index + 1);
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, int orderNumber) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToCompleteDelivery(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '#$orderNumber',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order.orderNumber ?? order.orderId}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            getCustomerName(order),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.purple, width: 1),
                    ),
                    child: Text(
                      'Out for Delivery',
                      style: TextStyle(
                        color: Colors.purple.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // Order details
              _buildInfoRow(
                Icons.location_on,
                'Address',
                order.shippingAddressLine1 ?? 'N/A',
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              if (getCustomerPhone(order) != null)
                _buildInfoRow(
                  Icons.phone,
                  'Phone',
                  getCustomerPhone(order)!,
                ),
              const SizedBox(height: 8),
              if (order.totalAmount != null)
                _buildInfoRow(
                  Icons.currency_rupee,
                  'Amount',
                  '₹${order.totalAmount!.toStringAsFixed(2)}',
                ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.access_time,
                'Assigned',
                DateFormat('MMM dd, hh:mm a').format(order.createdOn),
              ),

              const SizedBox(height: 16),

              // Complete delivery button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToCompleteDelivery(order),
                  icon: const Icon(Icons.check_circle, size: 20),
                  label: const Text('Complete Delivery with OTP'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {int maxLines = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}