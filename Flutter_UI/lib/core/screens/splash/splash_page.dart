import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pharmaish/core/app_routes.dart';
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
    //AppHelpers.disableScreenshots();
    _initializeApp();
  }

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

          // Extract user info from token
          final userInfo = StorageService.decodeJwtToken(token);
          final extractedUserInfo = StorageService.extractUserInfo(userInfo);
          
          if (extractedUserInfo.isNotEmpty) {
            await StorageService.storeUserInfo(extractedUserInfo);
          }

          // Store user ID
          final userId = responseData['userId'] ??
              responseData['id'] ??
              userInfo['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ??
              '';
          
          if (userId.isNotEmpty) {
            await StorageService.storeUserId(userId);
          }

          // Determine user role and navigate to appropriate dashboard
          final userRole = StorageService.extractUserRole(userInfo);
          
          if (mounted) {
            _navigateToDashboard(userRole);
          }

          return true;
        }
      }

      return false;
    } catch (e) {
      AppLogger.error('Auto-login failed: $e');
      return false;
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
