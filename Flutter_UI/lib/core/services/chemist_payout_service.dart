import 'package:dio/dio.dart';
import 'package:pharmaish/core/services/dio_client.dart';
import 'package:pharmaish/shared/models/chemist_payout_models.dart';

/// Backend API for chemist payout onboarding (Razorpay Route linked account)
/// and the one-time activation/onboarding fee (Razorpay Payment Links).
///
/// Mutating calls throw [DioException] on failure (callers handle the UX).
/// Status getters return `null` when no record exists yet (HTTP 404).
class ChemistPayoutService {
  ChemistPayoutService._();

  static Dio get _dio => DioClient.instance;

  // ── Payout (Route linked account) ─────────────────────────────────────────

  /// GET /chemist-payout/{storeId} — current onboarding status, or null if none.
  static Future<ChemistPayoutStatusModel?> getPayoutStatus(String storeId) async {
    try {
      final res = await _dio.get('/chemist-payout/$storeId');
      return ChemistPayoutStatusModel.fromJson(
        Map<String, dynamic>.from(res.data as Map),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// POST /chemist-payout/{storeId}/onboard — create/resume the linked account.
  static Future<ChemistPayoutStatusModel> onboard({
    required String storeId,
    required String bankAccountNumber,
    required String bankIfscCode,
    required String bankAccountHolderName,
  }) async {
    final res = await _dio.post(
      '/chemist-payout/$storeId/onboard',
      data: {
        'bankAccountNumber': bankAccountNumber,
        'bankIfscCode': bankIfscCode,
        'bankAccountHolderName': bankAccountHolderName,
      },
    );
    return ChemistPayoutStatusModel.fromJson(
      Map<String, dynamic>.from(res.data as Map),
    );
  }

  /// PUT /chemist-payout/{storeId}/bank — update bank details and re-submit.
  static Future<ChemistPayoutStatusModel> updateBank({
    required String storeId,
    required String bankAccountNumber,
    required String bankIfscCode,
    required String bankAccountHolderName,
  }) async {
    final res = await _dio.put(
      '/chemist-payout/$storeId/bank',
      data: {
        'bankAccountNumber': bankAccountNumber,
        'bankIfscCode': bankIfscCode,
        'bankAccountHolderName': bankAccountHolderName,
      },
    );
    return ChemistPayoutStatusModel.fromJson(
      Map<String, dynamic>.from(res.data as Map),
    );
  }

  // ── Activation fee (Payment Links) ────────────────────────────────────────

  /// POST /chemist-payout/{storeId}/activation-link — create (or fetch pending) link.
  static Future<ChemistActivationModel> createActivationLink(String storeId) async {
    final res = await _dio.post('/chemist-payout/$storeId/activation-link');
    return ChemistActivationModel.fromJson(
      Map<String, dynamic>.from(res.data as Map),
    );
  }

  /// GET /chemist-payout/{storeId}/activation — current activation status, or null.
  static Future<ChemistActivationModel?> getActivationStatus(String storeId) async {
    try {
      final res = await _dio.get('/chemist-payout/$storeId/activation');
      return ChemistActivationModel.fromJson(
        Map<String, dynamic>.from(res.data as Map),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }
}
