import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:pharmaish/shared/widgets/app_snackbar.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/core/services/payment_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentSummaryPage extends StatefulWidget {
  final int orderId; // ← required to record payment
  final double medicinesTotal;
  final double convenienceFee;
  final String? orderNumber;
  final VoidCallback? onPaymentSuccess;

  const PaymentSummaryPage({
    super.key,
    required this.orderId,
    required this.medicinesTotal,
    this.convenienceFee = 20.0,
    this.orderNumber,
    this.onPaymentSuccess,
  });

  @override
  State<PaymentSummaryPage> createState() => _PaymentSummaryPageState();
}

class _PaymentSummaryPageState extends State<PaymentSummaryPage> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.upi;
  bool _isProcessing = false;
  bool _agreedToTerms = false;
  late final Razorpay _razorpay;

  /// Razorpay order id for the checkout currently in flight (needed to verify
  /// the payment server-side once the success callback fires).
  String? _currentRazorpayOrderId;

  // Brand colours
  static const Color _blue = Color(0xFF1E3A8A);
  static const Color _green = Color(0xFF16A34A);
  static const Color _payGreen = Color(0xFF22C55E);

  double get totalAmount => widget.medicinesTotal + widget.convenienceFee;

  String _money(double amount) => NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 2,
      ).format(amount);

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: _buildPaymentSummaryCard(),
      ),
    );
  }

  Widget _buildPaymentSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),

          // Bill breakdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildMedicineBillRow(),
                const Divider(height: 28),
                _buildConvenienceFeeRow(),
                const SizedBox(height: 16),
                _buildTotalBox(),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Payment methods
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choose a payment method',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildPaymentMethods(),
          ),
          const SizedBox(height: 16),

          // Trust badges
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSecurityBadges(),
          ),
          const SizedBox(height: 16),

          // Important information
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildImportantInfo(),
          ),
          const SizedBox(height: 16),

          // Payment disclaimer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildPaymentDisclaimer(),
          ),
          const SizedBox(height: 16),

          // Terms consent
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildTermsConsent(),
          ),
          const SizedBox(height: 14),

          // Pay button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildPayButton(),
          ),
          const SizedBox(height: 14),

          _buildFooter(),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long, color: _blue, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Summary',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _blue,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Review your order and complete payment securely.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bill rows ─────────────────────────────────────────────────────────────
  Widget _buildMedicineBillRow() {
    return _buildAmountRow(
      icon: Icons.medication_outlined,
      iconColor: const Color(0xFF2563EB),
      iconBg: Colors.blue.shade50,
      title: const Text(
        'Medicine Bill Amount',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Amount set by the pharmacy',
        style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
      ),
      amount: widget.medicinesTotal,
    );
  }

  Widget _buildConvenienceFeeRow() {
    return _buildAmountRow(
      icon: Icons.account_balance_wallet_outlined,
      iconColor: _green,
      iconBg: Colors.green.shade50,
      title: Row(
        children: [
          const Flexible(
            child: Text(
              'Convenience / Payment Processing Fee',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
        ],
      ),
      subtitle: GestureDetector(
        onTap: _showFeeInfo,
        child: Text(
          'Why am I paying this?',
          style: TextStyle(
            fontSize: 12.5,
            color: Colors.blue.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      amount: widget.convenienceFee,
    );
  }

  Widget _buildAmountRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required Widget title,
    required Widget subtitle,
    required double amount,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 2),
              subtitle,
            ],
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            _money(amount),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F9EF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBCE8CC)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Amount Payable',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF15803D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '(Inclusive of all applicable charges)',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _money(totalAmount),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _green,
            ),
          ),
        ],
      ),
    );
  }

  // ── Payment methods ───────────────────────────────────────────────────────
  Widget _buildPaymentMethods() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPaymentMethodOption(
              PaymentMethod.upi,
              'UPI',
              imagePath: 'assets/images/payments/upi.jpeg',
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildPaymentMethodOption(
              PaymentMethod.card,
              'Credit / Debit Card',
              imagePath: 'assets/images/payments/credit_card.jpeg',
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildPaymentMethodOption(
              PaymentMethod.netBanking,
              'Net Banking',
              imagePath: 'assets/images/payments/net_banking.jpeg',
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildPaymentMethodOption(
              PaymentMethod.wallet,
              'Wallets',
              icon: Icons.account_balance_wallet_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption(
    PaymentMethod method,
    String label, {
    String? imagePath,
    IconData? icon,
  }) {
    final isSelected = _selectedPaymentMethod == method;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = method),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 54,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade300,
                width: isSelected ? 2.5 : 1,
              ),
            ),
            child: imagePath != null
                ? Image.asset(imagePath, fit: BoxFit.contain)
                : Icon(
                    icon,
                    size: 28,
                    color: isSelected ? Colors.blue : Colors.grey.shade700,
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.blue : Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Trust badges ──────────────────────────────────────────────────────────
  Widget _buildSecurityBadges() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSecurityBadge(
              'assets/images/payments/secure_payments.jpeg',
              'Secure Payments',
            ),
          ),
          Container(width: 1, height: 36, color: Colors.grey.shade300),
          Expanded(
            child: _buildSecurityBadge(
              'assets/images/payments/rbi_authorized.jpeg',
              'RBI-Compliant Payment Processing',
            ),
          ),
          Container(width: 1, height: 36, color: Colors.grey.shade300),
          Expanded(
            child: _buildSecurityBadge(
              'assets/images/payments/ssl_encrypted.jpeg',
              'SSL Encrypted',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityBadge(String imagePath, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(imagePath, width: 26, height: 26, fit: BoxFit.contain),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  // ── Important information ─────────────────────────────────────────────────
  Widget _buildImportantInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF9E7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3E5B3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text(
                'Important Information',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _infoBullet('Medicine invoice is generated by the retail pharmacy.'),
          _infoBullet(
              'Pharmaish is a technology platform and does not sell, stock, '
              'dispense, or invoice medicines.'),
          _infoBullet(
              '100% of the medicine bill amount is settled to the pharmacy '
              'through the marketplace settlement system (excluding platform '
              'usage fee, as per T&C).'),
          _infoBullet('Convenience / payment processing charges may apply.'),
        ],
      ),
    );
  }

  Widget _infoBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: _payGreen, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.grey.shade800,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Payment disclaimer ────────────────────────────────────────────────────
  Widget _buildPaymentDisclaimer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.gavel, color: Colors.black54, size: 18),
              SizedBox(width: 8),
              Text(
                'Payment Disclaimer',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Platform fees, activation fees, convenience fees, and other charges '
            'may be revised by Pharmaish from time to time upon prior notice.',
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ── Terms consent ─────────────────────────────────────────────────────────
  Widget _buildTermsConsent() {
    final linkStyle = TextStyle(
      fontSize: 13,
      color: Colors.blue.shade700,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _agreedToTerms,
            onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
              children: [
                const TextSpan(text: 'By proceeding, you agree to our '),
                TextSpan(
                  text: 'Terms & Conditions',
                  style: linkStyle,
                  recognizer: TapGestureRecognizer()
                    ..onTap =
                        () => _openPolicy(AppConstants.termsAndConditionsUrl),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: linkStyle,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _openPolicy(AppConstants.privacyPolicyUrl),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Pay button + footer ───────────────────────────────────────────────────
  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _handlePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: _payGreen,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
        ),
        child: _isProcessing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Pay ${_money(totalAmount)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_user_outlined,
              size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Your payment is safe and secure with encryption.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _showFeeInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Convenience / Payment Processing Fee'),
        content: const Text(
          'This is a small platform fee that covers secure online payment '
          'processing and facilitation of your offline medicine order. '
          'The full medicine bill amount is settled to the pharmacy.',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _openPolicy(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      AppLogger.error('Failed to open policy link: $url', e);
      if (mounted) {
        AppSnackBar.error(context, 'Unable to open link');
      }
    }
  }

  /// Step 1: ask the server to create a Razorpay order, then open checkout.
  Future<void> _handlePayment() async {
    setState(() => _isProcessing = true);

    try {
      AppLogger.info(
          'Creating Razorpay order for order ${widget.orderId}, amount=$totalAmount');

      final rzpOrder = await PaymentService.createRazorpayOrder(
        orderId: widget.orderId,
        amount: totalAmount,
        billAmount: widget.medicinesTotal,
        convenienceFee: widget.convenienceFee,
      );

      _currentRazorpayOrderId = rzpOrder.razorpayOrderId;

      final options = <String, dynamic>{
        'key': rzpOrder.keyId,
        'order_id': rzpOrder.razorpayOrderId,
        'amount': rzpOrder.amountInPaise,
        'currency': rzpOrder.currency,
        'name': 'Pharmaish',
        'description': 'Order #${widget.orderNumber ?? widget.orderId}',
        // Pre-select the method the user tapped; they can still switch in the sheet.
        'prefill': {
          if (_razorpayMethod(_selectedPaymentMethod) != null)
            'method': _razorpayMethod(_selectedPaymentMethod),
        },
      };

      // Razorpay's success/error callbacks drive the rest of the flow.
      _razorpay.open(options);
    } on DioException catch (e) {
      AppLogger.error('Failed to create Razorpay order', e);
      if (mounted) {
        AppSnackBar.error(context, _dioMessage(e, 'Could not start payment.'));
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      AppLogger.error('Unexpected error starting payment', e);
      if (mounted) {
        AppSnackBar.error(
            context, 'An unexpected error occurred. Please try again.');
        setState(() => _isProcessing = false);
      }
    }
  }

  /// Step 2: checkout succeeded on the client — verify it on the server before
  /// treating the payment as confirmed.
  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    AppLogger.info(
        'Razorpay checkout success: paymentId=${response.paymentId}, '
        'orderId=${response.orderId}');

    try {
      await PaymentService.verifyPayment(
        orderId: widget.orderId,
        razorpayOrderId: _currentRazorpayOrderId ?? response.orderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
      );

      if (mounted) {
        setState(() => _isProcessing = false);
        _showSuccessDialog();
      }
    } on DioException catch (e) {
      AppLogger.error('Server payment verification failed', e);
      if (mounted) {
        setState(() => _isProcessing = false);
        AppSnackBar.error(
          context,
          _dioMessage(
            e,
            'Payment could not be verified. If money was deducted, please '
            'contact support before paying again.',
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Unexpected error verifying payment', e);
      if (mounted) {
        setState(() => _isProcessing = false);
        AppSnackBar.error(
            context, 'An unexpected error occurred while verifying payment.');
      }
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    AppLogger.error(
        'Razorpay checkout error: code=${response.code}, message=${response.message}');
    if (!mounted) return;
    setState(() => _isProcessing = false);

    final msg = response.code == Razorpay.PAYMENT_CANCELLED
        ? 'Payment cancelled.'
        : (response.message?.isNotEmpty == true
            ? response.message!
            : 'Payment failed. Please try again.');
    AppSnackBar.error(context, msg);
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    // Final success/failure still arrives via the success/error callbacks.
    AppLogger.info('Razorpay external wallet selected: ${response.walletName}');
  }

  String _dioMessage(DioException e, String fallback) {
    if (e.response?.data is Map) {
      final d = e.response!.data as Map;
      return d['message']?.toString() ?? d['error']?.toString() ?? fallback;
    }
    return fallback;
  }

  /// Maps the in-app method tiles to Razorpay's `prefill.method` values.
  String? _razorpayMethod(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.upi:
        return 'upi';
      case PaymentMethod.card:
        return 'card';
      case PaymentMethod.netBanking:
        return 'netbanking';
      case PaymentMethod.wallet:
        return 'wallet';
      case PaymentMethod.cod:
        return null;
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Payment Successful!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Amount: ${_money(totalAmount)}',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              'Order #${widget.orderNumber ?? widget.orderId}',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close payment page
              widget.onPaymentSuccess?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

enum PaymentMethod {
  upi,
  card,
  netBanking,
  wallet, // Add Paytm, PhonePe, etc.
  cod // Cash on Delivery
}
