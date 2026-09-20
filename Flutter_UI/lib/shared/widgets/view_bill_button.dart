import 'package:flutter/material.dart';
import 'package:pharmaish/shared/models/order_model.dart';
import 'package:pharmaish/shared/widgets/authenticated_image.dart';

/// Whether the pharmacy has uploaded a bill for [order].
bool orderHasBill(OrderModel order) =>
    order.billFileUrl != null && order.billFileUrl!.isNotEmpty;

bool _isImageBill(OrderModel order) {
  final fileName = extractFileName(order.billFileUrl);
  final extension =
      fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
  return const ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
}

/// Shows the order's bill. Image bills open in a zoomable dialog; bills uploaded
/// as documents (PDF etc.) can't be previewed inline, so they are downloaded
/// and offered for opening instead.
void showBillDialog(BuildContext context, OrderModel order) {
  if (!_isImageBill(order)) {
    downloadBillFile(
      context,
      orderId: order.orderId,
      billFileUrl: order.billFileUrl,
    );
    return;
  }

  final url = getOrderBillFileUrl(order.orderId);

  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bill',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.download, color: Colors.white),
                      onPressed: () => downloadBillFile(
                        ctx,
                        orderId: order.orderId,
                        billFileUrl: order.billFileUrl,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Image with zoom
          Flexible(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 6.0,
              child: AuthNetworkImage(
                url: url,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    height: 300,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => const SizedBox(
                  height: 300,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, color: Colors.grey, size: 48),
                        SizedBox(height: 8),
                        Text(
                          'Could not load bill',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// "View Bill" button for order tiles, styled like the "View Prescription"
/// button. Renders nothing until the pharmacy has uploaded a bill.
class ViewBillButton extends StatelessWidget {
  final OrderModel order;

  const ViewBillButton({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    if (!orderHasBill(order)) return const SizedBox.shrink();

    return TextButton.icon(
      onPressed: () => showBillDialog(context, order),
      icon: const Icon(Icons.receipt_long, size: 16),
      label: const Text(
        'View Bill',
        style: TextStyle(fontSize: 12),
      ),
      style: TextButton.styleFrom(
        foregroundColor: Colors.orange[800],
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
      ),
    );
  }
}
