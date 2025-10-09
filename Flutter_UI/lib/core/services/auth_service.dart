import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pharmaish/utils/constants.dart';
import '../../utils/app_logger.dart';

class AuthService {
  static Uri baseUrl = Uri.parse('${AppConstants.apiBaseUrl}/Auth/login');
  static Future<String?> invokeLogin({
    required String mobileNumber,
    required String password,
    bool stayLoggedIn = false,
  }) async {
    try {
      // Make API call
      final response = await http.post(
        baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'mobileNumber': mobileNumber,
          'password': password,
          'stayLoggedIn': stayLoggedIn
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        AppLogger.apiResponse(
            response.statusCode, '$baseUrl/Auth/login', responseData);
        if (responseData['success'] == true) {
          // Extract tokens and user data
          final token = responseData['token'];
          // final refreshToken = responseData['refreshToken'];
          // final userId = responseData['userId'] ?? '';

          // // Store authentication tokens
          // await StorageService.storeAuthTokens(
          //   token: token,
          //   refreshToken: refreshToken,
          // );

          // // Store user ID
          // if (userId.isNotEmpty) {
          //   await StorageService.storeUserId(userId);
          // }

          // // Decode JWT token and extract user info
          // final userInfo = StorageService.decodeJwtToken(token);
          // final extractedUserInfo = StorageService.extractUserInfo(userInfo);

          // if (extractedUserInfo.isNotEmpty) {
          //   await StorageService.storeUserInfo(extractedUserInfo);
          // }

          return token; // Return token for immediate use
        }
      }

      // All error cases return null
      return null;
    } catch (e) {
      AppLogger.error('Login API error : $e');
      return null;
    }
  }

  //   user methods removed - app now uses real API authentication
  // All authentication is handled through the real API endpoints

  //  static Future<void> storeTokens(String token, String? refreshToken) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('auth_token', token);
  //   if (refreshToken != null) {
  //     await prefs.setString('refresh_token', refreshToken);
  //   }
  // }

  // static Future<String?> getToken() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('auth_token');
  // }

  // static Future<void> clearTokens() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('auth_token');
  //   await prefs.remove('refresh_token');
  // }
}
