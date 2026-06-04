import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharmaish/core/services/payment_service.dart';
import 'package:pharmaish/shared/models/payment_model.dart';
import 'package:pharmaish/utils/app_logger.dart';

/// A popup that lists every payment recorded against an order — both
/// successful and failed attempts. Shared by the Admin and Customer order
/// detail pages.
class OrderPaymentsDialog extends StatefulWidget {
  final int orderId;
  final String? orderNumber;

  const OrderPaymentsDialog({
    super.key,
    required this.orderId,
    this.orderNumber,
  });

  /// Opens the dialog. [orderId] is the numeric order id, [orderNumber] is the
  /// human-friendly order number shown in the title (optional).
  static Future<void> show(
    BuildContext context, {
    required int orderId,
    String? orderNumber,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => OrderPaymentsDialog(
        orderId: orderId,
        orderNumber: orderNumber,
      ),
    );
  }

  @override
  State<OrderPaymentsDialog> createState() => _OrderPaymentsDialogState();
}

class _OrderPaymentsDialogState extends State<OrderPaymentsDialog> {
  bool _isLoading = true;
  String? _errorMessage;
  List<PaymentModel> _payments = [];

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final payments =
          await PaymentService.getPaymentsForOrder(widget.orderId);
      // Newest payment first.
      payments.sort((a, b) => b.paidOn.compareTo(a.paidOn));
      if (!mounted) return;
      setState(() {
        _payments = payments;
        _isLoading = false;
      });
    } on DioException catch (e) {
      AppLogger.error('Error loading payments for order ${widget.orderId}', e);
      if (!mounted) return;
      setState(() {
        _errorMessage = e.response?.statusCode == 403
            ? 'You do not have permission to view these payments.'
            : 'Failed to load payments. Please try again.';
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Unexpected error loading payments', e);
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load payments. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.orderNumber != null && widget.orderNumber!.isNotEmpty
        ? 'Payments • Order #${widget.orderNumber}'
        : 'Payments';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payments, color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            Flexible(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 12),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadPayments,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_payments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 56, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No payments have been made for this order yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      itemCount: _payments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildPaymentCard(_payments[index]),
    );
  }

  Widget _buildPaymentCard(PaymentModel payment) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '₹${payment.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _statusChip(payment.status),
            ],
          ),
          const SizedBox(height: 10),
          _infoRow(Icons.account_balance_wallet, 'Mode',
              payment.paymentMode.isNotEmpty ? payment.paymentMode : 'N/A'),
          if (payment.transactionId.isNotEmpty)
            _infoRow(Icons.tag, 'Transaction', payment.transactionId),
          _infoRow(
            Icons.access_time,
            'Paid On',
            DateFormat('MMM dd, yyyy • hh:mm a').format(payment.paidOn.toLocal()),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(PaymentStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              color: status.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}
