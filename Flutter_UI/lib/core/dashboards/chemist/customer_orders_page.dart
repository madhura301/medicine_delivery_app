import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pharmaish/core/dashboards/chemist/order_details_page.dart';
import 'package:pharmaish/core/dashboards/chemist/widgets/reject_order_dialog.dart';
import 'package:pharmaish/core/services/order_service.dart';
import 'package:pharmaish/shared/models/order_model.dart';
import 'package:pharmaish/shared/widgets/app_snackbar.dart';
import 'package:pharmaish/shared/widgets/order_tile_with_bill.dart';
import 'package:pharmaish/utils/app_logger.dart';

class CustomerOrdersPage extends StatefulWidget {
  final List<OrderModel> allOrders;
  final Map<String, Map<String, String>> customerCache;
  final VoidCallback? onRefresh;

  const CustomerOrdersPage({
    super.key,
    required this.allOrders,
    required this.customerCache,
    this.onRefresh,
  });

  @override
  State<CustomerOrdersPage> createState() => _CustomerOrdersPageState();
}

class _CustomerOrdersPageState extends State<CustomerOrdersPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
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

      await OrderService.acceptOrder(order.orderId);

      if (mounted) {
        AppSnackBar.success(
            context, 'Order ${order.orderNumber ?? order.orderId} accepted');
        if (widget.onRefresh != null) {
          widget.onRefresh!();
        }
        setState(() {});
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
          if (widget.onRefresh != null) {
            widget.onRefresh!();
          }
          setState(() {});
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
                  onRefresh: widget.onRefresh,
                ),
              ),
            );
          },
          onAccept:
              _isPending(order.status) ? () => _handleAcceptOrder(order) : null,
          onReject:
              _isPending(order.status) ? () => _handleRejectOrder(order) : null,
          onRefresh: widget.onRefresh,
        );
      },
    );
  }
}
