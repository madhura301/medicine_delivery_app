import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pharmaish/core/services/order_service.dart';
import 'package:pharmaish/shared/models/order_enums.dart';
import 'package:pharmaish/shared/models/order_model.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/shared/widgets/step_progress_indicator.dart';
import 'package:pharmaish/shared/widgets/address_selector_widget.dart';
import 'package:pharmaish/utils/order_exceptions.dart';

class CameraPrescriptionScreen extends StatefulWidget {
  final String customerId;
  const CameraPrescriptionScreen({super.key, required this.customerId});

  @override
  State<CameraPrescriptionScreen> createState() =>
      _CameraPrescriptionScreenState();
}

class _CameraPrescriptionScreenState extends State<CameraPrescriptionScreen> {
  int _currentStep = 0;
  File? _capturedImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // Address selection
  CustomerAddressDto? _selectedAddress;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _patientNameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Delivery options
  String _deliveryType = 'home';
  String _urgency = 'regular';

  final List<StepItem> _steps = const [
    StepItem(label: 'Capture', icon: Icons.camera_alt),
    StepItem(label: 'Details', icon: Icons.edit_note),
    StepItem(label: 'Review', icon: Icons.preview),
  ];

  @override
  void dispose() {
    _notesController.dispose();
    _patientNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (photo != null) {
        setState(() {
          _capturedImage = File(photo.path);
        });
        AppLogger.info('Image captured: ${photo.path}');
      }
    } catch (e) {
      AppLogger.error('Error capturing image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (photo != null) {
        setState(() {
          _capturedImage = File(photo.path);
        });
        AppLogger.info('Image selected from gallery: ${photo.path}');
      }
    } catch (e) {
      AppLogger.error('Error selecting image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String> _convertImageToBase64() async {
    if (_capturedImage == null) return '';
    try {
      List<int> imageBytes = await _capturedImage!.readAsBytes();
      return base64Encode(imageBytes);
    } catch (e) {
      AppLogger.error('Error converting image to base64: $e');
      return '';
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_capturedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please capture or select an image first'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    } else if (_currentStep == 1) {
      // Validate address selection
      if (_selectedAddress == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a delivery address'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }

    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitOrder() async {
    // if (!_formKey.currentState!.validate() || _capturedImage == null) {
    //   return;
    // }

// ADD THIS DEBUG LOG
AppLogger.info('🔍 Selected Address Debug:');
AppLogger.info('Selected Address : $_selectedAddress');

    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a delivery address'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ADD THIS DEBUG LOG
    AppLogger.info('🔍 Selected Address Debug:');
    AppLogger.info('  addressId: ${_selectedAddress?.addressId}');
    AppLogger.info('  address: ${_selectedAddress?.address}');
    AppLogger.info('  fullAddress: ${_selectedAddress?.fullAddress}');

    // ADD THIS CHECK
    if (_selectedAddress?.addressId == null ||
        _selectedAddress!.addressId!.isEmpty) {
      AppLogger.error('❌ Selected address has no ID!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Invalid address selected. Please select another address.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final orderService = OrderService();

      // Now safe to use !
      final orderRequest = CreateOrderRequest(
        customerId: widget.customerId,
        customerAddressId: _selectedAddress?.addressId ?? '', // Safe now
        orderType: OrderType.prescriptionDrugs,
        orderInputType: OrderInputType.image,
        orderInputFile: _capturedImage,
        orderInputText: null,
        orderInputFileLocation: null,
      );

      AppLogger.info('📤 Submitting camera order...');
      AppLogger.info('Customer ID: ${widget.customerId}');
      AppLogger.info('Address ID: ${_selectedAddress?.addressId}');

      final createdOrder = await orderService.createOrder(orderRequest);

      AppLogger.info('✅ Order created! ID: ${createdOrder.orderId}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } on OrderValidationException catch (e) {
      AppLogger.error('Validation error: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Validation Error: ${e.message}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } on OrderNetworkException catch (e) {
      AppLogger.error('Network error: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network Error: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Error submitting order: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Prescription'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Step Progress Indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            color: Colors.grey.shade50,
            child: StepProgressIndicator(
              steps: _steps,
              currentStep: _currentStep,
              activeColor: Colors.black,
            ),
          ),

          // Step Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildStepContent(),
            ),
          ),

          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildCaptureStep();
      case 1:
        return _buildDetailsStep();
      case 2:
        return _buildReviewStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildCaptureStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Capture Prescription',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Take a clear photo of your prescription',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 30),

        // Preview or Capture Button
        if (_capturedImage == null) ...[
          // Camera Button
          InkWell(
            onTap: _captureImage,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(16),
                color: Colors.black.withOpacity(0.05),
              ),
              child: const Column(
                children: [
                  Icon(Icons.camera_alt, size: 80, color: Colors.black),
                  SizedBox(height: 16),
                  Text(
                    'Tap to Open Camera',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Make sure the prescription is clear and well-lit',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Or divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),

          const SizedBox(height: 16),

          // Gallery Button
          OutlinedButton.icon(
            onPressed: _pickFromGallery,
            icon: const Icon(Icons.photo_library),
            label: const Text('Choose from Gallery'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.black),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ] else ...[
          // Image Preview
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Image.file(
                    _capturedImage!,
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          setState(() => _capturedImage = null);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _captureImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Retake'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 20),

        // Tips
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.black),
                  const SizedBox(width: 8),
                  Text(
                    'Tips for better photos',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTipItem('Use good lighting'),
              _buildTipItem('Keep prescription flat'),
              _buildTipItem('Ensure all text is visible'),
              _buildTipItem('Avoid shadows and glare'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildDetailsStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Order Details',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Provide additional information for your order',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 30),

          // Patient Name
          TextFormField(
            controller: _patientNameController,
            decoration: InputDecoration(
              labelText: 'Patient Name',
              prefixIcon: const Icon(Icons.person, color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 2),
              ),
            ),
            validator: (value) {
              // if (value == null || value.isEmpty) {
              //   return 'Please enter patient name';
              // }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Phone Number
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            decoration: InputDecoration(
              labelText: 'Contact Number',
              prefixIcon: const Icon(Icons.phone, color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 2),
              ),
              counterText: '',
            ),
            validator: (value) {
              // if (value == null || value.isEmpty) {
              //   return 'Please enter contact number';
              // }
               if ((value != null && value.isNotEmpty) && value.length != 10) {
                return 'Please enter a valid 10-digit number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Notes
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Additional Notes (Optional)',
              prefixIcon: const Icon(Icons.note, color: Colors.black),
              hintText: 'Any specific instructions...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          const SizedBox(height: 24),

// Address Selection
          const Text(
            'Delivery Address',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          AddressSelectorWidget(
            customerId: widget.customerId,
            onAddressSelected: (address) {
              setState(() => _selectedAddress = address);
            },
            themeColor: Colors.black,
          ),

          const SizedBox(height: 24),

          // Delivery Type
          const Text(
            'Delivery Type',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Home'),
                  subtitle: const Text('Deliver to home'),
                  value: 'home',
                  groupValue: _deliveryType,
                  activeColor: Colors.black,
                  onChanged: (value) {
                    setState(() => _deliveryType = value!);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Pickup'),
                  subtitle: const Text('Store pickup'),
                  value: 'pickup',
                  groupValue: _deliveryType,
                  activeColor: Colors.black,
                  onChanged: (value) {
                    setState(() => _deliveryType = value!);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Urgency
          const Text(
            'Urgency',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Regular'),
                  subtitle: const Text('1-2 days'),
                  value: 'regular',
                  groupValue: _urgency,
                  activeColor: Colors.black,
                  onChanged: (value) {
                    setState(() => _urgency = value!);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Urgent'),
                  subtitle: const Text('Same day'),
                  value: 'urgent',
                  groupValue: _urgency,
                  activeColor: Colors.black,
                  onChanged: (value) {
                    setState(() => _urgency = value!);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Review Order',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Please review your order details before submitting',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 30),

        // Prescription Image Preview
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.camera_alt, color: Colors.black),
                    const SizedBox(width: 8),
                    const Text(
                      'Prescription Photo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                if (_capturedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _capturedImage!,
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Patient Details
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.black),
                    const SizedBox(width: 8),
                    const Text(
                      'Patient Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                _buildReviewRow('Name', _patientNameController.text),
                _buildReviewRow('Phone', _phoneController.text),
                if (_notesController.text.isNotEmpty)
                  _buildReviewRow('Notes', _notesController.text),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

// Delivery Address Card
        if (_selectedAddress != null)
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.black),
                      const SizedBox(width: 8),
                      const Text(
                        'Delivery Address',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  if (_selectedAddress!.address != null &&
                      _selectedAddress!.address!.isNotEmpty)
                    _buildReviewRow('Label', _selectedAddress!.address!),
                  _buildReviewRow('Address', _selectedAddress!.fullAddress),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        // Delivery Details
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_shipping, color: Colors.black),
                    const SizedBox(width: 8),
                    const Text(
                      'Delivery Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                _buildReviewRow(
                  'Type',
                  _deliveryType == 'home' ? 'Home Delivery' : 'Store Pickup',
                ),
                _buildReviewRow(
                  'Urgency',
                  _urgency == 'regular'
                      ? 'Regular (1-2 days)'
                      : 'Urgent (Same day)',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : _previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black),
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
                  : (_currentStep == _steps.length - 1
                      ? _submitOrder
                      : _nextStep),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                  : Text(
                      _currentStep == _steps.length - 1
                          ? 'Submit Order'
                          : 'Next',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
