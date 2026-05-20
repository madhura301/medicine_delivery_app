import 'package:dio/dio.dart';
import 'package:pharmaish/config/environment_config.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';

/// Shared Dio instance for all authenticated API calls.
///
/// Configures base URL, timeouts, attaches the auth token from
/// [StorageService] on every request, and logs requests/errors when
/// [EnvironmentConfig.shouldLog] is true.
class DioClient {
  DioClient._();

  static final Dio instance = _build();

  static Dio _build() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: EnvironmentConfig.timeoutDuration,
        receiveTimeout: EnvironmentConfig.timeoutDuration,
      ),
    );

    if (EnvironmentConfig.shouldLog) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        logPrint: (object) => AppLogger.info('API: $object'),
      ));
    }

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (EnvironmentConfig.shouldLog) {
          AppLogger.error('API Error: ${error.message}');
          AppLogger.error('Status Code: ${error.response?.statusCode}');
          AppLogger.error('Response Data: ${error.response?.data}');
        }
        handler.next(error);
      },
    ));

    return dio;
  }
}
