import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pharmaish/config/environment_config.dart';
import 'package:pharmaish/core/app_routes.dart';
import 'package:pharmaish/core/screens/splash/splash_page.dart';
import 'package:pharmaish/core/theme/app_theme.dart';
import 'package:pharmaish/utils/app_logger.dart';

void main() {
  // Initialize logging framework
  AppLogger.initialize();
  AppLogger.info('Application starting - PRODUCTION');

  //HttpOverrides.global = MyHttpOverrides();

  // Production entrypoint: hits _prodApiBaseUrl over HTTPS with the platform's
  // default certificate validation. Never install an HttpOverrides that accepts
  // bad certificates here - Google Play rejects it under the Unsafe SSL policy.
  EnvironmentConfig.setEnvironment(Environment.production);
  runApp(const PharmaishApp());
}

class PharmaishApp extends StatelessWidget {
  const PharmaishApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Pharmaish',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppTheme.primaryColor,
          ),
        ),
        home: const SplashPage(),
        debugShowCheckedModeBanner: false,
        routes: AppRoutes.routes);
  }
}


class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

// To build for release:
//
// # Play Store upload (App Bundle, production API)
// flutter build appbundle --release -t lib/main.dart
//
// # Side-loadable APK for device testing (production API)
// flutter build apk --release -t lib/main.dart
//
// # Staging
// flutter build apk --release -t lib/main_staging.dart
