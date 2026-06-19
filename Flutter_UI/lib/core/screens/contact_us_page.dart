import 'package:flutter/material.dart';
import 'package:pharmaish/core/theme/app_theme.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchPhone(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  const Icon(Icons.support_agent, size: 72, color: AppTheme.primaryColor),
                  const SizedBox(height: 12),
                  Text(
                    'We\'re here to help!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reach out to us for any queries, feedback, or support.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Contact cards
            _ContactCard(
              icon: Icons.phone_in_talk,
              iconColor: Colors.teal,
              title: 'Support Phone',
              subtitle: 'Call us for help',
              detail: AppConstants.supportPhoneNumber,
              trailingIcon: Icons.call,
              onTap: () =>
                  _launchPhone(AppConstants.supportPhoneNumberWithCountryCode),
            ),

            _ContactCard(
              icon: Icons.headset_mic,
              iconColor: Colors.blue,
              title: 'Support',
              subtitle: 'For general help and queries',
              detail: 'support@pharmaish.com',
              onTap: () => _launchEmail('support@pharmaish.com'),
            ),

            _ContactCard(
              icon: Icons.report_problem_outlined,
              iconColor: Colors.orange,
              title: 'Grievance',
              subtitle: 'Report issues or complaints',
              detail: 'grievance@pharmaish.com',
              onTap: () => _launchEmail('grievance@pharmaish.com'),
            ),

            _ContactCard(
              icon: Icons.account_balance_wallet,
              iconColor: Colors.green,
              title: 'Accounts',
              subtitle: 'Billing and payment related',
              detail: 'accounts@pharmaish.com',
              onTap: () => _launchEmail('accounts@pharmaish.com'),
            ),

            _ContactCard(
              icon: Icons.admin_panel_settings,
              iconColor: Colors.purple,
              title: 'Admin',
              subtitle: 'Business and partnership enquiries',
              detail: 'admin@pharmaish.com',
              onTap: () => _launchEmail('admin@pharmaish.com'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String detail;
  final IconData trailingIcon;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.onTap,
    this.trailingIcon = Icons.email_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.1),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 4),
            Text(detail, style: TextStyle(color: iconColor, fontSize: 13)),
          ],
        ),
        trailing: Icon(trailingIcon, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
