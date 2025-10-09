// Register Page - Complete Multi-Step Registration
import 'package:pharmaish/core/theme/app_theme.dart';
import 'package:pharmaish/shared/widgets/step_progress_indicator.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/core/services/auth_service.dart';

class CustomerRegisterPage extends StatefulWidget {
  const CustomerRegisterPage({super.key});

  @override
  State<CustomerRegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<CustomerRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  // Form Controllers - Required Fields
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _mobileController = TextEditingController();

  // Form Controllers - Optional Fields
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();

  String _selectedAddressType = 'Home'; // Default value
  final List<String> _addressTypes = ['Home', 'Office', 'Other'];
  
  // Other Form Data
  DateTime? _selectedDate;
  String? _selectedState;
  String? _selectedGender;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String _errorMessage = '';

  // Validation flags
  //bool _usernameAvailable = true;

  final List<String> _states = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Delhi',
    'Jammu and Kashmir',
    'Ladakh',
    'Lakshadweep',
    'Puducherry'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),

          // Form Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(), // Basic Information
                _buildStep2(), // Personal Details
                _buildStep3(), // Address & Final
              ],
            ),
          ),

          // Error Message
          if (_errorMessage.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
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
                      style:
                          TextStyle(color: Colors.red.shade600, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  
Widget _buildProgressIndicator() {
  return StepProgressIndicator(
    currentStep: _currentStep,
    steps: const [
      StepItem(label: 'Basic', icon: Icons.person),
      StepItem(label: 'Details', icon: Icons.info),
      StepItem(label: 'Address', icon: Icons.location_on),
    ],
  );
}

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildStepHeader(
              'Basic Information',
              'Create your account credentials',
              Icons.security,
            ),

            const SizedBox(height: 30),

            // Mobile Number Field (Primary identifier)
            TextFormField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(
                labelText: 'Mobile Number *',
                hintText: 'Enter 10-digit mobile number',
                prefixIcon: const Icon(Icons.phone_outlined),
                prefixText: '+91 ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
                counterText: '',
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Mobile number is required';
                }
                final phoneRegex = RegExp(r'^[6-9]\d{9}$');
                if (!phoneRegex.hasMatch(value!)) {
                  return 'Enter valid 10-digit mobile number';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  if (_errorMessage.contains('mobile') ||
                      _errorMessage.contains('exists')) {
                    _errorMessage = '';
                  }
                });
              },
            ),

            const SizedBox(height: 20),

            // Password Field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password *',
                hintText: 'Create a strong password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                      const BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Password is required';
                }
                if (value!.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                // Check for uppercase letter
                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                  return 'Password must contain at least 1 uppercase letter';
                }
                // Check for lowercase letter
                if (!RegExp(r'[a-z]').hasMatch(value)) {
                  return 'Password must contain at least 1 lowercase letter';
                }
                // Check for digit
                if (!RegExp(r'[0-9]').hasMatch(value)) {
                  return 'Password must contain at least 1 number';
                }
                // Check for special character
                if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                  return 'Password must contain at least 1 special character';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Confirm Password Field
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirm Password *',
                hintText: 'Re-enter your password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildStepHeader(
            'Personal Details',
            'Tell us more about yourself',
            Icons.badge,
          ),

          const SizedBox(height: 30),

          // First Name Field - Required
          TextFormField(
            controller: _firstNameController,
            decoration: InputDecoration(
              labelText: 'First Name *',
              hintText: 'Enter your first name',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'First name is required';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Last Name Field - Required
          TextFormField(
            controller: _lastNameController,
            decoration: InputDecoration(
              labelText: 'Last Name *',
              hintText: 'Enter your last name',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Last name is required';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Middle Name Field - Optional
          TextFormField(
            controller: _middleNameController,
            decoration: InputDecoration(
              labelText: 'Middle Name (Optional)',
              hintText: 'Enter your middle name',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address (Optional)',
              hintText: 'your.email@example.com',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final emailRegex =
                    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                if (!emailRegex.hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Date of Birth Field - Required
          GestureDetector(
            onTap: _selectDateOfBirth,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.grey),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Date of Birth *',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedDate != null
                            ? Colors.black87
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Gender Field - Optional
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: InputDecoration(
              labelText: 'Gender (Optional)',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
            items: ['Male', 'Female', 'Other'].map((String gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedGender = newValue;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildStepHeader(
            'Address Information',
            'Help us serve you better',
            Icons.location_on,
          ),

          const SizedBox(height: 30),

          // Address Type - Required
          DropdownButtonFormField<String>(
            value: _selectedAddressType,
            decoration: InputDecoration(
              labelText: 'Address Type *',
              prefixIcon: const Icon(Icons.label),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
            items: _addressTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedAddressType = newValue!;
              });
            },
          ),

          const SizedBox(height: 20),

          // Address Line 1 - Required
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Address Line 1 *',
              hintText: 'Building name, flat number',
              prefixIcon: const Icon(Icons.home_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // City Field - Required
          TextFormField(
            controller: _cityController,
            decoration: InputDecoration(
              labelText: 'City *',
              hintText: 'Enter city',
              prefixIcon: const Icon(Icons.location_city),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // State Field - Required
          DropdownButtonFormField<String>(
            value: _selectedState,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'State *',
              prefixIcon: const Icon(Icons.location_on),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
            items: _states.map((String state) {
              return DropdownMenuItem<String>(
                value: state,
                child: Text(state, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedState = newValue;
              });
            },
          ),

          const SizedBox(height: 20),

          // Postal Code Field - Required
          TextFormField(
            controller: _postalCodeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: 'Postal Code *',
              hintText: 'Enter 6-digit postal code',
              prefixIcon: const Icon(Icons.local_post_office),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
              counterText: '',
            ),
          ),

          const SizedBox(height: 30),

          // Summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Registration Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                    'Name: ${_firstNameController.text} ${_lastNameController.text}'),
                Text('Mobile: +91 ${_mobileController.text}'),
                if (_emailController.text.isNotEmpty)
                  Text('Email: ${_emailController.text}'),
                if (_selectedDate != null)
                  Text(
                      'DOB: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 40,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Back'),
              ),
            ),

          if (_currentStep > 0) const SizedBox(width: 16),

          // Next/Register Button
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text(_currentStep < 2 ? 'Next' : 'Register'),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    setState(() {
      _errorMessage = '';
    });

    if (_currentStep < 2) {
      if (_validateCurrentStep()) {
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _registerUser();
    }
  }

  void _previousStep() {
    setState(() {
      _currentStep--;
      _errorMessage = '';
    });
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _formKey.currentState?.validate() ?? false;
      case 1:
        // Validate required fields for step 2
        if (_firstNameController.text.isEmpty) {
          setState(() => _errorMessage = 'First name is required');
          return false;
        }
        if (_lastNameController.text.isEmpty) {
          setState(() => _errorMessage = 'Last name is required');
          return false;
        }
        if (_selectedDate == null) {
          setState(() => _errorMessage = 'Date of birth is required');
          return false;
        }
        // Validate email if provided
        if (_emailController.text.isNotEmpty) {
          final emailRegex =
              RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
          if (!emailRegex.hasMatch(_emailController.text)) {
            setState(
                () => _errorMessage = 'Please enter a valid email address');
            return false;
          }
        }
        return true;
      case 2:
        return true; // Address step is optional
      default:
        return false;
    }
  }

  Future<void> _registerUser() async {
    if (!_validateCurrentStep()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final token = await AuthService.invokeLogin(
          mobileNumber: AppConstants.adminMobileNumber,
          password: AppConstants.adminPassword,
          stayLoggedIn: false);

      if (token != null) {
        // Prepare registration data
        final Map<String, dynamic> registrationData = {
          'customerFirstName': _firstNameController.text.trim(),
          'customerLastName': _lastNameController.text.trim(),
          'mobileNumber': _mobileController.text.trim(),
          'password': _passwordController.text.trim(),
          'dateOfBirth': _selectedDate!.toIso8601String(),
        };

        // Add optional fields
        if (_middleNameController.text.trim().isNotEmpty) {
          registrationData['customerMiddleName'] =
              _middleNameController.text.trim();
        }

        if (_emailController.text.trim().isNotEmpty) {
          registrationData['emailId'] = _emailController.text.trim();
        }

        if (_selectedGender != null) {
          registrationData['gender'] = _selectedGender;
        }

        // Build address object matching DTO structure
        Map<String, dynamic> addressData = {
          'address': _selectedAddressType, // Home/Office/Other
          'addressLine1': _addressController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _selectedState!,
          'postalCode': _postalCodeController.text.trim(),
          'isDefault': true,
        };

        registrationData['addresses'] = [addressData];

        AppLogger.info('Registration Data: ${jsonEncode(registrationData)}');

        // Make API call
        final response = await http.post(
          Uri.parse('${AppConstants.apiBaseUrl}/Customers/register'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(registrationData),
        );

        setState(() {
          _isLoading = false;
        });

        AppLogger.info('Response status: ${response.statusCode}');
        AppLogger.info('Response body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = jsonDecode(response.body);

          if (responseData['success'] == true) {
            _showSuccessDialog();
          } else {
            final errors = responseData['errors'] as List<dynamic>?;
            setState(() {
              _errorMessage = errors?.isNotEmpty == true
                  ? errors!.first.toString()
                  : 'Registration failed. Please try again.';
            });
          }
        } else if (response.statusCode == 400) {
          try {
            final errorData = jsonDecode(response.body);
            final errors = errorData['errors'] as List<dynamic>?;
            setState(() {
              _errorMessage = errors?.isNotEmpty == true
                  ? errors!.first.toString()
                  : 'Invalid registration data. Please check your inputs.';
            });
          } catch (e) {
            setState(() {
              _errorMessage =
                  'Invalid registration data. Please check your inputs.';
            });
          }
        } else if (response.statusCode == 409) {
          setState(() {
            _errorMessage =
                'A customer with this mobile number already exists.';
          });
        } else {
          setState(() {
            _errorMessage = 'Server error. Please try again later.';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Authentication token not found. Please try again.';
        });
      }
    } catch (e) {
      AppLogger.error('Error during registration: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Network error. Please check your connection.';
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.all(24),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Registration Successful!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Welcome ${_firstNameController.text}!',
              style: const TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Steps:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Account created successfully\n'
                    '• Login with your mobile number\n'
                    '• Explore medicines and place orders',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to login
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Login Now',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // void _checkUsernameAvailability(String username) {
  //   setState(() {
  //     _usernameAvailable =
  //         !['admin', 'test', 'user'].contains(username.toLowerCase());
  //   });
  // }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
