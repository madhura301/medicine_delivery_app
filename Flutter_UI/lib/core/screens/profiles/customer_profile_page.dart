import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:medicine_delivery_app/utils/constants.dart';
import 'package:medicine_delivery_app/utils/storage.dart';

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

class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  CustomerDto? _customer;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  String _errorMessage = '';

  // Controllers for editable fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
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
      print('Profile response status: ${response.statusCode}');
      print('Response: ${response.body}');
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Profile data: $responseData');
        setState(() {
          _customer = CustomerDto.fromJson(responseData);
          _firstNameController.text = _customer!.customerFirstName;
          _lastNameController.text = _customer!.customerLastName;
          _isLoading = false;
        });
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
      print('Profile load error: $e');
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
      print(
          'PUT URL: ${AppConstants.apiBaseUrl}/Customers/${_customer!.customerId}');
      print('Request body: ${jsonEncode(updateData)}');
      print('Response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        _loadProfile(); // Reload to get updated data
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
      print('Profile update error: $e');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2E7D32),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _errorMessage = '';
      // Reset controllers to original values
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
        backgroundColor: const Color(0xFF2E7D32),
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
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
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
              onPressed: _loadProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
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
          // Profile Header
          _buildProfileHeader(),

          const SizedBox(height: 24),

          // Error Message
          if (_errorMessage.isNotEmpty)
            Container(
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

          // Personal Information Section
          _buildSection(
            title: 'Personal Information',
            icon: Icons.person,
            children: [
              _buildEditableField('First Name', _customer!.customerFirstName,
                  _firstNameController,
                  required: true),
              _buildEditableField(
                  'Last Name', _customer!.customerLastName, _lastNameController,
                  required: true),
              _buildReadOnlyField('Middle Name',
                  _customer!.customerMiddleName ?? 'Not provided'),
              _buildReadOnlyField(
                  'Date of Birth', _formatDate(_customer!.dateOfBirth)),
              _buildReadOnlyField(
                  'Gender', _customer!.gender ?? 'Not provided'),
            ],
          ),

          const SizedBox(height: 20),

          // Contact Information Section
          _buildSection(
            title: 'Contact Information',
            icon: Icons.contact_phone,
            children: [
              _buildReadOnlyField('Mobile Number', _customer!.mobileNumber),
              _buildReadOnlyField('Alternative Mobile',
                  _customer!.alternativeMobileNumber ?? 'Not provided'),
              _buildReadOnlyField(
                  'Email', _customer!.emailId ?? 'Not provided'),
            ],
          ),

          const SizedBox(height: 20),

          // Address Information Section
          _buildSection(
            title: 'Address Information',
            icon: Icons.location_on,
            children: [
              _buildReadOnlyField(
                  'Address', _customer!.address ?? 'Not provided'),
              _buildReadOnlyField('City', _customer!.city ?? 'Not provided'),
              _buildReadOnlyField('State', _customer!.state ?? 'Not provided'),
              _buildReadOnlyField(
                  'Postal Code', _customer!.postalCode ?? 'Not provided'),
            ],
          ),

          const SizedBox(height: 20),

          // Account Information Section
          _buildSection(
            title: 'Account Information',
            icon: Icons.account_circle,
            children: [
              _buildReadOnlyField('Account Status',
                  _customer!.isActive ? 'Active' : 'Inactive'),
              _buildReadOnlyField(
                  'Member Since', _formatDate(_customer!.createdOn)),
              if (_customer!.updatedOn != null)
                _buildReadOnlyField(
                    'Last Updated', _formatDate(_customer!.updatedOn!)),
            ],
          ),

          const SizedBox(height: 32),

          // Save Button (only show when editing)
          if (_isEditing)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Save Changes',
                        style: TextStyle(fontSize: 16)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF2E7D32),
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
              color: Color(0xFF2E7D32),
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
            color: Colors.black.withOpacity(0.05),
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
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF2E7D32), size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
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
                      const BorderSide(color: Color(0xFF2E7D32), width: 2),
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
