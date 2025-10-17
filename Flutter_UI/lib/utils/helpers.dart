import 'package:flutter/material.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/storage.dart';

class AppHelpers {
  static void showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Text('$feature will be implemented next!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void logout(BuildContext context) {
    Future<void> _logout(BuildContext context) async {
      try {
        // Clear ALL stored data
        await StorageService.clearAuthTokens();
        await StorageService.clearSavedCredentials();
        //await StorageService.clearUserInfo();

        // Navigate to login and remove all previous routes
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      } catch (e) {
        AppLogger.error('Error during logout', e);
        // Even if there's an error, try to navigate to login
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      }
    }
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // static Future<void> disableScreenshots() async {
  //   if (Platform.isIOS) {
  //     // Detect screenshots (iOS only)
  //     ScreenProtector.protectDataLeakageOn(); // Shows warning
  //   } else if (Platform.isAndroid) {
  //     await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  //   } else {
  //     // Other platforms - no action needed
  //   }
  // }
}
