// Updated Order Tile Widget with Upload Bill AND Assign Delivery Button
// Shows "Assign Delivery Boy" button for BillUploaded orders

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharmaish/core/app_routes.dart';
import 'package:pharmaish/core/screens/payment/payment_summary_page.dart';
import 'package:pharmaish/shared/models/order_model.dart';
import 'package:pharmaish/core/screens/orders/accepted_order_bill_screen.dart';
import 'package:pharmaish/core/screens/delivery/assign_delivery_boy_screen.dart';
import 'package:pharmaish/shared/widgets/payment_summary_dialog.dart';

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
    //return order.billFileUrl != null && order.billFileUrl!.isNotEmpty;
    final statusLower = order.status.toLowerCase();
    return statusLower.contains('billuploaded') ||
        statusLower == 'billuploaded';
  }

  bool _hasAmount() {
    return order.totalAmount != null && order.totalAmount! > 0;
  }

  bool _isBillUploaded() {
    final statusLower = order.status.toLowerCase();
    return statusLower.contains('bill') || statusLower == 'bill uploaded';
  }

  void navigateToPayNowPage(context) {
    // Navigator.pushNamed(
    //   context,
    //   AppRoutes.paymentGateway,
    //   arguments: {
    //     'medicinesTotal': 850.00,
    //     'convenienceFee': 20.00, // call calculateConvenienceFee() here
    //     'orderId': 'ORD123456',
    //   },
    // );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSummaryPage(
          medicinesTotal: 850.0,
          convenienceFee: 20.0,
          orderNumber: '5IKK4FVR3F',
          onPaymentSuccess: () {
            // Handle success
            print('Payment completed!');
          },
        ),
      ),
    );

// // Option 2: Show as modal dialog
// PaymentSummaryDialog.show(
//   context,
//   medicinesTotal: 850.0,
//   convenienceFee: 20.0,
//   orderNumber: '5IKK4FVR3F',
//   onPaymentSuccess: () {
//     print('Payment completed!');
//   },
// );
  }

  double calculateConvenienceFee(double medicinesTotal) {
    final fee = medicinesTotal * 0.025; // 2.5%
    return fee < 20 ? 20 : fee;
  }

  @override
  Widget build(BuildContext context) {
    final timeAgo = _getTimeAgo(order.createdOn);
    final isAccepted = _isAccepted();
    final hasBill = _hasBill();
    final hasAmount = _hasAmount();
    final isBillUploaded = _isBillUploaded();

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
                              //hasBill ? 'Bill Uploaded' : 'Bill Pending',
                              isBillUploaded ? 'Bill Uploaded' : 'Bill Pending',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isBillUploaded
                                    ? Colors.green
                                    : Colors.orange,
                                //color:hasBill ? Colors.green : Colors.orange,
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
                    if (!hasAmount)
                      //if (!hasBill || !hasAmount)
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

                    // // Pay Now Button
                    // if (hasAmount)
                    //   //if (!hasBill || !hasAmount)
                    //   ElevatedButton.icon(
                    //     onPressed: () async {
                    //       navigateToPayNowPage(context);
                    //     },
                    //     icon: Icon(
                    //       hasBill ? Icons.edit : Icons.upload_file,
                    //       size: 16,
                    //     ),
                    //     label: Text(
                    //       hasAmount ? 'Pay Now' : 'Pay Later',
                    //       style: const TextStyle(fontSize: 12),
                    //     ),
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: Colors.black,
                    //       foregroundColor: Colors.white,
                    //       padding: const EdgeInsets.symmetric(
                    //         horizontal: 12,
                    //         vertical: 8,
                    //       ),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(8),
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),
              ],

              // ⭐ ASSIGN DELIVERY BOY BUTTON - FOR BILLUPLOADED ORDERS ⭐
              if (hasAmount && isBillUploaded) ...[
                //if (isBillUploaded && hasBill && hasAmount) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssignDeliveryBoyScreen(
                            order: order,
                            customerName: customerName,
                            onComplete: onRefresh,
                          ),
                        ),
                      );

                      // Refresh if delivery boy was assigned
                      if (result == true && onRefresh != null) {
                        onRefresh!();
                      }
                    },
                    icon: const Icon(Icons.delivery_dining, size: 20),
                    label: const Text('Assign to Delivery Boy'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
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
    } else if (statusLower.contains('billuploaded')) {
      chipColor = Colors.purple;
      statusText = 'Bill Uploaded';
    } else if (statusLower.contains('outfordelivery')) {
      chipColor = Colors.blue;
      statusText = 'Out for Delivery';
    } else if (statusLower.contains('rejected')) {
      chipColor = Colors.red;
      statusText = 'Rejected';
    } else if (statusLower.contains('completed')) {
      chipColor = Colors.teal;
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
          color: chipColor.withOpacity(0.9),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${difference.inDays >= 730 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${difference.inDays >= 60 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
