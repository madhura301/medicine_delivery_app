import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pharmaish/core/services/dio_client.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';

/// Backend API for medical stores (pharmacies).
///
/// [getMedicalStoreByEmail] returns `null` on any failure because callers
/// (auth/profile flows) expect graceful handling rather than exceptions.
/// Uses `package:http` directly, consistent with [CustomerService].
class MedicalStoreService {
  MedicalStoreService._();

  /// GET /MedicalStores/by-email/{email} — fetch a pharmacy by owner email.
  ///
  /// Returns `null` when not authenticated, the store is not found, or any
  /// other failure occurs.
  static Future<Map<String, dynamic>?> getMedicalStoreByEmail({
    required String email,
  }) async {
    try {
      final token = await StorageService.getAuthToken();
      if (token == null) {
        AppLogger.warning('No auth token found - user not logged in');
        return null;
      }

      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/MedicalStores/by-email/$email'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      AppLogger.info(
          'MedicalStores/by-email API response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        AppLogger.warning(
            'MedicalStores/by-email returned status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      AppLogger.error('MedicalStores/by-email API error: $e');
      return null;
    }
  }

  /// GET /MedicalStores/{id} — resolve a pharmacy's display name by its id.
  ///
  /// Returns the `medicalName`, or `null` when the id is empty or any
  /// failure occurs.
  static Future<String?> getMedicalStoreNameById(String medicalStoreId) async {
    if (medicalStoreId.isEmpty) return null;
    try {
      final response =
          await DioClient.instance.get('/MedicalStores/$medicalStoreId');
      final data = response.data;
      if (data is Map && data['medicalName'] != null) {
        final name = data['medicalName'].toString();
        return name.isNotEmpty ? name : null;
      }
      return null;
    } catch (e) {
      AppLogger.error('MedicalStores/{id} API error: $e');
      return null;
    }
  }
}
