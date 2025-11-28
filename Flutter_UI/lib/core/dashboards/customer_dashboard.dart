// Customer Dashboard - Updated with new UI design
import 'package:pharmaish/core/theme/app_theme.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:pharmaish/shared/widgets/order_widgets.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  String _userName = 'Customer';
  String _customerId = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    try {
      final firstName = await StorageService.getUserName();
      final customerId = await StorageService.getUserId();
      if (firstName != null && firstName.isNotEmpty) {
        setState(() {
          _userName = firstName;
          _customerId = customerId ?? '';
          _isLoading = false;
        });
      } else {
        // Try to get full name from JWT token
        final token = await StorageService.getAuthToken();
        if (token != null) {
          final tokenData = StorageService.decodeJwtToken(token);
          final userInfo = StorageService.extractUserInfo(tokenData);
          final extractedFirstName = userInfo['firstName'];
          final customerId = userInfo['id'];
          if (extractedFirstName != null && extractedFirstName.isNotEmpty) {
            setState(() {
              _userName = extractedFirstName;
              _customerId = customerId ?? '';
              _isLoading = false;
            });
            return;
          }
        }
        setState(() {
          _userName = 'Customer';
          _customerId = customerId ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Error loading user name for welcome message', e);
      setState(() {
        _userName = 'Customer';
        _customerId = '';
        _isLoading = false;
      });
    }
  }

  void _goToCustomerProfile(BuildContext context) {
    Navigator.pushNamed(context, '/customerProfile').then((_) {
      // Refresh user name when returning from profile
      _loadUserDetails();
    });
  }

  Future<void> _logout(BuildContext context) async {
    try {
      // Clear all stored data including saved credentials
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top section with logo and title
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Logo at the top
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Image.asset(
                      'assets/images/app_icon_animated_white_tagline.png',
                      width: 150,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // Dashboard title and actions row
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Customer Dashboard', // or 'Chemist Dashboard'
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _goToCustomerProfile(context),
                          icon: const Icon(Icons.person, color: Colors.white),
                          tooltip: 'Profile',
                        ),
                        IconButton(
                          onPressed: () => _logout(context),
                          icon: const Icon(Icons.logout, color: Colors.white),
                          tooltip: 'Logout',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Welcome Header with reduced height
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 6), // Reduced from 10
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 18,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : Text(
                    'Welcome, $_userName!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
          ),
          // Order Options - New Design
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: OrderWidgets.buildNewOrderUI(context),
            ),
          ),
          // Black Footer
          Container(
            width: double.infinity,
            height: 50, // Adjust height as needed
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}