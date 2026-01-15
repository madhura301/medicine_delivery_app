// ============================================================================
// CREATE USER SCREEN - Admin functionality to create role-based users
// ============================================================================

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pharmaish/utils/app_logger.dart';

class CreateUserScreen extends StatefulWidget {
  final Dio dio;

  const CreateUserScreen({Key? key, required this.dio}) : super(key: key);

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Role selection
  String? _selectedRole;
  final List<Map<String, dynamic>> _roles = [
    {
      'value': 'Customer',
      'label': 'Customer',
      'icon': Icons.person,
      'color': Colors.green,
    },
    {
      'value': 'CustomerSupport',
      'label': 'Customer Support',
      'icon': Icons.support_agent,
      'color': Colors.blue,
    },
    {
      'value': 'Chemist',
      'label': 'Chemist / Medical Store',
      'icon': Icons.local_pharmacy,
      'color': Colors.purple,
    },
    {
      'value': 'Manager',
      'label': 'Manager',
      'icon': Icons.business_center,
      'color': Colors.orange,
    },
    {
      'value': 'DeliveryBoy',
      'label': 'Delivery Boy',
      'icon': Icons.delivery_dining,
      'color': Colors.teal,
    },
  ];

  // Common fields for all users
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String? _selectedGender;

  // Customer specific fields
  final _dobController = TextEditingController();

  // Customer Support specific fields
  final _employeeIdController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _supportAddressController = TextEditingController();
  final _supportCityController = TextEditingController();
  final _supportStateController = TextEditingController();
  final _alternativeMobileController = TextEditingController();
  int? _selectedRegionId;

  // Chemist specific fields
  final _medicalNameController = TextEditingController();
  final _ownerMiddleNameController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _alternativePhoneController = TextEditingController();
  final _gstinController = TextEditingController();
  final _panController = TextEditingController();
  final _fssaiController = TextEditingController();
  final _dlNumberController = TextEditingController();
  final _pharmacistFirstNameController = TextEditingController();
  final _pharmacistLastNameController = TextEditingController();
  final _pharmacistRegNumberController = TextEditingController();
  final _pharmacistPhoneController = TextEditingController();

  // Manager specific fields
  final _managerEmployeeIdController = TextEditingController();
  final _departmentController = TextEditingController();

  // Delivery Boy specific fields (using Manager entity for now)
  final _deliveryBoyEmployeeIdController = TextEditingController();
  final _vehicleTypeController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _employeeIdController.dispose();
    _middleNameController.dispose();
    _supportAddressController.dispose();
    _supportCityController.dispose();
    _supportStateController.dispose();
    _alternativeMobileController.dispose();
    _medicalNameController.dispose();
    _ownerMiddleNameController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _alternativePhoneController.dispose();
    _gstinController.dispose();
    _panController.dispose();
    _fssaiController.dispose();
    _dlNumberController.dispose();
    _pharmacistFirstNameController.dispose();
    _pharmacistLastNameController.dispose();
    _pharmacistRegNumberController.dispose();
    _pharmacistPhoneController.dispose();
    _managerEmployeeIdController.dispose();
    _departmentController.dispose();
    _deliveryBoyEmployeeIdController.dispose();
    _vehicleTypeController.dispose();
    super.dispose();
  }

  // =========================================================================
  // CREATE USER API CALLS
  // =========================================================================

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRole == null) {
      _showError('Please select a role');
      return;
    }

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> userData;
      String endpoint;

      switch (_selectedRole) {
        case 'Customer':
          endpoint = '/Customers';
          userData = {
            'mobileNumber': _mobileController.text.trim(),
            'emailId': _emailController.text.trim(),
            'password': _passwordController.text,
            'customerFirstName': _firstNameController.text.trim(),
            'customerLastName': _lastNameController.text.trim(),
            'gender': _selectedGender,
            'dateOfBirth': _dobController.text.isNotEmpty ? _dobController.text : null,
            'isActive': true,
          };
          break;

        case 'CustomerSupport':
          endpoint = '/CustomerSupports/register';
          userData = {
            'customerSupportFirstName': _firstNameController.text.trim(),
            'customerSupportLastName': _lastNameController.text.trim(),
            'customerSupportMiddleName': _middleNameController.text.trim(),
            'address': _supportAddressController.text.trim(),
            'city': _supportCityController.text.trim(),
            'state': _supportStateController.text.trim(),
            'mobileNumber': _mobileController.text.trim(),
            'emailId': _emailController.text.trim(),
            'alternativeMobileNumber': _alternativeMobileController.text.trim(),
            'employeeId': _employeeIdController.text.trim(),
            'customerSupportRegionId': _selectedRegionId,
          };
          break;

        case 'Chemist':
          endpoint = '/MedicalStores/register';
          userData = {
            'medicalName': _medicalNameController.text.trim(),
            'ownerFirstName': _firstNameController.text.trim(),
            'ownerLastName': _lastNameController.text.trim(),
            'ownerMiddleName': _ownerMiddleNameController.text.trim(),
            'password': _passwordController.text,
            'addressLine1': _addressLine1Controller.text.trim(),
            'addressLine2': _addressLine2Controller.text.trim(),
            'city': _cityController.text.trim(),
            'state': _stateController.text.trim(),
            'postalCode': _postalCodeController.text.trim(),
            'mobileNumber': _mobileController.text.trim(),
            'emailId': _emailController.text.trim(),
            'alternativeMobileNumber': _alternativePhoneController.text.trim(),
            'gstin': _gstinController.text.trim(),
            'pan': _panController.text.trim(),
            'fssaiNo': _fssaiController.text.trim(),
            'dlNo': _dlNumberController.text.trim(),
            'pharmacistFirstName': _pharmacistFirstNameController.text.trim(),
            'pharmacistLastName': _pharmacistLastNameController.text.trim(),
            'pharmacistRegistrationNumber': _pharmacistRegNumberController.text.trim(),
            'pharmacistMobileNumber': _pharmacistPhoneController.text.trim(),
            'registrationStatus': false,
          };
          break;

        case 'Manager':
          endpoint = '/Managers';
          userData = {
            'mobileNumber': _mobileController.text.trim(),
            'emailId': _emailController.text.trim(),
            'password': _passwordController.text,
            'managerFirstName': _firstNameController.text.trim(),
            'managerLastName': _lastNameController.text.trim(),
            'gender': _selectedGender,
            'employeeId': _managerEmployeeIdController.text.trim(),
            'department': _departmentController.text.trim(),
            'isActive': true,
          };
          break;

        case 'DeliveryBoy':
          // Using Managers endpoint with different role
          endpoint = '/Managers';
          userData = {
            'mobileNumber': _mobileController.text.trim(),
            'emailId': _emailController.text.trim(),
            'password': _passwordController.text,
            'managerFirstName': _firstNameController.text.trim(),
            'managerLastName': _lastNameController.text.trim(),
            'gender': _selectedGender,
            'employeeId': _deliveryBoyEmployeeIdController.text.trim(),
            'department': 'Delivery',
            'isActive': true,
          };
          break;

        default:
          _showError('Invalid role selected');
          setState(() => _isLoading = false);
          return;
      }

      AppLogger.info('Creating $_selectedRole user at endpoint: $endpoint');
      AppLogger.info('User data: $userData');

      final response = await widget.dio.post(
        endpoint,
        data: userData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.info('✅ User created successfully');
        
        // Check if CustomerSupport or MedicalStore and show generated password
        if ((_selectedRole == 'CustomerSupport' || _selectedRole == 'Chemist') && 
            response.data != null) {
          
          // Extract password from response
          String? generatedPassword;
          if (_selectedRole == 'CustomerSupport') {
            generatedPassword = response.data['password'];
          } else if (_selectedRole == 'Chemist') {
            // MedicalStore response might be nested
            if (response.data is Map) {
              generatedPassword = response.data['password'] ?? 
                                 response.data['medicalStore']?['password'];
            }
          }
          
          if (generatedPassword != null && generatedPassword.isNotEmpty) {
            // Show dialog with generated password
            if (mounted) {
              await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade600),
                      const SizedBox(width: 8),
                      const Text('User Created Successfully!'),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_selectedRole account has been created.',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.key, color: Colors.amber.shade700, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Generated Password',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              generatedPassword ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber, color: Colors.red.shade700, size: 16),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Save this password! It won\'t be shown again.',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('I\'ve Saved It'),
                    ),
                  ],
                ),
              );
            }
          }
        } else {
          _showSuccess('$_selectedRole created successfully!');
          await Future.delayed(const Duration(seconds: 1));
        }
        
        if (mounted) {
          Navigator.pop(context, true); // true indicates success
        }
      } else {
        AppLogger.warning('⚠️ Unexpected status code: ${response.statusCode}');
        _showError('Failed to create user. Please try again.');
      }
    } on DioException catch (e) {
      AppLogger.error('❌ DioException: ${e.response?.statusCode}');
      AppLogger.error('Response: ${e.response?.data}');

      String errorMessage = 'Failed to create user';

      if (e.response?.statusCode == 400) {
        final errors = e.response?.data;
        if (errors is Map) {
          errorMessage = errors['message'] ?? errors.toString();
        } else {
          errorMessage = 'Invalid data provided. Please check all fields.';
        }
      } else if (e.response?.statusCode == 409) {
        errorMessage = 'User already exists with this mobile number or email.';
      } else if (e.response?.statusCode == 500) {
        errorMessage = 'Server error occurred. Please try again later.';
      }

      _showError(errorMessage);
    } catch (e) {
      AppLogger.error('❌ Unexpected error: $e');
      _showError('An unexpected error occurred: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // =========================================================================
  // UI BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New User'),
        backgroundColor: Colors.black,
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
                    // Role Selection Card
                    _buildRoleSelectionCard(),
                    const SizedBox(height: 24),

                    // Common fields (shown for all roles)
                    if (_selectedRole != null) ...[
                      _buildSectionHeader('Basic Information'),
                      const SizedBox(height: 12),
                      _buildCommonFields(),
                      const SizedBox(height: 24),
                    ],

                    // Role-specific fields
                    if (_selectedRole == 'Customer') ...[
                      _buildSectionHeader('Customer Details'),
                      const SizedBox(height: 12),
                      _buildCustomerFields(),
                    ],
                    if (_selectedRole == 'CustomerSupport') ...[
                      _buildSectionHeader('Employee Details'),
                      const SizedBox(height: 12),
                      _buildCustomerSupportFields(),
                    ],
                    if (_selectedRole == 'Chemist') ...[
                      _buildSectionHeader('Medical Store Details'),
                      const SizedBox(height: 12),
                      _buildChemistFields(),
                    ],
                    if (_selectedRole == 'Manager') ...[
                      _buildSectionHeader('Manager Details'),
                      const SizedBox(height: 12),
                      _buildManagerFields(),
                    ],
                    if (_selectedRole == 'DeliveryBoy') ...[
                      _buildSectionHeader('Delivery Person Details'),
                      const SizedBox(height: 12),
                      _buildDeliveryBoyFields(),
                    ],

                    // Create button
                    if (_selectedRole != null) ...[
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _createUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Create $_selectedRole',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildRoleSelectionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select User Role',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: InputDecoration(
                labelText: 'Role',
                prefixIcon: const Icon(Icons.admin_panel_settings),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              items: _roles.map((role) {
                return DropdownMenuItem<String>(
                  value: role['value'],
                  child: Row(
                    children: [
                      Icon(
                        role['icon'] as IconData,
                        color: role['color'] as Color,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(role['label'] as String),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a role';
                }
                return null;
              },
            ),
            if (_selectedRole != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _roles
                      .firstWhere((r) => r['value'] == _selectedRole)['color']
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: _roles.firstWhere(
                          (r) => r['value'] == _selectedRole)['color'],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getRoleDescription(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getRoleDescription() {
    switch (_selectedRole) {
      case 'Customer':
        return 'Customers can place orders, track deliveries, and manage their profile.';
      case 'CustomerSupport':
        return 'Support staff can assist customers, manage queries, and handle order issues. Password will be auto-generated.';
      case 'Chemist':
        return 'Chemists/Pharmacists can manage their store, accept orders, and update inventory.';
      case 'Manager':
        return 'Managers can oversee operations, manage staff, and view reports.';
      case 'DeliveryBoy':
        return 'Delivery personnel can accept deliveries, update status, and complete orders.';
      default:
        return '';
    }
  }

  Widget _buildCommonFields() {
    final bool showPassword = _selectedRole != 'CustomerSupport'; // Hide password for CustomerSupport
    
    return Column(
      children: [
        // Mobile Number
        TextFormField(
          controller: _mobileController,
          decoration: InputDecoration(
            labelText: 'Mobile Number',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Mobile number is required';
            }
            if (value.length != 10) {
              return 'Please enter a valid 10-digit mobile number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Email
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email Address',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email is required';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Password (hidden for CustomerSupport - auto-generated by API)
        if (showPassword) ...[
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.grey.shade50,
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
        ] else ...[
          // Info message for CustomerSupport
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Password will be auto-generated and sent to the user',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // First Name
        TextFormField(
          controller: _firstNameController,
          decoration: InputDecoration(
            labelText: 'First Name',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'First name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Last Name
        TextFormField(
          controller: _lastNameController,
          decoration: InputDecoration(
            labelText: 'Last Name',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Last name is required';
            }
            return null;
          },
        ),

        // Gender (for applicable roles - not for CustomerSupport or Chemist)
        if (_selectedRole != 'Chemist' && _selectedRole != 'CustomerSupport') ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: InputDecoration(
              labelText: 'Gender',
              prefixIcon: const Icon(Icons.wc),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            items: ['Male', 'Female', 'Other'].map((gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildCustomerFields() {
    return Column(
      children: [
        TextFormField(
          controller: _dobController,
          decoration: InputDecoration(
            labelText: 'Date of Birth (Optional)',
            prefixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
            hintText: 'YYYY-MM-DD',
          ),
          keyboardType: TextInputType.datetime,
        ),
      ],
    );
  }

  Widget _buildCustomerSupportFields() {
    return Column(
      children: [
        // Middle Name
        TextFormField(
          controller: _middleNameController,
          decoration: InputDecoration(
            labelText: 'Middle Name (Optional)',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),

        // Employee ID
        TextFormField(
          controller: _employeeIdController,
          decoration: InputDecoration(
            labelText: 'Employee ID',
            prefixIcon: const Icon(Icons.badge),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Employee ID is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Address
        TextFormField(
          controller: _supportAddressController,
          decoration: InputDecoration(
            labelText: 'Address',
            prefixIcon: const Icon(Icons.location_on),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          maxLines: 2,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Address is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // City and State
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _supportCityController,
                decoration: InputDecoration(
                  labelText: 'City',
                  prefixIcon: const Icon(Icons.location_city),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'City is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _supportStateController,
                decoration: InputDecoration(
                  labelText: 'State',
                  prefixIcon: const Icon(Icons.map),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'State is required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Alternative Mobile Number
        TextFormField(
          controller: _alternativeMobileController,
          decoration: InputDecoration(
            labelText: 'Alternative Mobile Number (Optional)',
            prefixIcon: const Icon(Icons.phone_android),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value != null && value.isNotEmpty && value.length != 10) {
              return 'Please enter a valid 10-digit mobile number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Customer Support Region (Optional)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  const Text(
                    'Region Assignment (Optional)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'You can assign a region later through the region management interface.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChemistFields() {
    return Column(
      children: [
        // Owner Middle Name
        TextFormField(
          controller: _ownerMiddleNameController,
          decoration: InputDecoration(
            labelText: 'Owner Middle Name (Optional)',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        
        // Medical Store Name
        TextFormField(
          controller: _medicalNameController,
          decoration: InputDecoration(
            labelText: 'Medical Store Name',
            prefixIcon: const Icon(Icons.store),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Store name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Address Line 1
        TextFormField(
          controller: _addressLine1Controller,
          decoration: InputDecoration(
            labelText: 'Address Line 1',
            prefixIcon: const Icon(Icons.location_on),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Address is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Address Line 2
        TextFormField(
          controller: _addressLine2Controller,
          decoration: InputDecoration(
            labelText: 'Address Line 2 (Optional)',
            prefixIcon: const Icon(Icons.location_on_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        const SizedBox(height: 16),
        
        // City, State, Postal Code
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'City',
                  prefixIcon: const Icon(Icons.location_city),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'City required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _stateController,
                decoration: InputDecoration(
                  labelText: 'State',
                  prefixIcon: const Icon(Icons.map),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'State required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Postal Code
        TextFormField(
          controller: _postalCodeController,
          decoration: InputDecoration(
            labelText: 'Postal Code / PIN Code',
            prefixIcon: const Icon(Icons.pin_drop),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Postal code is required';
            }
            if (value.length != 6) {
              return 'Please enter a valid 6-digit postal code';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Alternative Mobile Number
        TextFormField(
          controller: _alternativePhoneController,
          decoration: InputDecoration(
            labelText: 'Alternative Mobile Number (Optional)',
            prefixIcon: const Icon(Icons.phone_android),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value != null && value.isNotEmpty && value.length != 10) {
              return 'Please enter a valid 10-digit mobile number';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        
        // License & Registration Section Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'License & Registration Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade900,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // GSTIN
        TextFormField(
          controller: _gstinController,
          decoration: InputDecoration(
            labelText: 'GSTIN (Optional)',
            prefixIcon: const Icon(Icons.receipt_long),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
            hintText: '15-digit GST number',
          ),
        ),
        const SizedBox(height: 16),
        
        // PAN
        TextFormField(
          controller: _panController,
          decoration: InputDecoration(
            labelText: 'PAN Number',
            prefixIcon: const Icon(Icons.badge),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
            hintText: '10-character PAN',
          ),
          textCapitalization: TextCapitalization.characters,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'PAN number is required';
            }
            if (value.length != 10) {
              return 'PAN must be 10 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // FSSAI Number
        TextFormField(
          controller: _fssaiController,
          decoration: InputDecoration(
            labelText: 'FSSAI License Number',
            prefixIcon: const Icon(Icons.verified),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
            hintText: '14-digit FSSAI number',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'FSSAI number is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Drug License (DL) Number
        TextFormField(
          controller: _dlNumberController,
          decoration: InputDecoration(
            labelText: 'Drug License (DL) Number',
            prefixIcon: const Icon(Icons.local_hospital),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Drug License number is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        
        // Pharmacist Section Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Pharmacist Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Pharmacist First Name
        TextFormField(
          controller: _pharmacistFirstNameController,
          decoration: InputDecoration(
            labelText: 'Pharmacist First Name',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Pharmacist first name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Pharmacist Last Name
        TextFormField(
          controller: _pharmacistLastNameController,
          decoration: InputDecoration(
            labelText: 'Pharmacist Last Name',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Pharmacist last name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Pharmacist Registration Number
        TextFormField(
          controller: _pharmacistRegNumberController,
          decoration: InputDecoration(
            labelText: 'Pharmacist Registration Number',
            prefixIcon: const Icon(Icons.card_membership),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Registration number is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Pharmacist Mobile Number
        TextFormField(
          controller: _pharmacistPhoneController,
          decoration: InputDecoration(
            labelText: 'Pharmacist Mobile Number',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Pharmacist mobile number is required';
            }
            if (value.length != 10) {
              return 'Please enter a valid 10-digit mobile number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildManagerFields() {
    return Column(
      children: [
        TextFormField(
          controller: _managerEmployeeIdController,
          decoration: InputDecoration(
            labelText: 'Employee ID',
            prefixIcon: const Icon(Icons.badge),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Employee ID is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _departmentController,
          decoration: InputDecoration(
            labelText: 'Department',
            prefixIcon: const Icon(Icons.business),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Department is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDeliveryBoyFields() {
    return Column(
      children: [
        TextFormField(
          controller: _deliveryBoyEmployeeIdController,
          decoration: InputDecoration(
            labelText: 'Employee ID',
            prefixIcon: const Icon(Icons.badge),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Employee ID is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _vehicleTypeController,
          decoration: InputDecoration(
            labelText: 'Vehicle Type (Optional)',
            prefixIcon: const Icon(Icons.two_wheeler),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
            hintText: 'e.g., Bike, Scooter, Car',
          ),
        ),
      ],
    );
  }
}