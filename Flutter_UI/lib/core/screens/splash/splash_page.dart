import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pharmaish/core/app_routes.dart';

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
    
    // Navigate to login after 2 seconds
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const LoginPage()),
        // );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,//White background for splash screen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
