import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:medicine_delivery_app/shared/models/user_model.dart';
import 'package:medicine_delivery_app/utils/constants.dart';
import 'package:medicine_delivery_app/utils/storage.dart';

class AuthService {
  static const String baseUrl = 'https://10.0.2.2:7000/api';
  static Future<String?> invokeLogin({
    required String mobileNumber,
    required String password,
    bool stayLoggedIn = false,
  }) async {
    try {
      // Make API call
      final response = await http.post(
        Uri.parse('$baseUrl/Auth/login'),
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

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Login response data: $responseData');
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
      print('Login error: $e');
      return null;
    }
  }

  static Future<User?> login(String username, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (AppConstants.demoUsers.containsKey(username) &&
        AppConstants.demoUsers[username]!['password'] == password) {
     
      final userInfo = AppConstants.demoUsers[username]!;
      return User(
        username: username,
        role: userInfo['role']!,
        email: userInfo['email']!,
        mobile: userInfo['mobile']!,
      );
    }

    return null;
  }

  static Future<bool> register(Map<String, dynamic> userData) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // In a real app, this would save to a database
    return true;
  }

  static Future<bool> sendResetCode(String username) async {
    await Future.delayed(const Duration(seconds: 2));
    return AppConstants.demoUsers.containsKey(username);
  }

  static Future<bool> verifyOTP(String otp, String expectedOtp) async {
    await Future.delayed(const Duration(seconds: 1));
    return otp == expectedOtp;
  }

  static Future<bool> resetPassword(String username, String newPassword) async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

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
