// File: lib/shared/widgets/order_widgets.dart
import 'package:flutter/material.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/helpers.dart';

/// Utility class for common order-related widgets and functions
class OrderWidgets {
  /// Opens WhatsApp with a predefined message
  static Future<void> openWhatsApp(BuildContext context,String message) async {
    const String phoneNumber = '+919226737083';
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

  /// Opens membership code PDF - "Click here.." link
  static Future<void> _showMembershipPDF(BuildContext context) async {
    const String pdfUrl =
        '${AppConstants.documentsProdBaseUrl}/Membership_Payment_Declaration_and_Consent.pdf';
    // Test URL: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf'

    try {
      final Uri uri = Uri.parse(pdfUrl);

      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        AppLogger.info('External app launch failed, trying browser mode');
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      AppLogger.error('Error opening membership PDF', e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open Membership Code document'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Opens membership benefits PDF - "extra benefits" link
  static Future<void> _showMembershipBenefitsPDF(BuildContext context) async {
    const String pdfUrl =
        '${AppConstants.documentsProdBaseUrl}/MEMBERSHIP_BENEFITS_DOCUMENT.pdf';
    // Test URL: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf'

    try {
      final Uri uri = Uri.parse(pdfUrl);

      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        AppLogger.info('External app launch failed, trying browser mode');
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      AppLogger.error('Error opening membership benefits PDF', e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open Membership Benefits document'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Builds a reusable order option card
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Center(child: icon),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
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
                  height: 1.2,
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

  /// Builds the complete order options grid
  static Widget buildOrderOptionsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: [
        buildOrderOption(
          icon: Image.asset(
            'assets/images/upload_icon.png',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
          title: 'Upload',
          subtitle: 'PDF/Image prescription',
          color: Colors.orange,
          onTap: () => AppHelpers.showComingSoon(context, 'Upload Feature'),
        ),
        buildOrderOption(
          icon: Image.asset(
            'assets/images/camera_icon.png',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
          title: 'Camera',
          subtitle: 'Take photo',
          color: Colors.orange,
          onTap: () => AppHelpers.showComingSoon(context, 'Camera Feature'),
        ),
        buildOrderOption(
          icon: Image.asset(
            'assets/images/recording_icon.png',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
          title: 'Voice',
          subtitle: 'Voice message/OTC',
          color: Colors.orange,
          onTap: () => AppHelpers.showComingSoon(context, 'Voice Feature'),
        ),
        buildOrderOption(
          icon: Image.asset(
            'assets/images/whatsapp_business.png',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
          title: 'Chat with Us',
          subtitle: 'WhatsApp chat',
          color: Colors.orange,
          onTap: () => openWhatsApp(context,'Hello, I would like to place an order.'),
        ),
      ],
    );
  }

  /// Builds the new order UI layout (from design)
  /// Builds the new order UI layout (from design)
static Widget buildNewOrderUI(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight,
            maxHeight: constraints.maxHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Membership Code Section - SAME LINE WITH FLEXIBLE LAYOUT
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => openWhatsApp(context,'Hello, I would like to become a member.'),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w300,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Become a Member to avail ',
                              ),
                              const TextSpan(
                                text: 'EXTRA BENEFITS',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(
                                text: '!\n',
                              ),
                              const TextSpan(
                                text: 'Call',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(
                                text: ' or ',
                              ),
                              const TextSpan(
                                text: 'DM',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(
                                text: '-\'connect\' on ',
                              ),
                              const TextSpan(
                                text: '09226737083',
                                style: TextStyle(
                                  color: Colors.lightBlueAccent,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const TextSpan(
                                text: '.',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Already a Member, ignore this message.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // PLACE YOUR ORDER Section
                const Text(
                  'PLACE YOUR ORDER',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: _buildNewOrderCard(
                        context,
                        imagePath: 'assets/images/upload_icon.png',
                        title: 'UPLOAD',
                        subtitle: 'Prescription/List of Non-Prescription Items',
                        onTap: () => AppHelpers.showComingSoon(context, 'Upload Feature'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildNewOrderCard(
                        context,
                        imagePath: 'assets/images/camera_icon.png',
                        title: 'CAMERA',
                        subtitle: 'Capture Photo',
                        onTap: () => AppHelpers.showComingSoon(context, 'Camera Feature'),
                      ),
                    ),
                  ],
                ),

                const Text(
                  'PATIENT COUNSELLING/\nORDER ASSISTANCE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    height: 1.2,
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: _buildNewOrderCard(
                        context,
                        imagePath: 'assets/images/recording_icon.png',
                        title: 'RECORD',
                        subtitle: 'Voice Message',
                        onTap: () => AppHelpers.showComingSoon(context, 'Voice Feature'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildNewOrderCard(
                        context,
                        imagePath: 'assets/images/whatsapp_business.png',
                        title: 'WHATSAPP',
                        subtitle: 'Chat with us',
                        onTap: () => openWhatsApp(context,'Hello, I would like to place an order.'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
  /// Helper method for the new order card design - COMPACT WITH BETTER SPACING
  static Widget _buildNewOrderCard(
    BuildContext context, {
    required String imagePath,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140, // Keep same height
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 8), // Reduced padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 65, // Reduced from 90
              height: 65, // Reduced from 90
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF4CAF50),
                fontSize: 14, // Reduced from 16
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF4CAF50),
                  fontSize: 10, // Reduced from 11
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
                maxLines: 2, // Reduced from 3
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
