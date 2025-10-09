//Forgot password page
// Step 1: Username Entry for Password Reset
import 'package:pharmaish/utils/app_logger.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  // Demo users removed - app now uses real API authentication

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.lock_reset,
                  size: 60,
                  color: Color(0xFF2E7D32),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Forgot Password?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Enter your username and we\'ll send you a reset code',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 40),

              // Username Field
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter your username',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your username';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (_errorMessage.isNotEmpty) {
                    setState(() {
                      _errorMessage = '';
                    });
                  }
                },
              ),

              // Error Message
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red.shade600, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              // Send Reset Code Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendResetCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Send Reset Code',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                ),
              ),

              //   const SizedBox(height: 30),

              //   // Demo Info
              //   Container(
              //     padding: const EdgeInsets.all(16),
              //     decoration: BoxDecoration(
              //       color: Colors.blue.shade50,
              //       borderRadius: BorderRadius.circular(12),
              //       border: Border.all(color: Colors.blue.shade200),
              //     ),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(
              //           'Demo Usernames:',
              //           style: TextStyle(
              //             color: Colors.blue.shade600,
              //             fontSize: 16,
              //             fontWeight: FontWeight.w600,
              //           ),
              //         ),
              //         const SizedBox(height: 8),
              //         Text(
              //           'customer, chemist, admin, support',
              //           style: TextStyle(
              //             color: Colors.blue.shade700,
              //             fontSize: 14,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendResetCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // TODO: Replace with real API call to send reset code
      // For now, simulate API call
      await Future.delayed(const Duration(seconds: 2));

      final username = _usernameController.text.trim();

      // TODO: Make actual API call to verify username and send reset code
      // This should call your backend API to:
      // 1. Verify the username exists
      // 2. Send reset code via SMS/Email
      // 3. Return user's email/mobile for OTP verification

      // For now, show a message that this feature needs real API integration
      AppLogger.info('Password reset requested for: $username');
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Password reset feature requires API integration. Please contact support.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error sending reset code. Please try again.';
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}
