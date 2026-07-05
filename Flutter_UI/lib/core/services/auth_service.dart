import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/constants.dart';

/// Result of an auth-endpoint call.
///
/// Carries both the HTTP status code (callers branch on 401/400) and the
/// parsed JSON body (callers read `success`, `token`, `errors`).
class AuthResponse {
  final int statusCode;
  final Map<String, dynamic> data;

  const AuthResponse({required this.statusCode, required this.data});

  bool get isHttpSuccess => statusCode == 200 || statusCode == 201;

  /// `true` when both the HTTP status and the body's `success` flag are OK.
  bool get success => isHttpSuccess && data['success'] == true;

  String? get token => data['token'] as String?;
  String? get refreshToken => data['refreshToken'] as String?;
  String? get userId => data['userId']?.toString();

  /// First error message from `data['errors']`, if any.
  String? get firstError {
    final errors = data['errors'];
    if (errors is List && errors.isNotEmpty) return errors.first.toString();
    return null;
  }

  /// Human-readable `data['message']`, used by endpoints that return a plain
  /// `{ message }` body (forgot-password, verify-otp-reset-password).
  String? get message => data['message'] as String?;
}

/// Authentication endpoints. Uses `package:http` directly because these calls
/// happen before the user has a token, so the Dio bearer-token interceptor
/// would have nothing to attach.
///
/// All methods throw on network errors — callers wrap calls in try/catch and
/// branch on the returned [AuthResponse] for HTTP-level errors.
class AuthService {
  AuthService._();

  static const _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// POST /Auth/login
  static Future<AuthResponse> login({
    required String mobileNumber,
    required String password,
    bool stayLoggedIn = false,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}/Auth/login'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'mobileNumber': mobileNumber,
        'password': password,
        'stayLoggedIn': stayLoggedIn,
      }),
    );
    return _parse(response, '/Auth/login');
  }

  /// POST /Auth/forgot-password — sends an OTP to [mobileNumber] via SMS.
  ///
  /// The backend keys this body `phoneNumber` and always responds `200` with a
  /// generic `{ message }` (it never reveals whether the number is registered),
  /// so callers should treat any HTTP-success as "OTP sent".
  static Future<AuthResponse> forgotPassword({
    required String mobileNumber,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}/Auth/forgot-password'),
      headers: _jsonHeaders,
      body: jsonEncode({'phoneNumber': mobileNumber}),
    );
    return _parse(response, '/Auth/forgot-password');
  }

  /// POST /Auth/verify-otp-reset-password — verifies the SMS OTP and sets the
  /// new password. Returns `200 { message }` on success or `400 { message }`
  /// on failure (wrong/expired OTP, weak password, mismatch).
  static Future<AuthResponse> verifyOtpResetPassword({
    required String mobileNumber,
    required String otpCode,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}/Auth/verify-otp-reset-password'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'phoneNumber': mobileNumber,
        'otpCode': otpCode,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      }),
    );
    return _parse(response, '/Auth/verify-otp-reset-password');
  }

  /// POST /Auth/change-password — directly updates the password for an
  /// authenticated user. Requires the current password and a bearer [authToken].
  static Future<AuthResponse> changePassword({
    required String mobileNumber,
    required String currentPassword,
    required String newPassword,
    required String authToken,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}/Auth/change-password'),
      headers: {
        ..._jsonHeaders,
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'mobileNumber': mobileNumber,
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );
    return _parse(response, '/Auth/change-password');
  }

  /// POST /Auth/verify-otp-login — exchanges an OTP for an auth token.
  static Future<AuthResponse> verifyOtpLogin({
    required String phoneNumber,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}/Auth/verify-otp-login'),
      headers: _jsonHeaders,
      body: jsonEncode({'phoneNumber': phoneNumber, 'otp': otp}),
    );
    return _parse(response, '/Auth/verify-otp-login');
  }

  /// Legacy wrapper. Returns the auth token on success or `null` otherwise.
  /// Prefer [login] for new code — it surfaces status codes and errors.
  static Future<String?> invokeLogin({
    required String mobileNumber,
    required String password,
    bool stayLoggedIn = false,
  }) async {
    try {
      final response = await login(
        mobileNumber: mobileNumber,
        password: password,
        stayLoggedIn: stayLoggedIn,
      );
      return response.success ? response.token : null;
    } catch (e) {
      AppLogger.error('Login API error : $e');
      return null;
    }
  }

  static AuthResponse _parse(http.Response response, String endpoint) {
    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      data = const {};
    }
    AppLogger.apiResponse(response.statusCode, endpoint, data);
    return AuthResponse(statusCode: response.statusCode, data: data);
  }
}
