import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:convert' show base64Url, json, utf8;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:medicine_delivery_app/core/app_routes.dart';
import 'package:medicine_delivery_app/core/screens/auth/forgot_password_page.dart';
import 'package:medicine_delivery_app/core/screens/auth/otp_verification_page.dart';
import 'package:medicine_delivery_app/core/screens/auth/register_page.dart';
import 'package:medicine_delivery_app/core/screens/auth/register_pharmacist_page.dart';
import 'package:medicine_delivery_app/utils/constants.dart';

class LoginWithOTPPage extends StatefulWidget {
  const LoginWithOTPPage({super.key});

  @override
  State<LoginWithOTPPage> createState() => _LoginWithOTPPageState();
}

class _LoginWithOTPPageState extends State<LoginWithOTPPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  bool _isOtpSent = false;
  bool _isOtpLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Header
                _buildHeader(),

                const SizedBox(height: 50),

                // Phone Number Field
                TextFormField(
                  controller: _phoneController,
                  maxLength: 10,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    hintText: 'Enter your 10-digit mobile number',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    prefixText: '+91 ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF2E7D32), width: 2),
                    ),
                    counterText: '', // Hide character counter
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your mobile number';
                    }
                    // Mobile number validation
                    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
                    if (!phoneRegex.hasMatch(value!)) {
                      return 'Please enter a valid 10-digit mobile number';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (_errorMessage.isNotEmpty) {
                      setState(() {
                        _errorMessage = '';
                      });
                    }
                    // Reset OTP state when phone number changes
                    if (_isOtpSent) {
                      setState(() {
                        _isOtpSent = false;
                        _otpController.clear();
                        _successMessage = '';
                      });
                    }
                  },
                ),

                const SizedBox(height: 20),

                // Send OTP Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isOtpLoading ? null : _handleSendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isOtpSent ? Colors.grey : const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isOtpLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _isOtpSent ? 'OTP Sent' : 'Send OTP',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // OTP Field (only shown after OTP is sent)
                if (_isOtpSent)
                  Column(
                    children: [
                      TextFormField(
                        controller: _otpController,
                        maxLength: 6,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Enter OTP',
                          hintText: 'Enter 6-digit OTP',
                          prefixIcon: const Icon(Icons.security),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF2E7D32), width: 2),
                          ),
                          counterText: '', // Hide character counter
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter OTP';
                          }
                          if (value!.length != 6) {
                            return 'OTP must be 6 digits';
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
                      const SizedBox(height: 10),
                      // Resend OTP option
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isOtpLoading ? null : _handleSendOtp,
                          child: const Text(
                            'Resend OTP',
                            style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                // Success Message
                if (_successMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              color: Colors.green.shade600, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _successMessage,
                              style: TextStyle(
                                color: Colors.green.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

                // Login Button (only shown after OTP is sent)
                if (_isOtpSent)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
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
                              'Login',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage()),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Color(0xFF2E7D32)),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade400)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade400)),
                  ],
                ),

                const SizedBox(height: 30),

                // Register Pharmacist Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const PharmacistRegistrationPage()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2E7D32),
                      side:
                          const BorderSide(color: Color(0xFF2E7D32), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_pharmacy, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Register as Pharmacist',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Customer Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Need a customer account? ",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CustomerRegisterPage()),
                        );
                      },
                      child: const Text(
                        'Register here',
                        style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App Icon
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.local_pharmacy,
            size: 60,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 30),

        // Welcome Text
        const Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Login with your mobile number',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  void _handleSendOtp() async {
    // Validate phone number first
    if (_phoneController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your mobile number';
      });
      return;
    }

    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(_phoneController.text)) {
      setState(() {
        _errorMessage = 'Please enter a valid 10-digit mobile number';
      });
      return;
    }

    setState(() {
      _isOtpLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPVerificationPage(
          username: _phoneController.text.trim(),
          email: _phoneController.text.trim() + '@medimart.com',
          mobile: _phoneController.text.trim(),
        ),
      ),
    );

    _isOtpSent = true;
    _successMessage = 'OTP sent successfully to +91 ${_phoneController.text.trim()}';
    // try {
    //   final phoneNumber = _phoneController.text.trim();

    //   // Make API call to send OTP
    //   final response = await http.post(
    //     Uri.parse('${AppConstants.apiBaseUrl}/Auth/send-otp'),
    //     headers: {
    //       'Content-Type': 'application/json',
    //       'Accept': 'application/json',
    //     },
    //     body: jsonEncode({
    //       'phoneNumber': phoneNumber,
    //     }),
    //   );

    //   setState(() {
    //     _isOtpLoading = false;
    //   });

    //   if (response.statusCode == 200) {
    //     final responseData = jsonDecode(response.body);

    //     if (responseData['success'] == true) {
    //       setState(() {
    //         _isOtpSent = true;
    //         _successMessage = 'OTP sent successfully to +91 ${phoneNumber}';
    //       });
    //     } else {
    //       final errors = responseData['errors'] as List<dynamic>;
    //       setState(() {
    //         _errorMessage = errors.isNotEmpty
    //             ? errors.first.toString()
    //             : 'Failed to send OTP. Please try again.';
    //       });
    //     }
    //   } else {
    //     setState(() {
    //       _errorMessage = 'Failed to send OTP. Please try again.';
    //     });
    //   }
    // } catch (e) {
    //   setState(() {
    //     _isOtpLoading = false;
    //     _errorMessage = 'Network error. Please check your connection.';
    //   });
    //   print('Send OTP error: $e');
    // }
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final phoneNumber = _phoneController.text.trim();
      final otp = _otpController.text.trim();

      // Make API call to verify OTP and login
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/Auth/verify-otp-login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'otp': otp,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        // Parse response
        final responseData = jsonDecode(response.body);

        // Check if login was successful
        if (responseData['success'] == true) {
          // Extract data from response
          final token = responseData['token'];
          final refreshToken = responseData['refreshToken'];

          // Store token securely
          await _storeToken(token, refreshToken);

          print('Login successful!');
          print('Token: $token');
          print('Refresh Token: $refreshToken');

          // Decode JWT token to get user information
          final userInfo = _decodeJwtToken(token);
          final userRole = _determineUserRole(userInfo);

          // Navigate to appropriate dashboard
          _navigateToDashboard(userRole);
        } else {
          // API returned success: false
          final errors = responseData['errors'] as List<dynamic>;
          setState(() {
            _errorMessage = errors.isNotEmpty
                ? errors.first.toString()
                : 'Login failed. Please try again.';
          });
        }
      } else if (response.statusCode == 401) {
        // Unauthorized - wrong OTP
        setState(() {
          _errorMessage = 'Invalid OTP. Please try again.';
        });
      } else if (response.statusCode == 400) {
        // Bad request - validation errors
        try {
          final errorData = jsonDecode(response.body);
          final errors = errorData['errors'] as List<dynamic>;
          setState(() {
            _errorMessage = errors.isNotEmpty
                ? errors.first.toString()
                : 'Invalid OTP or phone number';
          });
        } catch (e) {
          setState(() {
            _errorMessage = 'Invalid OTP or phone number';
          });
        }
      } else {
        // Other server errors
        setState(() {
          _errorMessage = 'Server error. Please try again later.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Network error. Please check your connection.';
      });
      print('Login error: $e');
    }
  }

  // Create secure storage instance
  static const _storage = FlutterSecureStorage();

  // Helper method to store authentication tokens securely
  Future<void> _storeToken(String token, String? refreshToken) async {
    try {
      await _storage.write(key: 'auth_token', value: token);

      if (refreshToken != null) {
        await _storage.write(key: 'refresh_token', value: refreshToken);
      }

      print('Tokens stored successfully');
    } catch (e) {
      print('Error storing tokens: $e');
    }
  }

  // Helper method to decode JWT token and extract user information
  Map<String, dynamic> _decodeJwtToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid token');
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(resp);

      return payloadMap;
    } catch (e) {
      print('Error decoding token: $e');
      return {};
    }
  }

  // Helper method to determine user role from JWT claims
  String _determineUserRole(Map<String, dynamic> userInfo) {
    // Extract user information from JWT claims
    final email = userInfo[
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'] ??
        '';
    final firstName = userInfo['firstName'] ?? '';
    final lastName = userInfo['lastName'] ?? '';

    print('User Info: Email: $email, Name: $firstName $lastName');

    // Determine role based on email or other claims
    // You might have a role claim in the token, adjust this logic as needed
    if (email.contains('admin')) {
      return 'Admin';
    } else if (email.contains('chemist')) {
      return 'Chemist';
    } else if (email.contains('support')) {
      return 'Customer Support';
    } else {
      return 'Customer';
    }
  }

  void _navigateToDashboard(String role) {
    String routeName;

    switch (role) {
      case 'Customer':
        routeName = AppRoutes.customerDashboard;
        break;
      case 'Chemist':
        routeName = AppRoutes.chemistDashboard;
        break;
      case 'Admin':
        routeName = AppRoutes.adminDashboard;
        break;
      case 'Customer Support':
        routeName = AppRoutes.customerSupportDashboard;
        break;
      default:
        routeName = AppRoutes.customerDashboard;
    }

    Navigator.pushReplacementNamed(context, routeName);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
