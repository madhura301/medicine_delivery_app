import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pharmaish/core/services/order_service.dart';
import 'package:pharmaish/shared/models/order_model.dart';
import 'package:pharmaish/shared/widgets/confirm_dialog.dart';
import 'package:pharmaish/utils/app_logger.dart';

/// Shows a dialog that cancels an order with a mandatory reason.
///
/// Calls `PUT /Orders/{orderId}/cancel` (backend policy: CancelOrders — only
/// Manager, Customer Support and Admin logins are authorised). Returns `true`
/// when the order was successfully cancelled so the caller can refresh its list.
Future<bool> showCancelOrderDialog(
  BuildContext context, {
  required OrderModel order,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _CancelOrderDialog(order: order),
  );
  return result ?? false;
}

/// Whether an order is in a state that can still be cancelled. Completed and
/// already-cancelled orders are excluded.
bool isOrderCancellable(OrderModel order) {
  final s = order.status.toLowerCase();
  return !s.contains('completed') && !s.contains('cancel');
}

class _CancelOrderDialog extends StatefulWidget {
  final OrderModel order;
  const _CancelOrderDialog({required this.order});

  @override
  State<_CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<_CancelOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Final confirmation before the irreversible cancellation.
    final confirmed = await confirmAction(
      context,
      title: 'Cancel this order?',
      message:
          'Order #${widget.order.orderNumber ?? widget.order.orderId} will be '
          'cancelled. This action cannot be undone.',
      confirmLabel: 'Yes, cancel',
      cancelLabel: 'No, keep it',
    );
    if (!confirmed) return;

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await OrderService.cancelOrder(
        orderId: widget.order.orderId,
        cancellationReason: _reasonController.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } on DioException catch (e) {
      AppLogger.error('Cancel order failed', e);
      final code = e.response?.statusCode;
      String msg;
      if (code == 403) {
        msg = 'You do not have permission to cancel orders.';
      } else if (code == 400) {
        msg = e.response?.data is Map
            ? (e.response?.data['error']?.toString() ??
                'This order cannot be cancelled.')
            : 'This order cannot be cancelled.';
      } else if (code == 404) {
        msg = 'Order not found.';
      } else {
        msg = 'Failed to cancel order. Please try again.';
      }
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _error = msg;
        });
      }
    } catch (e) {
      AppLogger.error('Cancel order failed', e);
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _error = 'Failed to cancel order. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Row(
        children: [
          Icon(Icons.cancel_outlined, color: Colors.red.shade700, size: 22),
          const SizedBox(width: 8),
          const Expanded(child: Text('Cancel Order')),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order #${widget.order.orderNumber ?? widget.order.orderId}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reasonController,
              enabled: !_isSubmitting,
              maxLength: 250,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Reason for cancellation',
                hintText: 'Enter a reason (required)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) {
                  return 'A cancellation reason is required';
                }
                if (text.length > 250) {
                  return 'Reason cannot exceed 250 characters';
                }
                return null;
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 4),
              Text(
                _error!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
          child: const Text('Keep Order'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Cancel Order'),
        ),
      ],
    );
  }
}
