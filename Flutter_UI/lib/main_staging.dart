import 'package:flutter/material.dart';
import 'package:pharmaish/config/environment_config.dart';
import 'package:pharmaish/core/app_routes.dart';
import 'package:pharmaish/core/screens/splash/splash_page.dart';
import 'package:pharmaish/core/theme/app_theme.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/media_pickers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.initialize();
  AppLogger.info('Application starting - STAGING');

  // Gallery selection must go through the Android System Photo Picker: the app
  // declares no READ_MEDIA_* permissions (Google Play policy).
  configureSystemPhotoPicker();

  // No HttpOverrides: the staging API is served over HTTPS with a valid
  // certificate, so the platform's default validation is used here exactly as
  // in main.dart. Never reinstate a badCertificateCallback that returns true —
  // it disables TLS validation for every request in the app.
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

//To build apk -

// # For staging
//flutter build apk --release --analyze-size --target-platform=android-arm64 -t lib/main_staging.dart

// # For production
//flutter build apk --release --analyze-size --target-platform=android-arm64 -t lib/main.dart