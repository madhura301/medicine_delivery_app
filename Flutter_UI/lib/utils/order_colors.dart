import 'package:flutter/material.dart';
import 'package:pharmaish/shared/models/order_enums.dart';

class OrderColors {
  // Order Input Type Colors
  static const Color upload = Color(0xFFFF9800);      // Orange - File Upload
  static const Color camera = Color(0xFF000000);      // Black - Camera
  static const Color voice = Color(0xFFFF9800);       // Orange - Voice
  static const Color text = Color(0xFF4CAF50);        // Green - Text/WhatsApp
  
  // Common Action Colors
  static const Color primary = Color(0xFF2196F3);     // Blue
  static const Color success = Color(0xFF4CAF50);     // Green
  static const Color error = Color(0xFFF44336);       // Red
  static const Color warning = Color(0xFFFF9800);     // Orange
  static const Color info = Color(0xFF2196F3);        // Blue
  
  // Status Colors
  static const Color pending = Color(0xFFFFC107);     // Amber
  static const Color accepted = Color(0xFF4CAF50);    // Green
  static const Color rejected = Color(0xFFF44336);    // Red
  static const Color completed = Color(0xFF9C27B0);   // Purple
  
  // UI Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  
  /// Get color for order input type
  static Color getColorForInputType(OrderInputType type) {
    switch (type) {
      case OrderInputType.image:
        return upload; // Used for both upload and camera
      case OrderInputType.voice:
        return voice;
      case OrderInputType.text:
        return text;
    }
  }
  
  /// Get icon for order input type
  static IconData getIconForInputType(OrderInputType type) {
    switch (type) {
      case OrderInputType.image:
        return Icons.image;
      case OrderInputType.voice:
        return Icons.mic;
      case OrderInputType.text:
        return Icons.text_fields;
    }
  }
}