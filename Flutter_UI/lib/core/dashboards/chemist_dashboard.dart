// Chemist Dashboard - Updated with new UI design
import 'package:pharmaish/core/theme/app_theme.dart';
import 'package:pharmaish/utils/app_logger.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPharmacistId();
    _loadPharmacistName();
  }

  Future<void> _loadPharmacistId() async {
    final userId = await StorageService.getUserId();
    AppLogger.info("pharmacistId in chemist dashboard: $userId");
    setState(() {
      _pharmacistId = userId;
      _isLoading = false;
    });
  }

  Future<void> _loadPharmacistName() async {
    final userName = await StorageService.getUserName();
    if (userName != null) {
      setState(() {
        _pharmacistName = userName;
        _isLoading = false;
      });
    }
  }

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

  void _goToChemistProfile(BuildContext context) {
    if (_pharmacistId != null) {
      Navigator.pushNamed(context, '/pharmacistProfile',
          arguments: {'pharmacistId': _pharmacistId!});
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
                            'Chemist Dashboard',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _goToChemistProfile(context),
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
                    'Welcome, $_pharmacistName!',
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
