import 'package:flutter/material.dart';
import 'package:medicine_delivery_app/core/dashboards/admin_dashboard.dart';
import 'package:medicine_delivery_app/core/dashboards/chemist_dashboard.dart';
import 'package:medicine_delivery_app/core/dashboards/customer_dashboard.dart';
import 'package:medicine_delivery_app/core/dashboards/support_dashboard.dart';
import 'package:medicine_delivery_app/core/screens/auth/login_page.dart';
import 'package:medicine_delivery_app/core/screens/auth/register_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String customerDashboard = '/customerDashboard';
  static const String chemistDashboard = '/chemistDashboard';
  static const String adminDashboard = '/adminDashboard';
  static const String customerSupportDashboard = '/customerSupportDashboard';


  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginPage(),
    register: (context) => const  RegisterPage(),
    customerDashboard: (context) => const CustomerDashboard(),
    chemistDashboard: (context) => const ChemistDashboard(),
    adminDashboard: (context) => const AdminDashboard(),
    customerSupportDashboard: (context) => const CustomerSupportDashboard(),
  };
}
