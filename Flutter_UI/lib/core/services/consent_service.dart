import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pharmaish/core/services/auth_service.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

/// Types of consent that can be tracked
enum ConsentType {
  // Customer consents
  generalDataConsent,
  prescriptionSharingConsent,
  termsAndConditions,

  // Pharmacist/Retailer consents
  retailerRegistrationConsent,
  licenseVerificationConfirmation,
  dataHandlingLiabilityDisclaimer,
  prescriptionAccessPermission,

  // Additional consents
  marketingConsent,
  notificationConsent,
}

/// Consent log entry
class ConsentLog {
  final String userId;
  final ConsentType consentType;
  final bool granted;
  final DateTime timestamp;
  final String? deviceId;
  final String? ipAddress;
  final Map<String, dynamic>? metadata;

  ConsentLog({
    required this.userId,
    required this.consentType,
    required this.granted,
    required this.timestamp,
    this.deviceId,
    this.ipAddress,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'consentType': consentType.toString().split('.').last,
      'granted': granted,
      'timestamp': timestamp.toIso8601String(),
      'deviceId': deviceId,
      'ipAddress': ipAddress,
      'metadata': metadata,
    };
  }
}

class ConsentService {
  static final Dio _dio = Dio();
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Initialize Dio with base URL
  static Future<void> initialize() async {
    _dio.options.baseUrl = AppConstants.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    // Add auth token if available
    final token = await StorageService.getAuthToken();
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  /// Accept consent via API
static Future<bool> acceptConsent({
  required String consentId,
  Map<String, dynamic>? metadata,
}) async {
  try {
    await initialize();
    
    // Get device info to send to backend
    final deviceData = await _getDeviceInfo();
    
    // Backend expects AcceptRejectConsentDto with DeviceInfo property
    final response = await _dio.post(
      '/Consents/$consentId/accept',
      data: {
        'deviceInfo': '${deviceData['deviceModel']} - ${deviceData['osVersion']}',
      },
    );
    
    AppLogger.info('Accept consent response: ${response.statusCode}');
    return response.statusCode == 200;
  } catch (e, stackTrace) {
    AppLogger.error('Error accepting consent', e, stackTrace);
    return false;
  }
}

/// Reject consent via API
static Future<bool> rejectConsent({
  required String consentId,
  Map<String, dynamic>? metadata,
  String? reason,
}) async {
  try {
    await initialize();
    
    final deviceData = await _getDeviceInfo();
    
    final response = await _dio.post(
      '/Consents/$consentId/reject',
      data: {
        'deviceInfo': '${deviceData['deviceModel']} - ${deviceData['osVersion']}',
      },
    );
    
    AppLogger.info('Reject consent response: ${response.statusCode}');
    return response.statusCode == 200;
  } catch (e, stackTrace) {
    AppLogger.error('Error rejecting consent', e, stackTrace);
    return false;
  }
}

  /// Log consent to backend
  static Future<bool> logConsent({
    required ConsentType consentType,
    required bool granted,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Initialize if not done
      await initialize();

      // Get device info
      final deviceData = await _getDeviceInfo();

      // Get retailer/user ID from storage
      final userId = await StorageService.getUserId();

      // Prepare request payload
      final payload = {
        'retailerId': userId ?? 'unknown', // Use retailerId for pharmacist
        'consentType': _mapConsentTypeToBackend(consentType),
        'accepted': granted,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'deviceId': deviceData['deviceId'],
        'deviceModel': deviceData['deviceModel'],
        'osVersion': deviceData['osVersion'],
        'appVersion': AppConstants.appVersion,
        'metadata': metadata ?? {},
      };

      AppLogger.info('Logging consent: ${payload['consentType']}');

      // POST to backend
      final response = await _dio.post(
        '/api/consent/retailer/log',
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.info('Consent logged successfully');
        return true;
      } else {
        AppLogger.error('Failed to log consent: ${response.statusCode}');
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error logging consent', e, stackTrace);
      // Store locally as fallback
      await _storeConsentLocally(consentType, granted, metadata);
      return false;
    }
  }

  /// Get device information
  /// Get device information
static Future<Map<String, dynamic>> _getDeviceInfo() async {
  final deviceData = <String, dynamic>{};

  try {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      deviceData['deviceId'] = androidInfo.id;
      deviceData['deviceModel'] = '${androidInfo.manufacturer} ${androidInfo.model}';
      deviceData['osVersion'] = 'Android ${androidInfo.version.release}';
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      deviceData['deviceId'] = iosInfo.identifierForVendor ?? 'unknown';
      deviceData['deviceModel'] = '${iosInfo.name} ${iosInfo.model}';
      deviceData['osVersion'] = 'iOS ${iosInfo.systemVersion}';
    } else {
      deviceData['deviceId'] = 'web-unknown';
      deviceData['deviceModel'] = 'Web Browser';
      deviceData['osVersion'] = 'Web';
    }
  } catch (e) {
    AppLogger.warning('Could not get device info: $e');
    deviceData['deviceId'] = 'unknown';
    deviceData['deviceModel'] = 'unknown';
    deviceData['osVersion'] = 'unknown';
  }

  return deviceData;
}
/// Get consent ID by type - searches by title from backend
// This version has extensive logging to show exactly what's happening

static Future<String?> getConsentIdByType(ConsentType consentType) async {
  try {
    // Step 1: Initialize
    AppLogger.info('=== Starting getConsentIdByType ===');
    AppLogger.info('ConsentType: $consentType');
    
    await initialize();
    AppLogger.info('✓ Dio initialized');
    AppLogger.info('Base URL: ${_dio.options.baseUrl}');
    
    // Check auth token
    var token = await StorageService.getAuthToken();
    if (token != null) {
      final previewLength = token.length > 20 ? 20 : token.length;
      AppLogger.info('✓ Auth token present: ${token.substring(0, previewLength)}...');
    } else {
      AppLogger.warning('⚠ No auth token found!');
    }
    
    // Step 2: Make API call
    AppLogger.info('Calling: ${_dio.options.baseUrl}/Consents/active');
    final response = await _dio.get('/Consents/active');
    
    AppLogger.info('✓ Response received');
    AppLogger.info('Status code: ${response.statusCode}');
    AppLogger.info('Response type: ${response.data.runtimeType}');
    
    // Step 3: Check response
    if (response.statusCode == 200) {
      if (response.data is! List) {
        AppLogger.error('✗ Response is not a List! It is: ${response.data.runtimeType}');
        AppLogger.error('Response data: ${response.data}');
        return null;
      }
      
      final List<dynamic> consents = response.data;
      AppLogger.info('✓ Received ${consents.length} consents');
      
      // Step 4: Map the consent type
      final expectedTitle = _mapConsentTypeToTitle(consentType);
      AppLogger.info('Looking for title: "$expectedTitle"');
      
      // Step 5: Log all available consents
      AppLogger.info('--- Available Consents ---');
      for (int i = 0; i < consents.length; i++) {
        final consent = consents[i];
        final title = consent['title']?.toString() ?? 'NULL';
        final id = consent['consentId']?.toString() ?? 'NULL';
        AppLogger.info('[$i] Title: "$title" | ID: $id');
      }
      AppLogger.info('--- End of List ---');
      
      // Step 6: Search for matching consent
      for (var consent in consents) {
        final consentTitle = consent['title']?.toString() ?? '';
        
        AppLogger.info('Comparing:');
        AppLogger.info('  Expected: "${expectedTitle.toLowerCase().trim()}"');
        AppLogger.info('  Got:      "${consentTitle.toLowerCase().trim()}"');
        
        if (consentTitle.toLowerCase().trim() == expectedTitle.toLowerCase().trim()) {
          AppLogger.info('✓✓✓ MATCH FOUND! ✓✓✓');
          AppLogger.info('Consent ID: ${consent['consentId']}');
          return consent['consentId']?.toString();
        } else {
          AppLogger.info('  ✗ No match');
        }
      }
      
      // Step 7: Not found
      AppLogger.warning('=== NO CONSENT FOUND ===');
      AppLogger.warning('Expected title: "$expectedTitle"');
      AppLogger.warning('Available titles:');
      for (var c in consents) {
        AppLogger.warning('  - "${c['title']}"');
      }
      return null;
      
    } else {
      AppLogger.error('✗ Bad status code: ${response.statusCode}');
      AppLogger.error('Response: ${response.data}');
      return null;
    }
    
  } on DioException catch (e) {
    AppLogger.error('=== DIO EXCEPTION ===');
    AppLogger.error('Type: ${e.type}');
    AppLogger.error('Message: ${e.message}');
    
    if (e.response != null) {
      AppLogger.error('Response status: ${e.response?.statusCode}');
      AppLogger.error('Response data: ${e.response?.data}');
      AppLogger.error('Response headers: ${e.response?.headers}');
      
      if (e.response?.statusCode == 401) {
        AppLogger.error('⚠ UNAUTHORIZED - Token is missing or invalid');
      } else if (e.response?.statusCode == 403) {
        AppLogger.error('⚠ FORBIDDEN - User lacks RequireReadConsentsPermission');
      } else if (e.response?.statusCode == 404) {
        AppLogger.error('⚠ NOT FOUND - Check endpoint URL');
      }
    } else {
      AppLogger.error('No response received');
      AppLogger.error('Error: ${e.error}');
      
      if (e.type == DioExceptionType.connectionTimeout) {
        AppLogger.error('⚠ CONNECTION TIMEOUT');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        AppLogger.error('⚠ RECEIVE TIMEOUT');
      } else if (e.type == DioExceptionType.connectionError) {
        AppLogger.error('⚠ CONNECTION ERROR - Can\'t reach server');
      } else if (e.type == DioExceptionType.badCertificate) {
        AppLogger.error('⚠ SSL CERTIFICATE ERROR');
      }
    }
    
    return null;
    
  } catch (e, stackTrace) {
    AppLogger.error('=== UNEXPECTED ERROR ===');
    AppLogger.error('Error: $e');
    AppLogger.error('Stack trace: $stackTrace');
    return null;
  }
}


/// Map ConsentType enum to the exact title stored in the backend database
/// IMPORTANT: These titles must match EXACTLY what you have in your Consent table
static String _mapConsentTypeToTitle(ConsentType type) {
  switch (type) {
    case ConsentType.termsAndConditions:
      return 'Accept Terms & Conditions';
    
    case ConsentType.retailerRegistrationConsent:
      return 'Retailer Registration Consent';
    
    case ConsentType.licenseVerificationConfirmation:
      return 'License Verification Confirmation';
    
    case ConsentType.dataHandlingLiabilityDisclaimer:
      return 'Data Handling & Liability Disclaimer';
    
    case ConsentType.prescriptionAccessPermission:
      return 'Prescription Access Permission';
    
    case ConsentType.generalDataConsent:
      return 'General Data Consent';
    
    case ConsentType.prescriptionSharingConsent:
      return 'Prescription Sharing Consent';
    
    default:
      return type.toString().split('.').last;
  }
}
  /// Map ConsentType enum to backend string
  static String _mapConsentTypeToBackend(ConsentType type) {
    switch (type) {
      case ConsentType.retailerRegistrationConsent:
        return 'REGISTRATION_CONSENT';
      case ConsentType.licenseVerificationConfirmation:
        return 'LICENSE_VERIFICATION';
      case ConsentType.dataHandlingLiabilityDisclaimer:
        return 'DATA_HANDLING_LIABILITY';
      case ConsentType.prescriptionAccessPermission:
        return 'PRESCRIPTION_ACCESS';
      case ConsentType.generalDataConsent:
        return 'GENERAL_DATA_CONSENT';
      case ConsentType.prescriptionSharingConsent:
        return 'PRESCRIPTION_SHARING_CONSENT';
      case ConsentType.termsAndConditions:
        return 'Terms And Conditions1';
      default:
        return type.toString();
    }
  }

  /// Store consent locally as fallback
  static Future<void> _storeConsentLocally(
    ConsentType consentType,
    bool granted,
    Map<String, dynamic>? metadata,
  ) async {
    try {
      // Store in local storage for retry later
      final key = 'pending_consent_${DateTime.now().millisecondsSinceEpoch}';
      await StorageService.store(
          key,
          jsonEncode({
            'consentType': _mapConsentTypeToBackend(consentType),
            'granted': granted,
            'timestamp': DateTime.now().toIso8601String(),
            'metadata': metadata,
          }));

      AppLogger.info('Consent stored locally for retry');
    } catch (e) {
      AppLogger.error('Failed to store consent locally: $e');
    }
  }

  /// Check if consent has been given (calls backend)
  static Future<bool> hasConsent(ConsentType consentType) async {
    try {
      await initialize();

      final userId = await StorageService.getUserId();
      final response = await _dio.get(
        '/api/consent/retailer/check',
        queryParameters: {
          'retailerId': userId,
          'consentType': _mapConsentTypeToBackend(consentType),
        },
      );

      if (response.statusCode == 200) {
        return response.data['hasConsent'] ?? false;
      }
      return false;
    } catch (e) {
      AppLogger.error('Error checking consent: $e');
      return false;
    }
  }
}
