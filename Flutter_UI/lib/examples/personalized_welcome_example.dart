// Example of how the personalized welcome message works

import 'package:pharmaish/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:pharmaish/utils/helpers.dart';
import '../utils/storage.dart';

class PersonalizedWelcomeExample extends StatefulWidget {
  const PersonalizedWelcomeExample({super.key});

  @override
  State<PersonalizedWelcomeExample> createState() =>
      _PersonalizedWelcomeExampleState();
}

class _PersonalizedWelcomeExampleState
    extends State<PersonalizedWelcomeExample> {
  String _userName = 'Customer';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    //AppHelpers.disableScreenshots();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      // First try to get the stored first name
      final firstName = await StorageService.getUserName();

      if (firstName != null && firstName.isNotEmpty) {
        setState(() {
          _userName = firstName;
          _isLoading = false;
        });
      } else {
        // Fallback: Try to extract from JWT token
        final token = await StorageService.getAuthToken();
        if (token != null) {
          final tokenData = StorageService.decodeJwtToken(token);
          final userInfo = StorageService.extractUserInfo(tokenData);
          final extractedFirstName = userInfo['firstName'];

          if (extractedFirstName != null && extractedFirstName.isNotEmpty) {
            setState(() {
              _userName = extractedFirstName;
              _isLoading = false;
            });
            return;
          }
        }

        // Final fallback
        setState(() {
          _userName = 'Customer';
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Error loading user name: $e');
      setState(() {
        _userName = 'Customer';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalized Welcome Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Text(
                'Welcome, $_userName!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadUserName,
              child: const Text('Refresh Name'),
            ),
          ],
        ),
      ),
    );
  }
}

// Usage scenarios:
/*
1. User logs in with email "john.doe@example.com" and first name "John"
   → Dashboard shows: "Welcome, John!"

2. User logs in but no first name is stored
   → Dashboard shows: "Welcome, Customer!"

3. User updates their profile with new name "Sarah"
   → Dashboard shows: "Welcome, Sarah!" (after refresh)

4. Network error or token issues
   → Dashboard shows: "Welcome, Customer!" (fallback)
*/
