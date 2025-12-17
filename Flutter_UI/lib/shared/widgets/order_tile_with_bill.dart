// Updated Order Tile Widget with Upload Bill Button for Accepted Orders
// Add this to replace the existing OrderTile in chemist_dashboard.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharmaish/shared/models/order_model.dart';
import 'package:pharmaish/core/screens/orders/accepted_order_bill_screen.dart';

class OrderTileWithBill extends StatelessWidget {
  final OrderModel order;
  final String customerName;
  final String? customerEmail;
  final String? customerPhone;
  final bool isPending;
  final VoidCallback onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onRefresh;

  const OrderTileWithBill({
    Key? key,
    required this.order,
    required this.customerName,
    this.customerEmail,
    this.customerPhone,
    required this.isPending,
    required this.onTap,
    this.onAccept,
    this.onReject,
    this.onRefresh,
  }) : super(key: key);

  bool _isAccepted() {
    final statusLower = order.status.toLowerCase();
    return statusLower.contains('accepted') ||
        statusLower.contains('bill') ||
        statusLower.contains('delivery');
  }

  bool _hasBill() {
    return order.billFileUrl != null && order.billFileUrl!.isNotEmpty;
  }

  bool _hasAmount() {
    return order.totalAmount != null && order.totalAmount! > 0;
  }

  @override
  Widget build(BuildContext context) {
    final timeAgo = _getTimeAgo(order.createdOn);
    final isAccepted = _isAccepted();
    final hasBill = _hasBill();
    final hasAmount = _hasAmount();

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
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.orderNumber ?? order.orderId}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          customerName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),

              const SizedBox(height: 12),

              // Order Details
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    timeAgo,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.list_alt, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    order.orderInputType.value.toString() ?? 'N/A',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),

              // Show bill status for accepted orders
              if (isAccepted) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                
                // Bill Status Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Bill Upload Status
                    Row(
                      children: [
                        Icon(
                          hasBill ? Icons.check_circle : Icons.receipt_long,
                          size: 20,
                          color: hasBill ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasBill ? 'Bill Uploaded' : 'Bill Pending',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: hasBill ? Colors.green : Colors.orange,
                              ),
                            ),
                            if (hasAmount)
                              Text(
                                '₹${order.totalAmount!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    // Upload Bill Button
                    if (!hasBill || !hasAmount)
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AcceptedOrderBillScreen(
                                order: order,
                                customerName: customerName,
                                customerEmail: customerEmail,
                                customerPhone: customerPhone,
                                onComplete: onRefresh,
                              ),
                            ),
                          );

                          // Refresh if bill was uploaded
                          if (result == true && onRefresh != null) {
                            onRefresh!();
                          }
                        },
                        icon: Icon(
                          hasBill ? Icons.edit : Icons.upload_file,
                          size: 16,
                        ),
                        label: Text(
                          hasBill ? 'Update' : 'Upload Bill',
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),
              ],

              // Action buttons for pending orders
              if (isPending && onAccept != null && onReject != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onReject,
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
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
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Accept'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
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

  Widget _buildStatusChip() {
    Color chipColor;
    String statusText = order.status;

    final statusLower = order.status.toLowerCase();
    if (statusLower.contains('pending') || statusLower.contains('assigned')) {
      chipColor = Colors.orange;
      statusText = 'Pending';
    } else if (statusLower.contains('accepted')) {
      chipColor = Colors.green;
      statusText = 'Accepted';
    } else if (statusLower.contains('rejected')) {
      chipColor = Colors.red;
      statusText = 'Rejected';
    } else if (statusLower.contains('completed')) {
      chipColor = Colors.blue;
      statusText = 'Completed';
    } else {
      chipColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor, width: 1),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}