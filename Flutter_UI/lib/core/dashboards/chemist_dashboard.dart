// Chemist Dashboard
import 'package:flutter/material.dart';
import 'package:medicine_delivery_app/utils/storage.dart';

class ChemistDashboard extends StatefulWidget {
  const ChemistDashboard({super.key});

  @override
  State<ChemistDashboard> createState() => _ChemistDashboardState();
}

class _ChemistDashboardState extends State<ChemistDashboard> {
  String? _pharmacistId;
  String? _pharmacistName;
  
  @override
  void initState() {
    super.initState();
    _loadPharmacistId();
    _loadPharmacistName();
  }

  Future<void> _loadPharmacistId() async {
    final userId = await StorageService.getUserId();
    print("pharmacistId in chemist dashboard: $userId");
    setState(() {
      _pharmacistId = userId;
    });
  }

  Future<void> _loadPharmacistName() async {
    final userName = await StorageService.getUserName();
    if (userName != null) {
      setState(() {
        _pharmacistName = userName;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    // Clear all stored data
    await StorageService.clearAuthTokens();
    await StorageService.clearSavedCredentials();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _goToChemistProfile(BuildContext context) {
    if (_pharmacistId != null) {
      Navigator.pushNamed(context, '/pharmacistProfile', arguments: {
        'pharmacistId': _pharmacistId!,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chemist Dashboard'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => _goToChemistProfile(context),
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
          ),
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.medication, size: 80, color: Color(0xFF2E7D32)),
            const SizedBox(height: 20),
            const Text(
              'Chemist Dashboard',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_pharmacistName != null)
              Text(
                'Welcome, $_pharmacistName',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            const SizedBox(height: 20),
            const Text(
              'Pending Orders • Accept/Reject\n(Coming Next!)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
