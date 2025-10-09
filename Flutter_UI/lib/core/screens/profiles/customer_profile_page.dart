import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmaish/core/theme/app_theme.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'dart:convert';

import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/helpers.dart';
import 'package:pharmaish/utils/storage.dart';

class CustomerDto {
  final String customerId;
  final String customerFirstName;
  final String customerLastName;
  final String? customerMiddleName;
  final String mobileNumber;
  final String? alternativeMobileNumber;
  final String? emailId;
  final String? address;
  final String? city;
  final String? state;
  final String? postalCode;
  final DateTime dateOfBirth;
  final String? gender;
  final String? customerPhoto;
  final bool isActive;
  final DateTime createdOn;
  final DateTime? updatedOn;
  final String? userId;

  CustomerDto({
    required this.customerId,
    required this.customerFirstName,
    required this.customerLastName,
    this.customerMiddleName,
    required this.mobileNumber,
    this.alternativeMobileNumber,
    this.emailId,
    this.address,
    this.city,
    this.state,
    this.postalCode,
    required this.dateOfBirth,
    this.gender,
    this.customerPhoto,
    required this.isActive,
    required this.createdOn,
    this.updatedOn,
    this.userId,
  });

  factory CustomerDto.fromJson(Map<String, dynamic> json) {
    return CustomerDto(
      customerId: json['customerId'] ?? '',
      customerFirstName: json['customerFirstName'] ?? '',
      customerLastName: json['customerLastName'] ?? '',
      customerMiddleName: json['customerMiddleName'],
      mobileNumber: json['mobileNumber'] ?? '',
      alternativeMobileNumber: json['alternativeMobileNumber'],
      emailId: json['emailId'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: json['gender'],
      customerPhoto: json['customerPhoto'],
      isActive: json['isActive'] ?? false,
      createdOn: DateTime.parse(json['createdOn']),
      updatedOn:
          json['updatedOn'] != null ? DateTime.parse(json['updatedOn']) : null,
      userId: json['userId'],
    );
  }
}

class CustomerAddressDto {
  final String? addressId;
  final String customerId;
  final String? address;
  final String? addressLine1;
  final String? addressLine2;
  final String? addressLine3;
  final String? city;
  final String? state;
  final String? postalCode;
  final bool isDefault;
  final bool isActive;
  final DateTime createdOn;
  final DateTime? updatedOn;

  CustomerAddressDto({
    this.addressId,
    required this.customerId,
    this.address,
    this.addressLine1,
    this.addressLine2,
    this.addressLine3,
    this.city,
    this.state,
    this.postalCode,
    this.isDefault = false,
    this.isActive = true,
    required this.createdOn,
    this.updatedOn,
  });

  factory CustomerAddressDto.fromJson(Map<String, dynamic> json) {
    return CustomerAddressDto(
      addressId: json['addressId'],
      customerId: json['customerId'] ?? '',
      address: json['address'],
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      addressLine3: json['addressLine3'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      isDefault: json['isDefault'] ?? false,
      isActive: json['isActive'] ?? true,
      createdOn: DateTime.parse(json['createdOn']),
      updatedOn:
          json['updatedOn'] != null ? DateTime.parse(json['updatedOn']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (addressId != null) 'addressId': addressId,
      'customerId': customerId,
      'address': address,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'addressLine3': addressLine3,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'isDefault': isDefault,
      'isActive': isActive,
      'createdOn': createdOn.toIso8601String(),
      if (updatedOn != null) 'updatedOn': updatedOn!.toIso8601String(),
    };
  }

  String get fullAddress {
    final parts = [
      if (addressLine1?.isNotEmpty == true) addressLine1,
      if (addressLine2?.isNotEmpty == true) addressLine2,
      if (addressLine3?.isNotEmpty == true) addressLine3,
      if (city?.isNotEmpty == true) city,
      if (state?.isNotEmpty == true) state,
      if (postalCode?.isNotEmpty == true) postalCode,
    ];
    return parts.join(', ');
  }
}

class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  CustomerDto? _customer;
  List<CustomerAddressDto> _addresses = [];
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isLoadingAddresses = false;
  String _errorMessage = '';
  final Set<String> _expandedAddresses = {};

  // Controllers for editable fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //AppHelpers.disableScreenshots();
    _loadCustomerProfile();
  }

  Future<void> _loadCustomerProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final token = await StorageService.getAuthToken();
      if (token == null) {
        setState(() {
          _errorMessage = 'Authentication token not found. Please login again.';
          _isLoading = false;
        });
        return;
      }
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/Customers/my-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      AppLogger.apiResponse(
        response.statusCode,
        '${AppConstants.apiBaseUrl}/Customers/my-profile',
        jsonDecode(response.body),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check if response body is not empty before parsing
        if (response.body.isEmpty) {
          setState(() {
            _errorMessage = 'No profile data received from server';
          });
          return;
        }

        final responseData = jsonDecode(response.body);
        setState(() {
          _customer = CustomerDto.fromJson(responseData);
          _firstNameController.text = _customer!.customerFirstName;
          _lastNameController.text = _customer!.customerLastName;
          _isLoading = false;
        });

        // Load addresses after profile is loaded
        _loadAddresses();
      } else {
        setState(() {
          _errorMessage = 'Failed to load profile. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Please check your connection.';
        _isLoading = false;
      });
      AppLogger.error('Profile load error: $e');
    }
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoadingAddresses = true;
    });

    try {
      final token = await StorageService.getAuthToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/CustomerAddresses/my-addresses'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          _addresses = responseData
              .map((address) => CustomerAddressDto.fromJson(address))
              .toList();
          _isLoadingAddresses = false;
        });
      }
    } catch (e) {
      AppLogger.error('Address load error: $e');
    } finally {
      setState(() {
        _isLoadingAddresses = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_firstNameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'First name is required');
      return;
    }

    if (_lastNameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Last name is required');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = '';
    });

    try {
      final token = await StorageService.getAuthToken();
      if (token == null) {
        setState(() {
          _errorMessage = 'Authentication token not found. Please login again.';
          _isSaving = false;
        });
        return;
      }

      if (_customer == null) {
        setState(() {
          _errorMessage = 'Customer profile not loaded.';
          _isSaving = false;
        });
        return;
      }

      final updateData = {
        'customerId': _customer!.customerId,
        'customerFirstName': _firstNameController.text.trim(),
        'customerLastName': _lastNameController.text.trim(),
        'customerMiddleName': _customer!.customerMiddleName,
        'mobileNumber': _customer!.mobileNumber,
        'alternativeMobileNumber': _customer!.alternativeMobileNumber,
        'emailId': _customer!.emailId,
        'address': _customer!.address,
        'city': _customer!.city,
        'state': _customer!.state,
        'postalCode': _customer!.postalCode,
        'dateOfBirth': _customer!.dateOfBirth.toIso8601String(),
        'gender': _customer!.gender,
        'customerPhoto': _customer!.customerPhoto,
        'isActive': _customer!.isActive,
        'createdOn': _customer!.createdOn.toIso8601String(),
        'updatedOn': DateTime.now().toIso8601String(),
        'userId': _customer!.userId,
      };

      final response = await http.put(
        Uri.parse(
            '${AppConstants.apiBaseUrl}/Customers/${_customer!.customerId}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        _loadCustomerProfile();
        _showSuccessMessage('Profile updated successfully!');
      } else {
        setState(() {
          _errorMessage = 'Failed to update profile. Please try again.';
          _isSaving = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Please check your connection.';
        _isSaving = false;
      });
      AppLogger.error('Profile update error: $e');
    }
  }

  Future<void> _deleteAddress(String addressId) async {
    final confirmed = await _showDeleteConfirmationDialog();
    if (!confirmed) return;

    try {
      final token = await StorageService.getAuthToken();
      if (token == null) return;

      final response = await http.delete(
        Uri.parse('${AppConstants.apiBaseUrl}/CustomerAddresses/$addressId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _showSuccessMessage('Address deleted successfully!');
        _loadAddresses();
      } else {
        _showErrorMessage('Failed to delete address. Please try again.');
      }
    } catch (e) {
      _showErrorMessage('Network error. Please check your connection.');
      AppLogger.error('Delete address error: $e');
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Address'),
              content:
                  const Text('Are you sure you want to delete this address?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _showAddAddressDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddAddressDialog(
          customerId: _customer?.customerId ?? '',
          onAddressAdded: () {
            _loadAddresses();
            _showSuccessMessage('Address added successfully!');
          },
        );
      },
    );
  }

  void _showEditAddressDialog(CustomerAddressDto address) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddAddressDialog(
          customerId: _customer?.customerId ?? '',
          address: address,
          onAddressAdded: () {
            _loadAddresses();
            _showSuccessMessage('Address updated successfully!');
          },
        );
      },
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _errorMessage = '';
      if (_customer != null) {
        _firstNameController.text = _customer!.customerFirstName;
        _lastNameController.text = _customer!.customerLastName;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading && _customer != null && !_isSaving)
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
              onPressed: _isEditing
                  ? _cancelEdit
                  : () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
      );
    }

    if (_customer == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              _errorMessage.isNotEmpty
                  ? _errorMessage
                  : 'Failed to load profile',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCustomerProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          if (_errorMessage.isNotEmpty) _buildErrorMessage(),
          _buildPersonalInfoSection(),
          const SizedBox(height: 20),
          _buildContactInfoSection(),
          const SizedBox(height: 20),
          _buildAddressSection(), // New address management section
          const SizedBox(height: 20),
          _buildAccountInfoSection(),
          const SizedBox(height: 32),
          if (_isEditing) _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage,
              style: TextStyle(color: Colors.red.shade600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Addresses',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: AppTheme.primaryColor),
                  onPressed: _showAddAddressDialog,
                  tooltip: 'Add Address',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildAddressList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList() {
    if (_isLoadingAddresses) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
      );
    }

    if (_addresses.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.location_off, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'No addresses found',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showAddAddressDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add First Address'),
            ),
          ],
        ),
      );
    }

    return Column(
      children:
          _addresses.map((address) => _buildAddressCard(address)).toList(),
    );
  }

  Widget _buildAddressCard(CustomerAddressDto address) {
    final isExpanded = _expandedAddresses.contains(address.addressId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          ListTile(
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    address.address ?? 'Address',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                if (address.isDefault)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Default',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              '${address.addressLine1 ?? ''}, ${address.city ?? ''}, ${address.state ?? ''}',
              maxLines: isExpanded ? null : 1,
              overflow: isExpanded ? null : TextOverflow.ellipsis,
            ),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: AppTheme.primaryColor,
            ),
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedAddresses.remove(address.addressId);
                } else {
                  _expandedAddresses.add(address.addressId!);
                }
              });
            },
          ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (address.address?.isNotEmpty == true)
                    _buildAddressDetailRow('Address', address.address!),
                  if (address.addressLine1?.isNotEmpty == true)
                    _buildAddressDetailRow(
                        'Address Line 1', address.addressLine1!),
                  if (address.addressLine2?.isNotEmpty == true)
                    _buildAddressDetailRow(
                        'Address Line 2', address.addressLine2!),
                  if (address.addressLine3?.isNotEmpty == true)
                    _buildAddressDetailRow(
                        'Address Line 3', address.addressLine3!),
                  if (address.city?.isNotEmpty == true)
                    _buildAddressDetailRow('City', address.city!),
                  if (address.state?.isNotEmpty == true)
                    _buildAddressDetailRow('State', address.state!),
                  if (address.postalCode?.isNotEmpty == true)
                    _buildAddressDetailRow('Postal Code', address.postalCode!),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showEditAddressDialog(address),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _deleteAddress(address.addressId!),
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text('Delete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Keep all existing methods for profile sections
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppTheme.primaryColor,
            child: _customer!.customerPhoto != null
                ? ClipOval(
                    child: Image.network(
                      _customer!.customerPhoto!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person,
                            size: 40, color: Colors.white);
                      },
                    ),
                  )
                : const Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            '${_customer!.customerFirstName} ${_customer!.customerLastName}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _customer!.mobileNumber,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      title: 'Personal Information',
      icon: Icons.person,
      children: [
        _buildEditableField(
            'First Name', _customer!.customerFirstName, _firstNameController,
            required: true),
        _buildEditableField(
            'Last Name', _customer!.customerLastName, _lastNameController,
            required: true),
        _buildReadOnlyField(
            'Middle Name', _customer!.customerMiddleName ?? 'Not provided'),
        _buildReadOnlyField(
            'Date of Birth', _formatDate(_customer!.dateOfBirth)),
        _buildReadOnlyField('Gender', _customer!.gender ?? 'Not provided'),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return _buildSection(
      title: 'Contact Information',
      icon: Icons.contact_phone,
      children: [
        _buildReadOnlyField('Mobile Number', _customer!.mobileNumber),
        _buildReadOnlyField('Alternative Mobile',
            _customer!.alternativeMobileNumber ?? 'Not provided'),
        _buildReadOnlyField('Email', _customer!.emailId ?? 'Not provided'),
      ],
    );
  }

  Widget _buildAccountInfoSection() {
    return _buildSection(
      title: 'Account Information',
      icon: Icons.account_circle,
      children: [
        _buildReadOnlyField(
            'Account Status', _customer!.isActive ? 'Active' : 'Inactive'),
        _buildReadOnlyField('Member Since', _formatDate(_customer!.createdOn)),
        if (_customer!.updatedOn != null)
          _buildReadOnlyField(
              'Last Updated', _formatDate(_customer!.updatedOn!)),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(
      String label, String value, TextEditingController controller,
      {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _isEditing
          ? TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: '$label${required ? ' *' : ''}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
              ),
            )
          : _buildFieldRow(label, value),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _buildFieldRow(label, value),
    );
  }

  Widget _buildFieldRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : const Text('Save Changes', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}

class AddAddressDialog extends StatefulWidget {
  final String customerId;
  final CustomerAddressDto? address;
  final VoidCallback onAddressAdded;

  const AddAddressDialog({
    super.key,
    required this.customerId,
    this.address,
    required this.onAddressAdded,
  });

  @override
  State<AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<AddAddressDialog> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _addressLine3Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  bool _isDefault = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    //AppHelpers.disableScreenshots();
    if (widget.address != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final address = widget.address!;
    _addressController.text = address.address ?? '';
    _addressLine1Controller.text = address.addressLine1 ?? '';
    _addressLine2Controller.text = address.addressLine2 ?? '';
    _addressLine3Controller.text = address.addressLine3 ?? '';
    _cityController.text = address.city ?? '';
    _stateController.text = address.state ?? '';
    _postalCodeController.text = address.postalCode ?? '';
    _isDefault = address.isDefault;
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final token = await StorageService.getAuthToken();
      if (token == null) {
        _showError('Authentication token not found. Please login again.');
        return;
      }

      final addressData = CustomerAddressDto(
        addressId: widget.address?.addressId,
        customerId: widget.customerId,
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        addressLine1: _addressLine1Controller.text.trim().isNotEmpty
            ? _addressLine1Controller.text.trim()
            : null,
        addressLine2: _addressLine2Controller.text.trim().isNotEmpty
            ? _addressLine2Controller.text.trim()
            : null,
        addressLine3: _addressLine3Controller.text.trim().isNotEmpty
            ? _addressLine3Controller.text.trim()
            : null,
        city: _cityController.text.trim().isNotEmpty
            ? _cityController.text.trim()
            : null,
        state: _stateController.text.trim().isNotEmpty
            ? _stateController.text.trim()
            : null,
        postalCode: _postalCodeController.text.trim().isNotEmpty
            ? _postalCodeController.text.trim()
            : null,
        isDefault: _isDefault,
        isActive: true,
        createdOn: widget.address?.createdOn ?? DateTime.now(),
        updatedOn: widget.address != null ? DateTime.now() : null,
      );

      final response = widget.address == null
          ? await http.post(
              Uri.parse('${AppConstants.apiBaseUrl}/CustomerAddresses'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode(addressData.toJson()),
            )
          : await http.put(
              Uri.parse(
                  '${AppConstants.apiBaseUrl}/CustomerAddresses/${widget.address!.addressId}'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode(addressData.toJson()),
            );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.of(context).pop();
        widget.onAddressAdded();
      } else {
        _showError('Failed to save address. Please try again.');
      }
    } catch (e) {
      _showError('Network error. Please check your connection.');
      AppLogger.error('Save address error: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.address == null ? 'Add Address' : 'Edit Address'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address Label',
                    hintText: 'e.g., Home, Office',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressLine1Controller,
                  decoration: const InputDecoration(
                    labelText: 'Address Line 1',
                    hintText: 'House/Flat No, Building Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressLine2Controller,
                  decoration: const InputDecoration(
                    labelText: 'Address Line 2',
                    hintText: 'Street, Area',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressLine3Controller,
                  decoration: const InputDecoration(
                    labelText: 'Address Line 3',
                    hintText: 'Landmark',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stateController,
                  decoration: const InputDecoration(
                    labelText: 'State',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _postalCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Postal Code',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  validator: (value) {
                    if (value != null &&
                        value.trim().isNotEmpty &&
                        value.trim().length != 6) {
                      return 'Postal code must be 6 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Set as default address'),
                  value: _isDefault,
                  onChanged: (value) {
                    setState(() => _isDefault = value ?? false);
                  },
                  activeColor: AppTheme.primaryColor,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveAddress,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                )
              : Text(widget.address == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _addressLine3Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }
}
