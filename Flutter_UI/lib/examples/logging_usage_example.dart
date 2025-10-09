// Example of how to use the AppLogger framework

import 'package:flutter/material.dart';
import 'package:pharmaish/utils/helpers.dart';
import '../utils/app_logger.dart';

class LoggingUsageExample extends StatefulWidget {
  const LoggingUsageExample({super.key});

  @override
  State<LoggingUsageExample> createState() => _LoggingUsageExampleState();
}

class _LoggingUsageExampleState extends State<LoggingUsageExample> {
  @override
  void initState() {
    super.initState();
    //AppHelpers.disableScreenshots();

    // Initialize the logger
    AppLogger.initialize();

    // Example usage
    _demonstrateLogging();
  }

  void _demonstrateLogging() {
    // Basic logging levels
    AppLogger.debug('This is a debug message');
    AppLogger.info('Application started successfully');
    AppLogger.warning('This is a warning message');
    AppLogger.error('This is an error message');
    AppLogger.fatal('This is a fatal error message');

    // Specialized logging methods
    AppLogger.apiRequest(
        'POST', '/api/auth/login', {'username': 'user@example.com'});
    AppLogger.apiResponse(200, '/api/auth/login', {'token': 'abc123'});
    AppLogger.userAction('login', {'method': 'email'});
    AppLogger.auth('User authentication successful');
    AppLogger.navigation('LoginPage', 'DashboardPage');
    AppLogger.performance('Database Query', const Duration(milliseconds: 150));

    // Logging with error and stack trace
    try {
      throw Exception('Something went wrong');
    } catch (e, stackTrace) {
      AppLogger.error('An error occurred', e, stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logging Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Check the console for log messages'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _demonstrateLogging,
              child: const Text('Generate More Logs'),
            ),
          ],
        ),
      ),
    );
  }
}

// Example of how to use logging in different scenarios:

class ApiService {
  Future<void> makeApiCall() async {
    AppLogger.apiRequest('GET', '/api/users');

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      AppLogger.apiResponse(200, '/api/users', {'users': []});
    } catch (e, stackTrace) {
      AppLogger.error('API call failed', e, stackTrace);
    }
  }
}

class UserService {
  Future<void> loginUser(String email) async {
    AppLogger.auth('Attempting user login');
    AppLogger.userAction('login_attempt', {'email': email});

    try {
      // Simulate login
      await Future.delayed(const Duration(milliseconds: 500));

      AppLogger.auth('User login successful');
      AppLogger.userAction('login_success', {'email': email});
    } catch (e, stackTrace) {
      AppLogger.error('Login failed', e, stackTrace);
      AppLogger.userAction(
          'login_failed', {'email': email, 'error': e.toString()});
    }
  }
}

class NavigationService {
  void navigateTo(String from, String to) {
    AppLogger.navigation(from, to);
  }
}

class PerformanceService {
  Future<void> performOperation() async {
    final stopwatch = Stopwatch()..start();

    try {
      // Simulate some work
      await Future.delayed(const Duration(milliseconds: 200));
    } finally {
      stopwatch.stop();
      AppLogger.performance('Database Operation', stopwatch.elapsed);
    }
  }
}

// Environment-based logging examples:
/*
Development Environment:
- All log levels are shown
- Logs are written to console
- Detailed error information

Staging Environment:
- Warning level and above
- Logs are written to console and file
- Moderate error information

Production Environment:
- Error level only
- Logs are written to file
- Minimal error information
*/
