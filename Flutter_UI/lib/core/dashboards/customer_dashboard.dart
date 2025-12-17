// Customer Dashboard - with Drawer Navigation and All Orders Feature
import 'package:pharmaish/core/screens/orders/customer_all_orders.dart';
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
  String _userEmail = '';
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
        });
      } else {
        // Try to get full name from JWT token
        final token = await StorageService.getAuthToken();
        if (token != null) {
          final tokenData = StorageService.decodeJwtToken(token);
          final userInfo = StorageService.extractUserInfo(tokenData);
          final extractedFirstName = userInfo['firstName'];
          final extractedEmail = userInfo['email'];
          final customerId = userInfo['id'];
          
          if (extractedFirstName != null && extractedFirstName.isNotEmpty) {
            setState(() {
              _userName = extractedFirstName;
              _userEmail = extractedEmail ?? '';
              _customerId = customerId ?? '';
            });
          } else {
            setState(() {
              _userName = 'Customer';
              _customerId = customerId ?? '';
            });
          }
        } else {
          setState(() {
            _userName = 'Customer';
          });
        }
      }
      
      setState(() => _isLoading = false);
    } catch (e) {
      AppLogger.error('Error loading user details', e);
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

  void _goToAllOrders(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CustomerAllOrders(),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context), // DRAWER ADDED
      body: Column(
        children: [
          // Top section with logo and title - ORIGINAL UI
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
                        // HAMBURGER MENU ICON ADDED
                        Builder(
                          builder: (context) => IconButton(
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                            icon: const Icon(Icons.menu, color: Colors.white),
                            tooltip: 'Menu',
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'Customer Dashboard',
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
                        // LOGOUT MOVED TO DRAWER - Removed from here
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Welcome Header - ORIGINAL UI
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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

          // Order Options - ORIGINAL UI (using OrderWidgets)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: OrderWidgets.buildNewOrderUI(context),
            ),
          ),

          // Black Footer - ORIGINAL UI
          Container(
            width: double.infinity,
            height: 50,
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Drawer Navigation (Similar to Support Dashboard)
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
                  Icons.person,
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
              leading: const Icon(Icons.dashboard, color: AppTheme.primaryColor),
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
              leading: const Icon(Icons.shopping_bag, color: Colors.blue),
              title: const Text('All Orders'),
              subtitle: const Text('View all your orders'),
              onTap: () {
                Navigator.pop(context);
                _goToAllOrders(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.history, color: Colors.green),
              title: const Text('Order History'),
              subtitle: const Text('Past orders'),
              onTap: () {
                Navigator.pop(context);
                _goToAllOrders(context); // Same as All Orders for now
              },
            ),

            const Divider(),

            // Profile Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'ACCOUNT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.person, color: AppTheme.primaryColor),
              title: const Text('My Profile'),
              subtitle: const Text('View and edit profile'),
              onTap: () {
                Navigator.pop(context);
                _goToCustomerProfile(context);
              },
            ),

            const Divider(),

            // Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _logout(context);
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}