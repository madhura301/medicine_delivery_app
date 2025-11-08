import 'package:pharmaish/core/theme/app_theme.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pharmaish/core/app_routes.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberPassword = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    //AppHelpers.disableScreenshots();
    _loadSavedCredentials();
  }

  /// Load saved credentials if "Remember Password" was previously checked
  Future<void> _loadSavedCredentials() async {
    try {
      final credentials = await StorageService.loadSavedCredentials();

      if (credentials['rememberPassword'] == true &&
          credentials['username'].isNotEmpty &&
          credentials['password'].isNotEmpty) {
        setState(() {
          _userNameController.text = credentials['username'];
          _passwordController.text = credentials['password'];
          _rememberPassword = true;
        });
      }
    } catch (e) {
      //AppLogger.error('Error loading saved credentials: $e');
    }
  }

  /// Open Privacy Policy PDF
  Future<void> _openPrivacyPolicy() async {
    const String pdfUrl = '${AppConstants.documentsProdBaseUrl}/Privacy_Policy.pdf';
    // Alternative test URL: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf'
    
    try {
      final Uri uri = Uri.parse(pdfUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      AppLogger.error('Error opening Privacy Policy', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open Privacy Policy'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Open Terms and Conditions PDF
  Future<void> _openTermsAndConditions() async {
    const String pdfUrl = '${AppConstants.documentsProdBaseUrl}/Terms_and_Conditions.pdf';
    // Alternative test URL: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf'
    
    try {
      final Uri uri = Uri.parse(pdfUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      AppLogger.error('Error opening Terms and Conditions', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open Terms and Conditions'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      // Header
                      _buildHeader(),

                      const SizedBox(height: 20),

                      // User Name Field (Phone Number)
                      TextFormField(
                        controller: _userNameController,
                        maxLength: 100,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'User Name',
                          hintText: 'Enter your phone number',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppTheme.primaryColor, width: 2),
                          ),
                          counterText: '', // Hide character counter
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'User Name is required';
                          }
                          // Phone number validation - only allow numbers
                          final phoneRegex = RegExp(r'^[0-9]+$');
                          if (!phoneRegex.hasMatch(value!)) {
                            return 'User Name should contain only numbers';
                          }
                          if (value.length > 100) {
                            return 'User Name cannot exceed 100 characters';
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
                            borderSide: const BorderSide(
                                color: AppTheme.primaryColor, width: 2),
                          ),
                          counterText: '', // Hide character counter
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Password is required';
                          }

                          // Check minimum length (6 characters as per requirement)
                          if (value!.length < 6) {
                            return 'Password must be at least 6 characters';
                          }

                          // Check maximum length
                          if (value.length > 20) {
                            return 'Password cannot exceed 20 characters';
                          }

                          // Check for minimum 1 capital letter
                          if (!RegExp(r'[A-Z]').hasMatch(value)) {
                            return 'Password must contain at least 1 capital letter';
                          }

                          // Check for minimum 1 small letter
                          if (!RegExp(r'[a-z]').hasMatch(value)) {
                            return 'Password must contain at least 1 small letter';
                          }

                          // Check for minimum 1 special character
                          if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                            return 'Password must contain at least 1 special character';
                          }

                          // Check for minimum 1 numerical number
                          if (!RegExp(r'[0-9]').hasMatch(value)) {
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

                      const SizedBox(height: 16),

                      // Remember Password Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberPassword,
                            onChanged: (value) {
                              setState(() {
                                _rememberPassword = value ?? false;
                              });
                            },
                            activeColor: AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const Text(
                            'Remember Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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
                            backgroundColor: AppTheme.primaryColor,
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

                      const SizedBox(height: 30),

                      // Register Pharmacist Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account as a Pharmacist yet? ",
                                  style: TextStyle(color: Colors.grey.shade600),
                                  textAlign: TextAlign.center,
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, AppRoutes.registerPharmacist);
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 0),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Register as Pharmacy/Pharmacist',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Register Customer Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  "Don't have a Customer account yet? ",
                                  style: TextStyle(color: Colors.grey.shade600),
                                  textAlign: TextAlign.center,
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, AppRoutes.registerCustomer);
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 0),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Register as Customer',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Security Notice
                      if (_rememberPassword)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.security,
                                color: Colors.amber.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Your password will be saved securely on this device only.',
                                  style: TextStyle(
                                    color: Colors.amber.shade800,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Privacy Policy and Terms & Conditions Links at Bottom
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Privacy Policy - Left
                  GestureDetector(
                    onTap: _openPrivacyPolicy,
                    child: const Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Terms and Conditions - Right
                  GestureDetector(
                    onTap: _openTermsAndConditions,
                    child: const Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App Icon
         Image.asset(
          'assets/images/app_icon_animated_blue_tagline.png',
          width: 220,
          height: 100,
          fit: BoxFit.contain,
        ),

        const SizedBox(height: 1),

        // Welcome Text
        const Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
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
      // Save credentials using StorageService
      await StorageService.saveCredentials(
        username: _userNameController.text.trim(),
        password: _passwordController.text.trim(),
        rememberPassword: _rememberPassword,
      );

      final userName = _userNameController.text.trim();
      final password = _passwordController.text.trim();

      // Make API call
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/Auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'mobileNumber': userName,
          'password': password,
          'stayLoggedIn': _rememberPassword
        }),
      );

      setState(() {
        _isLoading = false;
      });
      AppLogger.info(
          'Login API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse response
        final responseData = jsonDecode(response.body);

        // Check if login was successful
        if (responseData['success'] == true) {
          // Extract data from response
          final token = responseData['token'];
          final refreshToken = responseData['refreshToken'];

          // Store tokens using StorageService
          await StorageService.storeAuthTokens(
            token: token,
            refreshToken: refreshToken,
          );

          AppLogger.info('Login successful!');
          AppLogger.info('Token: $token');
          AppLogger.info('Refresh Token: $refreshToken');

          // Decode JWT token to get user information using StorageService
          final userInfo = StorageService.decodeJwtToken(token);
          final extractedUserInfo = StorageService.extractUserInfo(userInfo);
          if (extractedUserInfo.isNotEmpty) {
            AppLogger.info('Extracted User Info: $extractedUserInfo');
            StorageService.storeUserInfo(extractedUserInfo);
          } else {
            AppLogger.info('No user info extracted from token');
          }
          final userId = responseData['userId'] ??
              responseData['id'] ??
              userInfo[
                  'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ??
              userInfo['id'] ??
              '';
          AppLogger.info('User ID: $userId');
          // Store user ID
          if (userId != null && userId.isNotEmpty) {
            await StorageService.storeUserId(userId);
          }
          final userRole = StorageService.extractUserRole(userInfo);

          AppLogger.info('User Role: $userRole');
          // Navigate to appropriate dashboard
          _navigateToDashboard(userRole);
        } else {
          // API returned success: false
          final errors = responseData['errors'] as List<dynamic>?;
          setState(() {
            _errorMessage = errors?.isNotEmpty == true
                ? errors!.first.toString()
                : 'Login failed. Please try again.';
          });
        }
      } else if (response.statusCode == 401) {
        // Unauthorized - wrong credentials
        setState(() {
          _errorMessage = 'Incorrect phone number or password';
        });
      } else if (response.statusCode == 400) {
        // Bad request - validation errors
        try {
          final errorData = jsonDecode(response.body);
          final errors = errorData['errors'] as List<dynamic>?;
          setState(() {
            _errorMessage = errors?.isNotEmpty == true
                ? errors!.first.toString()
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
        AppLogger.error('Error: $e'); // Logs error message
        _errorMessage = 'Network error. Please check your connection.';
      });
      AppLogger.error('Login error: $e');
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
      case 'CustomerSupport':
        routeName = AppRoutes.customerSupportDashboard;
        break;
      case 'Manager':
        routeName = AppRoutes.managerDashboard;
        break;
      default:
        routeName = AppRoutes.customerDashboard;
    }

    Navigator.pushReplacementNamed(context, routeName);
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}