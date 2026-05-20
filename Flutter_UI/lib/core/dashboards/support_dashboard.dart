import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pharmaish/core/dashboards/support/assigned_orders_page.dart';
import 'package:pharmaish/core/dashboards/support/rejected_orders_page.dart';
import 'package:pharmaish/core/dashboards/support/whatsapp_order_creation_page.dart';
import 'package:pharmaish/core/services/dio_client.dart';
import 'package:pharmaish/shared/widgets/confirm_dialog.dart';
import 'package:pharmaish/utils/storage.dart';

// ============================================================================
// CUSTOMER SUPPORT DASHBOARD - MAIN
// ============================================================================

class CustomerSupportDashboard extends StatefulWidget {
  const CustomerSupportDashboard({super.key});

  @override
  State<CustomerSupportDashboard> createState() =>
      _CustomerSupportDashboardState();
}

class _CustomerSupportDashboardState extends State<CustomerSupportDashboard> {
  int _selectedIndex = 0;
  final Dio _dio = DioClient.instance;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleLogout() async {
    final confirm = await confirmLogout(context);
    if (confirm) {
      await StorageService.clearAll();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Support Dashboard';
      case 1:
        return 'Rejected Orders';
      case 2:
        return 'Create WhatsApp Order';
      case 3:
        return 'Assigned Orders';
      default:
        return 'Customer Support';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getPageTitle(),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {});
            },
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (context) => [
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
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboardHome(),
          RejectedOrdersPage(dio: _dio),
          WhatsAppOrderCreationPage(dio: _dio),
          AssignedOrdersPage(dio: _dio),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
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
                  child:
                      Icon(Icons.support_agent, size: 40, color: Colors.black),
                ),
                const SizedBox(height: 12),
                FutureBuilder<String?>(
                  future: StorageService.getUserName(),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? 'Support Agent',
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
                  'Customer Support',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.dashboard, color: Colors.black),
                  title: const Text('Dashboard'),
                  selected: _selectedIndex == 0,
                  selectedTileColor: Colors.black.withOpacity(0.1),
                  onTap: () {
                    setState(() => _selectedIndex = 0);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.assignment_return, color: Colors.red),
                  title: const Text('Rejected Orders'),
                  selected: _selectedIndex == 1,
                  selectedTileColor: Colors.black.withOpacity(0.1),
                  onTap: () {
                    setState(() => _selectedIndex = 1);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.message, color: Colors.green),
                  title: const Text('WhatsApp Orders'),
                  selected: _selectedIndex == 2,
                  selectedTileColor: Colors.black.withOpacity(0.1),
                  onTap: () {
                    setState(() => _selectedIndex = 2);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.assignment_ind, color: Colors.blue),
                  title: const Text('Assigned Orders'),
                  selected: _selectedIndex == 3,
                  selectedTileColor: Colors.black.withOpacity(0.1),
                  onTap: () {
                    setState(() => _selectedIndex = 3);
                    Navigator.of(context).pop();
                  },
                ),
                const Divider(height: 1),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.contact_support, color: Colors.black),
            title: const Text('Contact Us'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/contact-us');
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () => _handleLogout(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDashboardHome() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.support_agent, size: 100, color: Colors.black),
            const SizedBox(height: 24),
            const Text(
              'Customer Support Dashboard',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Manage rejected orders and create WhatsApp orders',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 40),
            _buildQuickActionCard(
              icon: Icons.assignment_return,
              title: 'Rejected Orders',
              subtitle: 'Reassign to another chemist',
              color: Colors.red,
              onTap: () => setState(() => _selectedIndex = 1),
            ),
            const SizedBox(height: 16),
            _buildQuickActionCard(
              icon: Icons.message,
              title: 'WhatsApp Orders',
              subtitle: 'Create order on behalf of customer',
              color: Colors.green,
              onTap: () => setState(() => _selectedIndex = 2),
            ),
            const SizedBox(height: 16),
            _buildQuickActionCard(
              icon: Icons.assignment_ind,
              title: 'Assigned Orders',
              subtitle: 'View orders assigned to you',
              color: Colors.blue,
              onTap: () => setState(() => _selectedIndex = 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 20, color: color),
          ],
        ),
      ),
    );
  }
}
