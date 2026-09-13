import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pharmaish/core/dashboards/chemist/customer_info_loader.dart';
import 'package:pharmaish/core/dashboards/chemist/order_details_page.dart';
import 'package:pharmaish/core/dashboards/chemist/widgets/reject_order_dialog.dart';
import 'package:pharmaish/core/services/order_service.dart';
import 'package:pharmaish/shared/models/order_model.dart';
import 'package:pharmaish/shared/widgets/app_snackbar.dart';
import 'package:pharmaish/shared/widgets/order_tile_with_bill.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/storage.dart';

class CustomerOrdersPage extends StatefulWidget {
  final List<OrderModel> allOrders;
  final Map<String, Map<String, String>> customerCache;
  final VoidCallback? onRefresh;

  /// When set, the page opens as a focused, single-status view (no tabs) — used
  /// by the dashboard Overview tiles. One of: pending, accepted, rejected,
  /// outForDelivery, billUploaded, completed.
  final String? initialStatusFilter;

  /// Title shown for the focused view (e.g. "Pending Orders").
  final String? filterTitle;

  const CustomerOrdersPage({
    super.key,
    required this.allOrders,
    required this.customerCache,
    this.onRefresh,
    this.initialStatusFilter,
    this.filterTitle,
  });

  @override
  State<CustomerOrdersPage> createState() => _CustomerOrdersPageState();
}

class _CustomerOrdersPageState extends State<CustomerOrdersPage> {
  int _selectedIndex = 0;

  // Locally owned, mutable copy so tiles can update the moment an action's POST
  // succeeds — without waiting for the dashboard (underneath this pushed route)
  // to reload.
  late List<OrderModel> _orders;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _orders = List<OrderModel>.from(widget.allOrders);
  }

  @override
  void didUpdateWidget(CustomerOrdersPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.allOrders, widget.allOrders)) {
      _orders = List<OrderModel>.from(widget.allOrders);
    }
  }

  /// Re-fetches a single order (with its new status) and swaps it into the
  /// local list so its tile/buttons update immediately after an action.
  Future<void> _refreshOrderById(String orderId) async {
    try {
      final json = await OrderService.getOrderById(orderId);
      final updated = OrderModel.fromJson(json);
      if (!mounted) return;
      final index = _orders.indexWhere((o) => o.orderId == orderId);
      setState(() {
        if (index != -1) {
          _orders[index] = updated;
        }
      });
    } catch (e) {
      AppLogger.error('Error refreshing order $orderId after action', e);
    }
  }

  /// Full refresh from the server (AppBar button / pull-to-refresh) so new
  /// orders and status changes made elsewhere show up without re-login.
  /// Also asks the dashboard underneath to reload so it stays in sync.
  Future<void> _refreshAll() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      final storeId = await StorageService.getUserId();
      if (storeId == null || storeId.isEmpty) {
        throw StateError('User ID not found. Please login again.');
      }
      final list = await OrderService.getOrdersForMedicalStore(storeId);
      final orders = list.map((json) => OrderModel.fromJson(json)).toList()
        ..sort((a, b) => b.createdOn.compareTo(a.createdOn));
      await loadCustomerInfoInto(widget.customerCache, orders);
      if (!mounted) return;
      setState(() => _orders = orders);
      widget.onRefresh?.call();
    } on DioException catch (e) {
      AppLogger.error('Error refreshing orders', e);
      if (!mounted) return;
      if (e.response?.statusCode == 401) {
        await StorageService.clearAll();
        if (mounted) Navigator.of(context).pushReplacementNamed('/login');
        return;
      }
      AppSnackBar.error(context, 'Failed to refresh orders. Please try again.');
    } catch (e) {
      AppLogger.error('Error refreshing orders', e);
      if (!mounted) return;
      AppSnackBar.error(context, 'Failed to refresh orders: $e');
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  /// Refresh triggered by tile/detail actions (bill upload, assign delivery,
  /// etc.): update this page's tile now and keep the dashboard list in sync.
  void _handleOrderChanged(OrderModel order) {
    widget.onRefresh?.call();
    _refreshOrderById(order.orderId);
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

  /// Matches an order's status against an Overview-tile key. Mirrors the count
  /// logic in the dashboard so a tile's number matches its filtered list.
  bool _matchesStatusKey(String status, String key) {
    final s = status.toLowerCase();
    switch (key) {
      case 'pending':
        return s.contains('pending') || s.contains('assigned');
      case 'accepted':
        return s.contains('accepted');
      case 'rejected':
        return s.contains('rejected');
      case 'outForDelivery':
        return s.contains('delivery');
      case 'billUploaded':
        return s.contains('bill');
      case 'completed':
        return s.contains('completed');
      default:
        return true;
    }
  }

  Future<void> _handleAcceptOrder(OrderModel order) async {
    try {
      AppLogger.info('Accepting order ${order.orderId}');

      await OrderService.acceptOrder(order.orderId);

      final pharmacyName = await StorageService.getPharmacyName();
      if (mounted) {
        AppSnackBar.success(
          context,
          pharmacyName != null && pharmacyName.isNotEmpty
              ? 'Request accepted by $pharmacyName'
              : 'Request accepted',
        );
        widget.onRefresh?.call();
        await _refreshOrderById(order.orderId);
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

        if (mounted) {
          AppSnackBar.success(
              context, 'Order ${order.orderNumber ?? order.orderId} rejected');
          widget.onRefresh?.call();
          await _refreshOrderById(order.orderId);
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

  bool get _isFocusedView => widget.initialStatusFilter != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.filterTitle ?? 'Customer Orders',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isRefreshing ? null : _refreshAll,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: _buildBody(),
      ),
      bottomNavigationBar: _isFocusedView
          ? null
          : BottomNavigationBar(
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
                  label: 'All (${_orders.length})',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.pending_actions),
                  label: 'Pending',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle_outline),
                  label: 'Accepted',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'History',
                ),
              ],
            ),
    );
  }

  Widget _buildBody() {
    List<OrderModel> filteredOrders;

    // Focused single-status view (opened from a dashboard Overview tile).
    if (_isFocusedView) {
      filteredOrders = _orders
          .where((o) => _matchesStatusKey(o.status, widget.initialStatusFilter!))
          .toList();
      return _buildOrderList(filteredOrders);
    }

    switch (_selectedIndex) {
      case 0:
        filteredOrders = _orders;
        break;
      case 1:
        filteredOrders = _orders.where((o) => _isPending(o.status)).toList();
        break;
      case 2:
        filteredOrders = _orders.where((o) => _isAccepted(o.status)).toList();
        break;
      case 3:
        filteredOrders = _orders.where((o) => _isHistory(o.status)).toList();
        break;
      default:
        filteredOrders = _orders;
    }

    return _buildOrderList(filteredOrders);
  }

  Widget _buildOrderList(List<OrderModel> filteredOrders) {
    if (filteredOrders.isEmpty) {
      // Scrollable so pull-to-refresh still works on an empty list.
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No orders found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pull down or tap refresh to check for new orders',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        final customerInfo = widget.customerCache[order.customerId];

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
                  onAccept: _isPending(order.status)
                      ? () => _handleAcceptOrder(order)
                      : null,
                  onReject: _isPending(order.status)
                      ? () => _handleRejectOrder(order)
                      : null,
                  onRefresh: () => _handleOrderChanged(order),
                ),
              ),
            );
          },
          onAccept:
              _isPending(order.status) ? () => _handleAcceptOrder(order) : null,
          onReject:
              _isPending(order.status) ? () => _handleRejectOrder(order) : null,
          onRefresh: () => _handleOrderChanged(order),
        );
      },
    );
  }
}
