import 'package:flutter/material.dart';
import 'package:pharmaish/core/screens/auth/change_password_page.dart';
import 'package:pharmaish/core/theme/app_theme.dart';
import 'package:pharmaish/shared/widgets/app_button.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/storage.dart';

/// Profile screen for the Admin role.
///
/// Admins have no Customer / Manager / MedicalStore record, so there is no
/// role-specific profile endpoint to call. Everything shown here comes from the
/// JWT claims cached by [StorageService] at login, which is why this page has
/// no network failure mode — the admin dashboard used to route to
/// CustomerProfilePage, whose GET /Customers/my-profile always 404s for an admin.
class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  bool _isLoading = true;
  String _errorMessage = '';

  String _firstName = '';
  String _lastName = '';
  String _mobileNumber = '';
  String _email = '';
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final firstName = await StorageService.getUserName() ?? '';
      final mobileNumber = await StorageService.getUserMobileNumber() ?? '';
      final email = await StorageService.getUserEmail() ?? '';
      final userId = await StorageService.getUserId() ?? '';
      final lastName = await StorageService.getUserLastName() ?? '';

      if (!mounted) return;
      setState(() {
        _firstName = firstName;
        _lastName = lastName;
        _mobileNumber = mobileNumber;
        _email = email;
        _userId = userId;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('AdminProfile error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load profile.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadProfile,
              tooltip: 'Refresh')
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : _errorMessage.isNotEmpty
              ? _buildError()
              : _buildBody(),
    );
  }

  Widget _buildError() => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(_errorMessage, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadProfile,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: AppButton.primary(),
          ),
        ]),
      );

  Widget _buildBody() {
    final fullName =
        [_firstName, _lastName].where((s) => s.isNotEmpty).join(' ');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withValues(alpha: 0.75)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3)),
              child: const Icon(Icons.admin_panel_settings,
                  size: 38, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(fullName.isNotEmpty ? fullName : 'Administrator',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  _roleBadge('Admin', Icons.admin_panel_settings),
                ])),
          ]),
        ),
        const SizedBox(height: 20),

        // ── Personal Info ──
        _section('Personal Information', Icons.person_outline, [
          _row(Icons.person, 'First Name',
              _firstName.isNotEmpty ? _firstName : '—'),
          if (_lastName.isNotEmpty)
            _row(Icons.person_outline, 'Last Name', _lastName),
          _row(Icons.phone, 'Mobile Number',
              _mobileNumber.isNotEmpty ? _mobileNumber : '—'),
          if (_email.isNotEmpty) _row(Icons.email_outlined, 'Email', _email),
        ]),
        const SizedBox(height: 16),

        // ── Account Info ──
        _section('Account Information', Icons.account_circle_outlined, [
          _row(Icons.verified_user_outlined, 'Role', 'Admin'),
          if (_userId.isNotEmpty)
            _row(Icons.badge_outlined, 'User ID', _userId),
        ]),
        const SizedBox(height: 16),

        // ── Security ──
        _section('Security', Icons.security, [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.lock_outline,
                  color: Colors.orange.shade700, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('Password',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  Text('Update your account password anytime',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600)),
                ])),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          ChangePasswordPage(mobileNumber: _mobileNumber))),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Change Password',
                  style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: const BorderSide(
                    color: AppTheme.primaryColor, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Icon(Icons.info_outline, size: 14, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(
                'Use a mix of uppercase, lowercase, numbers and special characters.',
                style: TextStyle(
                    fontSize: 11, color: Colors.blue.shade700, height: 1.3),
              )),
            ]),
          ),
        ]),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _roleBadge(String label, IconData icon) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ]),
      );

  Widget _section(String title, IconData icon, List<Widget> children) =>
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12)),
            ),
            child: Row(children: [
              Icon(icon, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children),
          ),
        ]),
      );

  Widget _row(IconData icon, String label, String value, {Color? valueColor}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: valueColor ?? Colors.grey.shade800)),
              ])),
        ]),
      );
}
