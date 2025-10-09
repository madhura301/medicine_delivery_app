// Chemist Dashboard - Updated to use OrderWidgets utility
import 'package:pharmaish/core/theme/app_theme.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/helpers.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:pharmaish/shared/widgets/order_widgets.dart';

class ChemistDashboard extends StatefulWidget {
  const ChemistDashboard({super.key});

  @override
  State<ChemistDashboard> createState() => _ChemistDashboardState();
}

class _ChemistDashboardState extends State<ChemistDashboard> {
  String? _pharmacistId;
  String? _pharmacistName;

  @override
  void initState() {
    super.initState();
    //AppHelpers.disableScreenshots();
    _loadPharmacistId();
    _loadPharmacistName();
  }

  Future<void> _loadPharmacistId() async {
    final userId = await StorageService.getUserId();
    AppLogger.info("pharmacistId in chemist dashboard: $userId");
    setState(() {
      _pharmacistId = userId;
    });
  }

  Future<void> _loadPharmacistName() async {
    final userName = await StorageService.getUserName();
    if (userName != null) {
      setState(() {
        _pharmacistName = userName;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    // Clear all stored data
    await StorageService.clearAuthTokens();
    await StorageService.clearSavedCredentials();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _goToChemistProfile(BuildContext context) {
    if (_pharmacistId != null) {
      Navigator.pushNamed(context, '/pharmacistProfile', arguments: {
        'pharmacistId': _pharmacistId!
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chemist Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => _goToChemistProfile(context),
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
          ),
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            const SizedBox(height: 10),
            if (_pharmacistName != null)
              Text(
                'Welcome, $_pharmacistName!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),

            const SizedBox(height: 8),

            Text(
              'How would you like to place your order today?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 30),

            // Order Options Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: [
                  // Upload PDF/Image Option
                  OrderWidgets.buildOrderOption(
                    icon: const Icon(Icons.upload_file,
                        size: 28, color: Colors.blue),
                    title: 'Upload PDF/Image',
                    subtitle: 'Upload prescription',
                    color: Colors.blue,
                    onTap: () =>
                        AppHelpers.showComingSoon(context, 'Upload Feature'),
                  ),

                  // Camera Option
                  OrderWidgets.buildOrderOption(
                    icon: const Icon(Icons.camera_alt,
                        size: 28, color: Colors.black),
                    title: 'Camera',
                    subtitle: 'Take photo',
                    color: Colors.black,
                    onTap: () =>
                        AppHelpers.showComingSoon(context, 'Camera Feature'),
                  ),

                  // Voice Option
                  OrderWidgets.buildOrderOption(
                    icon: const Icon(Icons.mic, size: 28, color: Colors.orange),
                    title: 'Voice',
                    subtitle: 'Voice message/OTC',
                    color: Colors.orange,
                    onTap: () =>
                        AppHelpers.showComingSoon(context, 'Voice Feature'),
                  ),

                  // WhatsApp Option
                  OrderWidgets.buildOrderOption(
                    icon: Image.asset(
                      'assets/images/whatsapp_business.png',
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                    title: 'Chat with Us',
                    subtitle: 'WhatsApp chat',
                    color: const Color(0xFF25D366),
                    onTap: () => OrderWidgets.openWhatsApp(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}