// Admin Dashboard
import 'package:pharmaish/core/theme/app_theme.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:pharmaish/utils/storage.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void _goToAdminProfile(BuildContext context) {
    Navigator.pushNamed(context, '/customerProfile');
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => _goToAdminProfile(context),
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
          ),
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings,
                size: 80, color: AppTheme.primaryColor),
            SizedBox(height: 20),
            Text(
              'Admin Dashboard',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Manage Users • System Settings\n(Coming Next!)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

