import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pharmaish/core/dashboards/chemist/customer_orders_page.dart';
import 'package:pharmaish/core/dashboards/chemist/order_details_page.dart';
import 'package:pharmaish/core/dashboards/chemist/widgets/reject_order_dialog.dart';
import 'package:pharmaish/core/services/consent_service.dart';
import 'package:pharmaish/core/services/customer_service.dart';
import 'package:pharmaish/core/services/order_service.dart';
import 'package:pharmaish/shared/models/order_model.dart';
import 'package:pharmaish/shared/widgets/app_snackbar.dart';
import 'package:pharmaish/shared/widgets/order_tile_with_bill.dart';
import 'package:pharmaish/shared/widgets/confirm_dialog.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/consent_manager.dart';
import 'package:pharmaish/utils/storage.dart';

// ============================================================================
// CHEMIST DASHBOARD - WITH BILL UPLOAD SUPPORT
// Features:
// 1. Uses OrderTileWithBill for accepted orders
// 2. Shows bill upload button on accepted orders
// 3. Proper status filtering
// ============================================================================

class ChemistDashboard extends StatefulWidget {
  const ChemistDashboard({super.key});

  @override
  State<ChemistDashboard> createState() => _ChemistDashboardState();
}

class _ChemistDashboardState extends State<ChemistDashboard> {
  List<OrderModel> _recentOrders = [];
  List<OrderModel> _allOrders = [];
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, int> _orderCounts = {};

  // Customer info cache (customerId -> customer data)
  final Map<String, Map<String, String>> _customerCache = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
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

      final ordersList =
          await OrderService.getOrdersForMedicalStore(pharmacistId);

      AppLogger.info('Received ${ordersList.length} active orders');

      final allOrders =
          ordersList.map((json) => OrderModel.fromJson(json)).toList();

      // Sort by date (most recent first)
      allOrders.sort((a, b) => b.createdOn.compareTo(a.createdOn));

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
          final customerData =
              await CustomerService.getCustomer(order.customerId);
          _customerCache[order.customerId] = {
            'name':
                '${customerData['customerFirstName'] ?? ''} ${customerData['customerLastName'] ?? ''}'
                    .trim(),
            'email': customerData['emailId']?.toString() ?? '',
            'phone': customerData['mobileNumber']?.toString() ?? '',
          };
          AppLogger.info('Loaded customer info for ${order.customerId}');
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

  Future<void> _navigateToOrderDetails(OrderModel order) async {
    // Check if consent already given
    final hasConsent = await ConsentService.hasConsent(
      ConsentType.dataHandlingLiabilityDisclaimer,
    );

    if (!hasConsent) {
      final accepted =
          await PharmacistConsentManager.showDataHandlingLiabilityDisclaimer(
              context);

      if (!accepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must accept the terms to view orders.'),
          ),
        );
        return;
      }
    }

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
                //   title: Text('Service Regions'),
                //   onTap: () => Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => AdminServiceRegionsPage(),
                //     ),
                //   ),
                // ),
                ListTile(
                    leading: const Icon(Icons.person, color: Colors.black),
                    title: const Text('Profile'),
                    onTap: () => _navigateToChemistProfile(context)),

                // ✅ FIXED: Reduced spacing before Deliveries section
                const Divider(height: 1), // Changed from default height

                // // Deliveries Section Header - removed extra padding
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(16, 8, 16,
                //       4), // ✅ Reduced top padding from 8 to 8 and bottom from 8 to 4
                //   child: Text(
                //     'DELIVERIES',
                //     style: TextStyle(
                //       fontSize: 12,
                //       fontWeight: FontWeight.bold,
                //       color: Colors.grey.shade600,
                //     ),
                //   ),
                // ),

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
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.contact_support, color: Colors.black),
            title: const Text('Contact Us'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/contact-us');
            },
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
    final confirm = await confirmLogout(context);
    if (confirm) {
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
                  onTap: () {
                    _navigateToOrderDetails(order);
                  },
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

      await OrderService.acceptOrder(order.orderId);
      await _loadDashboardData();

      if (mounted) {
        AppSnackBar.success(
            context, 'Order ${order.orderNumber ?? order.orderId} accepted');
      }
    } catch (e) {
      AppLogger.error('Error accepting order', e);

      if (mounted) {
        AppSnackBar.error(context, 'Failed to accept order');
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

        await OrderService.rejectOrder(
          orderId: order.orderId,
          rejectNote: reason,
        );
        await _loadDashboardData();

        if (mounted) {
          AppSnackBar.success(
              context, 'Order ${order.orderNumber ?? order.orderId} rejected');
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
          AppSnackBar.error(context, errorMessage);
        }
      }
    }
  }
}
