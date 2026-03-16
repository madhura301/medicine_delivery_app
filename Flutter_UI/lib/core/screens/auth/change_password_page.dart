import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pharmaish/core/theme/app_theme.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';

/// Allows an authenticated user to change their password.
///
/// Flow:
///   1. User enters current password  →  verified via POST /Auth/login
///   2. Backend sends OTP to their number  →  POST /Auth/forgot-password
///   3. User enters the OTP + new password  →  POST /Auth/reset-password
///
/// Pass [mobileNumber] when navigating to this page; it is loaded from
/// StorageService if not supplied.
class ChangePasswordPage extends StatefulWidget {
  final String? mobileNumber;

  const ChangePasswordPage({Key? key, this.mobileNumber}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  // ── Step tracking ─────────────────────────────────────────────────────────
  // Step 1 → verify current password
  // Step 2 → enter OTP + new password
  int _step = 1;

  // ── Form keys ─────────────────────────────────────────────────────────────
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();

  // ── Controllers ───────────────────────────────────────────────────────────
  final _currentPasswordController = TextEditingController();
  final _otpController             = TextEditingController();
  final _newPasswordController     = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ── UI state ──────────────────────────────────────────────────────────────
  bool _obscureCurrent  = true;
  bool _obscureNew      = true;
  bool _obscureConfirm  = true;
  bool _isLoading       = false;
  String _errorMessage  = '';
  String _mobileNumber  = '';
  String _resetToken    = ''; // token returned by forgot-password

  // ── Password strength ─────────────────────────────────────────────────────
  double _passwordStrength = 0;
  String _strengthLabel    = '';
  Color  _strengthColor    = Colors.red;

  @override
  void initState() {
    super.initState();
    _loadMobileNumber();
  }

  Future<void> _loadMobileNumber() async {
    if (widget.mobileNumber != null && widget.mobileNumber!.isNotEmpty) {
      setState(() => _mobileNumber = widget.mobileNumber!);
      return;
    }
    final stored = await StorageService.getUserMobileNumber();
    setState(() => _mobileNumber = stored ?? '');
  }

  // ── Password strength checker ─────────────────────────────────────────────
  void _checkPasswordStrength(String value) {
    int score = 0;
    if (value.length >= 6)                              score++;
    if (value.length >= 10)                             score++;
    if (RegExp(r'[A-Z]').hasMatch(value))               score++;
    if (RegExp(r'[a-z]').hasMatch(value))               score++;
    if (RegExp(r'[0-9]').hasMatch(value))               score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) score++;

    String label;
    Color color;
    if (score <= 2) {
      label = 'Weak';      color = Colors.red;
    } else if (score <= 4) {
      label = 'Medium';    color = Colors.orange;
    } else {
      label = 'Strong';    color = Colors.green;
    }

    setState(() {
      _passwordStrength = score / 6;
      _strengthLabel    = label;
      _strengthColor    = color;
    });
  }

  // ── Step 1: verify current password via login ─────────────────────────────
  Future<void> _verifyCurrentPassword() async {
    if (!_step1FormKey.currentState!.validate()) return;
    if (_mobileNumber.isEmpty) {
      setState(() => _errorMessage = 'Mobile number not found. Please login again.');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = ''; });

    try {
      // Verify via login endpoint
      final loginResp = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/Auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'mobileNumber': _mobileNumber,
          'password': _currentPasswordController.text.trim(),
          'stayLoggedIn': false,
        }),
      );

      if (loginResp.statusCode != 200 && loginResp.statusCode != 201) {
        setState(() {
          _isLoading = false;
          _errorMessage = loginResp.statusCode == 401
              ? 'Current password is incorrect.'
              : 'Could not verify password. Please try again.';
        });
        return;
      }

      final loginData = jsonDecode(loginResp.body);
      if (loginData['success'] != true) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Current password is incorrect.';
        });
        return;
      }

      // Current password verified → trigger OTP via forgot-password
      final otpResp = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/Auth/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'mobileNumber': _mobileNumber}),
      );

      if (otpResp.statusCode == 200 || otpResp.statusCode == 201) {
        final otpData = jsonDecode(otpResp.body);
        if (otpData['success'] == true) {
          final token = otpData['token']?.toString() ?? '';
          setState(() {
            _isLoading = false;
            _resetToken = token;
            if (token.isNotEmpty) _otpController.text = token;
            _step = 2;
          });
          return;
        }
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to send OTP. Please try again.';
      });
    } catch (e) {
      AppLogger.error('ChangePassword step1 error: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Network error. Please check your connection.';
      });
    }
  }

  // ── Step 2: submit OTP + new password ─────────────────────────────────────
  Future<void> _submitNewPassword() async {
    if (!_step2FormKey.currentState!.validate()) return;

    setState(() { _isLoading = true; _errorMessage = ''; });

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/Auth/reset-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'mobileNumber': _mobileNumber,
          'token':        _otpController.text.trim(),
          'newPassword':  _newPasswordController.text.trim(),
        }),
      );

      AppLogger.apiResponse(response.statusCode, '/Auth/reset-password',
          jsonDecode(response.body));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() => _isLoading = false);
          if (mounted) _showSuccessDialog();
          return;
        }
      }

      // Error handling
      setState(() { _isLoading = false; });
      try {
        final errData = jsonDecode(response.body);
        final errors = errData['errors'] as List<dynamic>?;
        setState(() {
          _errorMessage = errors?.isNotEmpty == true
              ? errors!.first.toString()
              : 'Failed to update password. Check the OTP and try again.';
        });
      } catch (_) {
        setState(() => _errorMessage = 'Failed to update password. Please try again.');
      }
    } catch (e) {
      AppLogger.error('ChangePassword step2 error: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Network error. Please check your connection.';
      });
    }
  }

  void _showSuccessDialog() {
    // Update saved credentials so Remember Password still works
    _updateSavedCredentials();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 60),
            ),
            const SizedBox(height: 20),
            const Text(
              'Password Updated!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your password has been changed successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop(); // back to profile
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Done', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateSavedCredentials() async {
    try {
      final creds = await StorageService.loadSavedCredentials();
      if (creds['rememberPassword'] == true) {
        await StorageService.saveCredentials(
          username: _mobileNumber,
          password: _newPasswordController.text.trim(),
          rememberPassword: true,
        );
      }
    } catch (_) {}
  }

  // ── Validators ────────────────────────────────────────────────────────────
  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a new password';
    if (value == _currentPasswordController.text.trim())
      return 'New password must be different from current password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    if (value.length > 20) return 'Password cannot exceed 20 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value))
      return 'Password must contain at least 1 uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(value))
      return 'Password must contain at least 1 lowercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value))
      return 'Password must contain at least 1 number';
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value))
      return 'Password must contain at least 1 special character';
    return null;
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStepIndicator(),
            const SizedBox(height: 24),
            _step == 1 ? _buildStep1() : _buildStep2(),
          ],
        ),
      ),
    );
  }

  // ── Step indicator ────────────────────────────────────────────────────────
  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepDot(1, 'Verify'),
        Expanded(
          child: Container(
            height: 2,
            color: _step >= 2 ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
        ),
        _buildStepDot(2, 'Set New'),
      ],
    );
  }

  Widget _buildStepDot(int step, String label) {
    final isActive   = _step == step;
    final isComplete = _step > step;
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isComplete
                ? AppTheme.primaryColor
                : isActive
                    ? AppTheme.primaryColor
                    : Colors.grey.shade300,
          ),
          child: Center(
            child: isComplete
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    '$step',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive || isComplete
                ? AppTheme.primaryColor
                : Colors.grey.shade500,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // ── Step 1: verify current password ──────────────────────────────────────
  Widget _buildStep1() {
    return Form(
      key: _step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoCard(
            icon: Icons.lock_outline,
            title: 'Verify Your Identity',
            subtitle:
                'Enter your current password to proceed. We\'ll send an OTP to your registered number.',
            color: Colors.blue,
          ),
          const SizedBox(height: 24),

          // Mobile number display (read-only)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.phone, color: Colors.grey.shade600, size: 20),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Registered Mobile',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500)),
                    Text(
                      _mobileNumber.isNotEmpty ? _mobileNumber : 'Loading...',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Current password field
          TextFormField(
            controller: _currentPasswordController,
            obscureText: _obscureCurrent,
            maxLength: 20,
            decoration: InputDecoration(
              labelText: 'Current Password',
              hintText: 'Enter your current password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscureCurrent
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: () =>
                    setState(() => _obscureCurrent = !_obscureCurrent),
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
              counterText: '',
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Please enter your current password' : null,
            onChanged: (_) {
              if (_errorMessage.isNotEmpty) {
                setState(() => _errorMessage = '');
              }
            },
          ),

          if (_errorMessage.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildErrorBanner(),
          ],

          const SizedBox(height: 24),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _verifyCurrentPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Verify & Send OTP',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 2: OTP + new password ────────────────────────────────────────────
  Widget _buildStep2() {
    return Form(
      key: _step2FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoCard(
            icon: Icons.sms_outlined,
            title: 'OTP Sent!',
            subtitle:
                'An OTP has been sent to $_mobileNumber. Enter it below along with your new password.',
            color: Colors.green,
          ),
          const SizedBox(height: 24),

          // OTP field
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 10,
            decoration: InputDecoration(
              labelText: 'OTP',
              hintText: 'Enter OTP received via SMS',
              prefixIcon: const Icon(Icons.key_outlined),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
              counterText: '',
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Please enter the OTP' : null,
            onChanged: (_) {
              if (_errorMessage.isNotEmpty) setState(() => _errorMessage = '');
            },
          ),

          const SizedBox(height: 20),

          // New password
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscureNew,
            maxLength: 20,
            decoration: InputDecoration(
              labelText: 'New Password',
              hintText: 'Enter new password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscureNew ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
              counterText: '',
            ),
            validator: _validateNewPassword,
            onChanged: (v) {
              _checkPasswordStrength(v);
              if (_errorMessage.isNotEmpty) setState(() => _errorMessage = '');
            },
          ),

          // Strength indicator
          if (_newPasswordController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildStrengthIndicator(),
          ],

          const SizedBox(height: 20),

          // Confirm password
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            maxLength: 20,
            decoration: InputDecoration(
              labelText: 'Confirm New Password',
              hintText: 'Re-enter new password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirm
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
              counterText: '',
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm your password';
              if (v != _newPasswordController.text) return 'Passwords do not match';
              return null;
            },
            onChanged: (_) {
              if (_errorMessage.isNotEmpty) setState(() => _errorMessage = '');
            },
          ),

          const SizedBox(height: 16),

          // Password requirements
          _buildRequirements(),

          if (_errorMessage.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildErrorBanner(),
          ],

          const SizedBox(height: 24),

          Row(
            children: [
              // Back to step 1
              OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : () => setState(() {
                          _step = 1;
                          _errorMessage = '';
                        }),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade400),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitNewPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Update Password',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade700, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Password strength',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            Text(_strengthLabel,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _strengthColor)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _passwordStrength,
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
          ),
        ),
      ],
    );
  }

  Widget _buildRequirements() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Password Requirements',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700)),
          const SizedBox(height: 8),
          _buildReqRow('At least 6 characters',
              _newPasswordController.text.length >= 6),
          _buildReqRow('At least 1 uppercase letter',
              RegExp(r'[A-Z]').hasMatch(_newPasswordController.text)),
          _buildReqRow('At least 1 lowercase letter',
              RegExp(r'[a-z]').hasMatch(_newPasswordController.text)),
          _buildReqRow('At least 1 number',
              RegExp(r'[0-9]').hasMatch(_newPasswordController.text)),
          _buildReqRow('At least 1 special character',
              RegExp(r'[!@#\$%^&*(),.?":{}|<>]')
                  .hasMatch(_newPasswordController.text)),
          _buildReqRow(
              'Matches confirm field',
              _newPasswordController.text.isNotEmpty &&
                  _newPasswordController.text ==
                      _confirmPasswordController.text),
        ],
      ),
    );
  }

  Widget _buildReqRow(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 15,
            color: met ? Colors.green : Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: met ? Colors.green.shade700 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage,
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}