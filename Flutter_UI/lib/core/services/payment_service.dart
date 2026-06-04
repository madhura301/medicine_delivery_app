import 'package:dio/dio.dart';
import 'package:pharmaish/core/services/dio_client.dart';
import 'package:pharmaish/shared/models/payment_model.dart';
import 'package:pharmaish/shared/models/razorpay_models.dart';

/// Backend API for the server-driven Razorpay payment flow.
///
/// The server does the trust-sensitive work: it creates the Razorpay order,
/// verifies the payment signature, and records the payment. The client only
/// opens the hosted checkout and relays the result back here for verification.
///
/// All methods throw [DioException] on transport/HTTP failure — callers handle
/// the UX (matching [OrderService]'s contract).
class PaymentService {
  PaymentService._();

  static Dio get _dio => DioClient.instance;

  /// POST /Razorpay/create-order — server creates a Razorpay order.
  static Future<RazorpayOrderResponse> createRazorpayOrder({
    required int orderId,
    required double amount,
  }) async {
    final response = await _dio.post(
      '/Razorpay/create-order',
      data: {
        'orderId': orderId,
        'amount': amount,
      },
    );
    return RazorpayOrderResponse.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  /// POST /Razorpay/verify-payment — server verifies the signature and records
  /// the payment. Returns normally on success (200); throws [DioException]
  /// (e.g. 400) when verification fails.
  static Future<void> verifyPayment({
    required int orderId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    await _dio.post(
      '/Razorpay/verify-payment',
      data: {
        'orderId': orderId,
        'razorpayOrderId': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
      },
    );
  }

  /// GET /Payments/order/{orderId} — all payments recorded for an order
  /// (successful and failed alike). Used to show payment history.
  static Future<List<PaymentModel>> getPaymentsForOrder(int orderId) async {
    final response = await _dio.get('/Payments/order/$orderId');
    final data = response.data as List;
    return data
        .map((e) => PaymentModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
