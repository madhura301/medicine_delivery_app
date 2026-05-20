import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:pharmaish/core/services/dio_client.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';

/// Backend API for customers.
///
/// Most methods throw [DioException] on transport/HTTP errors.
/// [getCustomerByMobile] is the exception — it returns `null` on failure
/// because callers (auth/profile flows) expect graceful handling.
class CustomerService {
  CustomerService._();

  static Dio get _dio => DioClient.instance;

  /// GET /Customers — full list.
  static Future<List<dynamic>> getAllCustomers() async {
    final response = await _dio.get('/Customers');
    final data = response.data;
    if (data is List) return data;
    return <dynamic>[];
  }

  /// GET /Customers/{customerId} — single customer profile.
  static Future<Map<String, dynamic>> getCustomer(String customerId) async {
    final response = await _dio.get('/Customers/$customerId');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// GET /Customers/by-mobile/{mobileNumber} — fetch customer by phone.
  ///
  /// Returns `null` when not authenticated, the customer is not found, or
  /// any other failure occurs. On 401, also clears stored auth state.
  /// Uses `package:http` directly (predates the Dio singleton).
  static Future<Map<String, dynamic>?> getCustomerByMobile({
    required String mobileNumber,
  }) async {
    try {
      final token = await StorageService.getAuthToken();
      AppLogger.info(
          'Fetching customer by mobile number: $mobileNumber Token: $token');

      if (token == null) {
        AppLogger.warning('No auth token found - user not logged in');
        return null;
      }

      final response = await http.get(
        Uri.parse(
            '${AppConstants.apiBaseUrl}/Customers/by-mobile/$mobileNumber'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      AppLogger.info(
          'Customers/by-mobile API response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.apiResponse(
          response.statusCode,
          '${AppConstants.apiBaseUrl}/Customers/by-mobile/$mobileNumber',
          response.body,
        );
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        AppLogger.warning('Unauthorized access - token may be expired');
        await StorageService.clearAll();
        return null;
      } else {
        AppLogger.warning(
            'API returned error status: ${response.statusCode}, Body: ${response.body}');
        return null;
      }
    } catch (e) {
      AppLogger.error('Customers/by-mobile API error : $e');
      return null;
    }
  }
}
