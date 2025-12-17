import 'package:flutter/material.dart';
import 'package:pharmaish/core/dashboards/admin_dashboard.dart';
import 'package:pharmaish/core/dashboards/chemist_dashboard.dart';
import 'package:pharmaish/core/dashboards/customer_dashboard.dart';
import 'package:pharmaish/core/dashboards/manager_dashboard.dart';
import 'package:pharmaish/core/dashboards/support_dashboard.dart';
import 'package:pharmaish/core/screens/orders/accepted_order_bill_screen.dart';
import 'package:pharmaish/core/screens/orders/create_whatsapp_order_screen.dart';
import 'package:pharmaish/core/screens/orders/rejected_orders_screen.dart';
import 'package:pharmaish/core/screens/profiles/customer_profile_page.dart';
import 'package:pharmaish/core/screens/profiles/pharmacist_profile_page.dart';
import 'package:pharmaish/core/screens/auth/register_customer_page.dart';
import 'package:pharmaish/core/screens/auth/register_pharmacist_page.dart';
import 'package:pharmaish/core/theme/app_theme.dart';
import 'package:pharmaish/utils/app_logger.dart';

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
  static const String createWhatsAppOrder = '/createWhatsAppOrder';
  static const String rejectedOrders = '/rejectedOrders';
  static const String acceptedOrderBill = '/acceptedOrderBill';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginPage(),
    registerCustomer: (context) => const CustomerRegisterPage(),
    registerPharmacist: (context) => const PharmacistRegistrationPage(),
    customerProfile: (context) => const CustomerProfilePage(),
    pharmacistProfile: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final pharmacistId = args?['pharmacistId'] as String?;

      AppLogger.info("pharmacistId: ${pharmacistId ?? 'null'}");

      if (pharmacistId == null) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Error'),
            backgroundColor: AppTheme.primaryColor,
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
    createWhatsAppOrder: (context) =>
        const CreateWhatsAppOrderScreen(), // Placeholder
    rejectedOrders: (context) => const RejectedOrdersScreen(), // Placeholder
    acceptedOrderBill: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      return AcceptedOrderBillScreen(
        order: args['order'],
        customerName: args['customerName'],
        customerEmail: args['customerEmail'],
        customerPhone: args['customerPhone'],
      );
    },
  };
}
