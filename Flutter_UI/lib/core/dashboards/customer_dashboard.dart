// Customer Dashboard - Updated to use OrderWidgets utility
import 'package:pharmaish/core/theme/app_theme.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/helpers.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:pharmaish/shared/widgets/order_widgets.dart'; // Import the utility

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  String _userName = 'Customer';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final firstName = await StorageService.getUserName();
      if (firstName != null && firstName.isNotEmpty) {
        setState(() {
          _userName = firstName;
          _isLoading = false;
        });
      } else {
        // Try to get full name from JWT token
        final token = await StorageService.getAuthToken();
        if (token != null) {
          final tokenData = StorageService.decodeJwtToken(token);
          final userInfo = StorageService.extractUserInfo(tokenData);
          final extractedFirstName = userInfo['firstName'];
          if (extractedFirstName != null && extractedFirstName.isNotEmpty) {
            setState(() {
              _userName = extractedFirstName;
              _isLoading = false;
            });
            return;
          }
        }
        setState(() {
          _userName = 'Customer';
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Error loading user name for welcome message', e);
      setState(() {
        _userName = 'Customer';
        _isLoading = false;
      });
    }
  }

  void _goToCustomerProfile(BuildContext context) {
    Navigator.pushNamed(context, '/customerProfile').then((_) {
      // Refresh user name when returning from profile
      _loadUserName();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => _goToCustomerProfile(context),
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
          ),
          IconButton(
            onPressed: () => AppHelpers.logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            _isLoading
                ? const CircularProgressIndicator()
                : Text(
                    'Welcome, $_userName!',
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