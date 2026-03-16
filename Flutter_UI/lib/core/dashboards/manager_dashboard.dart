import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:pharmaish/config/environment_config.dart';
import 'package:pharmaish/core/theme/app_theme.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:pharmaish/core/screens/profiles/manager_profile_page.dart';
import 'package:pharmaish/shared/models/order_model.dart';

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  int _selectedIndex = 0;
  late Dio _dio;
  String _userName = 'Manager';

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
        return 'Manager Dashboard';
      case 1:
        return 'All Orders';
      case 2:
        return 'Delivery Boys';
      default:
        return 'Manager Dashboard';
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
                backgroundColor: Colors.red, foregroundColor: Colors.white),
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
        backgroundColor: AppTheme.primaryColor,
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
                  Icon(Icons.person_outline, color: AppTheme.primaryColor),
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
          _ManagerHomePage(dio: _dio, userName: _userName,
              onNavigate: (i) => setState(() => _selectedIndex = i)),
          _ManagerAllOrdersPage(dio: _dio),
          _ManagerDeliveryBoysPage(dio: _dio),
        ],
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ManagerProfilePage()),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            color: AppTheme.primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.manage_accounts,
                      size: 40, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 12),
                Text(_userName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Manager',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.9), fontSize: 14)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(Icons.dashboard, 'Dashboard', 0,
                    color: AppTheme.primaryColor),
                _drawerItem(Icons.list_alt, 'All Orders', 1,
                    color: Colors.orange),
                _drawerItem(Icons.delivery_dining, 'Delivery Boys', 2,
                    color: Colors.purple),
                const Divider(height: 1),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.person_outline, color: AppTheme.primaryColor),
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

  Widget _drawerItem(IconData icon, String label, int index,
      {required Color color}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      selected: _selectedIndex == index,
      selectedTileColor: AppTheme.primaryColor.withOpacity(0.08),
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.of(context).pop();
      },
    );
  }
}

// ============================================================================
// MANAGER HOME PAGE — STATS + QUICK ACTIONS
// ============================================================================

class _ManagerHomePage extends StatefulWidget {
  final Dio dio;
  final String userName;
  final ValueChanged<int> onNavigate;

  const _ManagerHomePage(
      {required this.dio,
      required this.userName,
      required this.onNavigate});

  @override
  State<_ManagerHomePage> createState() => _ManagerHomePageState();
}

class _ManagerHomePageState extends State<_ManagerHomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isLoading = true;
  int _totalOrders = 0;
  int _pendingOrders = 0;
  int _activeDeliveries = 0;
  int _completedToday = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final response = await widget.dio.get('/Orders');
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

        final orders = list.map((j) => OrderModel.fromJson(j)).toList();
        final now = DateTime.now();

        setState(() {
          _totalOrders = orders.length;
          _pendingOrders = orders
              .where((o) =>
                  o.status.toLowerCase().contains('pending') ||
                  o.status.toLowerCase().contains('assigned'))
              .length;
          _activeDeliveries = orders
              .where((o) => o.status.toLowerCase().contains('delivery') &&
                  !o.status.toLowerCase().contains('completed'))
              .length;
          _completedToday = orders
              .where((o) =>
                  o.status.toLowerCase().contains('completed') &&
                  o.createdOn.year == now.year &&
                  o.createdOn.month == now.month &&
                  o.createdOn.day == now.day)
              .length;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Error loading stats', e);
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome
            Text(
              'Welcome back, ${widget.userName}!',
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Stats grid
            const Text('Overview',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                          color: AppTheme.primaryColor),
                    ))
                : GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      _statCard('Total Orders', _totalOrders.toString(),
                          Icons.receipt_long, Colors.blue),
                      _statCard('Pending', _pendingOrders.toString(),
                          Icons.hourglass_empty, Colors.orange),
                      _statCard('In Delivery', _activeDeliveries.toString(),
                          Icons.local_shipping, Colors.purple),
                      _statCard('Completed Today', _completedToday.toString(),
                          Icons.check_circle, Colors.green),
                    ],
                  ),

            const SizedBox(height: 28),

            // Quick actions
            const Text('Quick Actions',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _quickAction(
              icon: Icons.list_alt,
              title: 'View All Orders',
              subtitle: 'Browse and monitor all platform orders',
              color: Colors.orange,
              onTap: () => widget.onNavigate(1),
            ),
            const SizedBox(height: 12),
            _quickAction(
              icon: Icons.delivery_dining,
              title: 'Delivery Boys',
              subtitle: 'View and manage delivery personnel',
              color: Colors.purple,
              onTap: () => widget.onNavigate(2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color),
              ),
            ],
          ),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ALL ORDERS PAGE
// ============================================================================

class _ManagerAllOrdersPage extends StatefulWidget {
  final Dio dio;

  const _ManagerAllOrdersPage({required this.dio});

  @override
  State<_ManagerAllOrdersPage> createState() => _ManagerAllOrdersPageState();
}

class _ManagerAllOrdersPageState extends State<_ManagerAllOrdersPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<OrderModel> _allOrders = [];
  List<OrderModel> _filtered = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _filterIndex = 0; // 0=All 1=Pending 2=Active 3=Completed 4=Rejected
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
      final response = await widget.dio.get('/Orders');
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

        final orders = list.map((j) => OrderModel.fromJson(j)).toList();
        orders.sort((a, b) => b.createdOn.compareTo(a.createdOn));

        await _loadCustomerInfo(orders);

        setState(() {
          _allOrders = orders;
          _isLoading = false;
        });
        _applyFilter(_filterIndex);
      }
    } on DioException catch (e) {
      AppLogger.error('Error loading orders', e);
      setState(() {
        _errorMessage = 'Failed to load orders';
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

  void _applyFilter(int index) {
    setState(() {
      _filterIndex = index;
      switch (index) {
        case 0:
          _filtered = _allOrders;
          break;
        case 1:
          _filtered = _allOrders
              .where((o) =>
                  o.status.toLowerCase().contains('pending') ||
                  o.status.toLowerCase().contains('assigned'))
              .toList();
          break;
        case 2:
          _filtered = _allOrders
              .where((o) =>
                  o.status.toLowerCase().contains('accepted') ||
                  o.status.toLowerCase().contains('bill') ||
                  o.status.toLowerCase().contains('delivery'))
              .toList();
          break;
        case 3:
          _filtered = _allOrders
              .where((o) => o.status.toLowerCase().contains('completed'))
              .toList();
          break;
        case 4:
          _filtered = _allOrders
              .where((o) => o.status.toLowerCase().contains('rejected'))
              .toList();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        // Filter chips
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _chip('All', 0, AppTheme.primaryColor),
                _chip('Pending', 1, Colors.orange),
                _chip('Active', 2, Colors.blue),
                _chip('Completed', 3, Colors.green),
                _chip('Rejected', 4, Colors.red),
              ]
                  .map((w) => Padding(
                      padding: const EdgeInsets.only(right: 8), child: w))
                  .toList(),
            ),
          ),
        ),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _chip(String label, int index, Color color) {
    final selected = _filterIndex == index;
    return FilterChip(
      label: Text(label,
          style: TextStyle(
              color: selected ? Colors.white : color,
              fontWeight: FontWeight.w600)),
      selected: selected,
      onSelected: (_) => _applyFilter(index),
      backgroundColor: Colors.white,
      selectedColor: color,
      checkmarkColor: Colors.white,
      side: BorderSide(color: color, width: 1.5),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor));
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
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 72, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('No orders found',
                style:
                    TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _filtered.length,
        itemBuilder: (context, i) {
          final order = _filtered[i];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final statusLower = order.status.toLowerCase();
    Color statusColor;
    String statusText;

    if (statusLower.contains('pending') || statusLower.contains('assigned')) {
      statusColor = Colors.orange;
      statusText = 'Pending';
    } else if (statusLower.contains('rejected')) {
      statusColor = Colors.red;
      statusText = 'Rejected';
    } else if (statusLower.contains('completed')) {
      statusColor = Colors.green;
      statusText = 'Completed';
    } else if (statusLower.contains('bill')) {
      statusColor = Colors.purple;
      statusText = 'Bill Uploaded';
    } else if (statusLower.contains('delivery')) {
      statusColor = Colors.teal;
      statusText = 'Out for Delivery';
    } else if (statusLower.contains('accepted')) {
      statusColor = Colors.blue;
      statusText = 'Accepted';
    } else {
      statusColor = Colors.grey;
      statusText = order.status;
    }

    final customerName =
        _customerCache[order.customerId]?['name'] ?? 'Customer';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Order #${order.orderNumber ?? order.orderId}',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(customerName,
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(statusText,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 13, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a')
                      .format(order.createdOn),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                if (order.totalAmount != null) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.currency_rupee,
                      size: 13, color: Colors.grey[500]),
                  Text('${order.totalAmount!.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[500])),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// DELIVERY BOYS PAGE
// ============================================================================

class _ManagerDeliveryBoysPage extends StatefulWidget {
  final Dio dio;

  const _ManagerDeliveryBoysPage({required this.dio});

  @override
  State<_ManagerDeliveryBoysPage> createState() =>
      _ManagerDeliveryBoysPageState();
}

class _ManagerDeliveryBoysPageState extends State<_ManagerDeliveryBoysPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Map<String, dynamic>> _deliveryBoys = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDeliveryBoys();
  }

  Future<void> _loadDeliveryBoys() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await widget.dio.get('/Deliveries');
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

        setState(() {
          _deliveryBoys = list
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      AppLogger.error('Error loading delivery boys', e);
      setState(() {
        _errorMessage = 'Failed to load delivery boys';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor));
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
              onPressed: _loadDeliveryBoys,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_deliveryBoys.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delivery_dining, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('No Delivery Boys Found',
                style:
                    TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDeliveryBoys,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _deliveryBoys.length,
        itemBuilder: (context, i) {
          final boy = _deliveryBoys[i];
          final firstName = boy['firstName']?.toString() ?? '';
          final lastName = boy['lastName']?.toString() ?? '';
          final fullName =
              '$firstName $lastName'.trim().isEmpty ? 'Delivery Boy' : '$firstName $lastName'.trim();
          final phone = boy['mobileNumber']?.toString() ?? '';
          final isActive = boy['isActive'] == true;
          final licenceNo =
              boy['drivingLicenceNumber']?.toString() ?? '';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.purple.shade50,
                    child: Icon(Icons.delivery_dining,
                        color: Colors.purple.shade600, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(fullName,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        if (phone.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Row(children: [
                            Icon(Icons.phone,
                                size: 13, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(phone,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600])),
                          ]),
                        ],
                        if (licenceNo.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Row(children: [
                            Icon(Icons.badge,
                                size: 13, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text('DL: $licenceNo',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600])),
                          ]),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.green.shade50
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: isActive
                              ? Colors.green
                              : Colors.grey),
                    ),
                    child: Text(
                      isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                          color: isActive ? Colors.green : Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
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