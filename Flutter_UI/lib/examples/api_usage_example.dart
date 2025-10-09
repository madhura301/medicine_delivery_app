import 'package:pharmaish/utils/app_logger.dart';
import 'package:dio/dio.dart';
import '../config/environment_config.dart';
import '../utils/constants.dart';

class ApiService {
  late Dio _dio;

  ApiService() {
    _dio = Dio();
    _setupDio();
  }

  void _setupDio() {
    // Set base URL based on environment
    _dio.options.baseUrl = AppConstants.apiBaseUrl;

    // Set timeout based on environment
    _dio.options.connectTimeout = EnvironmentConfig.timeoutDuration;
    _dio.options.receiveTimeout = EnvironmentConfig.timeoutDuration;

    // Add logging interceptor for development/staging
    if (EnvironmentConfig.shouldLog) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => AppLogger.info('API: $object'),
      ));
    }

    // Add error handling interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        if (EnvironmentConfig.shouldLog) {
          AppLogger.error('API Error: ${error.message}');
        }
        handler.next(error);
      },
    ));
  }

  // Example API call
  Future<Response> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return response;
    } catch (e) {
      if (EnvironmentConfig.shouldLog) {
        AppLogger.error('Login failed: $e');
      }
      rethrow;
    }
  }

  // Example with environment-specific headers
  Future<Response> getProfile() async {
    final headers = <String, dynamic>{};

    // Add environment-specific headers
    if (EnvironmentConfig.isProduction) {
      headers['X-API-Key'] = 'prod-api-key';
    } else if (EnvironmentConfig.isStaging) {
      headers['X-API-Key'] = 'staging-api-key';
    } else {
      headers['X-API-Key'] = 'dev-api-key';
    }

    return await _dio.get('/profile', options: Options(headers: headers));
  }
}

// Usage example
void exampleUsage() {
  // Check current environment
  AppLogger.info('Current environment: ${AppConstants.environmentName}');
  AppLogger.info('API Base URL: ${AppConstants.apiBaseUrl}');

  // Environment-specific logic
  if (AppConstants.isProduction) {
    AppLogger.info('Running in production mode');
  } else if (AppConstants.isDevelopment) {
    AppLogger.info('Running in development mode');
  } else if (AppConstants.isStaging) {
    AppLogger.info('Running in staging mode');
  }

  // Create API service
  //final apiService = ApiService();

  // Use the service
  // apiService.login('user@example.com', 'password');
}
