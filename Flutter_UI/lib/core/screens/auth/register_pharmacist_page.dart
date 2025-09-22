import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:medicine_delivery_app/core/services/auth_service.dart';
import 'package:medicine_delivery_app/core/services/location-service.dart';
import 'package:medicine_delivery_app/utils/constants.dart';
import 'package:medicine_delivery_app/utils/storage.dart';

class PharmacistRegistrationPage extends StatefulWidget {
  const PharmacistRegistrationPage({super.key});

  @override
  State<PharmacistRegistrationPage> createState() =>
      _PharmacistRegistrationPageState();
}

class _PharmacistRegistrationPageState
    extends State<PharmacistRegistrationPage> {
  final LocationService _locationService = LocationService();
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  // Pharmacy Details Controllers
  final _pharmacyNameController = TextEditingController();
  final _ownerFirstNameController = TextEditingController();
  final _ownerLastNameController = TextEditingController();
  final _ownerMiddleNameController = TextEditingController();
  final _gstNumberController = TextEditingController();
  final _userNameController = TextEditingController(); // Mobile Number
  final _postalCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _alternativeMobileController = TextEditingController();
  final _panController = TextEditingController();
  final _fssaiController = TextEditingController();
  final _dlController = TextEditingController();

  // Address Controllers
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  // Pharmacist Details Controllers
  final _pharmacistFirstNameController = TextEditingController();
  final _pharmacistLastNameController = TextEditingController();
  final _pharmacistRegNumberController = TextEditingController();
  final _pharmacistMobileController = TextEditingController();

  // Form States
  bool _isGstRegistered = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _errorMessage = '';
  double? _latitude;
  double? _longitude;
  String _locationText = 'Tap to select location';

  String? _selectedState;
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
        title: const Text('Pharmacist Registration'),
        backgroundColor: const Color(0xFF2E7D32),
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
                _buildPharmacyDetailsStep(),
                _buildAddressStep(),
                _buildPharmacistDetailsStep(),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStepIndicator(0, 'Pharmacy\nDetails'),
          Expanded(child: _buildStepConnector(0)),
          _buildStepIndicator(1, 'Address'),
          Expanded(child: _buildStepConnector(1)),
          _buildStepIndicator(2, 'Pharmacist\nDetails'),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String title) {
    bool isActive = _currentStep >= step;
    bool isCurrent = _currentStep == step;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFF2E7D32) : Colors.grey.shade300,
            border: Border.all(
              color: isCurrent ? const Color(0xFF2E7D32) : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Center(
            child: isActive && _currentStep > step
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isCurrent ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? const Color(0xFF2E7D32) : Colors.grey.shade600,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStepConnector(int step) {
    bool isCompleted = _currentStep > step;
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 30),
      color: isCompleted ? const Color(0xFF2E7D32) : Colors.grey.shade300,
    );
  }

  Widget _buildPharmacyDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About Pharmacy',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 20),

          // Pharmacy/Firm Name
          _buildTextField(
            controller: _pharmacyNameController,
            label: 'Pharmacy/Firm Name *',
            hint: 'Enter pharmacy or firm name',
            icon: Icons.local_pharmacy,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Pharmacy name is required' : null,
          ),

          const SizedBox(height: 20),

          // Owner Details Section
          const Text(
            'Owner Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _ownerFirstNameController,
                  label: 'First Name *',
                  hint: 'First name',
                  icon: Icons.person,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'First name is required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _ownerLastNameController,
                  label: 'Last Name *',
                  hint: 'Last name',
                  icon: Icons.person,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Last name is required' : null,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildTextField(
            controller: _ownerMiddleNameController,
            label: 'Middle Name (Optional)',
            hint: 'Middle name',
            icon: Icons.person_outline,
          ),

          const SizedBox(height: 20),

          // GST Registration Section
          const Text(
            'GST Registration',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                RadioListTile<bool>(
                  title: const Text('GST Registered'),
                  value: true,
                  groupValue: _isGstRegistered,
                  activeColor: const Color(0xFF2E7D32),
                  onChanged: (value) {
                    setState(() {
                      _isGstRegistered = value!;
                    });
                  },
                ),
                RadioListTile<bool>(
                  title: const Text('GST Un-Registered'),
                  value: false,
                  groupValue: _isGstRegistered,
                  activeColor: const Color(0xFF2E7D32),
                  onChanged: (value) {
                    setState(() {
                      _isGstRegistered = value!;
                      if (!_isGstRegistered) {
                        _gstNumberController.clear();
                      }
                    });
                  },
                ),
              ],
            ),
          ),

          if (_isGstRegistered) ...[
            const SizedBox(height: 16),
            _buildTextField(
              controller: _gstNumberController,
              label: 'GST Number *',
              hint: 'Enter GST number',
              icon: Icons.receipt_long,
              validator: (value) {
                if (_isGstRegistered && (value?.isEmpty ?? true)) {
                  return 'GST number is required';
                }
                if (_isGstRegistered && value!.length != 15) {
                  return 'GST number should be 15 characters';
                }
                return null;
              },
            ),
          ],

          const SizedBox(height: 20),

          // Login Details Section
          const Text(
            'Login Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),

          // Main mobile number field
          _buildTextField(
            controller: _userNameController,
            label: 'User Name (Mobile Number) *',
            hint: 'Enter 10-digit mobile number',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Mobile number is required';
              }
              final phoneRegex = RegExp(r'^[6-9]\d{9}$');
              if (!phoneRegex.hasMatch(value!)) {
                return 'Enter valid 10-digit mobile number';
              }
              if (value == _alternativeMobileController.text &&
                  _alternativeMobileController.text.isNotEmpty) {
                return 'Mobile number cannot be same as alternative number';
              }
              return null;
            },
            onChanged: (value) {
              // Clear any previous errors and trigger validation refresh
              setState(() {
                if (_errorMessage.contains('same')) {
                  _errorMessage = '';
                }
              });
            },
          ),

          const SizedBox(height: 16),

          _buildTextField(
            controller: _passwordController,
            label: 'Password *',
            hint: 'Enter password',
            icon: Icons.lock,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Password is required';
              }
              if (value!.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          _buildTextField(
            controller: _emailController,
            label: 'Email ID (Optional)',
            hint: 'Enter email address',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              // Since it's optional, allow empty values
              if (value == null || value.isEmpty) {
                return null; // No validation error for empty optional field
              }

              // If user enters something, validate email format
              final emailRegex =
                  RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email address';
              }

              // Check for reasonable email length
              if (value.length > 50) {
                return 'Email address is too long';
              }

              // Basic format checks
              if (!value.contains('@') || !value.contains('.')) {
                return 'Please enter a valid email address';
              }

              // Check for multiple @ signs
              if (value.split('@').length > 2) {
                return 'Email address can only contain one @ symbol';
              }

              // Check domain has at least one dot after @
              String domain = value.split('@').last;
              if (!domain.contains('.') ||
                  domain.startsWith('.') ||
                  domain.endsWith('.')) {
                return 'Please enter a valid email domain';
              }

              return null;
            },
            onChanged: (value) {
              // Clear email-related error messages when user types
              setState(() {
                if (_errorMessage.contains('email') ||
                    _errorMessage.contains('Email')) {
                  _errorMessage = '';
                }
              });
            },
          ),
          const SizedBox(height: 16),

          // Alternative mobile number field
          _buildTextField(
            controller: _alternativeMobileController,
            label: 'Alternative Mobile Number *',
            hint: 'Enter alternative mobile number',
            icon: Icons.phone_android,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Alternative mobile number is required';
              }
              final phoneRegex = RegExp(r'^[6-9]\d{9}$');
              if (!phoneRegex.hasMatch(value!)) {
                return 'Enter valid 10-digit mobile number';
              }
              if (value == _userNameController.text &&
                  _userNameController.text.isNotEmpty) {
                return 'Alternative number cannot be same as main mobile number';
              }
              return null;
            },
            onChanged: (value) {
              // Clear any previous errors and trigger validation refresh
              setState(() {
                if (_errorMessage.contains('same')) {
                  _errorMessage = '';
                }
              });
            },
          ),
          const SizedBox(height: 20),

          // License Details Section
          const Text(
            'License Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _panController,
            label: 'PAN Number *',
            hint: 'Enter PAN number',
            icon: Icons.credit_card,
            textCapitalization: TextCapitalization.characters,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'PAN number is required';
              }
              final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
              if (!panRegex.hasMatch(value!)) {
                return 'Enter valid PAN number (e.g., ABCDE1234F)';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          _buildTextField(
            controller: _fssaiController,
            label: 'FSSAI Number *',
            hint: 'Enter FSSAI license number',
            icon: Icons.verified_user,
            validator: (value) =>
                value?.isEmpty ?? true ? 'FSSAI number is required' : null,
          ),

          const SizedBox(height: 16),

          _buildTextField(
            controller: _dlController,
            label: 'Drug License Number *',
            hint: 'Enter drug license number',
            icon: Icons.medical_services,
            validator: (value) => value?.isEmpty ?? true
                ? 'Drug license number is required'
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Address Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _addressLine1Controller,
            label: 'Address Line 1 *',
            hint: 'Building name, street name',
            icon: Icons.location_on,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Address Line 1 is required' : null,
          ),

          const SizedBox(height: 16),

          _buildTextField(
            controller: _addressLine2Controller,
            label: 'Address Line 2',
            hint: 'Area, landmark',
            icon: Icons.location_on_outlined,
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildTextField(
                  controller: _cityController,
                  label: 'City *',
                  hint: 'Enter city',
                  icon: Icons.location_city,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'City is required' : null,
                ),
              ),
              const SizedBox(width: 8), // Reduced from 12 to 8
              Expanded(
                flex: 1,
                child: _buildDropdownField(),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildTextField(
            controller: _postalCodeController,
            label: 'Postal Code (Optional)',
            hint: 'Enter postal code',
            icon: Icons.local_post_office,
            keyboardType: TextInputType.number,
            maxLength: 6,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (value.length != 6) {
                  return 'Postal code should be 6 digits';
                }
                if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                  return 'Postal code should contain only numbers';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Geolocation Section
          const Text(
            'Geolocation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.map, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 8),
                    const Text(
                      'Location:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _locationText,
                  style: TextStyle(
                    color:
                        _latitude != null ? Colors.black : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _checkLocationAndRequest, //_getCurrentLocation,
                  icon: const Icon(Icons.my_location),
                  label: Text(_latitude != null
                      ? 'Update Location'
                      : 'Select Current Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacistDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pharmacist Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _pharmacistFirstNameController,
                  label: 'First Name *',
                  hint: 'First name',
                  icon: Icons.person,
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Pharmacist first name is required'
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _pharmacistLastNameController,
                  label: 'Last Name *',
                  hint: 'Last name',
                  icon: Icons.person,
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Pharmacist last name is required'
                      : null,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildTextField(
            controller: _pharmacistRegNumberController,
            label: 'Pharmacist Registration Number *',
            hint: 'Enter pharmacist registration number',
            icon: Icons.badge,
            validator: (value) => value?.isEmpty ?? true
                ? 'Pharmacist registration number is required'
                : null,
          ),

          const SizedBox(height: 16),

          _buildTextField(
            controller: _pharmacistMobileController,
            label: 'Pharmacist Mobile Number *',
            hint: 'Enter pharmacist mobile number',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Pharmacist mobile number is required';
              }
              final phoneRegex = RegExp(r'^[6-9]\d{9}$');
              if (!phoneRegex.hasMatch(value!)) {
                return 'Enter valid 10-digit mobile number';
              }
              return null;
            },
          ),

          const SizedBox(height: 40),

          // Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Registration Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                    'Please review all information before submitting your registration.'),
                const SizedBox(height: 8),
                const Text(
                  '• Your application will be reviewed by our team\n'
                  '• You will receive a confirmation email/SMS once approved\n',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      String? hint,
      IconData? icon,
      Widget? suffixIcon,
      bool obscureText = false,
      TextInputType? keyboardType,
      int? maxLength,
      TextCapitalization textCapitalization = TextCapitalization.none,
      String? Function(String?)? validator,
      void Function(String)? onChanged}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon:
            icon != null ? Icon(icon, color: const Color(0xFF2E7D32)) : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
        ),
        counterText: maxLength != null ? '' : null,
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedState,
      isExpanded: true, // Add this line to prevent overflow
      decoration: InputDecoration(
        labelText: 'State *',
        prefixIcon: const Icon(Icons.location_on, color: Color(0xFF2E7D32)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 16), // Add this
      ),
      items: _states.map((String state) {
        return DropdownMenuItem<String>(
          value: state,
          child: Text(
            state,
            overflow: TextOverflow.ellipsis, // Add this to handle long text
            style: const TextStyle(fontSize: 14), // Smaller font if needed
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedState = newValue;
        });
      },
      validator: (value) => value == null ? 'Please select a state' : null,
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2E7D32),
                  side: const BorderSide(color: Color(0xFF2E7D32)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : (_currentStep < 2 ? _nextStep : _submitRegistration),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : Text(_currentStep < 2 ? 'Next' : 'Submit Registration'),
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

    // Validate current step
    if (!_validateCurrentStep()) return;

    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _errorMessage = '';
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _validatePharmacyDetails();
      case 1:
        return _validateAddressDetails();
      case 2:
        return _validatePharmacistDetails();
      default:
        return false;
    }
  }

  bool _validatePharmacyDetails() {
    if (_pharmacyNameController.text.isEmpty) {
      setState(() => _errorMessage = 'Pharmacy name is required');
      return false;
    }
    if (_ownerFirstNameController.text.isEmpty) {
      setState(() => _errorMessage = 'Owner first name is required');
      return false;
    }
    if (_ownerLastNameController.text.isEmpty) {
      setState(() => _errorMessage = 'Owner last name is required');
      return false;
    }
    if (_isGstRegistered && _gstNumberController.text.isEmpty) {
      setState(() =>
          _errorMessage = 'GST number is required for registered pharmacy');
      return false;
    }
    if (_userNameController.text.isEmpty) {
      setState(() => _errorMessage = 'Mobile number is required');
      return false;
    }
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(_userNameController.text)) {
      setState(() => _errorMessage = 'Enter valid 10-digit mobile number');
      return false;
    }
    if (_passwordController.text.isEmpty ||
        _passwordController.text.length < 8) {
      setState(() => _errorMessage = 'Password must be at least 8 characters');
      return false;
    }
    if (_alternativeMobileController.text.isEmpty) {
      setState(() => _errorMessage = 'Alternative mobile number is required');
      return false;
    }
    if (_panController.text.isEmpty) {
      setState(() => _errorMessage = 'PAN number is required');
      return false;
    }
    if (_fssaiController.text.isEmpty) {
      setState(() => _errorMessage = 'FSSAI number is required');
      return false;
    }
    if (_dlController.text.isEmpty) {
      setState(() => _errorMessage = 'Drug license number is required');
      return false;
    }
    if (_userNameController.text == _alternativeMobileController.text) {
      setState(() => _errorMessage =
          'Mobile number and alternative mobile number must be different');
      return false;
    }
    // Email validation (only if provided)
    if (_emailController.text.isNotEmpty) {
      final emailRegex =
          RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(_emailController.text)) {
        setState(() => _errorMessage = 'Please enter a valid email address');
        return false;
      }
      if (_emailController.text.length > 50) {
        setState(() =>
            _errorMessage = 'Email address must be less than 50 characters');
        return false;
      }
    }
    return true;
  }

  bool _validateAddressDetails() {
    if (_addressLine1Controller.text.isEmpty) {
      setState(() => _errorMessage = 'Address Line 1 is required');
      return false;
    }
    if (_cityController.text.isEmpty) {
      setState(() => _errorMessage = 'City is required');
      return false;
    }
    if (_selectedState == null) {
      setState(() => _errorMessage = 'Please select a state');
      return false;
    }
    return true;
  }

  bool _validatePharmacistDetails() {
    if (_pharmacistFirstNameController.text.isEmpty) {
      setState(() => _errorMessage = 'Pharmacist first name is required');
      return false;
    }
    if (_pharmacistLastNameController.text.isEmpty) {
      setState(() => _errorMessage = 'Pharmacist last name is required');
      return false;
    }
    if (_pharmacistRegNumberController.text.isEmpty) {
      setState(
          () => _errorMessage = 'Pharmacist registration number is required');
      return false;
    }
    if (_pharmacistMobileController.text.isEmpty) {
      setState(() => _errorMessage = 'Pharmacist mobile number is required');
      return false;
    }
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(_pharmacistMobileController.text)) {
      setState(() => _errorMessage = 'Enter valid pharmacist mobile number');
      return false;
    }
    return true;
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _locationText = 'Getting your location...';
      _errorMessage = '';
    });

    try {
      final LocationResult result = await _locationService.getCurrentLocation(
        includeAddress: true,
        timeLimit: const Duration(seconds: 20),
      );

      setState(() {
        if (result.isValid) {
          _latitude = result.latitude;
          _longitude = result.longitude;

          // Format the location text based on whether we have an address
          if (result.address != null && result.address!.isNotEmpty) {
            _locationText = '${result.address}\n'
                'Lat: ${result.latitude.toStringAsFixed(6)}, '
                'Long: ${result.longitude.toStringAsFixed(6)}';
          } else {
            _locationText = 'Location selected\n'
                'Lat: ${result.latitude.toStringAsFixed(6)}, '
                'Long: ${result.longitude.toStringAsFixed(6)}';
          }
          _errorMessage = '';
        } else {
          _errorMessage = result.error ?? 'Unable to get location';
          _locationText = 'Tap to select location';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Network error. Please check your connection and try again.';
        _locationText = 'Tap to select location';
      });
      print('Location error: $e');
    }
  }

  Future<void> _checkLocationAndRequest() async {
    bool isAvailable = await _locationService.isLocationServiceAvailable();

    if (!isAvailable) {
      // Try to request permission first
      bool granted = await _locationService.requestLocationPermission();
      if (granted) {
        _getCurrentLocation();
      } else {
        setState(() {
          _errorMessage = 'Location permission is required to continue.';
          _locationText = 'Tap to select location';
        });
      }
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _submitRegistration() async {
    if (!_validateCurrentStep()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

// Get stored token for making authenticated requests
    final token = await AuthService.invokeLogin(
        mobileNumber: '9999999999', password: 'Admin@123', stayLoggedIn: false);

    if (token != null) {
      try {
        // Prepare registration data
        final registrationData = {
          'medicalName': _pharmacyNameController.text.trim(),
          'ownerFirstName': _ownerFirstNameController.text.trim(),
          'ownerLastName': _ownerLastNameController.text.trim(),
          'ownerMiddleName': _ownerMiddleNameController.text.trim(),
          'mobileNumber': _userNameController.text.trim(),
          'alternativeMobileNumber': _alternativeMobileController.text.trim(),
          //'password': _passwordController.text.trim(),
          'emailId': _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
          'registrationStatus': _isGstRegistered,
          'gSTIN': _isGstRegistered ? _gstNumberController.text.trim() : null,
          'pAN': _panController.text.trim(),
          'fSSAINo': _fssaiController.text.trim(),
          'dLNo': _dlController.text.trim(),
          'addressLine1': _addressLine1Controller.text.trim(),
          'addressLine2': _addressLine2Controller.text.trim(),
          'city': _cityController.text.trim(),
          'state': _selectedState,
          'postalCode': _postalCodeController.text.trim().isNotEmpty
              ? _postalCodeController.text.trim()
              : null,
          'latitude': _latitude,
          'longitude': _longitude,
          'pharmacistFirstName': _pharmacistFirstNameController.text.trim(),
          'pharmacistLastName': _pharmacistLastNameController.text.trim(),
          'pharmacistRegistrationNumber':
              _pharmacistRegNumberController.text.trim(),
          'pharmacistMobileNumber': _pharmacistMobileController.text.trim(),
        };
        print('Registration Data: ${jsonEncode(registrationData)}');
        // Make API call
        final response = await http.post(
          Uri.parse('${AppConstants.apiBaseUrl}/MedicalStores/register'),
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
        print('Response status: ${response.statusCode}');
        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = jsonDecode(response.body);

          if (responseData['success'] == true) {
            // Registration successful
            _showSuccessDialog();
          } else {
            // API returned success: false
            final errors = responseData['errors'] as List<dynamic>?;
            setState(() {
              _errorMessage = errors?.isNotEmpty == true
                  ? errors!.first.toString()
                  : 'Registration failed. Please try again.';
            });
          }
        } else if (response.statusCode == 400) {
          // Bad request - validation errors
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
          // Conflict - user already exists
          setState(() {
            _errorMessage =
                'A pharmacy with this mobile number already exists.';
          });
        } else {
          // Other server errors
          setState(() {
            _errorMessage = 'Server error. Please try again later.';
          });
        }
      } catch (e) {
        print('Error during registration: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = 'Network error. Please check your connection.';
        });
        print('Registration error: $e');
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Authentication token not found. Please log in again.';
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Registration Submitted',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your pharmacist registration has been submitted successfully!',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Steps:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Your application will be reviewed by our team\n'
                      '• You will receive a confirmation email/SMS\n',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to login page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Back to Login'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // Dispose all controllers
    _pharmacyNameController.dispose();
    _ownerFirstNameController.dispose();
    _ownerLastNameController.dispose();
    _ownerMiddleNameController.dispose();
    _gstNumberController.dispose();
    _userNameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _alternativeMobileController.dispose();
    _panController.dispose();
    _fssaiController.dispose();
    _dlController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pharmacistFirstNameController.dispose();
    _pharmacistLastNameController.dispose();
    _pharmacistRegNumberController.dispose();
    _pharmacistMobileController.dispose();
    _pageController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }
}
