import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pharmaish/core/services/order_service.dart';
import 'package:pharmaish/shared/models/order_enums.dart';
import 'package:pharmaish/shared/models/order_model.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/shared/widgets/step_progress_indicator.dart';
import 'package:pharmaish/shared/widgets/address_selector_widget.dart';
import 'package:pharmaish/utils/order_exceptions.dart';
import 'package:pharmaish/utils/storage.dart';

class UploadPrescriptionScreen extends StatefulWidget {
  final String customerId;
  const UploadPrescriptionScreen({super.key, required this.customerId});

  @override
  State<UploadPrescriptionScreen> createState() =>
      _UploadPrescriptionScreenState();
}

class _UploadPrescriptionScreenState extends State<UploadPrescriptionScreen> {
  int _currentStep = 0;
  File? _selectedFile;
  String? _fileName;
  String? _fileExtension;
  bool _isLoading = false;

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
    StepItem(label: 'Upload', icon: Icons.upload_file),
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

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _fileName = result.files.single.name;
          _fileExtension = result.files.single.extension?.toLowerCase();
        });
        AppLogger.info('File selected: $_fileName');
      }
    } catch (e) {
      AppLogger.error('Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String> _convertFileToBase64() async {
    if (_selectedFile == null) return '';
    try {
      List<int> fileBytes = await _selectedFile!.readAsBytes();
      return base64Encode(fileBytes);
    } catch (e) {
      AppLogger.error('Error converting file to base64: $e');
      return '';
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_selectedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a file first'),
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
    // if (!_formKey.currentState!.validate() || _selectedFile == null) {
    //   return;
    // }
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No file selected'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a delivery address'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

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

      final orderRequest = CreateOrderRequest(
        customerId: widget.customerId,
        customerAddressId: _selectedAddress!.addressId!,
        orderType: OrderType.prescriptionDrugs,
        orderInputType: OrderInputType.image,
        orderInputFile: _selectedFile,
        orderInputText: null,
        orderInputFileLocation: null,
      );

      AppLogger.info('📤 Submitting upload order...');
      AppLogger.info('Customer ID: ${widget.customerId}');
      AppLogger.info('Address ID: ${_selectedAddress!.addressId}');
      AppLogger.info('File: $_fileName');

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
        title: const Text('Upload Prescription'),
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
        return _buildUploadStep();
      case 1:
        return _buildDetailsStep();
      case 2:
        return _buildReviewStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildUploadStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Upload Prescription',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select a PDF or image file of your prescription',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 30),

        // File Picker Button
        InkWell(
          onTap: _pickFile,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(16),
              color: Colors.blue.withOpacity(0.05),
            ),
            child: Column(
              children: [
                Icon(
                  _selectedFile == null
                      ? Icons.cloud_upload
                      : Icons.check_circle,
                  size: 80,
                  color: _selectedFile == null ? Colors.black : Colors.green,
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedFile == null
                      ? 'Tap to select file'
                      : 'File selected',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'PDF, JPG, JPEG, PNG (Max 10MB)',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Selected File Info
        if (_selectedFile != null) ...[
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            child: ListTile(
              leading: Icon(
                _fileExtension == 'pdf' ? Icons.picture_as_pdf : Icons.image,
                color: Colors.black,
                size: 40,
              ),
              title: Text(
                _fileName ?? 'Unknown',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle:
                  Text('Type: ${_fileExtension?.toUpperCase() ?? 'Unknown'}'),
              trailing: IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _selectedFile = null;
                    _fileName = null;
                    _fileExtension = null;
                  });
                },
              ),
            ),
          ),
        ],

        const SizedBox(height: 20),

        // Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Make sure the prescription is clear and readable',
                  style: TextStyle(color: Colors.blue.shade900),
                ),
              ),
            ],
          ),
        ),
      ],
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

        // Prescription File
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.upload_file, color: Colors.black),
                    const SizedBox(width: 8),
                    const Text(
                      'Prescription File',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  children: [
                    Icon(
                      _fileExtension == 'pdf'
                          ? Icons.picture_as_pdf
                          : Icons.image,
                      color: Colors.black,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _fileName ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Type: ${_fileExtension?.toUpperCase() ?? 'Unknown'}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
