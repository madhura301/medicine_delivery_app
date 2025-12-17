// Customer Support Dashboard with Drawer Navigation
import 'package:flutter/material.dart';
import 'package:pharmaish/core/theme/app_theme.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:pharmaish/utils/app_logger.dart';

class CustomerSupportDashboard extends StatefulWidget {
  const CustomerSupportDashboard({super.key});

  @override
  State<CustomerSupportDashboard> createState() =>
      _CustomerSupportDashboardState();
}

class _CustomerSupportDashboardState extends State<CustomerSupportDashboard> {
  String _userName = 'Support';
  String _userEmail = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userName = await StorageService.getUserName();
      setState(() {
        _userName = userName ?? 'Support';
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error loading user info: $e');
      setState(() => _isLoading = false);
    }
  }

  void _navigateToProfile() {
    // Navigate to Customer Support profile page when implemented
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile page coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Support'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _navigateToProfile,
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            _isLoading
                ? Container(
                    height: 32,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  )
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
              'Manage orders, chemists, and customer queries',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 32),

            // Dashboard Cards Grid - 2 columns
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  // WhatsApp Order Card
                  _buildDashboardCard(
                    context: context,
                    icon: Icons.chat,
                    title: 'WhatsApp Order',
                    subtitle: 'Create order from WhatsApp',
                    color: Colors.green,
                    onTap: () {
                      Navigator.pushNamed(context, '/createWhatsAppOrder');
                    },
                  ),

                  // Rejected Orders Card
                  _buildDashboardCard(
                    context: context,
                    icon: Icons.cancel_outlined,
                    title: 'Rejected Orders',
                    subtitle: 'Reassign rejected orders',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pushNamed(context, '/rejectedOrders');
                    },
                  ),

                  // Manage Chemists Card
                  _buildDashboardCard(
                    context: context,
                    icon: Icons.people,
                    title: 'Manage Chemists',
                    subtitle: 'View and manage chemists',
                    color: Colors.blue,
                    onTap: () {
                      _showComingSoon(context, 'Manage Chemists');
                    },
                  ),

                  // Register Chemist Card
                  _buildDashboardCard(
                    context: context,
                    icon: Icons.person_add,
                    title: 'Register Chemist',
                    subtitle: 'Add new chemist',
                    color: Colors.indigo,
                    onTap: () {
                      _showComingSoon(context, 'Register Chemist');
                    },
                  ),

                  // // Customer Complaints Card
                  // _buildDashboardCard(
                  //   context: context,
                  //   icon: Icons.report_problem,
                  //   title: 'Customer Complaints',
                  //   subtitle: 'View and resolve issues',
                  //   color: Colors.orange,
                  //   onTap: () {
                  //     _showComingSoon(context, 'Customer Complaints');
                  //   },
                  // ),

                  // // Reports Card
                  // _buildDashboardCard(
                  //   context: context,
                  //   icon: Icons.analytics,
                  //   title: 'Reports',
                  //   subtitle: 'View analytics',
                  //   color: Colors.purple,
                  //   onTap: () {
                  //     _showComingSoon(context, 'Reports');
                  //   },
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await StorageService.clearAuthTokens();
        await StorageService.clearSavedCredentials();

        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      } catch (e) {
        AppLogger.error('Error during logout', e);
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      }
    }
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.support_agent,
                  size: 40,
                  color: AppTheme.primaryColor,
                ),
              ),
              accountName: Text(
                _userName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(_userEmail),
            ),

            // Dashboard
            ListTile(
              leading:
                  const Icon(Icons.dashboard, color: AppTheme.primaryColor),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context); // Close drawer
              },
            ),

            const Divider(),

            // Orders Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'ORDERS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: const Text('WhatsApp Orders'),
              subtitle: const Text('Create from WhatsApp'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/createWhatsAppOrder');
              },
            ),

            ListTile(
              leading: const Icon(Icons.cancel_outlined, color: Colors.red),
              title: const Text('Rejected Orders'),
              subtitle: const Text('Reassign orders'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/rejectedOrders');
              },
            ),

            ListTile(
              leading: const Icon(Icons.pending_actions, color: Colors.orange),
              title: const Text('Pending Orders'),
              subtitle: const Text('View all pending'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Pending Orders');
              },
            ),

            const Divider(),

            // Chemists Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'CHEMISTS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.people, color: Colors.blue),
              title: const Text('Manage Chemists'),
              subtitle: const Text('View and edit'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Manage Chemists');
              },
            ),

            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.indigo),
              title: const Text('Register Chemist'),
              subtitle: const Text('Add new chemist'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Register Chemist');
              },
            ),

            const Divider(),

            // Customers Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'CUSTOMERS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ),

            // ListTile(
            //   leading: const Icon(Icons.report_problem, color: Colors.orange),
            //   title: const Text('Complaints'),
            //   subtitle: const Text('View and resolve'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     _showComingSoon(context, 'Customer Complaints');
            //   },
            // ),

            ListTile(
              leading: const Icon(Icons.people_outline, color: Colors.teal),
              title: const Text('Customer List'),
              subtitle: const Text('View all customers'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Customer List');
              },
            ),

            const Divider(),

            // // Analytics Section
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //   child: Text(
            //     'ANALYTICS',
            //     style: TextStyle(
            //       fontSize: 12,
            //       fontWeight: FontWeight.bold,
            //       color: Colors.grey.shade600,
            //     ),
            //   ),
            // ),

            // ListTile(
            //   leading: const Icon(Icons.analytics, color: Colors.purple),
            //   title: const Text('Reports'),
            //   subtitle: const Text('View analytics'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     _showComingSoon(context, 'Reports');
            //   },
            // ),

            // ListTile(
            //   leading: const Icon(Icons.bar_chart, color: Colors.deepPurple),
            //   title: const Text('Statistics'),
            //   subtitle: const Text('Performance metrics'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     _showComingSoon(context, 'Statistics');
            //   },
            // ),

            const Divider(),

            // Settings Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'SETTINGS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.person, color: AppTheme.primaryColor),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                _navigateToProfile();
              },
            ),

            // ListTile(
            //   leading: const Icon(Icons.settings, color: Colors.grey),
            //   title: const Text('Settings'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     _showComingSoon(context, 'Settings');
            //   },
            // ),

            // ListTile(
            //   leading: const Icon(Icons.help_outline, color: Colors.blueGrey),
            //   title: const Text('Help & Support'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     _showComingSoon(context, 'Help & Support');
            //   },
            // ),

            const Divider(),

            // Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () => _handleLogout(),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with circular background
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // Title
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

              // Subtitle
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
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

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue.shade700),
            const SizedBox(width: 12),
            const Text('Coming Soon'),
          ],
        ),
        content: Text(
          '$feature feature is under development and will be available soon.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
