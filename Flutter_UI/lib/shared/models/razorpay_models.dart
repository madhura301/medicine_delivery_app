/// Response from `POST /api/Razorpay/create-order`.
///
/// The server creates the Razorpay order and returns everything the client
/// needs to open the hosted checkout widget. [keyId] is the public key — safe
/// to use on the client.
class RazorpayOrderResponse {
  final String razorpayOrderId;
  final double amount; // rupees
  final String currency;
  final String keyId;

  const RazorpayOrderResponse({
    required this.razorpayOrderId,
    required this.amount,
    required this.currency,
    required this.keyId,
  });

  factory RazorpayOrderResponse.fromJson(Map<String, dynamic> json) {
    return RazorpayOrderResponse(
      razorpayOrderId: json['razorpayOrderId']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? 'INR',
      keyId: json['keyId']?.toString() ?? '',
    );
  }

  /// Razorpay checkout expects the amount in the smallest currency unit (paise).
  int get amountInPaise => (amount * 100).round();
}
