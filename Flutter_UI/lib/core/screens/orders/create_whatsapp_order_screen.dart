// Create WhatsApp Order Screen - Customer Support
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pharmaish/core/theme/app_theme.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:pharmaish/utils/app_logger.dart';

class CreateWhatsAppOrderScreen extends StatefulWidget {
  const CreateWhatsAppOrderScreen({super.key});

  @override
  State<CreateWhatsAppOrderScreen> createState() =>
      _CreateWhatsAppOrderScreenState();
}

class _CreateWhatsAppOrderScreenState extends State<CreateWhatsAppOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  bool _isSearching = false;
  bool _isSubmitting = false;

  List<dynamic> _customers = [];
  List<dynamic> _filteredCustomers = [];
  List<dynamic> _addresses = [];

  dynamic _selectedCustomer;
  dynamic _selectedAddress;
  String _selectedOrderType = 'NotSet';
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);

    try {
      final token = await StorageService.getAuthToken();
      final dio = Dio();

      final response = await dio.get(
        '${AppConstants.apiBaseUrl}/Customers',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _customers = response.data;
          _filteredCustomers = _customers;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Error loading customers: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load customers'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterCustomers(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredCustomers = _customers;
      } else {
        _filteredCustomers = _customers.where((customer) {
          final name = '${customer['firstName']} ${customer['lastName']}'
              .toLowerCase();
          final phone = customer['phoneNumber']?.toString() ?? '';
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || phone.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _loadAddresses(String customerId) async {
    setState(() => _isLoading = true);

    try {
      final token = await StorageService.getAuthToken();
      final dio = Dio();

      final response = await dio.get(
        '${AppConstants.apiBaseUrl}/CustomerAddresses/customer/$customerId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _addresses = response.data;
          _selectedAddress = null;
          _isLoading = false;
        });

        if (_addresses.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Customer has no saved addresses'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      AppLogger.error('Error loading addresses: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load addresses'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      AppLogger.error('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to pick image'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a customer'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an address'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final token = await StorageService.getAuthToken();
      final supportId = await StorageService.getUserId();
      //final supportId = userInfo['roleSpecificId'];

      if (supportId == null || supportId.isEmpty) {
        throw Exception('Customer Support ID not found');
      }

      final dio = Dio();
      final formData = FormData();

      formData.fields.addAll([
        MapEntry('CustomerId', _selectedCustomer['id'].toString()),
        MapEntry('CustomerAddressId', _selectedAddress['id'].toString()),
        MapEntry('OrderType', _selectedOrderType),
        MapEntry('CustomerPhoneNumber', _phoneController.text.trim()),
        MapEntry('OrderInputText', _messageController.text.trim()),
        MapEntry('SupportNotes', _notesController.text.trim()),
        MapEntry('CreatedByCustomerSupportId', supportId),
      ]);

      if (_selectedImage != null) {
        formData.files.add(
          MapEntry(
            'WhatsAppScreenshot',
            await MultipartFile.fromFile(
              _selectedImage!.path,
              filename: _selectedImage!.path.split('/').last,
            ),
          ),
        );
      }

      final response = await dio.post(
        '${AppConstants.apiBaseUrl}/Orders/whatsapp',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      setState(() => _isSubmitting = false);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('WhatsApp order created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      AppLogger.error('Error creating WhatsApp order: $e');
      setState(() => _isSubmitting = false);

      String errorMessage = 'Failed to create order';
      if (e is DioException && e.response != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create WhatsApp Order'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Search
                    Text(
                      'Search Customer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name or phone number',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _isSearching
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterCustomers('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: _filterCustomers,
                    ),
                    const SizedBox(height: 16),

                    // Customer List
                    if (_filteredCustomers.isNotEmpty)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filteredCustomers.length,
                          itemBuilder: (context, index) {
                            final customer = _filteredCustomers[index];
                            final isSelected =
                                _selectedCustomer?['id'] == customer['id'];
                            return ListTile(
                              selected: isSelected,
                              selectedTileColor:
                                  AppTheme.primaryColor.withOpacity(0.1),
                              leading: CircleAvatar(
                                backgroundColor: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.grey.shade300,
                                child: Icon(
                                  Icons.person,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                ),
                              ),
                              title: Text(
                                '${customer['firstName']} ${customer['lastName']}',
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              subtitle: Text(customer['phoneNumber'] ?? ''),
                              onTap: () {
                                setState(() {
                                  _selectedCustomer = customer;
                                  _searchController.text =
                                      '${customer['firstName']} ${customer['lastName']}';
                                  _isSearching = false;
                                });
                                _loadAddresses(customer['id']);
                              },
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Address Selection
                    if (_selectedCustomer != null) ...[
                      Text(
                        'Select Address',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_addresses.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber,
                                  color: Colors.orange.shade700),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Customer has no saved addresses',
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        DropdownButtonFormField<dynamic>(
                          value: _selectedAddress,
                          decoration: InputDecoration(
                            hintText: 'Select an address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: _addresses.map((address) {
                            return DropdownMenuItem(
                              value: address,
                              child: Text(
                                '${address['addressLine1']}, ${address['city']}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedAddress = value);
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select an address';
                            }
                            return null;
                          },
                        ),
                      const SizedBox(height: 24),
                    ],

                    // Order Type
                    Text(
                      'Order Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedOrderType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'NotSet', child: Text('Not Set')),
                        DropdownMenuItem(
                            value: 'Prescription', child: Text('Prescription')),
                        DropdownMenuItem(
                            value: 'OverTheCounter',
                            child: Text('Over The Counter')),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedOrderType = value!);
                      },
                    ),
                    const SizedBox(height: 24),

                    // WhatsApp Phone Number
                    Text(
                      'WhatsApp Phone Number',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        hintText: 'Enter WhatsApp number',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Phone number is required';
                        }
                        if (value.trim().length < 10) {
                          return 'Enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Order Message
                    Text(
                      'Order Message',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Enter WhatsApp message content',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        counterText:
                            '${_messageController.text.length}/5000 characters',
                      ),
                      maxLines: 5,
                      maxLength: 5000,
                      onChanged: (value) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Order message is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // WhatsApp Screenshot
                    Text(
                      'WhatsApp Screenshot (Optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_selectedImage != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() => _selectedImage = null);
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      InkWell(
                        onTap: _pickImage,
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade50,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image,
                                    size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to select screenshot',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Support Notes
                    Text(
                      'Customer Support Notes (Optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        hintText: 'Add internal notes for reference',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Create WhatsApp Order',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}