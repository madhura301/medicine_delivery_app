
import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  
  // Dimensions
  static const double defaultPadding = 20.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  
  // Durations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // Demo Users
  static const Map<String, Map<String, String>> demoUsers = {
    'customer': {
      'password': 'CUstomer12!',
      'role': 'Customer',
      'email': 'customer@example.com',
      'mobile': '9876543210'
    },
    'chemist': {
      'password': 'CHemist12!',
      'role': 'Chemist',
      'email': 'chemist@example.com',
      'mobile': '9876543211'
    },
    'admin': {
      'password': 'ADmin12!',
      'role': 'Admin',
      'email': 'admin@example.com',
      'mobile': '9876543212'
    },
    'support': {
      'password': 'SUpport12!',
      'role': 'Customer Support',
      'email': 'support@example.com',
      'mobile': '9876543213'
    },
  };
}
