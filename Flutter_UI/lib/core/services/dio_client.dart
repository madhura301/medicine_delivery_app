import 'package:dio/dio.dart';
import 'package:pharmaish/config/environment_config.dart';
import 'package:pharmaish/core/services/session_service.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';

/// Shared Dio instance for all authenticated API calls.
///
/// Configures base URL, timeouts, attaches the auth token from
/// [StorageService] on every request, and logs requests/errors when
/// [EnvironmentConfig.shouldLog] is true.
///
/// A 401 on an authenticated request renews the session once via
/// [SessionService] and retries the request. If the session can't be renewed
/// the user is sent to login with an explanation, and the 401 is still passed
/// on to the caller.
class DioClient {
  DioClient._();

  static final Dio instance = _build();

  /// Marks a request that has already been retried after a 401.
  static const _retriedKey = 'authRetried';

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
      onError: (error, handler) async {
        if (EnvironmentConfig.shouldLog) {
          AppLogger.error('API Error: ${error.message}');
          AppLogger.error('Status Code: ${error.response?.statusCode}');
          AppLogger.error('Response Data: ${error.response?.data}');
        }

        final options = error.requestOptions;
        final isAuthFailure = error.response?.statusCode == 401 &&
            options.headers.containsKey('Authorization') &&
            options.extra[_retriedKey] != true;
        if (!isAuthFailure) {
          handler.next(error);
          return;
        }

        switch (await SessionService.renewSession()) {
          case SessionRenewal.renewed:
            try {
              options.extra[_retriedKey] = true;
              // onRequest attaches the new token on the retry.
              handler.resolve(await dio.fetch(options));
            } on DioException catch (retryError) {
              handler.next(retryError);
            }
          case SessionRenewal.notPossible:
            await SessionService.endSession();
            handler.next(error);
          case SessionRenewal.failed:
            handler.next(error);
        }
      },
    ));

    return dio;
  }
}
