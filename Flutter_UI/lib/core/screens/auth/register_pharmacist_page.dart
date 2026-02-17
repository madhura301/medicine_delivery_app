import 'dart:async';
import 'package:pharmaish/core/theme/app_theme.dart';
import 'package:pharmaish/shared/widgets/step_progress_indicator.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pharmaish/core/services/auth_service.dart';
import 'package:pharmaish/core/services/location_service.dart';
import 'package:pharmaish/utils/consent_manager.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // Business Type Selection
  String? _businessType; // 'Retailer', 'Distributor/Wholesaler', 'Both'

  // Firm Details Controllers
  final _firmNameController = TextEditingController();
  final _ownerFirstNameController = TextEditingController();
  final _ownerLastNameController = TextEditingController();
  final _ownerMiddleNameController = TextEditingController();
  final _dlRetailerController = TextEditingController();
  final _dlWholesalerController = TextEditingController();
  final _gstNumberController = TextEditingController();
  final _fssaiController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _panController = TextEditingController();

  // Address Controllers
  final _cityController = TextEditingController();

  // Registered Pharmacist Controllers
  final _pharmacistFirstNameController = TextEditingController();
  final _pharmacistLastNameController = TextEditingController();
  final _pharmacistRegNumberController = TextEditingController();
  final _spcController = TextEditingController();

  // Login Credentials Controllers
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();

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

  Future<void> _openAreaRetailerPolicy() async {
    const String pdfUrl =
        '${AppConstants.documentsProdBaseUrl}/AREA_RETAILER_POLICY.pdf';
    // Test URL: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf'

    try {
      final Uri uri = Uri.parse(pdfUrl);

      try {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        AppLogger.info('External app launch failed, trying browser mode');
        await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
      }
    } catch (e) {
      AppLogger.error('Error opening Area Retailer Policy', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open policy document'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Pharmacist Registration'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildBusinessTypeStep(),
                _buildFirmDetailsStep(),
                _buildPharmacistDetailsStep(),
                _buildLoginCredentialsStep(),
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
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return StepProgressIndicator(
      currentStep: _currentStep,
      steps: const [
        StepItem(label: 'Business\nType', icon: Icons.business),
        StepItem(label: 'Firm\nDetails', icon: Icons.store),
        StepItem(label: 'Pharmacist\nInfo', icon: Icons.person),
        StepItem(label: 'Credentials', icon: Icons.lock),
      ],
    );
  }

  // Step 1: Business Type Selection
  Widget _buildBusinessTypeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Business Type',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose your business category',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          _buildBusinessTypeOption('Retailer', Icons.store),
          const SizedBox(height: 16),
          _buildBusinessTypeOption('Distributor/Wholesaler', Icons.warehouse),
          const SizedBox(height: 16),
          _buildBusinessTypeOption('Both', Icons.business),
          const SizedBox(height: 32),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildBusinessTypeOption(String type, IconData icon) {
    final isSelected = _businessType == type;
    return InkWell(
      onTap: () => setState(() => _businessType = type),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.white,
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                type,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppTheme.primaryColor : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  // Step 2: Firm Details
  Widget _buildFirmDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Firm Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),

            // 1. Firm Name
            _buildTextField(
              controller: _firmNameController,
              label: 'Firm Name*',
              hint: 'Enter firm name',
              icon: Icons.business,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Firm name is required' : null,
            ),
            const SizedBox(height: 16),

            // 2. Owner Name
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _ownerFirstNameController,
                    label: 'Owner First Name*',
                    hint: 'First name',
                    icon: Icons.person,
                    validator: (value) => value?.isEmpty ?? true
                        ? 'First name is required'
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _ownerLastNameController,
                    label: 'Last Name*',
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
              label: 'Owner Middle Name (Optional)',
              hint: 'Middle name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),

            // 3. Drug Licence Numbers based on business type
            if (_businessType == 'Retailer' || _businessType == 'Both')
              _buildTextField(
                controller: _dlRetailerController,
                label: 'Drug Licence Number - Retailer*',
                hint: 'Enter retailer drug license',
                icon: Icons.card_membership,
                validator: (value) => value?.isEmpty ?? true
                    ? 'Retailer Drug Licence No. is required'
                    : null,
              ),
            if (_businessType == 'Retailer' || _businessType == 'Both')
              const SizedBox(height: 16),

            if (_businessType == 'Distributor/Wholesaler' ||
                _businessType == 'Both')
              _buildTextField(
                controller: _dlWholesalerController,
                label: 'Drug Licence Number - Wholeseller*',
                hint: 'Enter wholeseller drug license',
                icon: Icons.card_membership,
                validator: (value) => value?.isEmpty ?? true
                    ? 'Wholeseller Drug Licence No. is required'
                    : null,
              ),
            if (_businessType == 'Distributor/Wholeseller' ||
                _businessType == 'Both')
              const SizedBox(height: 16),

            // 4. GST No - Registered/Unregistered
            const Text(
              'GST Registration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
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
                    activeColor: AppTheme.primaryColor,
                    onChanged: (value) {
                      setState(() => _isGstRegistered = value!);
                    },
                  ),
                  RadioListTile<bool>(
                    title: const Text('GST Un-Registered'),
                    value: false,
                    groupValue: _isGstRegistered,
                    activeColor: AppTheme.primaryColor,
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
                label: 'GST Number*',
                hint: 'Enter 15-digit GST number',
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
            const SizedBox(height: 16),

            // 5. FSSAI
            _buildTextField(
              controller: _fssaiController,
              label: 'FSSAI Number*',
              hint: 'Enter FSSAI license number',
              icon: Icons.verified_user,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'FSSAI number is required' : null,
            ),
            const SizedBox(height: 16),

            // 6. Address
            const Text(
              'Address Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),

            _buildTextField(
              controller: _addressLine1Controller,
              label: 'Address Line 1*',
              hint: 'Building name, street',
              icon: Icons.location_on,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Address is required' : null,
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
                  child: _buildTextField(
                    controller: _cityController,
                    label: 'City*',
                    hint: 'City',
                    icon: Icons.location_city,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'City is required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdownField(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 7. Pin Code
            _buildTextField(
              controller: _postalCodeController,
              label: 'Pin Code*',
              hint: 'Enter 6-digit pin code',
              icon: Icons.pin,
              keyboardType: TextInputType.number,
              maxLength: 6,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Pin code is required';
                if (value!.length != 6) return 'Pin code must be 6 digits';
                if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                  return 'Pin code should contain only numbers';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 8. Contact Number
            _buildTextField(
              controller: _contactNumberController,
              label: 'Contact Number*',
              hint: 'Enter 10-digit mobile',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Contact number is required';
                final phoneRegex = RegExp(r'^[6-9]\d{9}$');
                if (!phoneRegex.hasMatch(value!)) {
                  return 'Enter valid 10-digit mobile number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 9. PAN
            _buildTextField(
              controller: _panController,
              label: 'PAN Number*',
              hint: 'Enter PAN (e.g., ABCDE1234F)',
              icon: Icons.credit_card,
              textCapitalization: TextCapitalization.characters,
              maxLength: 10,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'PAN is required';
                final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
                if (!panRegex.hasMatch(value!)) {
                  return 'Enter valid PAN (e.g., ABCDE1234F)';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Geolocation
            const Text(
              'Geolocation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
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
                      const Icon(Icons.map, color: AppTheme.primaryColor),
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
                      color: _latitude != null
                          ? Colors.black
                          : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _checkLocationAndRequest,
                    icon: const Icon(Icons.my_location),
                    label: Text(_latitude != null
                        ? 'Update Location'
                        : 'Select Current Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  // Step 3: Registered Pharmacist Details
  Widget _buildPharmacistDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Registered Pharmacist Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),

            // 1. Pharmacist Name
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _pharmacistFirstNameController,
                    label: 'First Name*',
                    hint: 'First name',
                    icon: Icons.person,
                    validator: (value) => value?.isEmpty ?? true
                        ? 'First name is required'
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _pharmacistLastNameController,
                    label: 'Last Name*',
                    hint: 'Last name',
                    icon: Icons.person,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Last name is required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Registration Number
            _buildTextField(
              controller: _pharmacistRegNumberController,
              label: 'Registration Number*',
              hint: 'Pharmacist registration number',
              icon: Icons.badge,
              validator: (value) => value?.isEmpty ?? true
                  ? 'Registration number is required'
                  : null,
            ),
            const SizedBox(height: 16),

            // 3. Single Point of Contact (SPC)
            _buildTextField(
              controller: _spcController,
              label: 'Single Point of Contact (SPC)*',
              hint: 'Enter 10-digit mobile',
              icon: Icons.contact_phone,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'SPC is required';
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
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Registration Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text('Please review all information before proceeding.'),
                  SizedBox(height: 8),
                  Text(
                    '• Create login credentials in the next step\n'
                    '• Your application will be reviewed by our team\n'
                    '• You will receive confirmation email/SMS',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  // Step 4: Login Credentials
  Widget _buildLoginCredentialsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Login Credentials',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),

            _buildTextField(
              controller: _userNameController,
              label: 'Username (Mobile Number)*',
              hint: 'Enter 10-digit mobile',
              icon: Icons.person_outline,
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
                if (value == _spcController.text &&
                    _spcController.text.isNotEmpty) {
                  return 'Cannot be same as SPC number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _emailController,
              label: 'Email (Optional)',
              hint: 'Enter email address',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null;
                }
                final emailRegex =
                    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                if (!emailRegex.hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                if (value.length > 50) {
                  return 'Email address is too long';
                }
                if (value.split('@').length > 2) {
                  return 'Email address can only contain one @ symbol';
                }
                String domain = value.split('@').last;
                if (!domain.contains('.') ||
                    domain.startsWith('.') ||
                    domain.endsWith('.')) {
                  return 'Please enter a valid email domain';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _passwordController,
              label: 'Password*',
              hint: 'Enter password',
              icon: Icons.lock,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Password is required';
                }
                if (value!.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                  return 'Must contain at least 1 uppercase letter';
                }
                if (!RegExp(r'[a-z]').hasMatch(value)) {
                  return 'Must contain at least 1 lowercase letter';
                }
                if (!RegExp(r'[0-9]').hasMatch(value)) {
                  return 'Must contain at least 1 number';
                }
                if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                  return 'Must contain at least 1 special character';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password Requirements:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• At least 8 characters\n'
                    '• 1 uppercase letter (A-Z)\n'
                    '• 1 lowercase letter (a-z)\n'
                    '• 1 number (0-9)\n'
                    '• 1 special character (!@#\$%^&*)',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Area Retailer Policy Link
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.picture_as_pdf,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Important Policy Document',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: _openAreaRetailerPolicy,
                          child: const Text(
                            'View Area Retailer Policy',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _openAreaRetailerPolicy,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.open_in_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    Widget? suffixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
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
            icon != null ? Icon(icon, color: AppTheme.primaryColor) : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        counterText: maxLength != null ? '' : null,
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedState,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'State *',
        prefixIcon: const Icon(Icons.map, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      items: _states.map((String state) {
        return DropdownMenuItem<String>(
          value: state,
          child: Text(
            state,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() => _selectedState = newValue);
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
                  foregroundColor: AppTheme.primaryColor,
                  side: const BorderSide(color: AppTheme.primaryColor),
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
                  : (_currentStep < 3 ? _nextStep : _submitRegistration),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(_currentStep < 3 ? 'Next' : 'Submit'),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    setState(() => _errorMessage = '');

    if (!_validateCurrentStep()) return;

    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
        _errorMessage = '';
      }
    });
    _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _validateBusinessType();
      case 1:
        return _validateFirmDetails();
      case 2:
        return _validatePharmacistDetails();
      case 3:
        return _validateLoginCredentials();
      default:
        return false;
    }
  }

  bool _validateBusinessType() {
    if (_businessType == null) {
      setState(() => _errorMessage = 'Please select a business type');
      return false;
    }
    return true;
  }

  bool _validateFirmDetails() {
    if (_firmNameController.text.isEmpty) {
      setState(() => _errorMessage = 'Firm name is required');
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
    if (_businessType == 'Retailer' || _businessType == 'Both') {
      if (_dlRetailerController.text.isEmpty) {
        setState(
            () => _errorMessage = 'Retailer Drug Licence number is required');
        return false;
      }
    }
    if (_businessType == 'Distributor/Wholeseller' || _businessType == 'Both') {
      if (_dlWholesalerController.text.isEmpty) {
        setState(() =>
            _errorMessage = 'Wholeseller Drug Licence number is required');
        return false;
      }
    }
    if (_isGstRegistered && _gstNumberController.text.isEmpty) {
      setState(
          () => _errorMessage = 'GST number is required for registered firms');
      return false;
    }
    if (_isGstRegistered && _gstNumberController.text.length != 15) {
      setState(() => _errorMessage = 'GST number should be 15 characters');
      return false;
    }
    if (_fssaiController.text.isEmpty) {
      setState(() => _errorMessage = 'FSSAI number is required');
      return false;
    }
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
    if (_postalCodeController.text.isEmpty) {
      setState(() => _errorMessage = 'Pin code is required');
      return false;
    }
    if (_postalCodeController.text.length != 6) {
      setState(() => _errorMessage = 'Pin code must be 6 digits');
      return false;
    }
    if (!RegExp(r'^\d{6}$').hasMatch(_postalCodeController.text)) {
      setState(() => _errorMessage = 'Pin code should contain only numbers');
      return false;
    }
    if (_contactNumberController.text.isEmpty) {
      setState(() => _errorMessage = 'Contact number is required');
      return false;
    }
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(_contactNumberController.text)) {
      setState(() => _errorMessage = 'Enter valid 10-digit mobile number');
      return false;
    }
    if (_panController.text.isEmpty) {
      setState(() => _errorMessage = 'PAN number is required');
      return false;
    }
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (!panRegex.hasMatch(_panController.text)) {
      setState(
          () => _errorMessage = 'Enter valid PAN number (e.g., ABCDE1234F)');
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
    if (_spcController.text.isEmpty) {
      setState(() => _errorMessage = 'Single Point of Contact is required');
      return false;
    }
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(_spcController.text)) {
      setState(() => _errorMessage = 'Enter valid 10-digit SPC mobile number');
      return false;
    }
    return true;
  }

  bool _validateLoginCredentials() {
    if (_userNameController.text.isEmpty) {
      setState(() => _errorMessage = 'Mobile number is required');
      return false;
    }
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(_userNameController.text)) {
      setState(() => _errorMessage = 'Enter valid 10-digit mobile number');
      return false;
    }
    if (_userNameController.text == _spcController.text) {
      setState(() => _errorMessage = 'Username cannot be same as SPC number');
      return false;
    }
    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Password is required');
      return false;
    }
    if (_passwordController.text.length < 8) {
      setState(() => _errorMessage = 'Password must be at least 8 characters');
      return false;
    }
    if (!RegExp(r'[A-Z]').hasMatch(_passwordController.text) ||
        !RegExp(r'[a-z]').hasMatch(_passwordController.text) ||
        !RegExp(r'[0-9]').hasMatch(_passwordController.text) ||
        !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_passwordController.text)) {
      setState(() => _errorMessage =
          'Password must contain 1 uppercase, 1 lowercase, 1 number, and 1 special character');
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

  Future<void> _checkLocationAndRequest() async {
    bool? isAvailable = await _locationService.isLocationServiceAvailable();

    if (isAvailable == false || !isAvailable) {
      bool? granted = await _locationService.requestLocationPermission();
      if (granted == true) {
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
      AppLogger.info(
          'Location result: ${result.latitude}, ${result.longitude} - ${result.address}');
      setState(() {
        if (result.isValid) {
          _latitude = result.latitude;
          _longitude = result.longitude;

          // Auto-populate address fields with structured data
          if (result.street != null && result.street!.isNotEmpty) {
            _addressLine1Controller.text = result.street!;
          }
          if (result.locality != null && result.locality!.isNotEmpty) {
            _addressLine2Controller.text = result.locality!;
          }
          if (result.city != null && result.city!.isNotEmpty) {
            _cityController.text = result.city!;
          }
          if (result.state != null && result.state!.isNotEmpty) {
            final matchedState = _states.firstWhere(
              (state) => state.toLowerCase() == result.state!.toLowerCase(),
              orElse: () => '',
            );
            if (matchedState.isNotEmpty) {
              _selectedState = matchedState;
            }
          }
          if (result.postalCode != null && result.postalCode!.isNotEmpty) {
            _postalCodeController.text = result.postalCode!;
          }

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
          AppLogger.info('Address auto-populated from location');
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
      AppLogger.error('Location error: $e');
    }
  }

  Future<void> _submitRegistration() async {
    final consentAccepted =
        await PharmacistConsentManager.showRetailerRegistrationConsent(context);

    if (!consentAccepted) {
      if (mounted) {
        Navigator.of(context).pop(); // Exit if declined
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration consent is required to proceed'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return; // Stop registration
    }
    
    if (!_validateCurrentStep()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final token = await AuthService.invokeLogin(
        mobileNumber: AppConstants.adminMobileNumber,
        password: AppConstants.adminPassword,
        stayLoggedIn: false);

    if (token != null) {
      try {
        final registrationData = {
          'businessType': _businessType,
          'medicalName': _firmNameController.text.trim(),
          'ownerFirstName': _ownerFirstNameController.text.trim(),
          'ownerLastName': _ownerLastNameController.text.trim(),
          'ownerMiddleName': _ownerMiddleNameController.text.trim(),
          'dlRetailer': _dlRetailerController.text.trim(),
          'dlWholesaler': _dlWholesalerController.text.trim(),
          'registrationStatus': _isGstRegistered,
          'gSTIN': _isGstRegistered ? _gstNumberController.text.trim() : null,
          'fSSAINo': _fssaiController.text.trim(),
          'addressLine1': _addressLine1Controller.text.trim(),
          'addressLine2': _addressLine2Controller.text.trim(),
          'city': _cityController.text.trim(),
          'state': _selectedState,
          'postalCode': _postalCodeController.text.trim(),
          'mobileNumber': _contactNumberController.text.trim(),
          'pAN': _panController.text.trim(),
          'pharmacistFirstName': _pharmacistFirstNameController.text.trim(),
          'pharmacistLastName': _pharmacistLastNameController.text.trim(),
          'pharmacistRegistrationNumber':
              _pharmacistRegNumberController.text.trim(),
          'singlePointOfContact': _spcController.text.trim(),
          'userName': _userNameController.text.trim(),
          'emailId': _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
          'password': _passwordController.text,
          'latitude': _latitude,
          'longitude': _longitude,
        };

        AppLogger.info('Registration Data: ${jsonEncode(registrationData)}');
        
        final response = await http.post(
          Uri.parse('${AppConstants.apiBaseUrl}/MedicalStores/register'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(registrationData),
        );

        setState(() => _isLoading = false);

        AppLogger.info('Response status: ${response.statusCode}');

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
                'A pharmacy with this mobile number already exists.';
          });
        } else {
          setState(() {
            _errorMessage = 'Server error. Please try again later.';
          });
        }
      } catch (e) {
        AppLogger.error('Error during registration: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = 'Network error. Please check your connection.';
        });
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.all(24),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Registration Submitted',
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
              const Text(
                'Your pharmacist registration has been submitted successfully!',
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
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
                      '• Your application will be reviewed by our team\n'
                      '• You will receive a confirmation email/SMS',
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
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
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
                    'Back to Login',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _firmNameController.dispose();
    _ownerFirstNameController.dispose();
    _ownerLastNameController.dispose();
    _ownerMiddleNameController.dispose();
    _dlRetailerController.dispose();
    _dlWholesalerController.dispose();
    _gstNumberController.dispose();
    _fssaiController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _contactNumberController.dispose();
    _panController.dispose();
    _pharmacistFirstNameController.dispose();
    _pharmacistLastNameController.dispose();
    _pharmacistRegNumberController.dispose();
    _spcController.dispose();
    _userNameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
