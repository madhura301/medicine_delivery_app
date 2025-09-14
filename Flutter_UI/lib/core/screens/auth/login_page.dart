import 'package:flutter/material.dart';
import 'package:medicine_delivery_app/core/app_routes.dart';
import 'package:medicine_delivery_app/core/screens/auth/forgot_password_page.dart';
import 'package:medicine_delivery_app/core/screens/auth/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String _errorMessage = '';

  // Demo credentials for all user types - updated to use email format
  final Map<String, Map<String, String>> _demoUsers = {
    'customer@example.com': {'password': 'CUstomer12!', 'role': 'Customer'},
    'chemist@example.com': {'password': 'CHemist12!', 'role': 'Chemist'},
    'admin@example.com': {'password': 'ADmin12!', 'role': 'Admin'},
    'support@example.com': {'password': 'SUpport12!', 'role': 'Customer Support'},
  };

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

                // Email Field (User Name)
                TextFormField(
                  controller: _emailController,
                  maxLength: 100,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'User Name',
                    hintText: 'Enter your email address',
                    prefixIcon: const Icon(Icons.email_outlined),
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
                      return 'Please enter your email address';
                    }
                    // Email validation regex
                    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                    if (!emailRegex.hasMatch(value!)) {
                      return 'Please enter a valid email address';
                    }
                    if (value.length > 100) {
                      return 'Email address cannot exceed 100 characters';
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

                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  maxLength: 20,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
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
                      return 'Please enter your password';
                    }
                    
                    // Check minimum length
                    if (value!.length < 8) {
                      return 'Password must be at least 8 characters long';
                    }
                    
                    // Check maximum length
                    if (value.length > 20) {
                      return 'Password cannot exceed 20 characters';
                    }
                    
                    // Check for minimum 2 capital letters
                    final capitalLetters = RegExp(r'[A-Z]').allMatches(value).length;
                    if (capitalLetters < 2) {
                      return 'Password must contain at least 2 capital letters';
                    }
                    
                    // Check for minimum 2 small letters
                    final smallLetters = RegExp(r'[a-z]').allMatches(value).length;
                    if (smallLetters < 2) {
                      return 'Password must contain at least 2 small letters';
                    }
                    
                    // Check for minimum 1 special character
                    final specialCharacters = RegExp(r'[!@#$%^&*(),.?":{}|<>]').allMatches(value).length;
                    if (specialCharacters < 1) {
                      return 'Password must contain at least 1 special character';
                    }
                    
                    // Check for minimum 1 numerical number
                    final numbers = RegExp(r'[0-9]').allMatches(value).length;
                    if (numbers < 1) {
                      return 'Password must contain at least 1 number';
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

                // Login Button
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

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterPage()),
                        );
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Demo Credentials 
                //_buildDemoCredentials(),
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
          'Sign in to continue',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // Widget _buildDemoCredentials() {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.blue.shade50,
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: Colors.blue.shade200),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
  //             const SizedBox(width: 8),
  //             Text(
  //               'Demo Credentials',
  //               style: TextStyle(
  //                 color: Colors.blue.shade600,
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 12),
  //         Text(
  //           'Customer: customer@example.com / CUstomer12!',
  //           style: TextStyle(color: Colors.blue.shade700, fontSize: 14),
  //         ),
  //         Text(
  //           'Chemist: chemist@example.com / CHemist12!',
  //           style: TextStyle(color: Colors.blue.shade700, fontSize: 14),
  //         ),
  //         Text(
  //           'Admin: admin@example.com / ADmin12!',
  //           style: TextStyle(color: Colors.blue.shade700, fontSize: 14),
  //         ),
  //         Text(
  //           'Support: support@example.com / SUpport12!',
  //           style: TextStyle(color: Colors.blue.shade700, fontSize: 14),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Check credentials
    if (_demoUsers.containsKey(email) &&
        _demoUsers[email]!['password'] == password) {
      final userRole = _demoUsers[email]!['role']!;

      setState(() {
        _isLoading = false;
      });

      // Navigate based on role
      _navigateToDashboard(userRole);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Incorrect email address or password';
      });
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}