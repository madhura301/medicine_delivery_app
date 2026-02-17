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
  //String _userStatus = 'Active'; // Can be 'Active', 'Inactive', or 'Pause'

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

// // TODO: Fetch user status from API
//   // For now, it's hardcoded as 'Active'
//   // You should fetch this from your backend API based on customerId
//   // Get status color based on status
//   Color _getStatusColor() {
//     switch (_userStatus) {
//       case 'Active':
//         return Colors.green;
//       case 'Inactive':
//         return Colors.red;
//       case 'Pause':
//         return Colors.orange;
//       default:
//         return Colors.grey;
//     }
//   }

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

// This fixes:
// 1. Moves drawer and profile icons up aligned with logo
// 2. Fixes status badge overlap on profile icon
// 3. Adds Pharmaish disclaimer text in footer

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          // Top section with logo and title - UPDATED
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
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // HAMBURGER MENU ICON - Aligned with logo
                    Builder(
                      builder: (context) => IconButton(
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                        icon: const Icon(Icons.menu,
                            color: Colors.white, size: 28),
                        tooltip: 'Menu',
                      ),
                    ),

                    // Logo in the center
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          'assets/images/app_icon_animated_white_tagline.png',
                          width: 150,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // Profile Icon with Status Indicator - Aligned with logo
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          onPressed: () => _goToCustomerProfile(context),
                          icon: const Icon(Icons.person,
                              color: Colors.white, size: 28),
                          tooltip: 'Profile',
                        ),
                      //   // Status indicator - FIXED POSITIONING
                      //   Positioned(
                      //     bottom: -4,
                      //     left: 0,
                      //     right: 0,
                      //     child: Container(
                      //       padding: const EdgeInsets.symmetric(
                      //         horizontal: 4,
                      //         vertical: 2,
                      //       ),
                      //       decoration: BoxDecoration(
                      //         color: _getStatusColor(),
                      //         borderRadius: BorderRadius.circular(8),
                      //         border: Border.all(color: Colors.white, width: 1),
                      //       ),
                      //       child: Text(
                      //         _userStatus,
                      //         style: const TextStyle(
                      //           color: Colors.white,
                      //           fontSize: 7,
                      //           fontWeight: FontWeight.bold,
                      //         ),
                      //         textAlign: TextAlign.center,
                      //         maxLines: 1,
                      //       ),
                      //     ),
                      //   ),
                      // ]
                      ]
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Welcome Header
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

          // Order Options
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: OrderWidgets.buildNewOrderUI(context),
            ),
          ),

          // Black Footer with Pharmaish Disclaimer - UPDATED
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Row(
              children: [
                // Shield icon
                Icon(
                  Icons.verified_user,
                  color: Colors.grey.shade400,
                  size: 32,
                ),
                const SizedBox(width: 12),
                // Disclaimer text
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade300,
                        height: 1.3,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Pharmaish ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: 'is a technology facilitation platform. '
                              'Medicines are sold, billed, and delivered by licensed retail pharmacies.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
            // Drawer Header with Status Indicator
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
              ),
              currentAccountPicture: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: AppTheme.primaryColor,
                    ),
                  )
                  //   // Status indicator positioned below the profile picture
                  //   Positioned(
                  //     bottom: -8,
                  //     left: 0,
                  //     right: 0,
                  //     child: Container(
                  //       padding: const EdgeInsets.symmetric(
                  //         horizontal: 6,
                  //         vertical: 3,
                  //       ),
                  //       decoration: BoxDecoration(
                  //         color: _getStatusColor(),
                  //         borderRadius: BorderRadius.circular(10),
                  //         border: Border.all(color: Colors.white, width: 1.5),
                  //       ),
                  //       child: Text(
                  //         _userStatus,
                  //         style: const TextStyle(
                  //           color: Colors.white,
                  //           fontSize: 10,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //         textAlign: TextAlign.center,
                  //       ),
                  //     ),
                  //   ),
                  //
                ],
              ),
              accountName: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
