import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:pharmaish/core/screens/delivery/complete_delivery_screen.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:pharmaish/shared/models/order_model.dart';
import 'package:pharmaish/core/screens/profiles/delivery_profile_page.dart';
import 'package:pharmaish/shared/widgets/app_button.dart';
import 'package:pharmaish/shared/widgets/confirm_dialog.dart';
import 'package:pharmaish/shared/widgets/delivery_address_view.dart';
import 'package:pharmaish/core/services/dio_client.dart';

class DeliveryDashboard extends StatefulWidget {
  const DeliveryDashboard({super.key});

  @override
  State<DeliveryDashboard> createState() => _DeliveryDashboardState();
}

class _DeliveryDashboardState extends State<DeliveryDashboard> {
  int _selectedIndex = 0;

  /// Lets the drawer re-fetch the completed list when that tab is opened.
  final GlobalKey<_DeliveryCompletedOrdersPageState> _completedKey =
      GlobalKey<_DeliveryCompletedOrdersPageState>();
  final Dio _dio = DioClient.instance;
  String _userName = 'Delivery Boy';

  @override
  void initState() {
    super.initState();
    _loadUserName();
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
    final confirm = await confirmLogout(context);
    if (confirm) {
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
          _DeliveryCompletedOrdersPage(key: _completedKey, dio: _dio),
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
                      color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
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
                  selectedTileColor: Colors.black.withValues(alpha: 0.08),
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
                  selectedTileColor: Colors.black.withValues(alpha: 0.08),
                  onTap: () {
                    setState(() => _selectedIndex = 1);
                    // Re-fetch on open. The page keeps itself alive inside an
                    // IndexedStack and only loaded in initState, so a delivery
                    // completed after the dashboard opened never appeared here
                    // until the app was restarted.
                    _completedKey.currentState?.reload();
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
            leading: const Icon(Icons.contact_support, color: Colors.black),
            title: const Text('Contact Us'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/contact-us');
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

        // The delivery address now arrives inline on each order — no per-order
        // fetch. The old two-hop lookup went through /CustomerAddresses/{id},
        // which 403s for this role, so it never actually produced an address.
        await _loadCustomerInfo(orders);

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
        _errorMessage = 'No deliveries assigned yet.';
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

      // The order payload carries the customer name (delivery boys aren't allowed
      // to read other customers' records via /Customers/{id}), so use it directly.
      if (order.customerName != null && order.customerName!.trim().isNotEmpty) {
        _customerCache[order.customerId] = {
          'name': order.customerName!.trim(),
          'phone': '',
        };
        continue;
      }

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
                style: AppButton.primary(),
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
                    color: Colors.white.withValues(alpha: 0.85), fontSize: 14),
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
              // The destination is the single most important thing on this card,
              // so it gets the full multi-line treatment plus a Navigate action
              // rather than one ellipsised row.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.red.shade600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Deliver to',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87)),
                        const SizedBox(height: 2),
                        DeliveryAddressView(
                          address: order.deliveryAddress,
                          showActions: true,
                          textStyle: const TextStyle(fontSize: 13, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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

  // Takes a key so the dashboard can hold a GlobalKey and trigger reload()
  // when this tab is opened.
  const _DeliveryCompletedOrdersPage({super.key, required this.dio});

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

  /// Re-fetches the completed list. Called by the dashboard when this tab is
  /// opened, since the page is kept alive and would otherwise show whatever it
  /// loaded when the dashboard first opened.
  Future<void> reload() => _loadOrders();

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
      } else {
        // Without this the spinner span forever on any non-200: _isLoading was
        // only cleared inside the success branch.
        AppLogger.error(
            'Completed deliveries: unexpected status ${response.statusCode}');
        setState(() {
          _errorMessage =
              'Failed to load completed deliveries (${response.statusCode})';
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
              style: AppButton.primary(),
            ),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      // Wrapped in a RefreshIndicator over an always-scrollable view: the empty
      // state is exactly when a refresh is needed, but it used to be a bare
      // Center with nothing to pull on, so a stale empty list could not be
      // cleared without restarting the app.
      return RefreshIndicator(
        onRefresh: _loadOrders,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text('No Completed Deliveries Yet',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text('Pull down to refresh',
                        style:
                            TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
          ),
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
                        if (order.hasDeliveryAddress) ...[
                          const SizedBox(height: 2),
                          // Where it went — the delivery partner's own record of
                          // a completed run, useful for resolving disputes.
                          Text(
                            order.deliveryAddressLine!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
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