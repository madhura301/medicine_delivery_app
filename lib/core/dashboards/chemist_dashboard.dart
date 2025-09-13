// Chemist Dashboard
import 'package:flutter/material.dart';

class ChemistDashboard extends StatelessWidget {
  const ChemistDashboard({super.key});

  void _logout(BuildContext context) {
    // Clear user session here (e.g., SharedPreferences, Provider, etc.)
    // Navigate back to login page
    Navigator.pushReplacementNamed(context, '/login');
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
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medication, size: 80, color: Color(0xFF2E7D32)),
            SizedBox(height: 20),
            Text(
              'Chemist Dashboard',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
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
