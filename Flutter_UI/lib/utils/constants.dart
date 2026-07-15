import 'package:flutter/material.dart';
import '../config/environment_config.dart';

class AppConstants {
  // Colors
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  // Dimensions
  static const double defaultPadding = 20.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;

  // Durations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Environment-based API Configuration
  static String get apiBaseUrl => EnvironmentConfig.apiBaseUrl;
  static String get environmentName => EnvironmentConfig.environmentName;
  static bool get isProduction => EnvironmentConfig.isProduction;
  static bool get isDevelopment => EnvironmentConfig.isDevelopment;
  static bool get isStaging => EnvironmentConfig.isStaging;

  // Public web pages for legal policies
  static const String termsAndConditionsUrl =
      'https://pharmaish.com/terms-condition.html';
  static const String privacyPolicyUrl =
      'https://pharmaish.com/privacy-policy.html';
  static const String retailerOnboardingPolicyUrl =
      'https://pharmaish.com/retailer-onboarding-policy.html';
  static const String paymentPolicyUrl =
      'https://pharmaish.com/payment-policy.html';
  static const String retailerGuideUrl =
      'https://pharmaish.com/retailer-guide.html';

  // Customer support contact
  /// Support phone number (10-digit, for display).
  static const String supportPhoneNumber = '9028056076';
  /// Support phone number in E.164 form (with +91), for tel:/WhatsApp links.
  static const String supportPhoneNumberWithCountryCode = '+919028056076';

  // Document URLs
  /// Base URL for policy/legal documents served by the API
  /// (GET /api/PolicyDocuments/download/{fileName}).
  static String get policyDocumentsBaseUrl =>
      '$apiBaseUrl/PolicyDocuments/download';

  /// Builds the download URL for a policy document. [fileName] is the document's
  /// file name including the ".pdf" extension, keeping its original casing, e.g.
  /// "AREA_RETAILER_POLICY.pdf", "Privacy_Policy.pdf".
  static String policyDocumentUrl(String fileName) =>
      '$policyDocumentsBaseUrl/$fileName';

  // Order Configuration
  static const int maxFileSizeMB = 10;
  static const int maxFileSizeBytes = maxFileSizeMB * 1024 * 1024;
  static const int maxVoiceRecordingSeconds = 120; // 2 minutes
  static const int maxTextLength = 5000;
  
  // Supported file types
  static const List<String> supportedImageExtensions = ['jpg', 'jpeg', 'png'];
  static const List<String> supportedDocumentExtensions = ['pdf'];
  static const List<String> supportedAudioExtensions = ['m4a', 'mp4', 'aac', 'wav'];
  
  // Order Type Display Names
  static const Map<String, String> orderTypeDisplayNames = {
    'Upload': 'File Upload',
    'Camera': 'Camera Capture',
    'Voice': 'Voice Recording',
    'WhatsApp': 'WhatsApp Order',
  };
  
  // Delivery options
  static const List<String> deliveryTypes = ['home', 'pickup'];
  static const List<String> urgencyLevels = ['regular', 'express'];
  
  static const String appVersion= "1.0.0";
}
