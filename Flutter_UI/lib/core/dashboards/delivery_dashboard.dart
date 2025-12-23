// Delivery Boy Dashboard
// Shows all "OutForDelivery" orders assigned to the delivery boy
// Allows OTP verification to complete delivery

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:pharmaish/core/screens/delivery/complete_delivery_screen.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:pharmaish/shared/models/order_model.dart';

class DeliveryDashboard extends StatefulWidget {
  const DeliveryDashboard({super.key});

  @override
  State<DeliveryDashboard> createState() => _DeliveryDashboardState();
}

class _DeliveryDashboardState extends State<DeliveryDashboard> {
  List<OrderModel> _outForDeliveryOrders = [];
  bool _isLoading = true;
  String? _errorMessage;
  late Dio _dio;
  String _deliveryBoyName = 'Delivery';

  // Customer cache
  final Map<String, Map<String, String>> _customerCache = {};

  @override
  void initState() {
    super.initState();
    _setupDio();
    _loadUserName();
    _loadOutForDeliveryOrders();
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

  Future<void> _loadUserName() async {
    try {
      final userName = await StorageService.getUserName();
      if (userName != null) {
        setState(() {
          _deliveryBoyName = userName;
        });
      }
    } catch (e) {
      AppLogger.error('Error loading user name: $e');
    }
  }

  Future<void> _loadOutForDeliveryOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final deliveryId = await StorageService.getUserId();
      if (deliveryId == null) {
        throw Exception('Delivery ID not found');
      }

      AppLogger.info('Fetching out-for-delivery orders for delivery: $deliveryId');

      // GET /api/Orders/delivery/{deliveryId}/active
      // This endpoint should return orders with status "OutForDelivery"
      final response = await _dio.get('/Orders/delivery/$deliveryId/active');

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

        AppLogger.info('Received ${ordersList.length} out-for-delivery orders');

        final orders = ordersList.map((json) {
          return OrderModel.fromJson(json);
        }).toList();

        // Sort by created date (oldest first - FIFO)
        orders.sort((a, b) => a.createdOn.compareTo(b.createdOn));

        // Load customer info
        await _loadCustomerInfo(orders);

        setState(() {
          _outForDeliveryOrders = orders;
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      AppLogger.error('Error loading orders: ${e.message}');

      String errorMsg = 'Failed to load orders';
      if (e.response?.statusCode == 401) {
        errorMsg = 'Authentication failed. Please login again.';
        await StorageService.clearAll();
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
        return;
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

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await StorageService.clearAuthTokens();
        await StorageService.clearSavedCredentials();

        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      } catch (e) {
        AppLogger.error('Error during logout', e);
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      }
    }
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
          'Delivery Dashboard',
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Welcome header
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $_deliveryBoyName!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_outForDeliveryOrders.length} orders to deliver',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
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
            Icon(Icons.delivery_dining, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No Deliveries Pending',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have no orders to deliver right now',
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
                  label: const Text('Complete Delivery'),
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