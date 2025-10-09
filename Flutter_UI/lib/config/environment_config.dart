import 'package:flutter/foundation.dart';

enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  // Current environment - can be overridden
  static Environment _currentEnvironment = Environment.development;

  // API Base URLs
  //static const String _devApiBaseUrl = "https://localhost:7000/api";
  static const String _devApiBaseUrl = "https://10.0.2.2:7000/api";
  static const String _stagingApiBaseUrl =
      "https://staging-api.pharmaish.com/api";
  static const String _prodApiBaseUrl = "http://188.241.187.172/MediMartAPI1/api";

  // Timeout configurations
  static const Duration _devTimeout = Duration(seconds: 30);
  static const Duration _stagingTimeout = Duration(seconds: 20);
  static const Duration _prodTimeout = Duration(seconds: 15);

  // Logging configurations
  static const bool _devLogging = true;
  static const bool _stagingLogging = true;
  static const bool _prodLogging = false;

  // Get current environment
  static Environment get currentEnvironment {
    if (kDebugMode) {
      return Environment.development;
    } else if (kProfileMode) {
      return Environment.staging;
    } else {
      return Environment.production;
    }
  }

  // Set environment manually (useful for testing)
  static void setEnvironment(Environment environment) {
    _currentEnvironment = environment;
  }

  // Get API base URL based on current environment
  static String get apiBaseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return _devApiBaseUrl;
      case Environment.staging:
        return _stagingApiBaseUrl;
      case Environment.production:
        return _prodApiBaseUrl;
    }
  }

  // Get timeout duration based on environment
  static Duration get timeoutDuration {
    switch (_currentEnvironment) {
      case Environment.development:
        return _devTimeout;
      case Environment.staging:
        return _stagingTimeout;
      case Environment.production:
        return _prodTimeout;
    }
  }

  // Get logging configuration
  static bool get shouldLog {
    switch (_currentEnvironment) {
      case Environment.development:
        return _devLogging;
      case Environment.staging:
        return _stagingLogging;
      case Environment.production:
        return _prodLogging;
    }
  }

  // Environment name for display
  static String get environmentName {
    switch (_currentEnvironment) {
      case Environment.development:
        return "Development";
      case Environment.staging:
        return "Staging";
      case Environment.production:
        return "Production";
    }
  }

  // Check if current environment is production
  static bool get isProduction => _currentEnvironment == Environment.production;

  // Check if current environment is development
  static bool get isDevelopment =>
      _currentEnvironment == Environment.development;

  // Check if current environment is staging
  static bool get isStaging => _currentEnvironment == Environment.staging;
}
