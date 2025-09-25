// Import the complete registration from the artifact above
// For now, showing aimport 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:medicine_delivery_app/core/app_routes.dart';
import 'package:medicine_delivery_app/core/screens/splash/splash_page.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MedicineDeliveryApp());
}

class MedicineDeliveryApp extends StatelessWidget {
  const MedicineDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicine Delivery',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // Medical green
        ),
      ),
      home: const SplashPage(),
      debugShowCheckedModeBanner: false,
      routes: AppRoutes.routes
    );
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
