import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pharmaish/core/app_routes.dart';
import 'package:pharmaish/core/services/consent_service.dart';
import 'package:pharmaish/core/services/session_service.dart';
import 'package:pharmaish/utils/consent_manager.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:pharmaish/utils/app_logger.dart';

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

    // A stored token is only trusted while it is unexpired, and only if the
    // user chose Remember Me. An expired one used to open the dashboard anyway,
    // where every request then failed with 401; and without Remember Me the
    // session should end when the app is closed.
    var hadExpiredToken = false;
    try {
      final authToken = await StorageService.getAuthToken();

      if (authToken != null && authToken.isNotEmpty) {
        if (!await StorageService.isSessionPersistent()) {
          AppLogger.info('Session was not kept signed in; ending it');
        } else if (!StorageService.isTokenExpired(authToken)) {
          AppLogger.info('Valid token found, navigating to dashboard');
          final userInfo = StorageService.decodeJwtToken(authToken);
          final userRole = StorageService.extractUserRole(userInfo);
          if (mounted) {
            _navigateToDashboard(userRole);
          }
          return;
        } else {
          AppLogger.info('Stored token has expired');
          hadExpiredToken = true;
        }
        await StorageService.clearAuthTokens();
      }
    } catch (e) {
      AppLogger.error('Error checking auth token: $e');
    }

    // No usable token: sign in again with the Remember Me credentials, if saved.
    try {
      final renewal = await SessionService.renewSession();
      if (renewal == SessionRenewal.renewed && mounted) {
        final token = await StorageService.getAuthToken() ?? '';
        final role = StorageService.extractUserRole(
            StorageService.decodeJwtToken(token));
        await _checkAndShowTerms(role);
        return;
      }
    } catch (e) {
      AppLogger.error('Error during auto-login: $e');
    }

    // Otherwise go to login, explaining why if a session has just lapsed.
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.login,
        arguments:
            hadExpiredToken ? SessionService.sessionExpiredMessage : null,
      );
    }
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
      case 'DeliveryBoy':
        routeName = AppRoutes.deliveryDashboard;
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
            // App Logo — sized relative to screen width so it reads large.
            Image.asset(
              'assets/images/opening_logo_animated.png',
              fit: BoxFit.contain,
              width: MediaQuery.of(context).size.width * 0.75,
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
