import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pharmaish/config/environment_config.dart';
import 'package:pharmaish/core/app_routes.dart';
import 'package:pharmaish/core/screens/splash/splash_page.dart';
import 'package:pharmaish/core/theme/app_theme.dart';
import 'package:pharmaish/utils/app_logger.dart';

void main() {
  AppLogger.initialize();
  AppLogger.info('Application starting - STAGING');

  HttpOverrides.global = MyHttpOverrides();
  EnvironmentConfig.setEnvironment(Environment.staging);
  runApp(const PharmaishApp());
}

class PharmaishApp extends StatelessWidget {
  const PharmaishApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Pharmaish - Staging',
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

//To build apk -

// # For staging
//flutter build apk --release --analyze-size --target-platform=android-arm64 -t lib/main_staging.dart

// # For production
//flutter build apk --release --analyze-size --target-platform=android-arm64 -t lib/main.dart