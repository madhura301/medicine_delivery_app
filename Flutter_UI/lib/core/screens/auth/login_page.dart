import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:convert' show base64Url, json, utf8;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Make API call
      final response = await http.post(
        Uri.parse('https://localhost:7000/api/Auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
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
          final errors = responseData['errors'];
          
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
        // Unauthorized - wrong credentials
        setState(() {
          _errorMessage = 'Incorrect email address or password';
        });
      } else if (response.statusCode == 400) {
        // Bad request - validation errors
        try {
          final errorData = jsonDecode(response.body);
          final errors = errorData['errors'] as List<dynamic>;
          setState(() {
            _errorMessage = errors.isNotEmpty 
                ? errors.first.toString() 
                : 'Invalid login details';
          });
        } catch (e) {
          setState(() {
            _errorMessage = 'Invalid login details';
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
    final email = userInfo['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'] ?? '';
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}