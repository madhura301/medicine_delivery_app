// Customer Dashboard
import 'package:flutter/material.dart';
import 'package:medicine_delivery_app/utils/helpers.dart';


class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Dashboard'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => AppHelpers.logout(context),
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
              'Welcome, Customer!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'How would you like to place your order today?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Order Options Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildOrderOption(
                    icon: Icons.upload_file,
                    title: 'Upload PDF/Image',
                    subtitle: 'Upload prescription',
                    color: Colors.blue,
                    onTap: () => AppHelpers.showComingSoon(context, 'Upload Feature'),
                  ),
                  _buildOrderOption(
                    icon: Icons.camera_alt,
                    title: 'Camera',
                    subtitle: 'Take prescription photo',
                    color: Colors.green,
                    onTap: () => AppHelpers.showComingSoon(context, 'Camera Feature'),
                  ),
                  _buildOrderOption(
                    icon: Icons.mic,
                    title: 'Voice',
                    subtitle: 'Record medicine names',
                    color: Colors.orange,
                    onTap: () => AppHelpers.showComingSoon(context, 'Voice Feature'),
                  ),
                  _buildOrderOption(
                    icon: Icons.text_fields,
                    title: 'Text',
                    subtitle: 'Type medicine names',
                    color: Colors.purple,
                    onTap: () => AppHelpers.showComingSoon(context, 'Text Feature'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderOption({
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
                  color: color.withValues(alpha:0.1),
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
