import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:pharmaish/config/environment_config.dart';
import 'package:pharmaish/core/screens/admin/admin_customer_support_regions.dart';
import 'package:pharmaish/core/screens/chemist/chemist_delivery_management.dart';
import 'package:pharmaish/shared/widgets/order_tile_with_bill.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:pharmaish/shared/models/order_model.dart';
import 'package:pharmaish/shared/models/order_enums.dart';

// ============================================================================
// CHEMIST DASHBOARD - WITH BILL UPLOAD SUPPORT
// Features:
// 1. Uses OrderTileWithBill for accepted orders
// 2. Shows bill upload button on accepted orders
// 3. Proper status filtering
// ============================================================================

class ChemistDashboard extends StatefulWidget {
  const ChemistDashboard({Key? key}) : super(key: key);

  @override
  State<ChemistDashboard> createState() => _ChemistDashboardState();
}

class _ChemistDashboardState extends State<ChemistDashboard> {
  List<OrderModel> _recentOrders = [];
  List<OrderModel> _allOrders = [];
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, int> _orderCounts = {};
  late Dio _dio;

  // Customer info cache (customerId -> customer data)
  final Map<String, Map<String, String>> _customerCache = {};

  @override
  void initState() {
    super.initState();
    _setupDio();
    _loadDashboardData();
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
      onError: (error, handler) {
        if (EnvironmentConfig.shouldLog) {
          AppLogger.error('API Error: ${error.message}');
          AppLogger.error('Status Code: ${error.response?.statusCode}');
          AppLogger.error('Response Data: ${error.response?.data}');
        }
        handler.next(error);
      },
    ));
  }

  Future<void> _navigateToChemistProfile(BuildContext context) async {
    final pharmacistId = await StorageService.getUserId();
    Navigator.pushNamed(context, '/pharmacistProfile',
        arguments: {'pharmacistId': pharmacistId!});
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pharmacistId = await StorageService.getUserId();

      if (pharmacistId == null || pharmacistId.isEmpty) {
        setState(() {
          _errorMessage = 'User ID not found. Please login again.';
          _isLoading = false;
        });
        return;
      }

      AppLogger.info('Fetching active orders for pharmacist: $pharmacistId');

      final response = await _dio.get(
        '/Orders/medicalstore/$pharmacistId',
      );

      AppLogger.info('Response received with status: ${response.statusCode}');
      AppLogger.info(response.data.toString());
      if (response.statusCode == 200) {
        final data = response.data;

        List<dynamic> ordersList;
        if (data is List) {
          ordersList = data;
        } else if (data is Map && data.containsKey('data')) {
          ordersList = data['data'] as List;
        } else if (data is Map && data.containsKey('orders')) {
          ordersList = data['orders'] as List;
        } else {
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }

        AppLogger.info('Received ${ordersList.length} active orders');

        // Parse orders using existing OrderModel
        final allOrders = ordersList.map((json) {
          AppLogger.info('Parsing order: $json');
          return OrderModel.fromJson(json);
        }).toList();

        // Sort by date (most recent first)
        allOrders.sort((a, b) => b.createdOn.compareTo(a.createdOn));

        AppLogger.info(allOrders
            .map((o) =>
                'OrderId: ${o.orderId}, Status: ${o.status}, CreatedOn: ${o.createdOn}')
            .join('\n'));
        // Load customer info for each order
        await _loadCustomerInfo(allOrders);

        // Calculate order counts based on status string
        final pendingCount = allOrders
            .where((o) =>
                o.status.toLowerCase().contains('pending') ||
                o.status.toLowerCase().contains('assigned'))
            .length;

        final acceptedCount = allOrders
            .where((o) => o.status.toLowerCase().contains('accepted'))
            .length;

        final outForDeliveryCount = allOrders
            .where((o) => o.status.toLowerCase().contains('delivery'))
            .length;

        final billUploadedCount = allOrders
            .where((o) => o.status.toLowerCase().contains('bill'))
            .length;

        final rejectedCount = allOrders
            .where((o) => o.status.toLowerCase().contains('rejected'))
            .length;

        final completedCount = allOrders
            .where((o) => o.status.toLowerCase().contains('completed'))
            .length;

        setState(() {
          _allOrders = allOrders;
          _recentOrders = allOrders
              .where((o) =>
                  o.status.toLowerCase().contains('pending') ||
                  o.status.toLowerCase().contains('assigned'))
              .take(5)
              .toList();

          _orderCounts = {
            'pending': pendingCount,
            'accepted': acceptedCount,
            'rejected': rejectedCount,
            'completed': completedCount,
            'outForDelivery': outForDeliveryCount,
            'billUploaded': billUploadedCount,
          };
          _isLoading = false;

          AppLogger.info('Order counts: $_orderCounts');
        });
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMsg = 'Failed to load orders';

      if (e.response?.statusCode == 401) {
        errorMsg = 'Authentication failed. Please login again.';
        await StorageService.clearAll();
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
        return;
      } else if (e.response?.statusCode == 403) {
        errorMsg =
            'Access Forbidden (403)\n\nYour account may not have permission to view orders.';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMsg = 'Connection timeout. Please check your internet.';
      }

      AppLogger.error('Error loading orders', e);

      setState(() {
        _errorMessage = errorMsg;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Unexpected error loading orders', e);

      setState(() {
        _errorMessage = 'An unexpected error occurred: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCustomerInfo(List<OrderModel> orders) async {
    for (var order in orders) {
      if (!_customerCache.containsKey(order.customerId)) {
        try {
          final response = await _dio.get('/Customers/${order.customerId}');
          AppLogger.info(
              'Fetched customer info for ${order.customerId} with status: ${response.statusCode}');
          AppLogger.info('Customer data: ${response.data}');
          if (response.statusCode == 200) {
            final customerData = response.data;
            _customerCache[order.customerId] = {
              'name':
                  '${customerData['customerFirstName'] ?? ''} ${customerData['customerLastName'] ?? ''}'
                      .trim(),
              'email': customerData['emailId']?.toString() ?? '',
              'phone': customerData['mobileNumber']?.toString() ?? '',
            };

            AppLogger.info('Loaded customer info for ${order.customerId}');
          }
        } catch (e) {
          AppLogger.error('Error loading customer ${order.customerId}: $e');
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

  String? getCustomerEmail(OrderModel order) {
    final email = _customerCache[order.customerId]?['email'];
    return (email != null && email.isNotEmpty) ? email : null;
  }

  String? getCustomerPhone(OrderModel order) {
    final phone = _customerCache[order.customerId]?['phone'];
    return (phone != null && phone.isNotEmpty) ? phone : null;
  }

  bool isPendingStatus(String status) {
    final statusLower = status.toLowerCase();
    return statusLower.contains('pending') || statusLower.contains('assigned');
  }

  void _navigateToOrderDetails(OrderModel order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderDetailsPage(
          order: order,
          customerName: getCustomerName(order),
          customerEmail: getCustomerEmail(order),
          customerPhone: getCustomerPhone(order),
          onAccept: () {
            _handleAcceptOrder(order);
            Navigator.of(context).pop();
          },
          onReject: () {
            _handleRejectOrder(order);
            Navigator.of(context).pop();
          },
          onRefresh: _loadDashboardData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chemist Dashboard',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                _navigateToChemistProfile(context);
              } else if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
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
      drawer: _buildDrawer(),
      body: _buildBody(),
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
            Text('Loading orders...'),
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
                'Error Loading Orders',
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
                onPressed: _loadDashboardData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsSection(),
            _buildRecentOrdersSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            decoration: const BoxDecoration(color: Colors.black),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child:
                      Icon(Icons.local_pharmacy, size: 40, color: Colors.black),
                ),
                const SizedBox(height: 12),
                FutureBuilder<String?>(
                  future: StorageService.getUserName(),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? 'Chemist',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  'Licensed Pharmacist',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.dashboard, color: Colors.black),
                  title: const Text('Dashboard'),
                  selected: true,
                  selectedTileColor: Colors.black.withOpacity(0.1),
                  onTap: () => Navigator.of(context).pop(),
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_cart, color: Colors.black),
                  title: const Text('Customer Orders'),
                  trailing: _orderCounts['pending'] != null &&
                          _orderCounts['pending']! > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_orderCounts['pending']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CustomerOrdersPage(
                          allOrders: _allOrders,
                          customerCache: _customerCache,
                          onRefresh: _loadDashboardData,
                        ),
                      ),
                    );
                  },
                ),
                // ListTile(
                //   leading: Icon(Icons.location_city),
                //   title: Text('Customer Support Regions'),
                //   onTap: () => Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => AdminCustomerSupportRegionsPage(),
                //     ),
                //   ),
                // ),
                ListTile(
                    leading: const Icon(Icons.person, color: Colors.black),
                    title: const Text('Profile'),
                    onTap: () => _navigateToChemistProfile(context)),

                // ✅ FIXED: Reduced spacing before Deliveries section
                const Divider(height: 1), // Changed from default height

                // Deliveries Section Header - removed extra padding
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16,
                      4), // ✅ Reduced top padding from 8 to 8 and bottom from 8 to 4
                  child: Text(
                    'DELIVERIES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),

                ListTile(
                  leading:
                      const Icon(Icons.local_shipping, color: Colors.purple),
                  title: const Text('Out for Delivery'),
                  subtitle: const Text('Track & complete deliveries'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChemistDeliveryManagement(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // ✅ Logout at bottom with proper spacing
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () => _handleLogout(),
          ),
          const SizedBox(height: 8), // ✅ Reduced from 16 to 8
        ],
      ),
    );
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
      await StorageService.clearAll();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                    'Pending',
                    '${_orderCounts['pending'] ?? 0}',
                    Icons.pending_actions,
                    Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                    'Accepted',
                    '${_orderCounts['accepted'] ?? 0}',
                    Icons.check_circle,
                    Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                    'Rejected',
                    '${_orderCounts['rejected'] ?? 0}',
                    Icons.cancel,
                    Colors.red),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                    'Out for Delivery',
                    '${_orderCounts['outForDelivery'] ?? 0}',
                    Icons.done_all,
                    Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                    'Bill Uploaded',
                    '${_orderCounts['billUploaded'] ?? 0}',
                    Icons.cancel,
                    Colors.red),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                    'Completed',
                    '${_orderCounts['completed'] ?? 0}',
                    Icons.done_all,
                    Colors.blue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Orders',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CustomerOrdersPage(
                        allOrders: _allOrders,
                        customerCache: _customerCache,
                        onRefresh: _loadDashboardData, // ADDED
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_recentOrders.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined,
                        size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text('No recent orders',
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            )
          else
            ..._recentOrders.map((order) => OrderTileWithBill(
                  order: order,
                  customerName: getCustomerName(order),
                  customerEmail: getCustomerEmail(order),
                  customerPhone: getCustomerPhone(order),
                  isPending: isPendingStatus(order.status),
                  onTap: () => _navigateToOrderDetails(order),
                  onAccept: isPendingStatus(order.status)
                      ? () => _handleAcceptOrder(order)
                      : null,
                  onReject: isPendingStatus(order.status)
                      ? () => _handleRejectOrder(order)
                      : null,
                  onRefresh: _loadDashboardData,
                )),
        ],
      ),
    );
  }

  Future<void> _handleAcceptOrder(OrderModel order) async {
    try {
      AppLogger.info('Accepting order ${order.orderId}');

      final response = await _dio.put('/Orders/${order.orderId}/accept');

      if (response.statusCode == 200) {
        await _loadDashboardData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Order ${order.orderNumber ?? order.orderId} accepted'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Error accepting order', e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to accept order'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _handleRejectOrder(OrderModel order) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => RejectOrderDialog(orderId: order.orderId),
    );

    if (reason != null && reason.isNotEmpty) {
      try {
        AppLogger.info('Rejecting order ${order.orderId} with reason: $reason');

        final response = await _dio.put(
          '/Orders/${order.orderId}/reject',
          data: {
            'RejectNote': reason,
          },
        );

        if (response.statusCode == 200) {
          await _loadDashboardData();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Order ${order.orderNumber ?? order.orderId} rejected'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } on DioException catch (e) {
        AppLogger.error('Error rejecting order', e);

        String errorMessage = 'Failed to reject order';
        if (e.response?.data != null && e.response?.data is Map) {
          final errorData = e.response?.data as Map;
          if (errorData.containsKey('errors')) {
            final errors = errorData['errors'] as Map;
            errorMessage = errors.values.first.first.toString();
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }
}
// ============================================================================
// ORDER TILE WIDGET
// ============================================================================

class OrderTile extends StatelessWidget {
  final OrderModel order;
  final String customerName;
  final String? customerEmail;
  final String? customerPhone;
  final bool isPending;
  final VoidCallback onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const OrderTile({
    Key? key,
    required this.order,
    required this.customerName,
    this.customerEmail,
    this.customerPhone,
    required this.isPending,
    required this.onTap,
    this.onAccept,
    this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeAgo = _getTimeAgo(order.createdOn);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                order.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(order.status),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                customerName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Order #${order.orderNumber ?? order.orderId}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildInputTypeChip(order.orderInputType),
                ],
              ),
              const SizedBox(height: 12),
              if (customerEmail != null && customerEmail!.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.email, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        customerEmail!,
                        style:
                            const TextStyle(fontSize: 13, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              if (customerPhone != null && customerPhone!.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      customerPhone!,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.orange),
                  const SizedBox(width: 6),
                  Text(
                    timeAgo,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // ✅ BOTH buttons now use ElevatedButton
              if (isPending) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onReject,
                        icon: const Icon(Icons.close,
                            size: 18, color: Colors.white),
                        label: const Text('Reject',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // ✅ Red background
                          foregroundColor: Colors.white, // ✅ White text
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onAccept,
                        icon: const Icon(Icons.check,
                            size: 18, color: Colors.white),
                        label: const Text('Accept',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // ✅ Green background
                          foregroundColor: Colors.white, // ✅ White text
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    final statusLower = status.toLowerCase();
    if (statusLower.contains('pending') || statusLower.contains('assigned')) {
      return Colors.orange;
    } else if (statusLower.contains('accepted') ||
        statusLower.contains('bill') ||
        statusLower.contains('delivery')) {
      return Colors.green;
    } else if (statusLower.contains('rejected')) {
      return Colors.red;
    } else if (statusLower.contains('completed')) {
      return Colors.blue;
    }
    return Colors.grey;
  }

  Widget _buildInputTypeChip(OrderInputType type) {
    IconData icon;
    Color color;
    String label;

    switch (type) {
      case OrderInputType.image:
        icon = Icons.image;
        color = Colors.blue;
        label = 'Image';
        break;
      case OrderInputType.voice:
        icon = Icons.mic;
        color = Colors.purple;
        label = 'Voice';
        break;
      case OrderInputType.text:
        icon = Icons.text_fields;
        color = Colors.green;
        label = 'Text';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays == 1) {
      return '1 day ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    }
  }
}

// CUSTOMER ORDERS PAGE - UPDATED TO USE OrderTileWithBill
// ============================================================================

class CustomerOrdersPage extends StatefulWidget {
  final List<OrderModel> allOrders;
  final Map<String, Map<String, String>> customerCache;
  final VoidCallback? onRefresh; // ADDED

  const CustomerOrdersPage({
    Key? key,
    required this.allOrders,
    required this.customerCache,
    this.onRefresh, // ADDED
  }) : super(key: key);

  @override
  State<CustomerOrdersPage> createState() => _CustomerOrdersPageState();
}

class _CustomerOrdersPageState extends State<CustomerOrdersPage> {
  int _selectedIndex = 0;
  late Dio _dio;

  @override
  void initState() {
    super.initState();
    _setupDio();
  }

  void _setupDio() {
    _dio = Dio();
    _dio.options.baseUrl = AppConstants.apiBaseUrl;
    _dio.options.connectTimeout = EnvironmentConfig.timeoutDuration;
    _dio.options.receiveTimeout = EnvironmentConfig.timeoutDuration;

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

  bool _isPending(String status) {
    final statusLower = status.toLowerCase();
    return statusLower.contains('pending') || statusLower.contains('assigned');
  }

  bool _isAccepted(String status) {
    final statusLower = status.toLowerCase();
    return statusLower.contains('accepted') ||
        statusLower.contains('bill') ||
        statusLower.contains('delivery');
  }

  bool _isHistory(String status) {
    final statusLower = status.toLowerCase();
    return statusLower.contains('completed') ||
        statusLower.contains('rejected');
  }

  Future<void> _handleAcceptOrder(OrderModel order) async {
    try {
      AppLogger.info('Accepting order ${order.orderId}');

      final response = await _dio.put('/Orders/${order.orderId}/accept');

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Order ${order.orderNumber ?? order.orderId} accepted'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          if (widget.onRefresh != null) {
            widget.onRefresh!();
          }
          setState(() {});
        }
      }
    } catch (e) {
      AppLogger.error('Error accepting order', e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to accept order'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _handleRejectOrder(OrderModel order) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => RejectOrderDialog(orderId: order.orderId),
    );

    if (reason != null && reason.isNotEmpty) {
      try {
        AppLogger.info('Rejecting order ${order.orderId} with reason: $reason');

        final response = await _dio.put(
          '/Orders/${order.orderId}/reject',
          data: {
            'RejectNote': reason,
          },
        );

        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Order ${order.orderNumber ?? order.orderId} rejected'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            if (widget.onRefresh != null) {
              widget.onRefresh!();
            }
            setState(() {});
          }
        }
      } on DioException catch (e) {
        AppLogger.error('Error rejecting order', e);

        String errorMessage = 'Failed to reject order';
        if (e.response?.data != null && e.response?.data is Map) {
          final errorData = e.response?.data as Map;
          if (errorData.containsKey('errors')) {
            final errors = errorData['errors'] as Map;
            errorMessage = errors.values.first.first.toString();
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Orders',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.list),
            label: 'All (${widget.allOrders.length})',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.pending_actions),
            label: 'Pending',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.check_circle_outline),
            label: 'Accepted',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    List<OrderModel> filteredOrders;

    switch (_selectedIndex) {
      case 0:
        filteredOrders = widget.allOrders;
        break;
      case 1:
        filteredOrders =
            widget.allOrders.where((o) => _isPending(o.status)).toList();
        break;
      case 2:
        filteredOrders =
            widget.allOrders.where((o) => _isAccepted(o.status)).toList();
        break;
      case 3:
        filteredOrders =
            widget.allOrders.where((o) => _isHistory(o.status)).toList();
        break;
      default:
        filteredOrders = widget.allOrders;
    }

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No orders found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        final customerInfo = widget.customerCache[order.customerId];

        // USE OrderTileWithBill HERE
        return OrderTileWithBill(
          order: order,
          customerName: customerInfo?['name'] ?? 'Customer',
          customerEmail: customerInfo?['email'],
          customerPhone: customerInfo?['phone'],
          isPending: _isPending(order.status),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OrderDetailsPage(
                  order: order,
                  customerName: customerInfo?['name'] ?? 'Customer',
                  customerEmail: customerInfo?['email'],
                  customerPhone: customerInfo?['phone'],
                  onRefresh: widget.onRefresh, // PASS onRefresh
                ),
              ),
            );
          },
          onAccept:
              _isPending(order.status) ? () => _handleAcceptOrder(order) : null,
          onReject:
              _isPending(order.status) ? () => _handleRejectOrder(order) : null,
          onRefresh: widget.onRefresh, // PASS onRefresh
        );
      },
    );
  }
}
// ============================================================================
// ORDER DETAILS PAGE
// ============================================================================

class OrderDetailsPage extends StatefulWidget {
  final OrderModel order;
  final String customerName;
  final String? customerEmail;
  final String? customerPhone;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onRefresh;

  const OrderDetailsPage({
    Key? key,
    required this.order,
    required this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.onAccept,
    this.onReject,
    this.onRefresh,
  }) : super(key: key);

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Order #${widget.order.orderNumber ?? widget.order.orderId}',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white, // ✅ White back button
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusBanner(),
            _buildOrderInfoCard(),
            _buildPrescriptionSection(),
            _buildDeliveryAddressCard(),
            if (widget.order.rejectionReason != null &&
                widget.order.rejectionReason!.isNotEmpty)
              _buildRejectionReasonCard(),
            if (widget.order.totalAmount != null) _buildTotalAmountCard(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _isPendingStatus(widget.order.status)
          ? _buildBottomActionBar()
          : null,
    );
  }

  bool _isPendingStatus(String status) {
    final statusLower = status.toLowerCase();
    return statusLower.contains('pending') || statusLower.contains('assigned');
  }

  Widget _buildStatusBanner() {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    final statusLower = widget.order.status.toLowerCase();

    if (statusLower.contains('pending') || statusLower.contains('assigned')) {
      backgroundColor = Colors.orange.shade100;
      textColor = Colors.orange.shade900;
      icon = Icons.pending_actions;
    } else if (statusLower.contains('accepted') ||
        statusLower.contains('bill') ||
        statusLower.contains('delivery')) {
      backgroundColor = Colors.green.shade100;
      textColor = Colors.green.shade900;
      icon = Icons.check_circle;
    } else if (statusLower.contains('rejected')) {
      backgroundColor = Colors.red.shade100;
      textColor = Colors.red.shade900;
      icon = Icons.cancel;
    } else if (statusLower.contains('completed')) {
      backgroundColor = Colors.blue.shade100;
      textColor = Colors.blue.shade900;
      icon = Icons.done_all;
    } else {
      backgroundColor = Colors.grey.shade200;
      textColor = Colors.grey.shade900;
      icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(width: 8),
          Text(
            widget.order.status.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.person, 'Name', widget.customerName),
            if (widget.customerEmail != null &&
                widget.customerEmail!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.email, 'Email', widget.customerEmail!),
            ],
            if (widget.customerPhone != null &&
                widget.customerPhone!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.phone, 'Phone', widget.customerPhone!),
            ],
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.calendar_today,
              'Order Date',
              DateFormat('MMM dd, yyyy - hh:mm a')
                  .format(widget.order.createdOn),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrescriptionSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Prescription',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildInputTypeChip(widget.order.orderInputType),
              ],
            ),
            const SizedBox(height: 16),
            _buildPrescriptionContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputTypeChip(OrderInputType type) {
    IconData icon;
    Color color;
    String label;

    switch (type) {
      case OrderInputType.image:
        icon = Icons.image;
        color = Colors.blue;
        label = 'Image';
        break;
      case OrderInputType.voice:
        icon = Icons.mic;
        color = Colors.purple;
        label = 'Voice';
        break;
      case OrderInputType.text:
        icon = Icons.text_fields;
        color = Colors.green;
        label = 'Text';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionContent() {
    switch (widget.order.orderInputType) {
      case OrderInputType.image:
        return _buildImagePrescription();
      case OrderInputType.voice:
        return _buildVoicePrescription();
      case OrderInputType.text:
        return _buildTextPrescription();
    }
  }

  Widget _buildImagePrescription() {
    return Column(
      children: [
        Container(
          height: 250,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  widget.order.prescriptionFileUrl ?? 'Image Prescription',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement image viewer
                    // You can use packages like photo_view or cached_network_image
                  },
                  icon: const Icon(Icons.fullscreen),
                  label: const Text('View Full Image'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: () {
                // TODO: Implement download
              },
              icon: const Icon(Icons.download),
              label: const Text('Download'),
            ),
            TextButton.icon(
              onPressed: () {
                // TODO: Implement share
              },
              icon: const Icon(Icons.share),
              label: const Text('Share'),
            ),
            TextButton.icon(
              onPressed: () {
                // TODO: Implement zoom
              },
              icon: const Icon(Icons.zoom_in),
              label: const Text('Zoom'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVoicePrescription() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        children: [
          Icon(
            _isPlaying ? Icons.pause_circle : Icons.play_circle,
            size: 60,
            color: Colors.purple.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            widget.order.voiceNoteUrl ?? 'Voice Recording',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() => _isPlaying = !_isPlaying);
                  // TODO: Implement actual audio playback
                  // You can use packages like just_audio or audioplayers
                },
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 32,
                ),
                color: Colors.purple,
              ),
              Expanded(
                child: Slider(
                  value: 0.3,
                  onChanged: (value) {
                    // TODO: Implement seek functionality
                  },
                  activeColor: Colors.purple,
                ),
              ),
              const Text('0:45 / 2:30'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () {
                  // TODO: Implement download
                },
                icon: const Icon(Icons.download),
                label: const Text('Download'),
              ),
              TextButton.icon(
                onPressed: () {
                  // TODO: Implement speed control
                },
                icon: const Icon(Icons.speed),
                label: const Text('Speed'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextPrescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.text_fields, color: Colors.green.shade700),
              const SizedBox(width: 8),
              Text(
                'Text Prescription',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.order.prescriptionText ?? 'No prescription text available',
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                // TODO: Implement copy to clipboard
                // You can use Clipboard.setData()
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressCard() {
    final address = [
      widget.order.shippingAddressLine1,
      widget.order.shippingAddressLine2,
      widget.order.shippingArea,
      widget.order.shippingCity,
      widget.order.shippingPincode,
    ].where((e) => e != null && e.isNotEmpty).join(', ');

    if (address.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Address',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Colors.black, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    address,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectionReasonCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Rejection Reason',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                widget.order.rejectionReason!,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalAmountCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Amount',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '₹${widget.order.totalAmount!.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.onReject,
                icon: const Icon(Icons.close, color: Colors.white),
                label: const Text(
                  'Reject Order',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // ✅ Red background
                  foregroundColor: Colors.white, // ✅ White text
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.onAccept,
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text(
                  'Accept Order',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // ✅ Green background
                  foregroundColor: Colors.white, // ✅ White text
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// REJECT ORDER DIALOG
// ============================================================================

class RejectOrderDialog extends StatefulWidget {
  final String orderId;

  const RejectOrderDialog({Key? key, required this.orderId}) : super(key: key);

  @override
  State<RejectOrderDialog> createState() => _RejectOrderDialogState();
}

class _RejectOrderDialogState extends State<RejectOrderDialog> {
  String? _selectedReason;
  final _controller = TextEditingController();
  final _reasons = [
    'Out of stock',
    'Prescription not clear',
    'Invalid prescription',
    'Restricted medication',
    'Delivery location not serviceable',
    'Other'
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Reject Order ${widget.orderId}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please select a reason for rejection:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            ..._reasons.map((reason) => RadioListTile<String>(
                  title: Text(reason),
                  value: reason,
                  groupValue: _selectedReason,
                  onChanged: (value) => setState(() => _selectedReason = value),
                  contentPadding: EdgeInsets.zero,
                  activeColor: Colors.black,
                )),
            if (_selectedReason == 'Other') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Custom reason',
                  border: OutlineInputBorder(),
                  hintText: 'Enter your reason...',
                ),
                maxLines: 3,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedReason == null
              ? null
              : () {
                  final reason = _selectedReason == 'Other'
                      ? _controller.text
                      : _selectedReason!;
                  Navigator.pop(context, reason);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Reject'),
        ),
      ],
    );
  }
}
