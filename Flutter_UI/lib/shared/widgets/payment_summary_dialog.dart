
import 'package:flutter/material.dart';
import 'package:pharmaish/core/screens/payment/payment_summary_page.dart';

class PaymentSummaryDialog {
  static Future<void> show(
    BuildContext context, {
    required double medicinesTotal,
    double convenienceFee = 20.0,
    String? orderNumber,
    VoidCallback? onPaymentSuccess,
  }) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: PaymentSummaryPage(
            medicinesTotal: medicinesTotal,
            convenienceFee: convenienceFee,
            orderNumber: orderNumber,
            onPaymentSuccess: onPaymentSuccess,
          ),
        ),
      ),
    );
  }
}