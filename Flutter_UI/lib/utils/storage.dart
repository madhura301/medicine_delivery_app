import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert' show base64Url, json, utf8;
import 'app_logger.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  // Keys for different storage items
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _savedUsernameKey = 'saved_username';
  static const String _savedPasswordKey = 'saved_password';
  static const String _rememberPasswordKey = 'remember_password';
  static const String _userEmailKey = 'user_email';
  static const String _userMobileNumberKey  = 'user_mobile_number';
  static const String _userFirstNameKey = 'user_first_name';
  static const String _userLastNameKey = 'user_last_name';
  static const String _userIdKey = 'user_id';
  //static const String _userRoleKey = 'user_role';

  // Authentication Token Methods

  /// Store authentication tokens securely
  static Future<void> storeAuthTokens({
    required String token,
    String? refreshToken,
  }) async {
    try {
      await _storage.write(key: _authTokenKey, value: token);

      if (refreshToken != null) {
        await _storage.write(key: _refreshTokenKey, value: refreshToken);
      }

      AppLogger.info('Authentication tokens stored successfully');
    } catch (e) {
      AppLogger.error('Error storing authentication tokens', e);
      rethrow;
    }
  }

  /// Retrieve the stored authentication token
  static Future<String?> getAuthToken() async {
    try {
      return await _storage.read(key: _authTokenKey);
    } catch (e) {
      AppLogger.error('Error retrieving authentication token', e);
      return null;
    }
  }

  /// Retrieve the stored refresh token
  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      AppLogger.error('Error retrieving refresh token', e);
      return null;
    }
  }

  /// Clear authentication tokens
  static Future<void> clearAuthTokens() async {
    try {
      await _storage.delete(key: _authTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      AppLogger.info('Authentication tokens cleared successfully');
    } catch (e) {
      AppLogger.error('Error clearing authentication tokens', e);
      rethrow;
    }
  }

  // User Credentials Methods

  /// Load saved user credentials
  static Future<Map<String, dynamic>> loadSavedCredentials() async {
    try {
      final savedUserName = await _storage.read(key: _savedUsernameKey) ?? '';
      final savedPassword = await _storage.read(key: _savedPasswordKey) ?? '';
      final rememberPassword =
          await _storage.read(key: _rememberPasswordKey) ?? 'false';

      return {
        'username': savedUserName,
        'password': savedPassword,
        'rememberPassword': rememberPassword == 'true',
      };
    } catch (e) {
      AppLogger.error('Error loading saved credentials', e);
      return {
        'username': '',
        'password': '',
        'rememberPassword': false,
      };
    }
  }

  /// Save user credentials based on remember password preference
  static Future<void> saveCredentials({
    required String username,
    required String password,
    required bool rememberPassword,
  }) async {
    try {
      if (rememberPassword) {
        await _storage.write(key: _savedUsernameKey, value: username);
        await _storage.write(key: _savedPasswordKey, value: password);
        await _storage.write(key: _rememberPasswordKey, value: 'true');
      } else {
        // Clear saved credentials if checkbox is unchecked
        await _storage.delete(key: _savedUsernameKey);
        await _storage.delete(key: _savedPasswordKey);
        await _storage.write(key: _rememberPasswordKey, value: 'false');
      }
      AppLogger.info('Credentials saved/cleared successfully');
    } catch (e) {
      AppLogger.error('Error saving credentials', e);
      rethrow;
    }
  }

  /// Clear all saved credentials
  static Future<void> clearSavedCredentials() async {
    try {
      await _storage.delete(key: _savedUsernameKey);
      await _storage.delete(key: _savedPasswordKey);
      await _storage.delete(key: _rememberPasswordKey);
      AppLogger.info('Saved credentials cleared successfully');
    } catch (e) {
      AppLogger.error('Error clearing saved credentials', e);
      rethrow;
    }
  }

  // JWT Token Utility Methods

  /// Decode JWT token and extract user information
  static Map<String, dynamic> decodeJwtToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid JWT token format');
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decodedBytes = base64Url.decode(normalized);
      final jsonString = utf8.decode(decodedBytes);
      final payloadMap = json.decode(jsonString);

      return payloadMap;
    } catch (e) {
      AppLogger.error('Error decoding JWT token', e);
      return {};
    }
  }

  /// Extract user role from JWT token claims
  static String extractUserRole(Map<String, dynamic> userInfo) {
    // Extract role from various possible claim keys
    final role = userInfo['role'] ??
        userInfo[
            'http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ??
        '';

    final email = userInfo['email'] ??
        userInfo[
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'] ??
        '';

    final firstName = userInfo['firstName'] ?? '';
    final lastName = userInfo['lastName'] ?? '';
    final mobileNumber = userInfo['mobileNumber'] ??
        userInfo[
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'] ??
        '';
    final id = userInfo['UserId'] ??
              userInfo['id'] ??
              userInfo['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ??
              '';

    AppLogger.info(
        'User Info: Role: $role, Email: $email, Name: $firstName $lastName, Mobile: $mobileNumber, ID: $id');

    // Determine role based on role claim
    final roleString = role.toString().toLowerCase();

    if (roleString.contains('admin')) {
      return 'Admin';
    } else if (roleString.contains('chemist')) {
      return 'Chemist';
    } else if (roleString.contains('customersupport')) {
      return 'CustomerSupport';
    } else if (roleString.contains('manager')) {
      return 'Manager';
    } else if (roleString.contains('customer')) {
      return 'Customer';
    } else {
      return 'Customer'; // Default role
    }
  }

  /// Store user information securely
  static Future<void> storeUserInfo(Map<String, String> userInfo) async {
    try {
      AppLogger.info('Storing user information: $userInfo');
      var userId = userInfo['UserId'] ??
              userInfo['id'] ??
              userInfo['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ??
              '';
      await _storage.write(key: _userEmailKey, value: userInfo['email']);
      await _storage.write(
        key: _userMobileNumberKey, value: userInfo['mobileNumber']);
      await _storage.write(
          key: _userFirstNameKey, value: userInfo['firstName']);
      await _storage.write(key: _userLastNameKey, value: userInfo['lastName']);
      await _storage.write(key: _userIdKey, value: userId);
      //await _storage.write(key: _userRoleKey, value: userInfo['role']);
    } catch (e) {
      AppLogger.error('Error storing user information: $e');
      rethrow;
    }
  }

  /// Extract user information from JWT token
  static Map<String, String> extractUserInfo(Map<String, dynamic> tokenData) {
    return {
       'id': tokenData['UserId'] ?? 
        tokenData['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ??
        tokenData['id'] ??
        tokenData['sub'] ??
        '', 
      'email': tokenData['email'] ??
          tokenData[
              'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'] ??
          '',
      'firstName': tokenData['firstName'] ?? '',
      'lastName': tokenData['lastName'] ?? '',
      'mobileNumber': tokenData['mobileNumber'] ?? 
      tokenData['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'] ?? '',
      'role': extractUserRole(tokenData)
    };
  }

  /// Store the logged-in user's ID
  static Future<void> storeUserId(String userId) async {
    try {
      await _storage.write(key: _userIdKey, value: userId);
      AppLogger.info('User ID stored successfully');
    } catch (e) {
      AppLogger.error('Error storing user ID: $e');
      rethrow;
    }
  }

  /// Retrieve the stored user ID
  static Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      AppLogger.error('Error retrieving user ID: $e');
      return null;
    }
  }

  static Future<String?> getUserName() async {
    try {
      return await _storage.read(key: _userFirstNameKey);
    } catch (e) {
      AppLogger.error('Error retrieving user first name: $e');
      return null;
    }
  }

  static Future<String?> getUserMobileNumber() async {
    try {
      return await _storage.read(key: _userMobileNumberKey);
    } catch (e) {
      AppLogger.error('Error retrieving user mobile number: $e');
      return null;
    }
  }

  static Future<String?> getUserEmail() async {
    try {
      return await _storage.read(key: _userEmailKey);
    } catch (e) {
      AppLogger.error('Error retrieving user email: $e');
      return null;
    }
  }
  // General Storage Methods

  /// Store a key-value pair securely
  static Future<void> store(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      AppLogger.error('Error storing data for key $key: $e');
      rethrow;
    }
  }

  /// Retrieve a value by key
  static Future<String?> retrieve(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      AppLogger.error('Error retrieving data for key $key: $e');
      return null;
    }
  }

  /// Delete a value by key
  static Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      AppLogger.error('Error deleting data for key $key: $e');
      rethrow;
    }
  }

  /// Clear all stored data
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      AppLogger.info('All stored data cleared successfully');
    } catch (e) {
      AppLogger.error('Error clearing all stored data: $e');
      rethrow;
    }
  }

  /// Check if a key exists in storage
  static Future<bool> containsKey(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      AppLogger.error('Error checking key existence for $key: $e');
      return false;
    }
  }

  /// Get all keys from storage
  static Future<Map<String, String>> getAllData() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      AppLogger.error('Error retrieving all data: $e');
      return {};
    }
  }
}
