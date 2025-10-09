// File: lib/shared/widgets/order_widgets.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pharmaish/utils/app_logger.dart';

/// Utility class for common order-related widgets and functions
class OrderWidgets {
  /// Opens WhatsApp with a predefined message
  /// 
  /// Usage:
  /// ```dart
  /// OrderWidgets.openWhatsApp(context);
  /// ```
  static Future<void> openWhatsApp(BuildContext context) async {
    const String phoneNumber = '+919226737083'; // Replace with your WhatsApp number
    const String message = 'Hello, I would like to place an order.';

    // Create WhatsApp URL
    final String whatsappUrl =
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';

    try {
      // Try to launch WhatsApp
      final Uri uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // If WhatsApp is not installed, show error
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('WhatsApp is not installed on this device'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Error opening WhatsApp', e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open WhatsApp. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Builds a reusable order option card
  /// 
  /// Usage:
  /// ```dart
  /// OrderWidgets.buildOrderOption(
  ///   icon: const Icon(Icons.camera_alt, size: 28, color: Colors.black),
  ///   title: 'Camera',
  ///   subtitle: 'Take photo',
  ///   color: Colors.black,
  ///   onTap: () => print('Camera tapped'),
  /// )
  /// ```
  static Widget buildOrderOption({
    required Widget icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: icon,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}