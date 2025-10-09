import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../config/environment_config.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

class AppLogger {
  static Logger? _logger;
  static bool _isInitialized = false;

  /// Initialize the logger with environment-specific configuration
  static void initialize() {
    if (_isInitialized) return;

    final level = _getLogLevel();
    final shouldLogToFile =
        EnvironmentConfig.isDevelopment || EnvironmentConfig.isStaging;

    _logger = Logger(
      filter: _AppLogFilter(level),
      printer: _AppLogPrinter(),
      output: shouldLogToFile ? _AppLogOutput() : ConsoleOutput(),
    );

    _isInitialized = true;
  }

  /// Get the appropriate log level based on environment
  static Level _getLogLevel() {
    if (EnvironmentConfig.isProduction) {
      return Level.error; // Only errors in production
    } else if (EnvironmentConfig.isStaging) {
      return Level.warning; // Warnings and above in staging
    } else {
      return Level.debug; // All logs in development
    }
  }

  /// Debug level logging
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.debug, message, error, stackTrace);
  }

  /// Info level logging
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.info, message, error, stackTrace);
  }

  /// Warning level logging
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.warning, message, error, stackTrace);
  }

  /// Error level logging
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
  }

  /// Fatal level logging
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.fatal, message, error, stackTrace);
  }

  /// API request logging
  static void apiRequest(String method, String url,
      [Map<String, dynamic>? data]) {
    final message = 'API Request: $method $url';
    final details = data != null ? '\nData: $data' : '';
    debug('$message$details');
  }

  /// API response logging
  static void apiResponse(int statusCode, String url, [dynamic response]) {
    final message = 'API Response: $statusCode $url';
    final details = response != null ? '\nResponse: $response' : '';
    if (statusCode >= 400) {
      error('$message$details');
    } else {
      debug('$message$details');
    }
  }

  /// User action logging
  static void userAction(String action, [Map<String, dynamic>? context]) {
    final message = 'User Action: $action';
    final details = context != null ? '\nContext: $context' : '';
    info('$message$details');
  }

  /// Authentication logging
  static void auth(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.info, 'AUTH: $message', error, stackTrace);
  }

  /// Navigation logging
  static void navigation(String from, String to) {
    info('Navigation: $from → $to');
  }

  /// Performance logging
  static void performance(String operation, Duration duration) {
    final message = 'Performance: $operation took ${duration.inMilliseconds}ms';
    if (duration.inMilliseconds > 1000) {
      warning(message);
    } else {
      debug(message);
    }
  }

  /// Internal logging method
  static void _log(LogLevel level, String message,
      [dynamic error, StackTrace? stackTrace]) {
    if (!_isInitialized) {
      initialize();
    }

    final levelName = level.name.toUpperCase();
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] [$levelName] $message';

    // Use Flutter's developer log for better debugging
    if (kDebugMode) {
      developer.log(
        logMessage,
        name: 'Pharmaish',
        level: _getFlutterLogLevel(level),
        error: error,
        stackTrace: stackTrace,
      );
    }

    // Use logger for file output and console formatting
    _logger?.log(_getLoggerLevel(level), logMessage,
        error: error, stackTrace: stackTrace);
  }

  /// Convert our log level to Flutter's log level
  static int _getFlutterLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.fatal:
        return 1200;
    }
  }

  /// Convert our log level to Logger's level
  static Level _getLoggerLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Level.debug;
      case LogLevel.info:
        return Level.info;
      case LogLevel.warning:
        return Level.warning;
      case LogLevel.error:
        return Level.error;
      case LogLevel.fatal:
        return Level.error; // Logger doesn't have fatal, use error
    }
  }
}

/// Custom log filter for environment-based filtering
class _AppLogFilter extends LogFilter {
  final Level _level;

  _AppLogFilter(this._level);

  @override
  bool shouldLog(LogEvent event) {
    return event.level.index >= _level.index;
  }
}

/// Custom log printer for better formatting
class _AppLogPrinter extends LogPrinter {
  
  @override
  List<String> log(LogEvent event) {
    final color = _getColor(event.level);
    final emoji = _getEmoji(event.level);
    final level = event.level.name.toUpperCase().padRight(7);

    final formatted = '$color$emoji $level ${event.message}';
    return _chunked(formatted);
  }

  List<String> _chunked(String message) {
    const chunkSize = 800;
    final result = <String>[];
    for (var i = 0; i < message.length; i += chunkSize) {
      result.add(
        message.substring(i, i + chunkSize > message.length ? message.length : i + chunkSize),
      );
    }
    return result;
  }


  String _getColor(Level level) {
    switch (level) {
      case Level.debug:
        return '\x1B[37m'; // White
      case Level.info:
        return '\x1B[34m'; // Blue
      case Level.warning:
        return '\x1B[33m'; // Yellow
      case Level.error:
        return '\x1B[31m'; // Red
      case Level.fatal:
        return '\x1B[35m'; // Magenta
      default:
        return '\x1B[37m'; // White
    }
  }

  String _getEmoji(Level level) {
    switch (level) {
      case Level.debug:
        return '🐛';
      case Level.info:
        return 'ℹ️';
      case Level.warning:
        return '⚠️';
      case Level.error:
        return '❌';
      case Level.fatal:
        return '💀';
      default:
        return '📝';
    }
  }
}

/// Custom log output for file logging (simplified version)
class _AppLogOutput extends LogOutput {
  @override
   void output(OutputEvent event) {
    for (final line in event.lines) {
      _safePrint(line); // direct print, not AppLogger.info
    }
  }

  void _safePrint(String message) {
  const chunkSize = 800;
  for (var i = 0; i < message.length; i += chunkSize) {
    debugPrint(
      message.substring(i, i + chunkSize > message.length ? message.length : i + chunkSize),
    );
  }
}
}


