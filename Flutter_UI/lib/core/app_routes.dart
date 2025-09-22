import 'package:flutter/material.dart';
import 'package:medicine_delivery_app/core/dashboards/admin_dashboard.dart';
import 'package:medicine_delivery_app/core/dashboards/chemist_dashboard.dart';
import 'package:medicine_delivery_app/core/dashboards/customer_dashboard.dart';
import 'package:medicine_delivery_app/core/dashboards/manager_dashboard.dart';
import 'package:medicine_delivery_app/core/dashboards/support_dashboard.dart';
import 'package:medicine_delivery_app/core/screens/profiles/chemist_profile_page.dart';
import 'package:medicine_delivery_app/core/screens/profiles/customer_profile_page.dart';
import 'package:medicine_delivery_app/core/screens/profiles/pharmacist_profile_page.dart';
import 'package:medicine_delivery_app/core/screens/auth/register_customer_page.dart';
import 'package:medicine_delivery_app/core/screens/auth/register_pharmacist_page.dart';

import 'screens/auth/login_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String registerCustomer = '/registerCustomer';
  static const String registerPharmacist = '/registerPharmacist';
  static const String pharmacistProfile = '/pharmacistProfile';
  static const String chemistProfile = '/chemistProfile';
  static const String customerProfile = '/customerProfile';
  static const String customerDashboard = '/customerDashboard';
  static const String adminDashboard = '/adminDashboard';
  static const String chemistDashboard = '/chemistDashboard';
  static const String managerDashboard = '/managerDashboard';
  static const String customerSupportDashboard = '/customerSupportDashboard';


  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginPage(),
    registerCustomer: (context) => const CustomerRegisterPage(),
    registerPharmacist: (context) => const PharmacistRegistrationPage(),
    chemistProfile: (context) => const ChemistProfilePage(),
    customerProfile: (context) => const CustomerProfilePage(),
    pharmacistProfile: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final pharmacistId = args?['pharmacistId'] as String?;

      print("pharmacistId: ${pharmacistId ?? 'null'}");

      if (pharmacistId == null) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Error'),
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Profile ID not found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('Please navigate from the dashboard'),
              ],
            ),
          ),
        );
      }

      return PharmacistProfilePage(pharmacistId: pharmacistId);
    },
    customerDashboard: (context) => const CustomerDashboard(),
    chemistDashboard: (context) => const ChemistDashboard(),
    adminDashboard: (context) => const AdminDashboard(),
    managerDashboard: (context) => const ManagerDashboard(),
    customerSupportDashboard: (context) => const CustomerSupportDashboard(),
  };
}
