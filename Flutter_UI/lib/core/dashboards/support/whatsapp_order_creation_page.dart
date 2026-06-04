import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pharmaish/shared/widgets/app_button.dart';
import 'package:pharmaish/shared/widgets/app_snackbar.dart';
import 'package:pharmaish/shared/widgets/step_progress_indicator.dart';
import 'package:pharmaish/utils/app_logger.dart';

// ============================================================================
// WHATSAPP ORDER CREATION PAGE
// ============================================================================

// COMPLETE WHATSAPP ORDER CREATION WITH CUSTOMER LOOKUP
// Replace the entire WhatsAppOrderCreationPage class in support_dashboard.dart

// Required imports - Add these at the top of support_dashboard.dart if not already present:
// import 'package:file_picker/file_picker.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// ============================================================================
// WHATSAPP ORDER CREATION PAGE - 3-STEP WIZARD WITH CUSTOMER LOOKUP
// ============================================================================

class WhatsAppOrderCreationPage extends StatefulWidget {
  final Dio dio;

  const WhatsAppOrderCreationPage({super.key, required this.dio});

  @override
  State<WhatsAppOrderCreationPage> createState() =>
      _WhatsAppOrderCreationPageState();
}

class _WhatsAppOrderCreationPageState extends State<WhatsAppOrderCreationPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Customer Lookup
  final _mobileController = TextEditingController();
  bool _isLoadingCustomer = false;
  Map<String, dynamic>? _customerData;
  String? _customerId;

  // Step 2: Prescription Details
  final _prescriptionNotesController = TextEditingController();
  File? _prescriptionFile;
  String? _prescriptionFileName;
  String? _prescriptionFileType; // 'image' or 'pdf'

  // Step 3: Delivery Address (from fetched customer or new)
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  String? _selectedState;
  double? _latitude;
  double? _longitude;

  bool _isSubmitting = false;
  final ImagePicker _imagePicker = ImagePicker();

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
  ];

  @override
  void dispose() {
    _mobileController.dispose();
    _prescriptionNotesController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ========== CUSTOMER LOOKUP ==========

  Future<void> _lookupCustomer() async {
    final mobile = _mobileController.text.trim();

    // Validation
    if (mobile.isEmpty) {
      _showError('Please enter mobile number');
      return;
    }

    if (mobile.length != 10) {
      _showError('Mobile number must be 10 digits');
      return;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(mobile)) {
      _showError('Mobile number must contain only digits');
      return;
    }

    setState(() => _isLoadingCustomer = true);

    try {
      AppLogger.info('Looking up customer with mobile: $mobile');

      // CORRECT ENDPOINT: /api/Customers/by-mobile/{mobileNumber}
      final response = await widget.dio.get('/Customers/by-mobile/$mobile');

      if (response.statusCode == 200) {
        final customerData = response.data;

        AppLogger.info('Customer found: ${customerData['customerId']}');

        setState(() {
          _customerData = customerData;
          _customerId = customerData['customerId'];
          _isLoadingCustomer = false;
        });

        // Load customer's default address if available
        await _loadCustomerAddress();

        final firstName = customerData['customerFirstName'] ?? '';
        final lastName = customerData['customerLastName'] ?? '';
        //final customerNumber = customerData['customerNumber'] ?? '';
        final fullName = '$firstName $lastName'.trim();

        _showSuccess(
            'Customer found: ${fullName.isNotEmpty ? fullName : "Customer"}');

        // Auto-advance to next step
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _nextStep();
        });
      }
    } on DioException catch (e) {
      setState(() => _isLoadingCustomer = false);

      AppLogger.error('Customer lookup error: ${e.response?.statusCode}');

      // Handle different error scenarios
      if (e.response?.statusCode == 404) {
        // Customer not found - this is expected, show dialog
        _showCustomerNotFoundDialog();
      } else if (e.response?.statusCode == 403) {
        _showError('Permission denied. Please contact administrator.');
      } else if (e.response?.statusCode == 401) {
        _showError('Session expired. Please login again.');
      } else {
        _showError('Failed to lookup customer. Please try again.');
      }
    } catch (e) {
      setState(() => _isLoadingCustomer = false);
      AppLogger.error('Unexpected error during customer lookup', e);
      _showError('An unexpected error occurred');
    }
  }

  Future<void> _loadCustomerAddress() async {
    if (_customerId == null) return;

    try {
      AppLogger.info('Loading customer default address for: $_customerId');

      // CORRECT ENDPOINT: /api/CustomerAddresses/customer/{customerId}/default
      final response = await widget.dio
          .get('/CustomerAddresses/customer/$_customerId/default');

      if (response.statusCode == 200) {
        final address = response.data;

        AppLogger.info('Default address loaded successfully');

        setState(() {
          _addressLine1Controller.text = address['addressLine1'] ?? '';
          _addressLine2Controller.text = address['addressLine2'] ?? '';
          _cityController.text = address['city'] ?? '';
          _selectedState = address['state'];
          _pincodeController.text = address['postalCode'] ?? '';
          _latitude = address['latitude'];
          _longitude = address['longitude'];
        });
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        AppLogger.info('No default address found for customer');
        // This is fine - user will enter address manually
      } else {
        AppLogger.error(
            'Error loading customer address: ${e.response?.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Unexpected error loading customer address', e);
    }
  }

  void _showCustomerNotFoundDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Customer Not Found'),
        content: Text(
          'No customer found with mobile number ${_mobileController.text}.\n\n'
          'You can still create the order, and a new customer will be created.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Proceed to next step even without customer
              _nextStep();
            },
            style: AppButton.success(),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  // ========== FILE PICKER METHODS ==========
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        setState(() {
          _prescriptionFile = File(image.path);
          _prescriptionFileName = image.name;
          _prescriptionFileType = 'image';
        });
        AppLogger.info('Image captured: ${image.name}');
        _showSuccess('Image attached successfully');
      }
    } catch (e) {
      AppLogger.error('Error capturing image', e);
      _showError('Failed to capture image');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        setState(() {
          _prescriptionFile = File(image.path);
          _prescriptionFileName = image.name;
          _prescriptionFileType = 'image';
        });
        AppLogger.info('Image selected: ${image.name}');
        _showSuccess('Image attached successfully');
      }
    } catch (e) {
      AppLogger.error('Error selecting image', e);
      _showError('Failed to select image');
    }
  }

  Future<void> _pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSizeInMB = file.lengthSync() / (1024 * 1024);

        // Validate file size (max 10MB)
        if (fileSizeInMB > 10) {
          _showError('PDF file size must be less than 10MB');
          return;
        }

        setState(() {
          _prescriptionFile = file;
          _prescriptionFileName = result.files.single.name;
          _prescriptionFileType = 'pdf';
        });
        AppLogger.info('PDF selected: ${result.files.single.name}');
        _showSuccess('PDF attached successfully');
      }
    } catch (e) {
      AppLogger.error('Error selecting PDF', e);
      _showError('Failed to select PDF');
    }
  }

  void _removeAttachment() {
    setState(() {
      _prescriptionFile = null;
      _prescriptionFileName = null;
      _prescriptionFileType = null;
    });
    _showSuccess('Attachment removed');
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Attach Prescription',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.blue),
              ),
              title: const Text('Take Photo'),
              subtitle: const Text('Capture prescription with camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.photo_library, color: Colors.green),
              ),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Select image from device'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.picture_as_pdf, color: Colors.red),
              ),
              title: const Text('Choose PDF'),
              subtitle: const Text('Select PDF document (max 10MB)'),
              onTap: () {
                Navigator.pop(context);
                _pickPdfFile();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ========== NAVIGATION ==========
  void _nextStep() {
    if (_currentStep == 0) {
      // Step 1 validation already done in _lookupCustomer
      // Just check if mobile is entered
      if (_mobileController.text.trim().isEmpty) {
        _showError('Please enter mobile number');
        return;
      }
    } else if (_currentStep == 1) {
      // Step 2 validation - At least file OR notes required
      if (_prescriptionFile == null &&
          _prescriptionNotesController.text.trim().isEmpty) {
        _showError('Please attach prescription file OR enter order notes');
        return;
      }
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // ========== ORDER SUBMISSION ==========
  // FIXED ORDER SUBMISSION - Remove OrderInputType
// COMPLETE FIXED ORDER SUBMISSION
// Replace the _submitOrder() method in WhatsAppOrderCreationPage

// COMPLETE FIXED ORDER SUBMISSION - NO DUPLICATES
// Replace the entire _submitOrder() method in WhatsAppOrderCreationPage

// COMPLETE FIX - Use enum indices instead of enum names
// Replace the entire _submitOrder() method
// DIAGNOSTIC VERSION - Matches customer app EXACTLY
// Replace _submitOrder() with this version

  Future<void> _submitOrder() async {
    // Validation
    if (_addressLine1Controller.text.trim().isEmpty) {
      _showError('Please enter Address Line 1');
      return;
    }

    if (_cityController.text.trim().isEmpty) {
      _showError('Please enter city');
      return;
    }

    if (_selectedState == null || _selectedState!.isEmpty) {
      _showError('Please select state');
      return;
    }

    final pincode = _pincodeController.text.trim();
    if (pincode.isEmpty ||
        pincode.length != 6 ||
        !RegExp(r'^[0-9]+$').hasMatch(pincode)) {
      _showError('Please enter valid 6-digit pincode');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? customerIdToUse = _customerId;
      String? addressIdToUse;

      // Step 1: Ensure customer exists
      if (customerIdToUse == null) {
        AppLogger.info('[STEP 1] Creating new customer');

        final customerResponse =
            await widget.dio.post('/Customers/register', data: {
          'mobileNumber': _mobileController.text.trim(),
          'emailId': '',
          'customerFirstName':
              _customerData?['customerFirstName'] ?? 'Customer',
          'customerLastName': _customerData?['customerLastName'] ?? '',
          'password': 'Temp@123',
        });

        if (customerResponse.statusCode == 200 ||
            customerResponse.statusCode == 201) {
          customerIdToUse = customerResponse.data['customerId'] ??
              customerResponse.data['id'];
          AppLogger.info('[STEP 1] Customer created: $customerIdToUse');
        } else {
          throw Exception('Failed to create customer');
        }
      } else {
        AppLogger.info('[STEP 1] Using existing customer: $customerIdToUse');
      }

      // Step 2: Create address
      AppLogger.info('[STEP 2] Creating address');
      final addressResponse =
          await widget.dio.post('/CustomerAddresses', data: {
        'customerId': customerIdToUse,
        'addressLine1': _addressLine1Controller.text.trim(),
        'addressLine2': _addressLine2Controller.text.trim(),
        'addressLine3': '',
        'city': _cityController.text.trim(),
        'state': _selectedState,
        'postalCode': pincode,
        'latitude': _latitude,
        'longitude': _longitude,
        'isDefault': true,
        'isActive': true,
      });

      if (addressResponse.statusCode == 200 ||
          addressResponse.statusCode == 201) {
        addressIdToUse = addressResponse.data['id'];
        AppLogger.info('[STEP 2] Address created: $addressIdToUse');
      } else {
        throw Exception('Failed to create address');
      }

      // Step 3: Create order - EXACTLY like customer app
      AppLogger.info('[STEP 3] Creating order');

      final formData = FormData();

      // Add fields in same order as customer app
      formData.fields.add(MapEntry('CustomerId', customerIdToUse!));
      formData.fields.add(MapEntry('CustomerAddressId', addressIdToUse!));
      formData.fields.add(const MapEntry('OrderType', '2')); // PrescriptionDrugs
      formData.fields.add(const MapEntry('OrderInputType', '0')); // Image

      // Add file if present - customer app ALWAYS uses OrderInputType=0 for files
      if (_prescriptionFile != null) {
        formData.files.add(
          MapEntry(
            'OrderInputFile',
            await MultipartFile.fromFile(
              _prescriptionFile!.path,
              filename: _prescriptionFileName ?? 'prescription.jpg',
            ),
          ),
        );
        AppLogger.info('[STEP 3] File added: $_prescriptionFileName');
      } else if (_prescriptionNotesController.text.trim().isNotEmpty) {
        // Text only
        formData.fields[2] = const MapEntry('OrderInputType', '2'); // Change to Text
        formData.fields.add(MapEntry(
            'OrderInputText', _prescriptionNotesController.text.trim()));
        AppLogger.info('[STEP 3] Text-only order');
      } else {
        _showError('Please provide prescription');
        setState(() => _isSubmitting = false);
        return;
      }

      // Log everything for debugging
      AppLogger.info('=== FINAL REQUEST ===');
      AppLogger.info(
          'CustomerId: $customerIdToUse (${customerIdToUse.runtimeType})');
      AppLogger.info(
          'AddressId: $addressIdToUse (${addressIdToUse.runtimeType})');
      AppLogger.info('Fields:');
      for (var field in formData.fields) {
        AppLogger.info(
            '  ${field.key}: ${field.value} (${field.value.runtimeType})');
      }
      AppLogger.info('Files: ${formData.files.length}');
      for (var file in formData.files) {
        AppLogger.info('  ${file.key}: ${file.value.filename}');
      }
      AppLogger.info('====================');

      // Submit
      final response = await widget.dio.post(
        '/Orders',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.info('[SUCCESS] Request Shared with Nearby Licensed Pharmacies');
        AppLogger.info('Response: ${response.data}');

        if (mounted) {
          final orderId =
              response.data['orderId'] ?? response.data['id'] ?? 'N/A';

          AppSnackBar.success(context, 'Request Shared with Nearby Licensed Pharmacies. Pharmacy Reference ID: $orderId',
              duration: const Duration(seconds: 3));

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) _clearForm();
          });
        }
      }
    } on DioException catch (e) {
      AppLogger.error('[ERROR] DioException');
      AppLogger.error('Status: ${e.response?.statusCode}');
      AppLogger.error('Message: ${e.message}');
      AppLogger.error('Response: ${e.response?.data}');

      // Check for specific backend errors
      String errorMessage = 'Failed to create order';

      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map) {
          errorMessage =
              data['error'] ?? data['message'] ?? data['title'] ?? errorMessage;

          // Check for validation errors
          if (data['errors'] != null) {
            AppLogger.error('Validation Errors: ${data['errors']}');
            if (data['errors'] is Map) {
              final errors = data['errors'] as Map;
              errorMessage = errors.values.first.toString();
            }
          }
        }
      }

      if (mounted) {
        _showError(errorMessage);
      }
    } catch (e, stack) {
      AppLogger.error('[ERROR] Unexpected: $e');
      AppLogger.error('Stack: $stack');

      if (mounted) {
        _showError('Unexpected error occurred');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _clearForm() {
    _mobileController.clear();
    _prescriptionNotesController.clear();
    _addressLine1Controller.clear();
    _addressLine2Controller.clear();
    _cityController.clear();
    _pincodeController.clear();

    setState(() {
      _customerData = null;
      _customerId = null;
      _prescriptionFile = null;
      _prescriptionFileName = null;
      _prescriptionFileType = null;
      _selectedState = null;
      _latitude = null;
      _longitude = null;
      _currentStep = 0;
    });

    _pageController.jumpToPage(0);
  }

  // ========== UI HELPERS ==========
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      color: Colors.green.shade50,
      child: Column(
        children: [
          // Step Progress Indicator
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: StepProgressIndicator(
              steps: const [
                StepItem(label: 'Customer', icon: Icons.person_search),
                StepItem(label: 'Prescription', icon: Icons.medical_services),
                StepItem(label: 'Address', icon: Icons.location_on),
              ],
              currentStep: _currentStep,
              activeColor: Colors.green,
            ),
          ),

          // Page Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                _buildStep1CustomerLookup(),
                _buildStep2PrescriptionDetails(),
                _buildStep3Address(),
              ],
            ),
          ),

          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  // ========== STEP 1: CUSTOMER LOOKUP ==========
  Widget _buildStep1CustomerLookup() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Find Customer',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter customer mobile number to lookup',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          // Mobile Number Input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.shade100,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: _mobileController,
              decoration: InputDecoration(
                labelText: 'Mobile Number *',
                hintText: 'Enter 10-digit mobile number',
                prefixIcon: Icon(Icons.phone, color: Colors.green.shade700),
                suffixIcon: _isLoadingCustomer
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              keyboardType: TextInputType.phone,
              maxLength: 10,
              onChanged: (value) {
                // Auto-lookup when 10 digits entered
                if (value.length == 10 && RegExp(r'^[0-9]+$').hasMatch(value)) {
                  _lookupCustomer();
                }
              },
            ),
          ),
          const SizedBox(height: 16),

          // Lookup Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoadingCustomer ? null : _lookupCustomer,
              icon: const Icon(Icons.search),
              label: const Text('Search Customer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Customer Details (if found)
          if (_customerData != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.green.shade700,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Customer Found',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_customerData!['customerFirstName'] ?? ''} ${_customerData!['customerLastName'] ?? ''}'
                                  .trim(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.email,
                    'Email',
                    _customerData!['emailId'] ?? 'Not provided',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.phone,
                    'Mobile',
                    _customerData!['mobileNumber'] ?? '',
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Info Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'If customer not found, you can continue and create a new customer',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ========== STEP 2: PRESCRIPTION DETAILS WITH FILE ATTACHMENT ==========
  Widget _buildStep2PrescriptionDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prescription Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Attach prescription file or enter notes',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          // File Attachment Section
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _prescriptionFile != null
                    ? Colors.green
                    : Colors.green.shade200,
                width: _prescriptionFile != null ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Prescription File',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                if (_prescriptionFile == null) ...[
                  // No file attached
                  InkWell(
                    onTap: _showAttachmentOptions,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.shade200,
                          style: BorderStyle.solid,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 48,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tap to Attach Prescription',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Camera • Gallery • PDF',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // File attached - Show preview
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _prescriptionFileType == 'pdf'
                                ? Icons.picture_as_pdf
                                : Icons.image,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _prescriptionFileName ?? 'File attached',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _prescriptionFileType == 'pdf'
                                          ? 'PDF'
                                          : 'IMAGE',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.check_circle,
                                    size: 14,
                                    color: Colors.green.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Attached',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _removeAttachment,
                          icon: const Icon(Icons.close, color: Colors.red),
                          tooltip: 'Remove',
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Optional Notes Section
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Notes (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _prescriptionNotesController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Example:\n'
                        'Paracetamol 500mg - 1 strip\n'
                        'Crocin Cold - 1 bottle\n'
                        'Vicks Vaporub - 1 box\n\n'
                        'Additional instructions or special requests...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Colors.green, width: 2),
                    ),
                  ),
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Info Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline,
                    size: 20, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You must provide either a prescription file OR order notes (or both)',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== STEP 3: DELIVERY ADDRESS ==========
  Widget _buildStep3Address() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Address',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _customerData != null
                ? 'Confirm or update delivery address'
                : 'Enter delivery address',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          _buildTextField(
            controller: _addressLine1Controller,
            label: 'Address Line 1 *',
            icon: Icons.home,
            hint: 'House/Flat No., Building Name',
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _addressLine2Controller,
            label: 'Address Line 2',
            icon: Icons.home_outlined,
            hint: 'Street, Area, Landmark (Optional)',
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _cityController,
            label: 'City *',
            icon: Icons.location_city,
            hint: 'Enter city name',
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedState,
              decoration: InputDecoration(
                labelText: 'State *',
                prefixIcon: Icon(Icons.map, color: Colors.green.shade700),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              isExpanded: true,
              items: _states.map((state) {
                return DropdownMenuItem(
                  value: state,
                  child: Text(state, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedState = value),
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _pincodeController,
            label: 'Pincode *',
            icon: Icons.pin_drop,
            hint: 'Enter 6-digit pincode',
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.green.shade700),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          counterText: maxLength != null ? '' : null,
        ),
        keyboardType: keyboardType,
        maxLength: maxLength,
      ),
    );
  }

  // ========== NAVIGATION BUTTONS ==========
  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : _previousStep,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Previous',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : (_currentStep == 2 ? _submitOrder : _nextStep),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentStep == 2 ? 'Create Order' : 'Next',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentStep == 2
                                ? Icons.check
                                : Icons.arrow_forward,
                            size: 20,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
