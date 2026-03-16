import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:pharmaish/config/environment_config.dart';
import 'package:pharmaish/core/screens/chemist/chemist_delivery_management.dart';
import 'package:pharmaish/core/screens/delivery/complete_delivery_screen.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:pharmaish/shared/models/order_model.dart';
import 'package:pharmaish/core/theme/app_theme.dart';
import 'package:pharmaish/core/screens/profiles/delivery_profile_page.dart';

class DeliveryDashboard extends StatefulWidget {
  const DeliveryDashboard({super.key});

  @override
  State<DeliveryDashboard> createState() => _DeliveryDashboardState();
}

class _DeliveryDashboardState extends State<DeliveryDashboard> {
  int _selectedIndex = 0;
  late Dio _dio;
  String _userName = 'Delivery Boy';

  @override
  void initState() {
    super.initState();
    _setupDio();
    _loadUserName();
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
        logPrint: (o) => AppLogger.info('API: $o'),
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
        AppLogger.error('API Error: ${error.message}');
        handler.next(error);
      },
    ));
  }

  Future<void> _loadUserName() async {
    final name = await StorageService.getUserName();
    if (name != null && mounted) {
      setState(() => _userName = name);
    }
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'My Deliveries';
      case 1:
        return 'Completed Deliveries';
      default:
        return 'Delivery Dashboard';
    }
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
      await StorageService.clearAuthTokens();
      await StorageService.clearSavedCredentials();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle(),
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => setState(() {}),
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (v) {
              if (v == 'logout') _handleLogout();
              if (v == 'profile') _navigateToProfile();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(children: [
                  Icon(Icons.person_outline, color: Colors.black),
                  SizedBox(width: 8),
                  Text('My Profile'),
                ]),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Logout'),
                ]),
              ),
            ],
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _DeliveryActiveOrdersPage(dio: _dio, userName: _userName),
          _DeliveryCompletedOrdersPage(dio: _dio),
        ],
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DeliveryProfilePage()),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.delivery_dining, size: 40, color: Colors.black),
                ),
                const SizedBox(height: 12),
                Text(
                  _userName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Delivery Boy',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.9), fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // ListTile(
                //   leading:
                //       const Icon(Icons.local_shipping, color: Colors.purple),
                //   title: const Text('Out for Delivery'),
                //   subtitle: const Text('Track & complete deliveries'),
                //   onTap: () {
                //     Navigator.pop(context);
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => const ChemistDeliveryManagement(),
                //       ),
                //     );
                //   },
                // ),
                ListTile(
                  leading: const Icon(Icons.local_shipping, color: Colors.purple),
                  title: const Text('My Deliveries'),
                  selected: _selectedIndex == 0,
                  selectedTileColor: Colors.black.withOpacity(0.08),
                  onTap: () {
                    setState(() => _selectedIndex = 0);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.check_circle_outline,
                      color: Colors.green),
                  title: const Text('Completed Deliveries'),
                  selected: _selectedIndex == 1,
                  selectedTileColor: Colors.black.withOpacity(0.08),
                  onTap: () {
                    setState(() => _selectedIndex = 1);
                    Navigator.of(context).pop();
                  },
                ),
                const Divider(height: 1),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.black),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.of(context).pop();
              _navigateToProfile();
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: _handleLogout,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ============================================================================
// ACTIVE / OUT-FOR-DELIVERY ORDERS
// ============================================================================

class _DeliveryActiveOrdersPage extends StatefulWidget {
  final Dio dio;
  final String userName;

  const _DeliveryActiveOrdersPage({required this.dio, required this.userName});

  @override
  State<_DeliveryActiveOrdersPage> createState() =>
      _DeliveryActiveOrdersPageState();
}

class _DeliveryActiveOrdersPageState extends State<_DeliveryActiveOrdersPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;
  final Map<String, Map<String, String>> _customerCache = {};
  final Map<String, String> _addressCache = {};

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Uses JWT token's UserId claim server-side — no ID needed in URL
      final response = await widget.dio.get('/Orders/delivery/my-orders');

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> list;
        if (data is List) {
          list = data;
        } else if (data is Map && data.containsKey('data')) {
          list = data['data'] as List;
        } else {
          list = [];
        }

        final orders = list
            .map((j) => OrderModel.fromJson(j))
            .where((o) =>
                o.status.toLowerCase().contains('outfordelivery') ||
                o.status.toLowerCase().contains('delivery') &&
                    !o.status.toLowerCase().contains('completed'))
            .toList();

        orders.sort((a, b) => a.createdOn.compareTo(b.createdOn)); // oldest first = FIFO

        await _loadCustomerInfo(orders);
        await _loadAddresses(orders);

        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      AppLogger.error('Error loading delivery orders', e);
      if (e.response?.statusCode == 401) {
        await StorageService.clearAll();
        if (mounted) Navigator.of(context).pushReplacementNamed('/login');
        return;
      }
      if (e.response?.statusCode == 404) {
        setState(() { _orders = []; _isLoading = false; });
        return;
      }
      setState(() {
        _errorMessage = 'Failed to load deliveries';
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Unexpected error', e);
      setState(() {
        _errorMessage = 'An unexpected error occurred';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCustomerInfo(List<OrderModel> orders) async {
    for (final order in orders) {
      if (_customerCache.containsKey(order.customerId)) continue;
      try {
        final r = await widget.dio.get('/Customers/${order.customerId}');
        if (r.statusCode == 200) {
          final d = r.data;
          _customerCache[order.customerId] = {
            'name':
                '${d['customerFirstName'] ?? ''} ${d['customerLastName'] ?? ''}'
                    .trim(),
            'phone': d['mobileNumber']?.toString() ?? '',
          };
        }
      } catch (_) {
        _customerCache[order.customerId] = {'name': 'Customer', 'phone': ''};
      }
    }
  }

  Future<void> _loadAddresses(List<OrderModel> orders) async {
    for (final order in orders) {
      if (_addressCache.containsKey(order.orderId)) continue;
      try {
        // Step 1: get customerAddressId from the order detail endpoint
        final orderResp = await widget.dio.get('/Orders/${order.orderId}');
        if (orderResp.statusCode != 200) continue;

        final orderJson = orderResp.data as Map<String, dynamic>;
        final addressId =
            orderJson['customerAddressId']?.toString() ??
            orderJson['CustomerAddressId']?.toString();
        if (addressId == null || addressId.isEmpty) continue;

        // Step 2: fetch the address record
        final addrResp = await widget.dio.get('/CustomerAddresses/$addressId');
        if (addrResp.statusCode != 200) continue;

        final d = addrResp.data as Map<String, dynamic>;
        String _get(String key) =>
            (d[key] ?? d[key[0].toUpperCase() + key.substring(1)] ?? '').toString().trim();

        final parts = [
          _get('addressLine1'),
          _get('addressLine2'),
          _get('area'),
          _get('city'),
          _get('pincode'),
        ].where((s) => s.isNotEmpty).toList();

        _addressCache[order.orderId] = parts.isNotEmpty
            ? parts.join(', ')
            : 'Address not available';
      } catch (e) {
        AppLogger.error('Could not load address for order ${order.orderId}: $e');
        _addressCache[order.orderId] = 'Address not available';
      }
    }
  }

  String _resolvedAddress(String orderId) =>
      _addressCache[orderId] ?? 'Loading...';

  String _customerName(String id) =>
      _customerCache[id]?['name'] ?? 'Customer';
  String? _customerPhone(String id) {
    final p = _customerCache[id]?['phone'];
    return (p != null && p.isNotEmpty) ? p : null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
              Text(_errorMessage!, textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700])),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadOrders,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    // Summary header
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${widget.userName}!',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '${_orders.length} order${_orders.length != 1 ? 's' : ''} to deliver',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.85), fontSize: 14),
              ),
            ],
          ),
        ),
        Expanded(
          child: _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delivery_dining,
                          size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text('No Pending Deliveries',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('You\'re all caught up!',
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (context, i) {
                      final order = _orders[i];
                      return _buildDeliveryCard(order, i + 1);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildDeliveryCard(OrderModel order, int position) {
    final name = _customerName(order.customerId);
    final phone = _customerPhone(order.customerId);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToComplete(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '#$position',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.orderNumber ?? order.orderId}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(name,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[700])),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.purple),
                    ),
                    child: Text(
                      'Out for Delivery',
                      style: TextStyle(
                          color: Colors.purple.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 10),
              _infoRow(Icons.location_on, 'Address',
                  _resolvedAddress(order.orderId), maxLines: 3),
              // city/pincode merged into resolved address above
              if (phone != null) ...[
                const SizedBox(height: 6),
                _infoRow(Icons.phone, 'Customer', phone),
              ],
              if (order.totalAmount != null) ...[
                const SizedBox(height: 6),
                _infoRow(Icons.currency_rupee, 'Amount',
                    '₹${order.totalAmount!.toStringAsFixed(2)}'),
              ],
              const SizedBox(height: 6),
              _infoRow(Icons.access_time, 'Created',
                  DateFormat('MMM dd, hh:mm a').format(order.createdOn)),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToComplete(order),
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: const Text('Mark as Delivered'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToComplete(OrderModel order) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CompleteDeliveryScreen(
          order: order,
          customerName: _customerName(order.customerId),
          customerPhone: _customerPhone(order.customerId),
          deliveryAddress: _resolvedAddress(order.orderId),
        ),
      ),
    );
    if (result == true) _loadOrders();
  }

  Widget _infoRow(IconData icon, String label, String value,
      {int maxLines = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              children: [
                TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// COMPLETED DELIVERIES PAGE
// ============================================================================

class _DeliveryCompletedOrdersPage extends StatefulWidget {
  final Dio dio;

  const _DeliveryCompletedOrdersPage({required this.dio});

  @override
  State<_DeliveryCompletedOrdersPage> createState() =>
      _DeliveryCompletedOrdersPageState();
}

class _DeliveryCompletedOrdersPageState
    extends State<_DeliveryCompletedOrdersPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;
  final Map<String, Map<String, String>> _customerCache = {};

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await widget.dio.get('/Orders/delivery/my-orders');

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> list;
        if (data is List) {
          list = data;
        } else if (data is Map && data.containsKey('data')) {
          list = data['data'] as List;
        } else {
          list = [];
        }

        final orders = list
            .map((j) => OrderModel.fromJson(j))
            .where((o) => o.status.toLowerCase().contains('completed'))
            .toList();

        orders.sort((a, b) => b.createdOn.compareTo(a.createdOn));

        await _loadCustomerInfo(orders);

        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      AppLogger.error('Error loading completed orders', e);
      setState(() {
        _errorMessage = 'Failed to load completed deliveries';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCustomerInfo(List<OrderModel> orders) async {
    for (final order in orders) {
      if (_customerCache.containsKey(order.customerId)) continue;
      try {
        final r = await widget.dio.get('/Customers/${order.customerId}');
        if (r.statusCode == 200) {
          final d = r.data;
          _customerCache[order.customerId] = {
            'name':
                '${d['customerFirstName'] ?? ''} ${d['customerLastName'] ?? ''}'
                    .trim(),
            'phone': d['mobileNumber']?.toString() ?? '',
          };
        }
      } catch (_) {
        _customerCache[order.customerId] = {'name': 'Customer', 'phone': ''};
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.black));
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadOrders,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, foregroundColor: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('No Completed Deliveries Yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, i) {
          final order = _orders[i];
          final name =
              _customerCache[order.customerId]?['name'] ?? 'Customer';
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_circle,
                        color: Colors.green.shade600, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.orderNumber ?? order.orderId}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(name,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[600])),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('MMM dd, yyyy • hh:mm a')
                              .format(order.createdOn),
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                  if (order.totalAmount != null)
                    Text(
                      '₹${order.totalAmount!.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}