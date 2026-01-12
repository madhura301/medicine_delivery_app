// Admin Dashboard with Real Statistics from API
import 'package:pharmaish/core/screens/admin/admin_user_management.dart';
import 'package:pharmaish/core/screens/admin/admin_all_orders.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:dio/dio.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/config/environment_config.dart';
import 'package:pharmaish/core/screens/admin/admin_customer_support_regions.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Statistics data
  Map<String, int> _statistics = {
    'totalUsers': 0,
    'totalOrders': 0,
    'activeChemists': 0,
    'pendingOrders': 0,
  };
  bool _isLoading = true;
  late Dio _dio;

  @override
  void initState() {
    super.initState();
    _setupDio();
    _loadDashboardData();
  }

  void _setupDio() {
    _dio = Dio();
    _dio.options.baseUrl = AppConstants.apiBaseUrl;
    _dio.options.connectTimeout = EnvironmentConfig.timeoutDuration;
    _dio.options.receiveTimeout = EnvironmentConfig.timeoutDuration;

    if (EnvironmentConfig.shouldLog) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        logPrint: (object) => AppLogger.info('API: $object'),
      ));
    }

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (EnvironmentConfig.shouldLog) {
          AppLogger.error('API Error: ${error.message}');
          AppLogger.error('Status Code: ${error.response?.statusCode}');
          AppLogger.error('Response Data: ${error.response?.data}');
        }
        handler.next(error);
      },
    ));
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      AppLogger.info('Loading admin dashboard statistics');

      // Load statistics from API
      int totalUsers = 0;
      int totalOrders = 0;
      int activeChemists = 0;
      int pendingOrders = 0;

      // Get all customers (Total Users)
      try {
        final customersResponse = await _dio.get('/Customers');
        if (customersResponse.statusCode == 200) {
          final data = customersResponse.data;
          if (data is List) {
            totalUsers = data.length;
          }
          AppLogger.info('Loaded ${totalUsers} customers');
        }
      } catch (e) {
        AppLogger.error('Error loading customers count', e);
      }

      // Get all medical stores (Chemists)
      try {
        final chemistsResponse = await _dio.get('/MedicalStores');
        if (chemistsResponse.statusCode == 200) {
          final data = chemistsResponse.data;
          if (data is List) {
            activeChemists = data.length;
          }
          AppLogger.info('Loaded ${activeChemists} chemists');
        }
      } catch (e) {
        AppLogger.error('Error loading chemists count', e);
      }

      // Get all orders
      try {
        final ordersResponse = await _dio.get('/Orders');
        if (ordersResponse.statusCode == 200) {
          final data = ordersResponse.data;
          List<dynamic> ordersList;

          if (data is List) {
            ordersList = data;
          } else if (data is Map && data.containsKey('data')) {
            ordersList = data['data'] as List;
          } else if (data is Map && data.containsKey('orders')) {
            ordersList = data['orders'] as List;
          } else {
            ordersList = [];
          }

          totalOrders = ordersList.length;

          // Count pending orders
          pendingOrders = ordersList.where((order) {
            final status = order['status']?.toString().toLowerCase() ?? '';
            return status.contains('pending') || status.contains('assigned');
          }).length;

          AppLogger.info(
              'Loaded ${totalOrders} total orders, ${pendingOrders} pending');
        }
      } catch (e) {
        AppLogger.error('Error loading orders count', e);
        // If /Orders doesn't exist, set to 0
        totalOrders = 0;
        pendingOrders = 0;
      }

      setState(() {
        _statistics = {
          'totalUsers': totalUsers,
          'totalOrders': totalOrders,
          'activeChemists': activeChemists,
          'pendingOrders': pendingOrders,
        };
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error loading dashboard data', e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _goToAdminProfile(BuildContext context) {
    Navigator.pushNamed(context, '/customerProfile');
  }

  void _goToUserManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminUserManagementPage(dio: _dio),
      ),
    );
  }

  void _goToAllOrders(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminAllOrders(),
      ),
    );
  }

   void _goToRegionManagementPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminCustomerSupportRegionsPage(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications - Coming Soon!')),
              );
            },
            tooltip: 'Notifications',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'profile') {
                _goToAdminProfile(context);
              } else if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            decoration: const BoxDecoration(color: Colors.black),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 40,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                FutureBuilder<String?>(
                  future: StorageService.getUserName(),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? 'Administrator',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  'System Administrator',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.dashboard, color: Colors.black),
                  title: const Text('Dashboard'),
                  selected: true,
                  selectedTileColor: Colors.black.withOpacity(0.1),
                  onTap: () => Navigator.of(context).pop(),
                ),
                ListTile(
                  leading: const Icon(Icons.people, color: Colors.black),
                  title: const Text('User Management'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _goToUserManagement(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_cart, color: Colors.black),
                  title: const Text('All Orders'),
                  trailing: _statistics['totalOrders']! > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_statistics['totalOrders']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                  onTap: () {
                    Navigator.of(context).pop();
                    _goToAllOrders(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.location_city),
                  title: Text('Customer Support Regions'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _goToRegionManagementPage(context);
                  },
                ),
                // ListTile(
                //   leading:
                //       const Icon(Icons.local_pharmacy, color: Colors.black),
                //   title: const Text('Chemists'),
                //   onTap: () {
                //     Navigator.of(context).pop();
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       const SnackBar(content: Text('Chemists - Coming Soon!')),
                //     );
                //   },
                // ),
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.black),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _goToAdminProfile(context);
                  },
                ),
              ],
            ),
          ),

          // Logout at bottom
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () => _handleLogout(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.black),
            SizedBox(height: 16),
            Text('Loading dashboard...'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              _buildWelcomeCard(),
              const SizedBox(height: 24),

              // Statistics Section
              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatisticsGrid(),

              const SizedBox(height: 24),

              // Quick Actions Section
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildQuickActionsGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black,
            Colors.black.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.admin_panel_settings,
            size: 40,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<String?>(
                  future: StorageService.getUserName(),
                  builder: (context, snapshot) {
                    return Text(
                      'Welcome, ${snapshot.data ?? 'System'}!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
                Text(
                  'Manage your system efficiently',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Users',
                '${_statistics['totalUsers'] ?? 0}',
                Icons.people,
                Colors.blue,
              ),
            ),
            // const SizedBox(width: 12),
            // Expanded(
            //   child: _buildStatCard(
            //     'Total Orders',
            //     '${_statistics['totalOrders'] ?? 0}',
            //     Icons.shopping_cart,
            //     Colors.purple,
            //   ),
            // ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Active Chemists',
                '${_statistics['activeChemists'] ?? 0}',
                Icons.local_pharmacy,
                Colors.green,
              ),
            ),
            // const SizedBox(width: 12),
            // Expanded(
            //   child: _buildStatCard(
            //     'Pending Orders',
            //     '${_statistics['pendingOrders'] ?? 0}',
            //     Icons.pending_actions,
            //     Colors.orange,
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildActionCard(
          title: 'User Management',
          subtitle: 'Manage users & roles',
          icon: Icons.people,
          color: Colors.blue,
          onTap: () => _goToUserManagement(context),
        ),
        _buildActionCard(
          title: 'All Orders',
          subtitle: 'Manage orders',
          icon: Icons.shopping_cart,
          color: Colors.purple,
          onTap: () => _goToAllOrders(context),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
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
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
