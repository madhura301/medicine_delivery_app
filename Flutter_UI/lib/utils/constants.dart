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

  // Admin Credentials for Testing
  static const String adminMobileNumber = '9999999999';
  static const String adminPassword = 'Admin@123';

  // Document URLs
  static const String documentsProdBaseUrl = "http://188.241.187.172/MediMartAPIProd/documents";
}
