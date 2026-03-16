import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:pharmaish/config/environment_config.dart';

class PaymentSummaryPage extends StatefulWidget {
  final int orderId;           // ← NEW: required to record payment
  final double medicinesTotal;
  final double convenienceFee;
  final String? orderNumber;
  final VoidCallback? onPaymentSuccess;

  const PaymentSummaryPage({
    Key? key,
    required this.orderId,     // ← NEW
    required this.medicinesTotal,
    this.convenienceFee = 20.0,
    this.orderNumber,
    this.onPaymentSuccess,
  }) : super(key: key);

  @override
  State<PaymentSummaryPage> createState() => _PaymentSummaryPageState();
}

class _PaymentSummaryPageState extends State<PaymentSummaryPage> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.upi;
  bool _isProcessing = false;
  late Dio _dio;

  double get totalAmount => widget.medicinesTotal + widget.convenienceFee;

  @override
  void initState() {
    super.initState();
    _setupDio();
  }

  void _setupDio() {
    _dio = Dio();
    _dio.options.baseUrl = AppConstants.apiBaseUrl;
    _dio.options.connectTimeout = EnvironmentConfig.timeoutDuration;
    _dio.options.receiveTimeout = EnvironmentConfig.timeoutDuration;
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getAuthToken();
        if (token != null) options.headers['Authorization'] = 'Bearer \$token';
        handler.next(options);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text(
          'My Order',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildPaymentSummaryCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummaryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Text(
              'Payment Summary',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 24),

          // Price Breakdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildPriceRow(
                  'Medicines Total',
                  widget.medicinesTotal,
                  isRegular: true,
                ),
                const SizedBox(height: 12),
                _buildPriceRow(
                  '+ Convenience Fee',
                  widget.convenienceFee,
                  isHighlighted: true,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(thickness: 1),
                ),
                _buildPriceRow(
                  'Amount Payable',
                  totalAmount,
                  isTotal: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Payment Methods
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildPaymentMethods(),
          ),

          const SizedBox(height: 24),

          // Pay Now Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _handlePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                  : Text(
                      'Pay Now ₹${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 24),

          // Security Badges
          _buildSecurityBadges(),

          const SizedBox(height: 20),

          // Disclaimers
          _buildDisclaimers(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {
    bool isRegular = false,
    bool isHighlighted = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? const Color(0xFF1E3A8A) : Colors.grey.shade700,
          ),
        ),
        Container(
          padding: isHighlighted
              ? const EdgeInsets.symmetric(horizontal: 12, vertical: 4)
              : null,
          decoration: isHighlighted
              ? BoxDecoration(
                  border: Border.all(color: Colors.orange, width: 2),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 24 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal
                  ? const Color(0xFF22C55E)
                  : isHighlighted
                      ? Colors.orange
                      : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

Widget _buildPaymentMethods() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300, width: 2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Wrap each payment option in Expanded to prevent overflow
        Expanded(
          child: _buildPaymentMethodOption(
            PaymentMethod.upi,
            'assets/images/payments/upi.jpeg',
            'UPI',
          ),
        ),
        const SizedBox(width: 8), // Add spacing between items
        Expanded(
          child: _buildPaymentMethodOption(
            PaymentMethod.card,
            'assets/images/payments/credit_card.jpeg',
            'Credit / Debit Card',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildPaymentMethodOption(
            PaymentMethod.netBanking,
            'assets/images/payments/net_banking.jpeg',
            'Net Banking',
          ),
        ),
      ],
    ),
  );
}

  Widget _buildPaymentMethodOption(
  PaymentMethod method,
  String imagePath,
  String label,
) {
  final isSelected = _selectedPaymentMethod == method;

  return GestureDetector(
    onTap: () {
      setState(() {
        _selectedPaymentMethod = method;
      });
    },
    child: Column(
      mainAxisSize: MainAxisSize.min, // Important: don't take more space than needed
      children: [
        Container(
          // Remove fixed width, let it be flexible
          constraints: const BoxConstraints(
            maxWidth: 100, // Maximum width
            minHeight: 60,  // Keep minimum height
            maxHeight: 60,
          ),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.shade300,
              width: isSelected ? 3 : 1,
            ),
          ),
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 8),
        // Wrap text to prevent overflow
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blue : Colors.grey.shade700,
          ),
          textAlign: TextAlign.center,
          maxLines: 2, // Allow up to 2 lines
          overflow: TextOverflow.ellipsis, // Add ellipsis if still too long
        ),
      ],
    ),
  );
}

  Widget _buildSecurityBadges() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSecurityBadge(
            'assets/images/payments/secure_payments.jpeg',
            'Secure',
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          _buildSecurityBadge(
            'assets/images/payments/rbi_authorized.jpeg',
            'RBI Auth',
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          _buildSecurityBadge(
            'assets/images/payments/ssl_encrypted.jpeg',
            'Encrypted',
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityBadge(String imagePath, String text) {
    return Row(
      children: [
        Image.asset(
          imagePath,
          width: 32,
          height: 32,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimers() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildDisclaimerRow(
            Icons.check_circle,
            Colors.green,
            'Payment for facilitation of offline medicine order.',
          ),
          const SizedBox(height: 12),
          _buildDisclaimerRow(
            Icons.medical_services,
            Colors.blue,
            'Pharmaish does not sell or dispense medicines.',
            imagePath: 'assets/images/payments/medicines_icon.jpeg',
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerRow(
    IconData icon,
    Color color,
    String text, {
    String? imagePath,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: imagePath != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade800,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handlePayment() async {
    setState(() => _isProcessing = true);

    try {
      // Build a transaction ID (in real app this comes from payment gateway)
      final transactionId = 'TXN_${widget.orderId}_${DateTime.now().millisecondsSinceEpoch}';
      final paymentMode = _paymentModeString(_selectedPaymentMethod);

      AppLogger.info('Recording payment for order ${widget.orderId}: '
          'amount=\$totalAmount, mode=\$paymentMode, txn=\$transactionId');

      // POST /api/Payments  — records the payment and marks order FullyPaid
      await _dio.post(
        '/Payments',
        data: {
          'orderId': widget.orderId,
          'paymentMode': paymentMode,
          'transactionId': transactionId,
          'amount': totalAmount,
          'paymentStatus': 1, // 1 = Success
        },
      );

      if (mounted) {
        _showSuccessDialog();
      }
    } on DioException catch (e) {
      AppLogger.error('Payment recording failed', e);
      String msg = 'Payment failed. Please try again.';
      if (e.response?.data is Map) {
        final d = e.response!.data as Map;
        msg = d['error']?.toString() ?? d['message']?.toString() ?? msg;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      AppLogger.error('Unexpected payment error', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  String _paymentModeString(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.upi:        return 'UPI';
      case PaymentMethod.card:       return 'Card';
      case PaymentMethod.netBanking: return 'NetBanking';
      case PaymentMethod.wallet:     return 'Wallet';
      case PaymentMethod.cod:        return 'COD';
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
              'Amount: ₹${totalAmount.toStringAsFixed(2)}',
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
  wallet,  // Add Paytm, PhonePe, etc.
  cod     // Cash on Delivery
}