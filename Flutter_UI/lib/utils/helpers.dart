import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharmaish/core/screens/orders/camera_prescription_screen.dart';
import 'package:pharmaish/core/screens/orders/upload_prescription_screen.dart';
import 'package:pharmaish/core/screens/orders/voice_order_screen.dart';
import 'package:pharmaish/core/services/customer_service.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/shared/widgets/app_snackbar.dart';
import 'package:pharmaish/utils/order_exceptions.dart';
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

  static Future<void> navigateToUploadPrescription(BuildContext context) async {
    var mobileNumber = await StorageService.getUserMobileNumber();
    
    if (mobileNumber == null) {
      AppLogger.warning('❌ Mobile number not found in storage - user not logged in');
      // Show a message and redirect to login
      if (context.mounted) {
        AppSnackBar.warning(context, 'Please log in to place an order');
        // Navigate to login screen
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    // Clean the mobile number - remove quotes and trim whitespace
    mobileNumber = mobileNumber.replaceAll('"', '').replaceAll("'", '').trim();
    AppLogger.info('User mobile number: "$mobileNumber"');

    var customer = await CustomerService.getCustomerByMobile(
        mobileNumber: mobileNumber);

    if (customer != null) {
      AppLogger.info('🔍 Retrieved customer: "$customer"');
      AppLogger.info(
          "Navigating to Upload Prescription for customerId: ${customer['customerId']}");

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                UploadPrescriptionScreen(customerId: customer['customerId'] ?? ''),
          ),
        ).then((result) {
          // if (result == true && mounted) {
          //   _loadUserName(); // Refresh dashboard if needed
          // }
        });
      }
    } else {
      AppLogger.error(
          '❌ No customer found for mobile number: "$mobileNumber" - possibly logged out');
      // User's session may have expired
      if (context.mounted) {
        AppSnackBar.error(context, 'Session expired. Please log in again.');
        // Navigate to login screen
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  static Future<void> navigateToCameraPrescription(BuildContext context) async {
    var mobileNumber = await StorageService.getUserMobileNumber();
    
    if (mobileNumber == null) {
      AppLogger.warning('❌ Mobile number not found in storage - user not logged in');
      if (context.mounted) {
        AppSnackBar.warning(context, 'Please log in to place an order');
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    // Clean the mobile number - remove quotes and trim whitespace
    mobileNumber = mobileNumber.replaceAll('"', '').replaceAll("'", '').trim();
    AppLogger.info('User mobile number: "$mobileNumber"');

    var customer = await CustomerService.getCustomerByMobile(
        mobileNumber: mobileNumber);

    if (customer != null) {
      AppLogger.info('🔍 Retrieved customer: "$customer"');
      AppLogger.info(
          "Navigating to Camera Prescription for customerId: ${customer['customerId']}");

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CameraPrescriptionScreen(
                customerId: customer['customerId'] ?? ''),
          ),
        ).then((result) {
          // if (result == true && mounted) {
          //   _loadUserName();
          // }
        });
      }
    } else {
      AppLogger.error(
          '❌ No customer found for mobile number: "$mobileNumber" - possibly logged out');
      if (context.mounted) {
        AppSnackBar.error(context, 'Session expired. Please log in again.');
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  // Apply the same pattern to other navigation methods...
  static Future<void> navigateToVoiceOrder(BuildContext context) async {
    var mobileNumber = await StorageService.getUserMobileNumber();
    
    if (mobileNumber == null) {
      AppLogger.warning('❌ Mobile number not found in storage - user not logged in');
      if (context.mounted) {
        AppSnackBar.warning(context, 'Please log in to place an order');
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    mobileNumber = mobileNumber.replaceAll('"', '').replaceAll("'", '').trim();
    AppLogger.info('User mobile number: "$mobileNumber"');
    
    var customer = await CustomerService.getCustomerByMobile(
        mobileNumber: mobileNumber);
        
    if (customer != null) {
      AppLogger.info('🔍 Retrieved customer: "$customer"');
      AppLogger.info(
          "Navigating to Voice Prescription for customerId: ${customer['customerId']}");
      
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VoiceOrderScreen(
                customerId: customer['customerId'] ?? ''),
          ),
        );
      }
    } else {
      AppLogger.error(
          '❌ No customer found for mobile number: "$mobileNumber" - possibly logged out');
      if (context.mounted) {
        AppSnackBar.error(context, 'Session expired. Please log in again.');
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  /// Show error dialog
  static void showOrderErrorDialog(
    BuildContext context,
    OrderException exception,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 10),
            Text('Order Error'),
          ],
        ),
        content: Text(exception.getUserFriendlyMessage()),
        actions: [
          if (exception.type == OrderErrorType.cameraPermissionDenied ||
              exception.type == OrderErrorType.microphonePermissionDenied)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
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