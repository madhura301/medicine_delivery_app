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
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String _errorMessage = '';

  // Demo credentials for all user types
  final Map<String, Map<String, String>> _demoUsers = {
    'customer': {'password': 'customer123', 'role': 'Customer'},
    'chemist': {'password': 'chemist123', 'role': 'Chemist'},
    'admin': {'password': 'admin123', 'role': 'Admin'},
    'support': {'password': 'support123', 'role': 'Customer Support'},
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

                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
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
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your password';
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
                      //_showForgotPasswordDialog();
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
  //           'Customer: customer / customer123',
  //           style: TextStyle(color: Colors.blue.shade700, fontSize: 14),
  //         ),
  //         Text(
  //           'Chemist: chemist / chemist123',
  //           style: TextStyle(color: Colors.blue.shade700, fontSize: 14),
  //         ),
  //         Text(
  //           'Admin: admin / admin123',
  //           style: TextStyle(color: Colors.blue.shade700, fontSize: 14),
  //         ),
  //         Text(
  //           'Support: support / support123',
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

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Check credentials
    if (_demoUsers.containsKey(username) &&
        _demoUsers[username]!['password'] == password) {
      final userRole = _demoUsers[username]!['role']!;

      setState(() {
        _isLoading = false;
      });

      // Navigate based on role
      _navigateToDashboard(userRole);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Incorrect username or password';
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
  // void _showForgotPasswordDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Forgot Password'),
  //       content: const Text('Reset password functionality coming soon!'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
