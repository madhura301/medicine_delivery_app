import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pharmaish/core/app_routes.dart';
import 'package:pharmaish/core/services/consent_service.dart';
import 'package:pharmaish/utils/consent_manager.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pharmaish/utils/constants.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp(); // Directly initialize, no terms check here
    //AppHelpers.disableScreenshots();
  }

  // REMOVED: _checkFirstLaunchAndConsent() method
  // Terms will now be shown after login

  Future<void> _initializeApp() async {
    // Wait for minimum splash duration
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // First, check if user has a valid auth token (is currently logged in)
    try {
      final authToken = await StorageService.getAuthToken();
      
      // If there's a valid token, user is already logged in - go to dashboard
      if (authToken != null && authToken.isNotEmpty) {
        AppLogger.info('Valid token found, navigating to dashboard');
        
        // Decode token to get user role
        final userInfo = StorageService.decodeJwtToken(authToken);
        final userRole = StorageService.extractUserRole(userInfo);
        
        if (mounted) {
          _navigateToDashboard(userRole);
        }
        return;
      }
    } catch (e) {
      AppLogger.error('Error checking auth token: $e');
    }

    // No valid token, check if user wants to be auto-logged in
    try {
      final credentials = await StorageService.loadSavedCredentials();
      final rememberPassword = credentials['rememberPassword'] as bool;
      final username = credentials['username'] as String;
      final password = credentials['password'] as String;

      if (rememberPassword && username.isNotEmpty && password.isNotEmpty) {
        // Attempt auto-login
        AppLogger.info('Auto-login attempt for user: $username');
        final success = await _attemptAutoLogin(username, password);

        if (success && mounted) {
          // Auto-login successful, navigation already handled in _attemptAutoLogin
          return;
        }
      }
    } catch (e) {
      AppLogger.error('Error during auto-login check: $e');
    }

    // If no valid token and auto-login failed or not enabled, go to login page
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  Future<bool> _attemptAutoLogin(String username, String password) async {
    try {
      // Make API call to login
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/Auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'mobileNumber': username,
          'password': password,
          'stayLoggedIn': true
        }),
      ).timeout(const Duration(seconds: 10));

      AppLogger.info('Auto-login response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          // Extract and store tokens
          final token = responseData['token'];
          final refreshToken = responseData['refreshToken'];

          await StorageService.storeAuthTokens(
            token: token,
            refreshToken: refreshToken,
          );

          // Store user info
          final userInfo = StorageService.decodeJwtToken(token);
          final extractedUserInfo = StorageService.extractUserInfo(userInfo);
          
          if (extractedUserInfo.isNotEmpty) {
            await StorageService.storeUserInfo(extractedUserInfo);
          }

          // Store user ID if available
          final userId = responseData['userId'] ?? '';
          if (userId.isNotEmpty) {
            await StorageService.storeUserId(userId);
          }

          // Get role and navigate
          final role = extractedUserInfo['role'] ?? extractedUserInfo['Role'] ?? '';
          
          if (mounted) {
            // CHECK TERMS AFTER AUTO-LOGIN
            await _checkAndShowTerms(role);
          }

          return true;
        }
      }
    } catch (e) {
      AppLogger.error('Auto-login failed: $e');
    }

    return false;
  }

  // NEW METHOD: Check and show terms after auto-login
  Future<void> _checkAndShowTerms(String role) async {
    try {
      // Check if user has accepted terms
      final hasAcceptedTerms = await ConsentService.hasConsent(
        ConsentType.termsAndConditions,
      );

      if (!hasAcceptedTerms && mounted) {
        // Show terms dialog
        final accepted = await CustomerConsentManager.showTermsAndConditions(context);

        if (!accepted) {
          // User declined - logout and go back to login
          await StorageService.clearAuthTokens();
          if (mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          }
          return;
        }
      }

      // Terms accepted or already accepted, navigate to dashboard
      if (mounted) {
        _navigateToDashboard(role);
      }
    } catch (e) {
      AppLogger.error('Error checking terms: $e');
      // On error, still navigate to dashboard
      if (mounted) {
        _navigateToDashboard(role);
      }
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             // Add some top spacing to push logo slightly down from perfect center
            const SizedBox(height: 60),
            // App Logo with proper constraints to prevent stretching
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280, maxHeight: 150),
              child: Image.asset(
                'assets/images/full_logo_animated.png',
                fit: BoxFit.contain,
                width: 280,
                height: 150,
              ),
            ),
            const SizedBox(height: 50),
            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
            const SizedBox(height: 20),
            const Text(
              'Please wait...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
