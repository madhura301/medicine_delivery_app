// Customer Support Dashboard
import 'package:flutter/material.dart';
import 'package:pharmaish/core/theme/app_theme.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/helpers.dart';
import 'package:pharmaish/utils/storage.dart';

class CustomerSupportDashboard extends StatelessWidget {
  const CustomerSupportDashboard({super.key});

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
        title: const Text('Customer Support'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => _logout(context),
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
            Text(
              'Customer Support Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Manage rejected orders and chemist operations',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 30),

            // Support Options
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildSupportOption(
                    icon: Icons.assignment_return,
                    title: 'Rejected Orders',
                    subtitle: 'Handle chemist rejections',
                    color: Colors.red,
                    onTap: () => AppHelpers.showComingSoon(
                        context, 'Rejected Orders Management'),
                  ),
                  _buildSupportOption(
                    icon: Icons.store,
                    title: 'Manage Chemists',
                    subtitle: 'Edit chemist profiles',
                    color: Colors.blue,
                    onTap: () => AppHelpers.showComingSoon(
                        context, 'Chemist Management'),
                  ),
                  _buildSupportOption(
                    icon: Icons.person_add,
                    title: 'Register Chemist',
                    subtitle: 'Add new chemist',
                    color: Colors.green,
                    onTap: () => AppHelpers.showComingSoon(
                        context, 'Chemist Registration'),
                  ),
                  _buildSupportOption(
                    icon: Icons.assignment_late,
                    title: 'Customer Complaints',
                    subtitle: 'Handle delivery issues',
                    color: Colors.orange,
                    onTap: () => AppHelpers.showComingSoon(
                        context, 'Customer Complaints'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption({
    required IconData icon,
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
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
