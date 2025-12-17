// PART 2: UserCard, EditUserPage, AddUserPage, and Models

// User Card Widget
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pharmaish/config/environment_config.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';

class UserCard extends StatelessWidget {
  final UserDto user;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const UserCard({
    super.key,
    required this.user,
    this.onEdit,
    this.onDelete,
  });

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.purple;
      case 'manager':
        return Colors.orange;
      case 'chemist':
        return Colors.blue;
      case 'customersupport':
        return Colors.green;
      case 'customer':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: user.isActive ? Colors.black : Colors.grey,
                  child: Text(
                    user.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (user.email != null)
                        Text(
                          user.email!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      if (user.phoneNumber != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.phone,
                                size: 12, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              user.phoneNumber!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: user.isActive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.isActive ? 'ACTIVE' : 'INACTIVE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: user.isActive ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            if (user.roles.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: user.roles
                    .map((role) => Chip(
                          label: Text(
                            role,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor:
                              _getRoleColor(role).withOpacity(0.1),
                          side: BorderSide(
                              color: _getRoleColor(role).withOpacity(0.3)),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// EDIT USER PAGE WITH ROLE-SPECIFIC DTOs

class EditUserPage extends StatefulWidget {
  final dynamic user; // Can be CustomerDto, ManagerDto, MedicalStoreDto, etc.
  final String userRole; // "Customer", "Manager", "Chemist", etc.
  final VoidCallback onSaved;

  const EditUserPage({
    super.key,
    required this.user,
    required this.userRole,
    required this.onSaved,
  });

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();
  late Dio _dio;
  bool _isLoading = false;

  // Common fields
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  late TextEditingController _altMobileController;

  // Customer specific
  late TextEditingController _dobController;
  String? _selectedGender;

  // Manager specific
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _employeeIdController;

  // MedicalStore/Chemist specific
  late TextEditingController _medicalNameController;
  late TextEditingController _addressLine1Controller;
  late TextEditingController _addressLine2Controller;
  late TextEditingController _postalCodeController;
  late TextEditingController _gstinController;
  late TextEditingController _panController;
  late TextEditingController _fssaiController;
  late TextEditingController _dlNoController;
  late TextEditingController _pharmacistFirstNameController;
  late TextEditingController _pharmacistLastNameController;
  late TextEditingController _pharmacistRegNoController;
  late TextEditingController _pharmacistMobileController;

  late bool _isActive;
  DateTime? _dateOfBirth;

  @override
  void initState() {
    super.initState();
    _setupDio();
    _initializeControllers();
  }

  void _setupDio() {
    _dio = Dio();
    _dio.options.baseUrl = AppConstants.apiBaseUrl;
    _dio.options.connectTimeout = EnvironmentConfig.timeoutDuration;
    _dio.options.receiveTimeout = EnvironmentConfig.timeoutDuration;

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  void _initializeControllers() {
    final role = widget.userRole.toLowerCase();

    // Initialize common controllers
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _middleNameController = TextEditingController();
    _mobileController = TextEditingController();
    _emailController = TextEditingController();
    _altMobileController = TextEditingController();

    if (role == 'customer') {
      _initializeCustomerFields();
    } else if (role == 'manager') {
      _initializeManagerFields();
    } else if (role == 'chemist') {
      _initializeChemistFields();
    }

    _isActive = _getIsActive();
  }

  void _initializeCustomerFields() {
    final user = widget.user;
    _firstNameController.text = user.customerFirstName ?? '';
    _lastNameController.text = user.customerLastName ?? '';
    _middleNameController.text = user.customerMiddleName ?? '';
    _mobileController.text = user.mobileNumber ?? '';
    _emailController.text = user.emailId ?? '';
    _altMobileController.text = user.alternativeMobileNumber ?? '';
    _selectedGender = user.gender;
    _dateOfBirth = user.dateOfBirth;
    _dobController = TextEditingController(
      text: _dateOfBirth != null
          ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
          : '',
    );
  }

  void _initializeManagerFields() {
    final user = widget.user;
    _firstNameController.text = user.managerFirstName ?? '';
    _lastNameController.text = user.managerLastName ?? '';
    _middleNameController.text = user.managerMiddleName ?? '';
    _mobileController.text = user.mobileNumber ?? '';
    _emailController.text = user.emailId ?? '';
    _altMobileController.text = user.alternativeMobileNumber ?? '';
    _addressController = TextEditingController(text: user.address ?? '');
    _cityController = TextEditingController(text: user.city ?? '');
    _stateController = TextEditingController(text: user.state ?? '');
    _employeeIdController = TextEditingController(text: user.employeeId ?? '');
  }

  void _initializeChemistFields() {
    final user = widget.user;
    _medicalNameController = TextEditingController(text: user.medicalName ?? '');
    _firstNameController.text = user.ownerFirstName ?? '';
    _lastNameController.text = user.ownerLastName ?? '';
    _middleNameController.text = user.ownerMiddleName ?? '';
    _mobileController.text = user.mobileNumber ?? '';
    _emailController.text = user.emailId ?? '';
    _altMobileController.text = user.alternativeMobileNumber ?? '';
    _addressLine1Controller = TextEditingController(text: user.addressLine1 ?? '');
    _addressLine2Controller = TextEditingController(text: user.addressLine2 ?? '');
    _cityController = TextEditingController(text: user.city ?? '');
    _stateController = TextEditingController(text: user.state ?? '');
    _postalCodeController = TextEditingController(text: user.postalCode ?? '');
    _gstinController = TextEditingController(text: user.gstin ?? '');
    _panController = TextEditingController(text: user.pan ?? '');
    _fssaiController = TextEditingController(text: user.fssaiNo ?? '');
    _dlNoController = TextEditingController(text: user.dlNo ?? '');
    _pharmacistFirstNameController = TextEditingController(text: user.pharmacistFirstName ?? '');
    _pharmacistLastNameController = TextEditingController(text: user.pharmacistLastName ?? '');
    _pharmacistRegNoController = TextEditingController(text: user.pharmacistRegistrationNumber ?? '');
    _pharmacistMobileController = TextEditingController(text: user.pharmacistMobileNumber ?? '');
  }

  bool _getIsActive() {
    final user = widget.user;
    try {
      return user.isActive ?? true;
    } catch (e) {
      return true;
    }
  }

  String _getUserId() {
    final user = widget.user;
    final role = widget.userRole.toLowerCase();

    if (role == 'customer') {
      return user.customerId?.toString() ?? '';
    } else if (role == 'manager') {
      return user.managerId?.toString() ?? '';
    } else if (role == 'chemist') {
      return user.medicalStoreId?.toString() ?? '';
    }

    return '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _altMobileController.dispose();
    _dobController?.dispose();
    _addressController?.dispose();
    _cityController?.dispose();
    _stateController?.dispose();
    _employeeIdController?.dispose();
    _medicalNameController?.dispose();
    _addressLine1Controller?.dispose();
    _addressLine2Controller?.dispose();
    _postalCodeController?.dispose();
    _gstinController?.dispose();
    _panController?.dispose();
    _fssaiController?.dispose();
    _dlNoController?.dispose();
    _pharmacistFirstNameController?.dispose();
    _pharmacistLastNameController?.dispose();
    _pharmacistRegNoController?.dispose();
    _pharmacistMobileController?.dispose();
    super.dispose();
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updateUrl = _getUpdateUrl();
      final requestBody = _buildRequestBody();

      AppLogger.info('🔄 Updating user at $updateUrl with data: $requestBody');

      final response = await _dio.put(updateUrl, data: requestBody);

      if (mounted) {
        setState(() => _isLoading = false);

        if (response.statusCode == 200 || response.statusCode == 204) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User updated successfully'),
              backgroundColor: Colors.green,
            ),
          );

          widget.onSaved();
          Navigator.of(context).pop();
        }
      }
    } on DioException catch (e) {
      String errorMsg = 'Failed to update user';

      if (e.response?.statusCode == 400) {
        if (e.response?.data != null) {
          if (e.response?.data is Map && e.response?.data['error'] != null) {
            errorMsg = e.response?.data['error'];
          } else if (e.response?.data is Map && e.response?.data['errors'] != null) {
            final errors = e.response?.data['errors'];
            errorMsg = errors.values.first.join(', ');
          } else {
            errorMsg = 'Invalid user data. Please check all fields.';
          }
        }
      } else if (e.response?.statusCode == 404) {
        errorMsg = 'User not found';
      } else if (e.response?.statusCode == 403) {
        errorMsg = 'You don\'t have permission to update this user';
      } else if (e.response?.statusCode == 401) {
        errorMsg = 'Authentication failed. Please login again.';
      }

      if (mounted) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      AppLogger.error('❌ Error updating user: $errorMsg');
      AppLogger.error('Response: ${e.response?.data}');
    }
  }

  String _getUpdateUrl() {
    final userId = _getUserId();
    final role = widget.userRole.toLowerCase();

    switch (role) {
      case 'manager':
        return '/Managers/$userId';
      case 'chemist':
        return '/MedicalStores/$userId';
      case 'customer':
        return '/Customers/$userId';
      case 'customersupport':
        return '/CustomerSupports/$userId';
      default:
        return '/Users/$userId';
    }
  }

  Map<String, dynamic> _buildRequestBody() {
    final role = widget.userRole.toLowerCase();

    if (role == 'customer') {
      return _buildCustomerUpdateDto();
    } else if (role == 'manager') {
      return _buildManagerUpdateDto();
    } else if (role == 'chemist') {
      return _buildMedicalStoreUpdateDto();
    }

    return {};
  }

  Map<String, dynamic> _buildCustomerUpdateDto() {
    return {
      'customerFirstName': _firstNameController.text.trim(),
      'customerLastName': _lastNameController.text.trim(),
      'customerMiddleName': _middleNameController.text.trim().isNotEmpty
          ? _middleNameController.text.trim()
          : null,
      'mobileNumber': _mobileController.text.trim(),
      'alternativeMobileNumber': _altMobileController.text.trim().isNotEmpty
          ? _altMobileController.text.trim()
          : null,
      'emailId': _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : null,
      'dateOfBirth': _dateOfBirth?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'gender': _selectedGender,
      'isActive': _isActive,
      // 'customerPhoto': null, // Keep existing photo
      // 'addresses': null, // Keep existing addresses
    };
  }

  Map<String, dynamic> _buildManagerUpdateDto() {
    return {
      'managerFirstName': _firstNameController.text.trim(),
      'managerLastName': _lastNameController.text.trim(),
      'managerMiddleName': _middleNameController.text.trim(),
      'address': _addressController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'mobileNumber': _mobileController.text.trim(),
      'emailId': _emailController.text.trim(),
      'alternativeMobileNumber': _altMobileController.text.trim(),
      'employeeId': _employeeIdController.text.trim(),
    };
  }

  Map<String, dynamic> _buildMedicalStoreUpdateDto() {
    return {
      'medicalName': _medicalNameController.text.trim(),
      'ownerFirstName': _firstNameController.text.trim(),
      'ownerLastName': _lastNameController.text.trim(),
      'ownerMiddleName': _middleNameController.text.trim(),
      'addressLine1': _addressLine1Controller.text.trim(),
      'addressLine2': _addressLine2Controller.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'postalCode': _postalCodeController.text.trim(),
      'mobileNumber': _mobileController.text.trim(),
      'emailId': _emailController.text.trim(),
      'alternativeMobileNumber': _altMobileController.text.trim(),
      'gstin': _gstinController.text.trim().isNotEmpty
          ? _gstinController.text.trim()
          : null,
      'pan': _panController.text.trim(),
      'fssaiNo': _fssaiController.text.trim(),
      'dlNo': _dlNoController.text.trim(),
      'pharmacistFirstName': _pharmacistFirstNameController.text.trim(),
      'pharmacistLastName': _pharmacistLastNameController.text.trim(),
      'pharmacistRegistrationNumber': _pharmacistRegNoController.text.trim(),
      'pharmacistMobileNumber': _pharmacistMobileController.text.trim(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit ${widget.userRole}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildUserHeader(),
            const SizedBox(height: 16),
            _buildRoleSpecificFields(),
            const SizedBox(height: 24),
            _buildUpdateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Card(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Text(
                _getInitials(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getFullName(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.userRole,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFullName() {
    return '${_firstNameController.text} ${_lastNameController.text}'.trim();
  }

  String _getInitials() {
    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    return '${first.isNotEmpty ? first[0] : ''}${last.isNotEmpty ? last[0] : ''}'.toUpperCase();
  }

  Widget _buildRoleSpecificFields() {
    final role = widget.userRole.toLowerCase();

    if (role == 'customer') {
      return _buildCustomerFields();
    } else if (role == 'manager') {
      return _buildManagerFields();
    } else if (role == 'chemist') {
      return _buildChemistFields();
    }

    return const SizedBox.shrink();
  }

  Widget _buildCustomerFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _firstNameController,
          label: 'First Name *',
          icon: Icons.person,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _lastNameController,
          label: 'Last Name *',
          icon: Icons.person_outline,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _middleNameController,
          label: 'Middle Name',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _mobileController,
          label: 'Mobile Number *',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _altMobileController,
          label: 'Alternative Mobile',
          icon: Icons.phone_android,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildDateField(),
        const SizedBox(height: 16),
        _buildGenderField(),
        const SizedBox(height: 16),
        _buildActiveSwitch(),
      ],
    );
  }

  Widget _buildManagerFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _firstNameController,
          label: 'First Name *',
          icon: Icons.person,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _lastNameController,
          label: 'Last Name *',
          icon: Icons.person_outline,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _middleNameController,
          label: 'Middle Name',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _mobileController,
          label: 'Mobile Number *',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _altMobileController,
          label: 'Alternative Mobile',
          icon: Icons.phone_android,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email *',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _employeeIdController,
          label: 'Employee ID *',
          icon: Icons.badge,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _addressController,
          label: 'Address *',
          icon: Icons.location_on,
          maxLines: 2,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _cityController,
                label: 'City *',
                icon: Icons.location_city,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _stateController,
                label: 'State *',
                icon: Icons.map,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChemistFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medical Store Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _medicalNameController,
          label: 'Medical Store Name *',
          icon: Icons.local_pharmacy,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        const Divider(),
        const Text(
          'Owner Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _firstNameController,
          label: 'Owner First Name *',
          icon: Icons.person,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _lastNameController,
          label: 'Owner Last Name *',
          icon: Icons.person_outline,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _middleNameController,
          label: 'Owner Middle Name',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        const Divider(),
        const Text(
          'Contact Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _mobileController,
          label: 'Mobile Number *',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _altMobileController,
          label: 'Alternative Mobile',
          icon: Icons.phone_android,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email *',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        const Divider(),
        const Text(
          'Address',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _addressLine1Controller,
          label: 'Address Line 1 *',
          icon: Icons.location_on,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _addressLine2Controller,
          label: 'Address Line 2',
          icon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _cityController,
                label: 'City *',
                icon: Icons.location_city,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _stateController,
                label: 'State *',
                icon: Icons.map,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _postalCodeController,
          label: 'Postal Code *',
          icon: Icons.markunread_mailbox,
          keyboardType: TextInputType.number,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        const Divider(),
        const Text(
          'Registration Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _gstinController,
          label: 'GSTIN',
          icon: Icons.numbers,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _panController,
          label: 'PAN *',
          icon: Icons.credit_card,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _fssaiController,
          label: 'FSSAI No *',
          icon: Icons.food_bank,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _dlNoController,
          label: 'DL No *',
          icon: Icons.card_membership,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        const Divider(),
        const Text(
          'Pharmacist Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _pharmacistFirstNameController,
                label: 'Pharmacist First Name *',
                icon: Icons.medical_services,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _pharmacistLastNameController,
                label: 'Last Name *',
                icon: Icons.medical_services_outlined,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _pharmacistRegNoController,
          label: 'Registration Number *',
          icon: Icons.app_registration,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _pharmacistMobileController,
          label: 'Pharmacist Mobile *',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dobController,
      decoration: const InputDecoration(
        labelText: 'Date of Birth',
        prefixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(),
      ),
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );

        if (date != null) {
          setState(() {
            _dateOfBirth = date;
            _dobController.text = '${date.day}/${date.month}/${date.year}';
          });
        }
      },
    );
  }

  Widget _buildGenderField() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: const InputDecoration(
        labelText: 'Gender',
        prefixIcon: Icon(Icons.wc),
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'Male', child: Text('Male')),
        DropdownMenuItem(value: 'Female', child: Text('Female')),
        DropdownMenuItem(value: 'Other', child: Text('Other')),
      ],
      onChanged: (value) {
        setState(() => _selectedGender = value);
      },
    );
  }

  Widget _buildActiveSwitch() {
    return Card(
      child: SwitchListTile(
        title: const Text('Active'),
        subtitle: const Text('User can login and access system'),
        value: _isActive,
        onChanged: (value) {
          setState(() => _isActive = value);
        },
        activeColor: Colors.green,
      ),
    );
  }

  Widget _buildUpdateButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _updateUser,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
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
          : const Text(
              'Update User',
              style: TextStyle(fontSize: 16),
            ),
    );
  }
}

// Add User Page (from previous implementation)
class AddUserPage extends StatefulWidget {
  final List<RoleDto> availableRoles;
  final VoidCallback onSaved;

  const AddUserPage({
    super.key,
    required this.availableRoles,
    required this.onSaved,
  });

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  late Dio _dio;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedRoleId;
  bool _isActive = true;
  bool _emailConfirmed = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _setupDio();
  }

  void _setupDio() {
    _dio = Dio();
    _dio.options.baseUrl = AppConstants.apiBaseUrl;
    _dio.options.connectTimeout = EnvironmentConfig.timeoutDuration;
    _dio.options.receiveTimeout = EnvironmentConfig.timeoutDuration;

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRoleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a role'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _dio.post(
        '/Users/create-with-role',
        data: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'roleId': _selectedRoleId,
          'phoneNumber': _phoneController.text.trim(),
          'emailConfirmed': _emailConfirmed,
          'isActive': _isActive,
        },
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (response.statusCode == 201 || response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User created successfully'),
              backgroundColor: Colors.green,
            ),
          );

          widget.onSaved();
          Navigator.of(context).pop();
        }
      }
    } on DioException catch (e) {
      String errorMsg = 'Failed to create user';

      if (e.response?.statusCode == 400) {
        if (e.response?.data != null && e.response?.data['error'] != null) {
          errorMsg = e.response?.data['error'];
        } else {
          errorMsg = 'Invalid user data. Please check all fields.';
        }
      } else if (e.response?.statusCode == 403) {
        errorMsg = 'You don\'t have permission to create users';
      }

      if (mounted) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
          ),
        );
      }

      AppLogger.error('Error creating user: $errorMsg');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New User',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                hintText: 'user@example.com',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password *',
                hintText: 'Minimum 6 characters',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '1234567890',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _selectedRoleId,
              decoration: const InputDecoration(
                labelText: 'Role *',
                prefixIcon: Icon(Icons.shield),
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              hint: const Text('Select a role'),
              items: widget.availableRoles.map((role) {
                return DropdownMenuItem(
                  value: role.id,
                  child: Text(role.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedRoleId = value);
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a role';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Active'),
                    subtitle: const Text('User can login and access system'),
                    value: _isActive,
                    onChanged: (value) {
                      setState(() => _isActive = value);
                    },
                    activeColor: Colors.green,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Email Confirmed'),
                    subtitle: const Text('Skip email verification'),
                    value: _emailConfirmed,
                    onChanged: (value) {
                      setState(() => _emailConfirmed = value);
                    },
                    activeColor: Colors.blue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _createUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
                  : const Text(
                      'Create User',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// User DTO Model
class UserDto {
  final String id;
  final String? userName;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final List<String> roles;
  final bool isActive;
  final bool emailConfirmed;
  final DateTime? createdAt;

  UserDto({
    required this.id,
    this.userName,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    required this.roles,
    required this.isActive,
    required this.emailConfirmed,
    this.createdAt,
  });

  String get fullName {
    if (firstName != null || lastName != null) {
      return '${firstName ?? ''} ${lastName ?? ''}'.trim();
    }
    return email ?? userName ?? 'Unknown User';
  }

  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    }
    if (firstName != null) {
      return firstName!.substring(0, 1).toUpperCase();
    }
    if (email != null && email!.isNotEmpty) {
      return email!.substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  factory UserDto.fromJson(Map<String, dynamic> json) {
    List<String> rolesList = [];

    if (json['roles'] != null) {
      if (json['roles'] is List) {
        final rolesData = json['roles'] as List;
        rolesList = rolesData.map((r) {
          if (r is String) return r;
          if (r is Map && r.containsKey('name')) return r['name'].toString();
          if (r is Map && r.containsKey('roleName'))
            return r['roleName'].toString();
          return r.toString();
        }).toList();
      } else if (json['roles'] is String) {
        rolesList = [json['roles'].toString()];
      }
    }

    return UserDto(
      id: json['id'] ?? '',
      userName: json['userName'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      roles: rolesList,
      isActive: json['isActive'] ?? true,
      emailConfirmed: json['emailConfirmed'] ?? false,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}

// Role DTO Model
class RoleDto {
  final String id;
  final String name;

  RoleDto({
    required this.id,
    required this.name,
  });

  factory RoleDto.fromJson(Map<String, dynamic> json) {
    return RoleDto(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}