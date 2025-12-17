import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pharmaish/config/environment_config.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';

// COMPLETE VERSION WITH EDIT AND DELETE

class UserWithRole {
  final Map<String, dynamic> user;
  final String role;
  final String id;

  UserWithRole({
    required this.user,
    required this.role,
    required this.id,
  });
}

class AdminUserManagement extends StatefulWidget {
  const AdminUserManagement({super.key});

  @override
  State<AdminUserManagement> createState() => _AdminUserManagementState();
}

class _AdminUserManagementState extends State<AdminUserManagement> {
  late Dio _dio;
  List<UserWithRole> _users = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedRoleFilter;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _setupDio();
    _loadUsers();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _dio.get('/Users');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final usersList = <UserWithRole>[];

        for (var json in data) {
          String role = 'Customer';
          if (json['roles'] != null &&
              json['roles'] is List &&
              (json['roles'] as List).isNotEmpty) {
            final roleData = json['roles'][0];
            role = roleData is String
                ? roleData
                : (roleData['name'] ?? 'Customer');
          }

          // Get user ID (generic id is fine - we call the right endpoint)
          String userId = _getUserId(json, role);

          AppLogger.info('👤 User: $role - ID: $userId');

          usersList.add(UserWithRole(
            user: json,
            role: role,
            id: userId,
          ));
        }

        setState(() {
          _users = usersList;
          _isLoading = false;
        });

        AppLogger.info('✅ Loaded ${_users.length} users');
      }
    } on DioException catch (e) {
      String errorMsg = 'Failed to load users';
      if (e.response?.statusCode == 401) {
        errorMsg = 'Authentication failed.';
      } else if (e.response?.statusCode == 403) {
        errorMsg = 'Access denied.';
      }

      setState(() {
        _errorMessage = errorMsg;
        _isLoading = false;
      });
    }
  }

  // Helper method to get ID from user JSON
  String _getUserId(Map<String, dynamic> json, String role) {
    // Try role-specific ID first (if backend includes it)
    final roleKey = role.toLowerCase();

    String? roleId;
    switch (roleKey) {
      case 'customer':
        roleId = json['customerId']?.toString();
        break;
      case 'manager':
        roleId = json['managerId']?.toString();
        break;
      case 'chemist':
      case 'medicalstore':
        roleId = json['medicalStoreId']?.toString();
        break;
      case 'customersupport':
        roleId = json['customerSupportId']?.toString();
        break;
    }

    // Use role-specific ID if available, otherwise use generic id
    // The generic id works fine - we just need to call the right endpoint
    final finalId = roleId ?? json['id']?.toString() ?? '';

    return finalId;
  }

  // Navigate to Edit User Page
  void _navigateToEditUser(UserWithRole userWithRole) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserPage(
          userWithRole: userWithRole,
          onSaved: _loadUsers,
        ),
      ),
    );
  }

  // Confirm and Delete User
  Future<void> _confirmDeleteUser(UserWithRole userWithRole) async {
    final displayName = _getDisplayName(userWithRole.user);
    final email = _getEmail(userWithRole.user);

    // 🔍 DEBUG LOGGING
    AppLogger.info('🔍 ==========================================');
    AppLogger.info('🔍 DELETE BUTTON CLICKED');
    AppLogger.info('🔍 Display Name: $displayName');
    AppLogger.info('🔍 Email: $email');
    AppLogger.info('🔍 Role: ${userWithRole.role}');
    AppLogger.info('🔍 UserWithRole.id: ${userWithRole.id}');
    AppLogger.info('🔍 user["id"]: ${userWithRole.user["id"]}');
    AppLogger.info('🔍 user["customerId"]: ${userWithRole.user["customerId"]}');
    AppLogger.info('🔍 user["managerId"]: ${userWithRole.user["managerId"]}');
    AppLogger.info(
        '🔍 user["medicalStoreId"]: ${userWithRole.user["medicalStoreId"]}');
    AppLogger.info('🔍 ==========================================');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Confirm Delete'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Are you sure you want to delete this user? ${userWithRole.id}'),
            const SizedBox(height: 12),
            Text(
              'User: $displayName',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (email != null) Text('Email: $email'),
            Text('Role: ${userWithRole.role}'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will deactivate the user account',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteUser(userWithRole);
    }
  }

  // FINAL CORRECT DELETE FIX
// Customer has: customerId (PK), userId (FK to User)
// We need to find Customer by userId, then delete by customerId

  Future<void> _deleteUser(UserWithRole userWithRole) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Deleting user...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final role = userWithRole.role.toLowerCase();
      final userId = userWithRole.user['id']?.toString() ?? '';

      AppLogger.info(
          '🔍 Looking for role-specific record with userId: $userId');
      AppLogger.info('📋 Role: $role');

      String? roleSpecificId;
      String deleteUrl;

      if (role == 'customer') {
        // Get all customers and find the one with this userId (FK)
        final response = await _dio.get('/Customers');
        final List<dynamic> customers = response.data;

        AppLogger.info(
            '📊 Searching ${customers.length} customers for userId: $userId');

        for (var customer in customers) {
          final customerUserId = customer['userId']?.toString();
          if (customerUserId == userId) {
            roleSpecificId = customer['customerId']?.toString();
            AppLogger.info(
                '✅ Found Customer! customerId: $roleSpecificId, userId: $customerUserId');
            break;
          }
        }

        if (roleSpecificId == null) {
          AppLogger.error('❌ No customer found with userId: $userId');
          throw Exception('Customer record not found for this user');
        }

        deleteUrl = '/Customers/$roleSpecificId';
      } else if (role == 'manager') {
        final response = await _dio.get('/Managers');
        final List<dynamic> managers = response.data;

        AppLogger.info(
            '📊 Searching ${managers.length} managers for userId: $userId');

        for (var manager in managers) {
          final managerUserId = manager['userId']?.toString();
          if (managerUserId == userId) {
            roleSpecificId = manager['managerId']?.toString();
            AppLogger.info(
                '✅ Found Manager! managerId: $roleSpecificId, userId: $managerUserId');
            break;
          }
        }

        if (roleSpecificId == null) {
          AppLogger.error('❌ No manager found with userId: $userId');
          throw Exception('Manager record not found for this user');
        }

        deleteUrl = '/Managers/$roleSpecificId';
      } else if (role == 'chemist' || role == 'medicalstore') {
        final response = await _dio.get('/MedicalStores');
        final List<dynamic> stores = response.data;

        AppLogger.info(
            '📊 Searching ${stores.length} medical stores for userId: $userId');

        for (var store in stores) {
          final storeUserId = store['userId']?.toString();
          if (storeUserId == userId) {
            roleSpecificId = store['medicalStoreId']?.toString();
            AppLogger.info(
                '✅ Found MedicalStore! medicalStoreId: $roleSpecificId, userId: $storeUserId');
            break;
          }
        }

        if (roleSpecificId == null) {
          AppLogger.error('❌ No medical store found with userId: $userId');
          throw Exception('Medical store record not found for this user');
        }

        deleteUrl = '/MedicalStores/$roleSpecificId';
      } else if (role == 'customersupport') {
        final response = await _dio.get('/CustomerSupports');
        final List<dynamic> supports = response.data;

        AppLogger.info(
            '📊 Searching ${supports.length} customer supports for userId: $userId');

        for (var support in supports) {
          final supportUserId = support['userId']?.toString();
          if (supportUserId == userId) {
            roleSpecificId = support['customerSupportId']?.toString();
            AppLogger.info(
                '✅ Found CustomerSupport! customerSupportId: $roleSpecificId, userId: $supportUserId');
            break;
          }
        }

        if (roleSpecificId == null) {
          AppLogger.error('❌ No customer support found with userId: $userId');
          throw Exception('Customer support record not found for this user');
        }

        deleteUrl = '/CustomerSupports/$roleSpecificId';
      } else {
        // For roles without separate tables, try /Users endpoint
        AppLogger.info('⚠️ Unknown role, using /Users endpoint');
        deleteUrl = '/Users/$userId';
      }

      AppLogger.info('🗑️ DELETE URL: $deleteUrl');

      final deleteResponse = await _dio.delete(deleteUrl);

      if (mounted) {
        Navigator.pop(context);

        if (deleteResponse.statusCode == 204 ||
            deleteResponse.statusCode == 200) {
          AppLogger.info('✅ User deleted successfully');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          await _loadUsers();
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        Navigator.pop(context);

        String errorMsg = 'Failed to delete user';
        if (e.response?.statusCode == 404) {
          errorMsg = 'User not found';
          AppLogger.error('❌ 404: ${e.response?.data}');
        } else if (e.response?.statusCode == 403) {
          errorMsg = 'No permission to delete this user';
          AppLogger.error('❌ 403: Access denied');
        } else if (e.response?.statusCode == 400) {
          errorMsg = e.response?.data['error'] ?? 'Bad request';
          AppLogger.error('❌ 400: $errorMsg');
        } else {
          AppLogger.error('❌ Delete error: ${e.message}');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);

        AppLogger.error('❌ Unexpected error: ${e.toString()}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  List<UserWithRole> get _filteredUsers {
    List<UserWithRole> filtered = _users;

    if (_selectedRoleFilter != null && _selectedRoleFilter!.isNotEmpty) {
      filtered = filtered.where((u) {
        return u.role.toLowerCase() == _selectedRoleFilter!.toLowerCase();
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((u) {
        final name = _getDisplayName(u.user).toLowerCase();
        final email = _getEmail(u.user)?.toLowerCase() ?? '';
        final phone = _getMobile(u.user)?.toLowerCase() ?? '';
        return name.contains(_searchQuery) ||
            email.contains(_searchQuery) ||
            phone.contains(_searchQuery);
      }).toList();
    }

    return filtered;
  }

  String _getDisplayName(Map<String, dynamic> user) {
    final firstName = user['firstName'] ??
        user['customerFirstName'] ??
        user['managerFirstName'] ??
        user['ownerFirstName'] ??
        '';
    final lastName = user['lastName'] ??
        user['customerLastName'] ??
        user['managerLastName'] ??
        user['ownerLastName'] ??
        '';
    final fullName = '$firstName $lastName'.trim();
    return fullName.isNotEmpty ? fullName : (user['email'] ?? 'Unknown');
  }

  String? _getEmail(Map<String, dynamic> user) {
    return user['email'] ?? user['emailId'];
  }

  String? _getMobile(Map<String, dynamic> user) {
    return user['phoneNumber'] ?? user['mobileNumber'];
  }

  bool _getIsActive(Map<String, dynamic> user) {
    return user['isActive'] ?? true;
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search',
              hintText: 'Search by name, email or phone',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedRoleFilter,
            decoration: const InputDecoration(
              labelText: 'Filter by Role',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('All Roles')),
              DropdownMenuItem(value: 'Admin', child: Text('Admin')),
              DropdownMenuItem(value: 'Manager', child: Text('Manager')),
              DropdownMenuItem(value: 'Chemist', child: Text('Chemist')),
              DropdownMenuItem(
                  value: 'CustomerSupport', child: Text('Customer Support')),
              DropdownMenuItem(value: 'Customer', child: Text('Customer')),
            ],
            onChanged: (value) {
              setState(() => _selectedRoleFilter = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading users...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUsers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredUsers.isEmpty) {
      return const Center(child: Text('No users found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final userWithRole = _filteredUsers[index];
        return _buildUserCard(userWithRole);
      },
    );
  }

  Widget _buildUserCard(UserWithRole userWithRole) {
    final user = userWithRole.user;
    final displayName = _getDisplayName(user);
    final email = _getEmail(user);
    final mobile = _getMobile(user);
    final isActive = _getIsActive(user);
    final initials = _getInitials(displayName);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isActive ? Colors.black : Colors.grey,
                  child: Text(
                    initials,
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
                        displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (email != null) ...[
                        const SizedBox(height: 4),
                        Text(email, style: TextStyle(color: Colors.grey[600])),
                      ],
                      if (mobile != null) ...[
                        const SizedBox(height: 2),
                        Text(mobile, style: TextStyle(color: Colors.grey[600])),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isActive ? 'ACTIVE' : 'INACTIVE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Chip(
              label: Text(userWithRole.role),
              backgroundColor: Colors.blue.withOpacity(0.1),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _navigateToEditUser(userWithRole),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _confirmDeleteUser(userWithRole),
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// EDIT USER PAGE
// ============================================

class EditUserPage extends StatefulWidget {
  final UserWithRole userWithRole;
  final VoidCallback onSaved;

  const EditUserPage({
    super.key,
    required this.userWithRole,
    required this.onSaved,
  });

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  late Dio _dio;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Common fields
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _altMobileController;
  bool _isActive = true;

  // Customer specific
  TextEditingController? _dobController;
  String? _selectedGender;

  // Manager specific
  TextEditingController? _employeeIdController;
  TextEditingController? _addressController;
  TextEditingController? _cityController;
  TextEditingController? _stateController;

  // Chemist specific
  TextEditingController? _medicalNameController;
  TextEditingController? _addressLine1Controller;
  TextEditingController? _addressLine2Controller;
  TextEditingController? _postalCodeController;
  TextEditingController? _gstinController;
  TextEditingController? _panController;
  TextEditingController? _fssaiController;
  TextEditingController? _dlNoController;
  TextEditingController? _pharmacistFirstNameController;
  TextEditingController? _pharmacistLastNameController;
  TextEditingController? _pharmacistRegNoController;
  TextEditingController? _pharmacistMobileController;

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
    final user = widget.userWithRole.user;
    final role = widget.userWithRole.role.toLowerCase();

    // Common fields
    _firstNameController = TextEditingController(
      text: user['firstName'] ??
          user['customerFirstName'] ??
          user['managerFirstName'] ??
          user['ownerFirstName'] ??
          '',
    );

    _lastNameController = TextEditingController(
      text: user['lastName'] ??
          user['customerLastName'] ??
          user['managerLastName'] ??
          user['ownerLastName'] ??
          '',
    );

    _middleNameController = TextEditingController(
      text: user['middleName'] ??
          user['customerMiddleName'] ??
          user['managerMiddleName'] ??
          '',
    );

    _emailController = TextEditingController(
      text: user['email'] ?? user['emailId'] ?? '',
    );

    _mobileController = TextEditingController(
      text: user['mobileNumber'] ??
          user['phoneNumber'] ??
          '', // ← Checks mobileNumber first
    );

    _altMobileController = TextEditingController(
      text: user['alternativeMobileNumber'] ?? '',
    );

    _isActive = user['isActive'] ?? true;

    // Customer specific
    if (role == 'customer') {
      _dobController = TextEditingController(
        text: user['dateOfBirth']?.toString().split('T')[0] ??
            '', // ← Returns "2000-01-15"
      );
      _selectedGender = user['gender']?.toString() ?? 'Male';
    }

    // Manager specific
    if (role == 'manager') {
      _employeeIdController = TextEditingController(
        text: user['employeeId'] ?? '',
      );
      _addressController = TextEditingController(
        text: user['address'] ?? '',
      );
      _cityController = TextEditingController(text: user['city'] ?? '');
      _stateController = TextEditingController(text: user['state'] ?? '');
    }

    // Chemist specific
    if (role == 'chemist') {
      _medicalNameController = TextEditingController(
        text: user['medicalName'] ?? '',
      );
      _addressLine1Controller = TextEditingController(
        text: user['addressLine1'] ?? '',
      );
      _addressLine2Controller = TextEditingController(
        text: user['addressLine2'] ?? '',
      );
      _cityController = TextEditingController(text: user['city'] ?? '');
      _stateController = TextEditingController(text: user['state'] ?? '');
      _postalCodeController = TextEditingController(
        text: user['postalCode'] ?? '',
      );
      _gstinController = TextEditingController(text: user['gstin'] ?? '');
      _panController = TextEditingController(text: user['pan'] ?? '');
      _fssaiController = TextEditingController(text: user['fssaiNo'] ?? '');
      _dlNoController = TextEditingController(text: user['dlNo'] ?? '');
      _pharmacistFirstNameController = TextEditingController(
        text: user['pharmacistFirstName'] ?? '',
      );
      _pharmacistLastNameController = TextEditingController(
        text: user['pharmacistLastName'] ?? '',
      );
      _pharmacistRegNoController = TextEditingController(
        text: user['pharmacistRegistrationNumber'] ?? '',
      );
      _pharmacistMobileController = TextEditingController(
        text: user['pharmacistMobileNumber'] ?? '',
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _altMobileController.dispose();
    _dobController?.dispose();
    _employeeIdController?.dispose();
    _addressController?.dispose();
    _cityController?.dispose();
    _stateController?.dispose();
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

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updateUrl = _getUpdateUrl();
      final requestBody = _buildRequestBody();

      AppLogger.info('🔄 Updating user at: $updateUrl');
      AppLogger.info('📤 Request body: $requestBody');

      final response = await _dio.put(updateUrl, data: requestBody);

      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 204) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onSaved();
          Navigator.pop(context);
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        String errorMsg = 'Failed to update user';

        if (e.response?.statusCode == 400) {
          errorMsg = e.response?.data['error'] ?? 'Validation failed';
        } else if (e.response?.statusCode == 404) {
          errorMsg = 'User not found';
        } else if (e.response?.statusCode == 403) {
          errorMsg = 'No permission to update';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
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

  String _getUpdateUrl() {
    final roleKey = widget.userWithRole.role.toLowerCase();
    final userId = widget.userWithRole.id;

    switch (roleKey) {
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
    final roleKey = widget.userWithRole.role.toLowerCase();

    if (roleKey == 'customer') {
      return {
        'customerFirstName': _firstNameController.text,
        'customerLastName': _lastNameController.text,
        'customerMiddleName': _middleNameController.text,
        'mobileNumber': _mobileController.text,
        'alternativeMobileNumber': _altMobileController.text,
        'emailId': _emailController.text,
        'dateOfBirth': _dobController?.text.trim().isNotEmpty == true
            ? _dobController!.text.trim()
            : null, // ✅ Null instead of empty
        'gender': _selectedGender ?? 'Male',
        'isActive': _isActive,
      };
    } else if (roleKey == 'manager') {
      return {
        'managerFirstName': _firstNameController.text,
        'managerLastName': _lastNameController.text,
        'managerMiddleName': _middleNameController.text,
        'address': _addressController?.text ?? '',
        'city': _cityController?.text ?? '',
        'state': _stateController?.text ?? '',
        'mobileNumber': _mobileController.text,
        'emailId': _emailController.text,
        'alternativeMobileNumber': _altMobileController.text,
        'employeeId': _employeeIdController?.text ?? '',
      };
    } else if (roleKey == 'chemist') {
      return {
        'medicalName': _medicalNameController?.text ?? '',
        'ownerFirstName': _firstNameController.text,
        'ownerLastName': _lastNameController.text,
        'ownerMiddleName': _middleNameController.text,
        'addressLine1': _addressLine1Controller?.text ?? '',
        'addressLine2': _addressLine2Controller?.text ?? '',
        'city': _cityController?.text ?? '',
        'state': _stateController?.text ?? '',
        'postalCode': _postalCodeController?.text ?? '',
        'mobileNumber': _mobileController.text,
        'emailId': _emailController.text,
        'alternativeMobileNumber': _altMobileController.text,
        'gstin': _gstinController?.text ?? '',
        'pan': _panController?.text ?? '',
        'fssaiNo': _fssaiController?.text ?? '',
        'dlNo': _dlNoController?.text ?? '',
        'pharmacistFirstName': _pharmacistFirstNameController?.text ?? '',
        'pharmacistLastName': _pharmacistLastNameController?.text ?? '',
        'pharmacistRegistrationNumber': _pharmacistRegNoController?.text ?? '',
        'pharmacistMobileNumber': _pharmacistMobileController?.text ?? '',
      };
    }

    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit ${widget.userWithRole.role}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCommonFields(),
            if (widget.userWithRole.role.toLowerCase() == 'customer')
              _buildCustomerFields(),
            if (widget.userWithRole.role.toLowerCase() == 'manager')
              _buildManagerFields(),
            if (widget.userWithRole.role.toLowerCase() == 'chemist')
              _buildChemistFields(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _firstNameController,
          decoration: const InputDecoration(
            labelText: 'First Name *',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _lastNameController,
          decoration: const InputDecoration(
            labelText: 'Last Name *',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _middleNameController,
          decoration: const InputDecoration(
            labelText: 'Middle Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email *',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _mobileController,
          decoration: const InputDecoration(
            labelText: 'Mobile Number *',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _altMobileController,
          decoration: const InputDecoration(
            labelText: 'Alternative Mobile',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Active'),
          value: _isActive,
          onChanged: (value) => setState(() => _isActive = value),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCustomerFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customer Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _dobController,
          decoration: const InputDecoration(
            labelText: 'Date of Birth',
            border: OutlineInputBorder(),
            hintText: 'YYYY-MM-DD',
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          decoration: const InputDecoration(
            labelText: 'Gender',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'Male', child: Text('Male')),
            DropdownMenuItem(value: 'Female', child: Text('Female')),
            DropdownMenuItem(value: 'Other', child: Text('Other')),
          ],
          onChanged: (value) => setState(() => _selectedGender = value),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildManagerFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Manager Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _employeeIdController,
          decoration: const InputDecoration(
            labelText: 'Employee ID',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Address',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _cityController,
          decoration: const InputDecoration(
            labelText: 'City',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _stateController,
          decoration: const InputDecoration(
            labelText: 'State',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildChemistFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medical Store Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _medicalNameController,
          decoration: const InputDecoration(
            labelText: 'Medical Store Name *',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        const Text(
          'Address',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _addressLine1Controller,
          decoration: const InputDecoration(
            labelText: 'Address Line 1',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _addressLine2Controller,
          decoration: const InputDecoration(
            labelText: 'Address Line 2',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _postalCodeController,
          decoration: const InputDecoration(
            labelText: 'Postal Code',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Registration Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _gstinController,
          decoration: const InputDecoration(
            labelText: 'GSTIN',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _panController,
          decoration: const InputDecoration(
            labelText: 'PAN',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _fssaiController,
          decoration: const InputDecoration(
            labelText: 'FSSAI Number',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _dlNoController,
          decoration: const InputDecoration(
            labelText: 'Drug License Number',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Pharmacist Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _pharmacistFirstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _pharmacistLastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _pharmacistRegNoController,
          decoration: const InputDecoration(
            labelText: 'Registration Number',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _pharmacistMobileController,
          decoration: const InputDecoration(
            labelText: 'Mobile Number',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
