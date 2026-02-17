// ============================================================================
// ADMIN SERVICE REGIONS - COMPLETE VERSION
// ============================================================================
// Features:
// - Region CRUD operations
// - Pincode management with search and scrolling
// - Staff assignment
// - Region search by name, city, display name
// - City filter chips
// - Quick pincode lookup
// - View all pincodes page

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pharmaish/core/screens/admin/view_all_pincodes.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:pharmaish/config/environment_config.dart';

enum RegionType {
  customerSupport(0, 'Customer Support'),
  deliveryBoy(1, 'Delivery Boy');

  final int value;
  final String displayName;

  const RegionType(this.value, this.displayName);

  static RegionType fromValue(int value) {
    return RegionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => RegionType.customerSupport,
    );
  }
}

class AdminServiceRegionsPage extends StatefulWidget {
  const AdminServiceRegionsPage({Key? key}) : super(key: key);

  @override
  State<AdminServiceRegionsPage> createState() =>
      _AdminServiceRegionsPageState();
}

class _AdminServiceRegionsPageState extends State<AdminServiceRegionsPage> {
  late Dio _dio;

  List<Map<String, dynamic>> _regions = [];
  List<Map<String, dynamic>> _customerSupports = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _deliveryBoys = <Map<String, dynamic>>[]; // ✨ NEW

  bool _isLoading = true;
  String? _errorMessage;
  bool _hasPermission = true;

  // Region search & filter
  String _regionSearchQuery = '';
  final _regionSearchController = TextEditingController();
  String _selectedCityFilter = 'All Cities';
  List<String> _availableCities = ['All Cities'];

// ✨ NEW: Region Type Filter
  RegionType? _selectedRegionTypeFilter; // null = show all

  @override
  void initState() {
    super.initState();
    _setupDio();
    _checkPermissionAndLoad();
  }

  @override
  void dispose() {
    _regionSearchController.dispose();
    super.dispose();
  }

  void _setupDio() {
    _dio = Dio();
    _dio.options.baseUrl = AppConstants.apiBaseUrl;
    _dio.options.connectTimeout = EnvironmentConfig.timeoutDuration;
    _dio.options.receiveTimeout = EnvironmentConfig.timeoutDuration;

    if (EnvironmentConfig.shouldLog) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        logPrint: (object) => AppLogger.info('API: $object'),
      ));
    }

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        AppLogger.error('API Error: ${error.message}');
        AppLogger.error('Status Code: ${error.response?.statusCode}');
        AppLogger.error('Response Data: ${error.response?.data}');
        handler.next(error);
      },
    ));
  }

  Future<void> _checkPermissionAndLoad() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasPermission = true;
    });

    try {
      await _loadRegions();

      if (_hasPermission) {
        await _loadCustomerSupports();
      }
    } catch (e) {
      AppLogger.error('Error in permission check: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRegions() async {
    try {
      AppLogger.info('Loading regions...');
      final response = await _dio.get('/ServiceRegions');

      if (response.statusCode == 200) {
        final loadedRegions = response.data is List
            ? (response.data as List)
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList()
            : <Map<String, dynamic>>[];

        // Extract unique cities
        final cities = loadedRegions
            .map((r) => r['city']?.toString() ?? '')
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList();
        cities.sort();

        setState(() {
          _regions = loadedRegions;
          _availableCities = ['All Cities', ...cities];
          _hasPermission = true;
        });

        AppLogger.info('Loaded ${_regions.length} regions');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        setState(() {
          _hasPermission = false;
          _errorMessage =
              'Access Denied: This feature is only available to Admin users.';
        });
        AppLogger.error(
            '403 Forbidden - User lacks permission to view regions');
      } else if (e.response?.statusCode == 401) {
        setState(() {
          _hasPermission = false;
          _errorMessage = 'Authentication failed. Please login again.';
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load regions: ${e.message}';
        });
      }
      rethrow;
    }
  }

  Future<void> _loadCustomerSupports() async {
    try {
      AppLogger.info('Loading customer supports...');
      final response = await _dio.get('/CustomerSupports');

      if (response.statusCode == 200) {
        setState(() {
          if (response.data is List) {
            _customerSupports = (response.data as List)
                .map((e) => Map<String, dynamic>.from(e as Map))
                .where((cs) =>
                    (cs['isActive'] ?? false) && !(cs['isDeleted'] ?? false))
                .toList();
          } else {
            _customerSupports = [];
          }
        });
        AppLogger.info('Loaded ${_customerSupports.length} customer supports');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        AppLogger.error('403 Forbidden - Cannot load customer supports list');
        setState(() {
          _customerSupports = [];
        });
      } else {
        AppLogger.error('Error loading customer supports: ${e.message}');
      }
    }
  }

  Future<void> _loadDeliveryBoys() async {
    try {
      AppLogger.info('Loading delivery boys...');
      final response = await _dio.get('/Deliveries');

      if (response.statusCode == 200) {
        final deliveryBoys = response.data is List
            ? (response.data as List)
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList()
            : <Map<String, dynamic>>[];

        setState(() {
          _deliveryBoys = deliveryBoys;
        });

        AppLogger.info('Loaded ${_deliveryBoys.length} delivery boys');
      }
    } catch (e) {
      AppLogger.error('Error loading delivery boys: $e');
    }
  }

  // =========================================================================
  // REGION FILTERING
  // =========================================================================

  List<Map<String, dynamic>> _getFilteredRegions() {
    var filtered = List<Map<String, dynamic>>.from(_regions);

    // Apply city filter
    if (_selectedCityFilter != 'All Cities') {
      filtered = filtered.where((region) {
        return region['city']?.toString() == _selectedCityFilter;
      }).toList();
    }

    // ✨ NEW: Region Type filter
    if (_selectedRegionTypeFilter != null) {
      filtered = filtered.where((region) {
        // Use .where() with (region)
        final regionType = region['regionType'] as int?;
        return regionType == _selectedRegionTypeFilter!.value;
      }).toList();
    }
    // Apply search filter
    if (_regionSearchQuery.isNotEmpty) {
      final query = _regionSearchQuery.toLowerCase();
      filtered = filtered.where((region) {
        final name = (region['name'] ?? '').toString().toLowerCase();
        final city = (region['city'] ?? '').toString().toLowerCase();
        final regionName =
            (region['regionName'] ?? '').toString().toLowerCase();

        return name.contains(query) ||
            city.contains(query) ||
            regionName.contains(query);
      }).toList();
    }

    return filtered;
  }

  void _clearRegionSearch() {
    setState(() {
      _regionSearchController.clear();
      _regionSearchQuery = '';
      _selectedCityFilter = 'All Cities';
    });
  }

  // =========================================================================
  // CREATE REGION
  // =========================================================================

  Future<void> _showCreateRegionDialog() async {
    final nameController = TextEditingController();
    final cityController = TextEditingController();
    final regionNameController = TextEditingController();
    final pinCodesController = TextEditingController();
    RegionType selectedRegionType = RegionType.customerSupport; // ✨ NEW

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Service Region'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Region Name',
                    hintText: 'e.g., South Mumbai',
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    hintText: 'e.g., Mumbai',
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: regionNameController,
                  decoration: const InputDecoration(
                    labelText: 'Area/Region',
                    hintText: 'e.g., Colaba, Churchgate',
                  ),
                ),
                const SizedBox(height: 16),

                // ✨ NEW: Region Type Dropdown
                DropdownButtonFormField<RegionType>(
                  value: selectedRegionType,
                  decoration: InputDecoration(
                    labelText: 'Region Type',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      selectedRegionType == RegionType.customerSupport
                          ? Icons.support_agent
                          : Icons.delivery_dining,
                    ),
                  ),
                  items: RegionType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Row(
                        children: [
                          Icon(
                            type == RegionType.customerSupport
                                ? Icons.support_agent
                                : Icons.delivery_dining,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(type.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedRegionType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: pinCodesController,
                  decoration: const InputDecoration(
                    labelText: 'PIN Codes',
                    hintText: 'e.g., 400001, 400002, 400003',
                    helperText: 'Comma-separated PIN codes',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    cityController.text.isEmpty ||
                    regionNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all required fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.pop(context);
                await _createRegion(
                  nameController.text.trim(),
                  cityController.text.trim(),
                  regionNameController.text.trim(),
                  selectedRegionType, // ✨ PASS REGION TYPE
                  pinCodesController.text.trim(),
                );
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createRegion(
    String name,
    String city,
    String regionName,
    RegionType regionType, // ✨ ADD THIS PARAMETER
    String pinCodesStr,
  ) async {
    try {
      // Parse PIN codes
      final pinCodes = pinCodesStr.isEmpty
          ? <String>[]
          : pinCodesStr
              .split(',')
              .map((p) => p.trim())
              .where((p) => p.isNotEmpty)
              .toList();

      final response = await _dio.post(
        '/ServiceRegions', // ✨ CHANGED FROM /CustomerSupportRegions
        data: {
          'name': name,
          'city': city,
          'regionName': regionName,
          'regionType': regionType.value, // ✨ ADD THIS
          'pinCodes': pinCodes,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Service region "$name" created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        await _loadRegions();
      }
    } catch (e) {
      AppLogger.error('Error creating region: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create service region'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // =========================================================================
  // MANAGE PINCODES
  // =========================================================================

  Future<void> _showManagePincodesDialog(Map<String, dynamic> region) async {
    if (!_hasPermission) {
      _showError('You do not have permission to manage pincodes');
      return;
    }

    final regionId = region['id'] ?? region['Id'];
    List<String> pincodes = [];

    try {
      final response = await _dio.get('/ServiceRegions/$regionId/pincodes');
      if (response.statusCode == 200) {
        pincodes = (response.data as List).map((e) => e.toString()).toList();
      }
    } catch (e) {
      AppLogger.error('Error loading pincodes: $e');
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => _ManagePincodesDialog(
        dio: _dio,
        region: region,
        initialPincodes: pincodes,
        onSaved: () => _loadRegions(),
      ),
    );
  }

  // =========================================================================
  // ASSIGN CUSTOMER SUPPORT
  // =========================================================================

  Future<void> _showAssignCustomerSupportDialog(
      Map<String, dynamic> region) async {
    if (!_hasPermission) {
      _showError('You do not have permission to assign staff');
      return;
    }

    if (_customerSupports.isEmpty) {
      _showError('No customer support staff available to assign.');
      return;
    }

    String? selectedCustomerSupportId;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Assign to ${region['name']}'),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Customer Support to assign:'),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCustomerSupportId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Customer Support',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  items: _customerSupports.map((cs) {
                    final firstName = cs['customerSupportFirstName'] ?? '';
                    final lastName = cs['customerSupportLastName'] ?? '';
                    final employeeId = cs['employeeId'] ?? '';
                    final currentRegionId = cs['serviceRegionId'];

                    return DropdownMenuItem<String>(
                      value: cs['serviceRegionId'],
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$firstName $lastName',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Emp ID: $employeeId${currentRegionId != null ? ' (Assigned)' : ''}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCustomerSupportId = value;
                    });
                  },
                  selectedItemBuilder: (context) {
                    return _customerSupports.map((cs) {
                      final firstName = cs['customerSupportFirstName'] ?? '';
                      final lastName = cs['customerSupportLastName'] ?? '';
                      return Text(
                        '$firstName $lastName',
                        overflow: TextOverflow.ellipsis,
                      );
                    }).toList();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedCustomerSupportId == null
                  ? null
                  : () => Navigator.pop(context, selectedCustomerSupportId),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await _assignCustomerSupport(region['id'] ?? region['Id'], result);
    }
  }

  Future<void> _assignCustomerSupport(
      int regionId, String customerSupportId) async {
    try {
      final response = await _dio.post('/ServiceRegions/assign', data: {
        'ServiceRegionId': regionId,
        'CustomerSupportId': customerSupportId
      });

      if (response.statusCode == 200) {
        if (mounted) {
          _showSuccess('Customer support assigned successfully');
          await _checkPermissionAndLoad();
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        if (e.response?.statusCode == 403) {
          _showError(
              'Access Denied: You do not have permission to assign staff');
        } else {
          _showError(
              'Failed to assign: ${e.response?.data?['error'] ?? e.message}');
        }
      }
    }
  }

  // =========================================================================
  // DELETE REGION
  // =========================================================================

  Future<void> _deleteRegion(Map<String, dynamic> region) async {
    if (!_hasPermission) {
      _showError('You do not have permission to delete regions');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
            'Are you sure you want to delete "${region['name']}"?\n\nThis will unassign all customer support staff from this region.'),
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

    if (confirm != true) return;

    try {
      final response = await _dio
          .delete('/CustomerSupportRegions/${region['id'] ?? region['Id']}');

      if (response.statusCode == 204 || response.statusCode == 200) {
        if (mounted) {
          _showSuccess('Region deleted successfully');
          await _checkPermissionAndLoad();
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        if (e.response?.statusCode == 403) {
          _showError(
              'Access Denied: You do not have permission to delete regions');
        } else {
          _showError(
              'Failed to delete: ${e.response?.data?['error'] ?? e.message}');
        }
      }
    }
  }

  // =========================================================================
  // QUICK PINCODE LOOKUP
  // =========================================================================

  Future<void> _showQuickPincodeLookup() async {
    await showDialog(
      context: context,
      builder: (context) => _QuickPincodeLookupDialog(dio: _dio),
    );
  }

  // =========================================================================
  // UI BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Regions'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showQuickPincodeLookup,
            tooltip: 'Search Pincode',
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewAllPincodesPage(
                    dio: _dio,
                    regions: _regions,
                  ),
                ),
              );
            },
            tooltip: 'View All Pincodes',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkPermissionAndLoad,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_hasPermission
              ? _buildAccessDeniedView()
              : _errorMessage != null
                  ? _buildErrorView()
                  : _buildContentWithSearch(),
      floatingActionButton: _hasPermission
          ? FloatingActionButton.extended(
              onPressed: _showCreateRegionDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create Region'),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildAccessDeniedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 24),
            const Text(
              'Access Denied',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ??
                  'You do not have permission to access this feature.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 32),
                  SizedBox(height: 12),
                  Text(
                    'Service Regions is an Admin-only feature',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'If you need access to this feature, please contact your system administrator.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'An error occurred',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _checkPermissionAndLoad,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContentWithSearch() {
    final filteredRegions = _getFilteredRegions();

    return Column(
      children: [
        // Search and filter section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Search bar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _regionSearchController,
                      onChanged: (value) {
                        setState(() {
                          _regionSearchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by name, city, or region code...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _regionSearchQuery.isNotEmpty ||
                                _selectedCityFilter != 'All Cities'
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: _clearRegionSearch,
                                tooltip: 'Clear filters',
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_regionSearchQuery.isNotEmpty ||
                      _selectedCityFilter != 'All Cities') ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.filter_list,
                              size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '${filteredRegions.length}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              // City filter chips
              if (_availableCities.length > 2)
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _availableCities.length,
                    itemBuilder: (context, index) {
                      final city = _availableCities[index];
                      final isSelected = city == _selectedCityFilter;
                      final count = city == 'All Cities'
                          ? _regions.length
                          : _regions.where((r) => r['city'] == city).length;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text('$city ($count)'),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCityFilter = city;
                            });
                          },
                          selectedColor: Colors.black,
                          backgroundColor: Colors.grey.shade200,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 12),

              // Region Type filter chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Label
                    Padding(
                      padding: const EdgeInsets.only(top: 8, right: 4),
                      child: Text(
                        'Type:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),

                    // All filter chip
                    FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.view_list,
                            size: 16,
                            color: _selectedRegionTypeFilter == null
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text('All'),
                        ],
                      ),
                      selected: _selectedRegionTypeFilter == null,
                      onSelected: (selected) {
                        setState(() {
                          _selectedRegionTypeFilter = null;
                        });
                      },
                      selectedColor: Colors.black,
                      backgroundColor: Colors.grey.shade200,
                      labelStyle: TextStyle(
                        color: _selectedRegionTypeFilter == null
                            ? Colors.white
                            : Colors.black87,
                        fontSize: 13,
                        fontWeight: _selectedRegionTypeFilter == null
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),

                    // Customer Support filter chip
                    FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.support_agent,
                            size: 16,
                            color: _selectedRegionTypeFilter ==
                                    RegionType.customerSupport
                                ? Colors.white
                                : Colors.blue.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text('Support'),
                        ],
                      ),
                      selected: _selectedRegionTypeFilter ==
                          RegionType.customerSupport,
                      onSelected: (selected) {
                        setState(() {
                          _selectedRegionTypeFilter =
                              selected ? RegionType.customerSupport : null;
                        });
                      },
                      selectedColor: Colors.blue.shade600,
                      backgroundColor: Colors.blue.shade50,
                      labelStyle: TextStyle(
                        color: _selectedRegionTypeFilter ==
                                RegionType.customerSupport
                            ? Colors.white
                            : Colors.blue.shade700,
                        fontSize: 13,
                        fontWeight: _selectedRegionTypeFilter ==
                                RegionType.customerSupport
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),

                    // Delivery Boy filter chip
                    FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delivery_dining,
                            size: 16,
                            color: _selectedRegionTypeFilter ==
                                    RegionType.deliveryBoy
                                ? Colors.white
                                : Colors.orange.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text('Delivery'),
                        ],
                      ),
                      selected:
                          _selectedRegionTypeFilter == RegionType.deliveryBoy,
                      onSelected: (selected) {
                        setState(() {
                          _selectedRegionTypeFilter =
                              selected ? RegionType.deliveryBoy : null;
                        });
                      },
                      selectedColor: Colors.orange.shade600,
                      backgroundColor: Colors.orange.shade50,
                      labelStyle: TextStyle(
                        color:
                            _selectedRegionTypeFilter == RegionType.deliveryBoy
                                ? Colors.white
                                : Colors.orange.shade700,
                        fontSize: 13,
                        fontWeight:
                            _selectedRegionTypeFilter == RegionType.deliveryBoy
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Stats bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.grey.shade100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${filteredRegions.length} of ${_regions.length} regions',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_availableCities.length > 2)
                Text(
                  '${_availableCities.length - 1} cities',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),

        // Regions list
        Expanded(
          child: _buildRegionsList(filteredRegions),
        ),
      ],
    );
  }

  Widget _buildRegionsList(List<Map<String, dynamic>> filteredRegions) {
    if (_regions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No regions created yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a region to get started',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (filteredRegions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No regions match your filters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              _regionSearchQuery.isNotEmpty
                  ? 'Try different search terms'
                  : 'Try selecting a different city',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _clearRegionSearch,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredRegions.length,
      itemBuilder: (context, index) {
        final region = filteredRegions[index];
        return _buildRegionCard(region);
      },
    );
  }

  Widget _buildRegionCard(Map<String, dynamic> region) {
    final regionTypeValue = region['regionType'] as int? ?? 0;
    final regionType = RegionType.fromValue(regionTypeValue);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: regionType == RegionType.customerSupport
              ? Colors.blue.shade100
              : Colors.orange.shade100,
          child: Icon(
            regionType == RegionType.customerSupport
                ? Icons.support_agent
                : Icons.delivery_dining,
            color: regionType == RegionType.customerSupport
                ? Colors.blue.shade700
                : Colors.orange.shade700,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                region['name'] ?? 'Unnamed Region',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // ✨ NEW: Region Type Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: regionType == RegionType.customerSupport
                    ? Colors.blue.shade50
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: regionType == RegionType.customerSupport
                      ? Colors.blue.shade200
                      : Colors.orange.shade200,
                ),
              ),
              child: Text(
                regionType.displayName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: regionType == RegionType.customerSupport
                      ? Colors.blue.shade700
                      : Colors.orange.shade700,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('📍 ${region['city']} - ${region['regionName']}'),
            const SizedBox(height: 4),
            Text(
              '📮 ${(region['pinCodes'] as List?)?.length ?? 0} PIN codes',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPinCodesSection(region),
                const Divider(height: 24),
                _buildAssignedPersonsSection(region, regionType), // ✨ PASS TYPE
                const SizedBox(height: 12),
                _buildActionButtons(region, regionType), // ✨ PASS TYPE
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedPersonsSection(
      Map<String, dynamic> region, RegionType regionType) {
    if (regionType == RegionType.customerSupport) {
      // Show assigned customer supports
      final assigned = _customerSupports
          .where((cs) =>
              cs['serviceRegionId'] == (region['id'] ?? region['Id']))
          .toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.support_agent, size: 16, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Assigned Customer Supports (${assigned.length})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (assigned.isEmpty)
            const Text('No customer supports assigned',
                style: TextStyle(color: Colors.grey))
          else
            ...assigned
                .map((cs) => _buildAssignedPersonTile(cs, regionType, region)),
        ],
      );
    } else {
      // Show assigned delivery boys
      final assigned = _deliveryBoys
          .where(
              (db) => db['serviceRegionId'] == (region['id'] ?? region['Id']))
          .toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.delivery_dining,
                  size: 16, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                'Assigned Delivery Boys (${assigned.length})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (assigned.isEmpty)
            const Text('No delivery boys assigned',
                style: TextStyle(color: Colors.grey))
          else
            ...assigned
                .map((db) => _buildAssignedPersonTile(db, regionType, region)),
        ],
      );
    }
  }

  Widget _buildAssignedPersonTile(
    Map<String, dynamic> person,
    RegionType regionType,
    Map<String, dynamic> region,
  ) {
    final name = regionType == RegionType.customerSupport
        ? '${person['customerSupportFirstName'] ?? ''} ${person['customerSupportLastName'] ?? ''}'
        : '${person['firstName'] ?? ''} ${person['lastName'] ?? ''}';

    final phone = person['mobileNumber'] ?? '';
    final id = regionType == RegionType.customerSupport
        ? person['customerSupportId'] // ✅ correct key from CustomerSupportDto
        : person['deliveryBoyId'] ?? person['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: regionType == RegionType.customerSupport
            ? Colors.blue.shade50
            : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: regionType == RegionType.customerSupport
                ? Colors.blue.shade200
                : Colors.orange.shade200,
            radius: 16,
            child: Icon(
              regionType == RegionType.customerSupport
                  ? Icons.support_agent
                  : Icons.delivery_dining,
              size: 18,
              color: regionType == RegionType.customerSupport
                  ? Colors.blue.shade700
                  : Colors.orange.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (phone.isNotEmpty)
                  Text(
                    '📱 $phone',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: Colors.red.shade400,
            onPressed: () => _unassignPerson(region, id, regionType),
            tooltip: 'Unassign',
          ),
        ],
      ),
    );
  }

  Widget _buildPinCodesSection(Map<String, dynamic> region) {
    final pinCodes = List<String>.from(
        (region['pinCodes'] as List? ?? []).map((e) => e.toString()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.pin_drop, size: 16, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            Text(
              'PIN Codes (${pinCodes.length})',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showAddPinCodeDialog(region),
              icon: Icon(Icons.add, size: 16, color: Colors.blue.shade700),
              label: Text(
                'Add PIN',
                style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (pinCodes.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'No PIN codes assigned',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pinCodes.map<Widget>((pinCode) {
              return Chip(
                label: Text(
                  pinCode,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade900,
                  ),
                ),
                backgroundColor: Colors.blue.shade50,
                side: BorderSide(color: Colors.blue.shade200),
                deleteIcon: Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.red.shade400,
                ),
                onDeleted: () => _confirmRemovePinCode(region, pinCode),
              );
            }).toList(),
          ),
      ],
    );
  }

  Future<void> _showAddPinCodeDialog(Map<String, dynamic> region) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.pin_drop, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            const Text('Add PIN Code'),
          ],
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            labelText: 'PIN Code',
            hintText: 'e.g. 411001',
            prefixIcon: const Icon(Icons.dialpad),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          autofocus: true,
          onSubmitted: (_) async {
            final pin = controller.text.trim();
            if (pin.length == 6) {
              Navigator.pop(context);
              await _addPinCode(region, pin);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final pin = controller.text.trim();
              if (pin.length != 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PIN code must be exactly 6 digits'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              await _addPinCode(region, pin);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Future<void> _addPinCode(
      Map<String, dynamic> region, String pinCode) async {
    final regionId = region['id'] ?? region['Id'];
    try {
      await _dio.post('/ServiceRegions/add-pincode', data: {
        'ServiceRegionId': (regionId as num).toInt(),
        'PinCode': pinCode,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('PIN $pinCode added successfully'),
          backgroundColor: Colors.green,
        ));
        await _loadRegions();
      }
    } on DioException catch (e) {
      if (mounted) {
        final msg =
            e.response?.data?['error'] ?? 'Failed to add PIN code';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> _confirmRemovePinCode(
      Map<String, dynamic> region, String pinCode) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove PIN Code'),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            children: [
              const TextSpan(text: 'Remove PIN code '),
              TextSpan(
                text: pinCode,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' from ${region['name']}?'),
            ],
          ),
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
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _removePinCode(region, pinCode);
  }

  Future<void> _removePinCode(
      Map<String, dynamic> region, String pinCode) async {
    final regionId = region['id'] ?? region['Id'];
    try {
      await _dio.post('/ServiceRegions/remove-pincode', data: {
        'ServiceRegionId': (regionId as num).toInt(),
        'PinCode': pinCode,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('PIN $pinCode removed successfully'),
          backgroundColor: Colors.green,
        ));
        await _loadRegions();
      }
    } on DioException catch (e) {
      if (mounted) {
        final msg =
            e.response?.data?['error'] ?? 'Failed to remove PIN code';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> _showEditRegionDialog(Map<String, dynamic> region) async {
    final nameController = TextEditingController(text: region['name']);
    final cityController = TextEditingController(text: region['city']);
    final regionNameController =
        TextEditingController(text: region['regionName']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Region'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Region Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: regionNameController,
                decoration: const InputDecoration(
                  labelText: 'Region Display Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  cityController.text.isEmpty ||
                  regionNameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              await _updateRegion(
                region['id'] ?? region['Id'],
                nameController.text.trim(),
                cityController.text.trim(),
                regionNameController.text.trim(),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateRegion(
    int regionId,
    String name,
    String city,
    String regionName,
  ) async {
    try {
      final response = await _dio.put(
        '/ServiceRegions/$regionId',
        data: {
          'name': name,
          'city': city,
          'regionName': regionName,
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Region updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        await _checkPermissionAndLoad();
      }
    } catch (e) {
      AppLogger.error('Error updating region: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update region'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteRegion(Map<String, dynamic> region) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Region'),
        content: Text(
          'Are you sure you want to delete "${region['name']}"?\n\n'
          'This action cannot be undone.',
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
      await _deleteRegion(region['id'] ?? region['Id']);
    }
  }

  Widget _buildActionButtons(
      Map<String, dynamic> region, RegionType regionType) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showAssignPersonDialog(region, regionType),
            icon: Icon(
              regionType == RegionType.customerSupport
                  ? Icons.person_add
                  : Icons.delivery_dining,
            ),
            label: Text(
              regionType == RegionType.customerSupport
                  ? 'Assign Support'
                  : 'Assign Delivery',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: regionType == RegionType.customerSupport
                  ? Colors.blue
                  : Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _showEditRegionDialog(region),
          icon: const Icon(Icons.edit),
          color: Colors.blue,
          tooltip: 'Edit Region',
        ),
        IconButton(
          onPressed: () => _confirmDeleteRegion(region),
          icon: const Icon(Icons.delete),
          color: Colors.red,
          tooltip: 'Delete Region',
        ),
      ],
    );
  }

  Future<void> _showAssignPersonDialog(
      Map<String, dynamic> region, RegionType regionType) async {
    // 🔍 DEBUG: See what's actually in the region
    print('=== REGION DEBUG ===');
    print('Region keys: ${region.keys.toList()}');
    print('Full region: $region');
    print('region[\'id\']: ${region['id']}');
    print('region[\'Id\']: ${region['Id']}');
    print('====================');
    final regionId = region['id'] ?? region['Id'];

    // Get unassigned persons based on type
    final List<Map<String, dynamic>> availablePersons;

    if (regionType == RegionType.customerSupport) {
      availablePersons = _customerSupports
          .where((cs) =>
              cs['serviceRegionId'] == null ||
              cs['serviceRegionId'] != regionId)
          .toList();
    } else {
      availablePersons = _deliveryBoys
          .where((db) =>
              db['serviceRegionId'] == null ||
              db['serviceRegionId'] != regionId)
          .toList();
    }

    if (availablePersons.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              regionType == RegionType.customerSupport
                  ? 'All customer supports are already assigned'
                  : 'All delivery boys are already assigned',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              regionType == RegionType.customerSupport
                  ? Icons.support_agent
                  : Icons.delivery_dining,
              color: regionType == RegionType.customerSupport
                  ? Colors.blue
                  : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(
              regionType == RegionType.customerSupport
                  ? 'Assign Customer Support'
                  : 'Assign Delivery Boy',
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availablePersons.length,
            itemBuilder: (context, index) {
              final person = availablePersons[index];
              final name = regionType == RegionType.customerSupport
                  ? '${person['customerSupportFirstName'] ?? ''} ${person['customerSupportLastName'] ?? ''}'
                  : '${person['firstName'] ?? ''} ${person['lastName'] ?? ''}';
              final phone = person['mobileNumber'] ?? '';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: regionType == RegionType.customerSupport
                      ? Colors.blue.shade100
                      : Colors.orange.shade100,
                  child: Icon(
                    regionType == RegionType.customerSupport
                        ? Icons.support_agent
                        : Icons.delivery_dining,
                    color: regionType == RegionType.customerSupport
                        ? Colors.blue.shade700
                        : Colors.orange.shade700,
                  ),
                ),
                title: Text(name),
                subtitle: Text(phone),
                onTap: () {
                  Navigator.pop(context);
                  _assignPersonToRegion(
                      regionId,
                      regionType == RegionType.customerSupport
                          ? person[
                              'customerSupportId'] // ✅ correct key from CustomerSupportDto
                          : person['deliveryBoyId'] ?? person['id'],
                      regionType);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _assignPersonToRegion(
    dynamic regionId,
    dynamic personId,
    RegionType regionType,
  ) async {
    try {
      final int id = (regionId as num).toInt(); // ✅ Safe cast with type check
      AppLogger.info('Assigning region $id to $personId (type: $regionType)');
      if (regionType == RegionType.customerSupport) {
        // Assign to customer support (existing logic)
        await _dio.post(
          '/ServiceRegions/assign',
          data: {
            'ServiceRegionId': id, // ✅ PascalCase, int
            'CustomerSupportId': personId, // ✅ PascalCase
          },
        );
      } else {
        // Assign to delivery boy (new logic)
        await _dio.put(
          '/Deliveries/$personId',
          data: {
            'serviceRegionId': id, // Check what delivery endpoint expects
          },
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              regionType == RegionType.customerSupport
                  ? 'Customer support assigned successfully'
                  : 'Delivery boy assigned successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      await _checkPermissionAndLoad();
    } catch (e) {
      AppLogger.error('Error assigning person: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to assign'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _unassignPerson(
    Map<String, dynamic> region,
    dynamic personId,
    RegionType regionType,
  ) async {
    try {
      if (regionType == RegionType.customerSupport) {
        // Unassign customer support
        await _dio.post(
          '/ServiceRegions/assign',
          data: {'ServiceRegionId': null, 'CustomerSupportId': personId},
        );
      } else {
        // Unassign delivery boy
        await _dio.put(
          '/Deliveries/$personId',
          data: {
            'serviceRegionId': null,
          },
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              regionType == RegionType.customerSupport
                  ? 'Customer support unassigned'
                  : 'Delivery boy unassigned',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      await _checkPermissionAndLoad();
    } catch (e) {
      AppLogger.error('Error unassigning person: $e');
    }
  }

  Widget _buildAssignedStaffTile(
      Map<String, dynamic> cs, Map<String, dynamic> region) {
    final firstName = cs['customerSupportFirstName'] ?? '';
    final lastName = cs['customerSupportLastName'] ?? '';
    final employeeId = cs['employeeId'] ?? '';
    final mobile = cs['mobileNumber'] ?? '';

    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.green,
        child: Icon(Icons.support_agent, color: Colors.white, size: 20),
      ),
      title: Text('$firstName $lastName'),
      subtitle: Text('Emp ID: $employeeId\n📱 $mobile'),
      isThreeLine: true,
      trailing: IconButton(
        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
        onPressed: () => _unassignCustomerSupport(cs, region),
        tooltip: 'Unassign',
      ),
    );
  }

  Future<void> _unassignCustomerSupport(
      Map<String, dynamic> cs, Map<String, dynamic> region) async {
    final firstName = cs['customerSupportFirstName'] ?? '';
    final lastName = cs['customerSupportLastName'] ?? '';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Unassignment'),
        content: Text(
            'Are you sure you want to unassign $firstName $lastName from ${region['name']}?'),
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
            child: const Text('Unassign'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await _dio.post(
        '/ServiceRegions/assign',
        data: {
          'ServiceRegionId': null,
          'CustomerSupportId': cs['customerSupportId']
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          _showSuccess('Customer support unassigned successfully');
          await _checkPermissionAndLoad();
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        _showError('Failed to unassign: ${e.message}');
      }
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}

// ============================================================================
// MANAGE PINCODES DIALOG - WITH SEARCH AND SCROLLING
// ============================================================================

class _ManagePincodesDialog extends StatefulWidget {
  final Dio dio;
  final Map<String, dynamic> region;
  final List<String> initialPincodes;
  final VoidCallback onSaved;

  const _ManagePincodesDialog({
    required this.dio,
    required this.region,
    required this.initialPincodes,
    required this.onSaved,
  });

  @override
  State<_ManagePincodesDialog> createState() => _ManagePincodesDialogState();
}

class _ManagePincodesDialogState extends State<_ManagePincodesDialog> {
  late List<String> _allPincodes;
  List<String> _filteredPincodes = [];
  final _pincodeController = TextEditingController();
  final _searchController = TextEditingController();
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _allPincodes = List.from(widget.initialPincodes);
    _filteredPincodes = List.from(_allPincodes);
  }

  @override
  void dispose() {
    _pincodeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterPincodes(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredPincodes = List.from(_allPincodes);
      } else {
        _filteredPincodes =
            _allPincodes.where((pincode) => pincode.contains(query)).toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterPincodes('');
  }

  Future<void> _addPincode() async {
    final pincode = _pincodeController.text.trim();

    if (pincode.isEmpty) {
      _showError('Please enter a pincode');
      return;
    }

    if (pincode.length != 6) {
      _showError('Pincode must be 6 digits');
      return;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(pincode)) {
      _showError('Pincode must contain only numbers');
      return;
    }

    if (_allPincodes.contains(pincode)) {
      _showError('Pincode already added');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await widget.dio.post(
        '/ServiceRegions/add-pincode',
        data: {
          'serviceRegionId': widget.region['id'] ?? widget.region['Id'],
          'pinCode': pincode,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _allPincodes.add(pincode);
          _pincodeController.clear();
          _filterPincodes(_searchQuery);
        });
        _showSuccess('Pincode added');
      }
    } catch (e) {
      _showError('Failed to add pincode: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removePincode(String pincode) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to remove pincode $pincode?'),
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
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final response = await widget.dio.post(
        '/ServiceRegions/remove-pincode',
        data: {
          'serviceRegionId': widget.region['id'] ?? widget.region['Id'],
          'pinCode': pincode,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _allPincodes.remove(pincode);
          _filterPincodes(_searchQuery);
        });
        _showSuccess('Pincode removed');
      }
    } catch (e) {
      _showError('Failed to remove pincode: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 550,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.pin_drop, color: Colors.blue, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Manage Pincodes',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.region['name'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      widget.onSaved();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Add pincode section
                      const Text(
                        'Add New Pincode',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _pincodeController,
                              decoration: const InputDecoration(
                                labelText: 'Pincode',
                                hintText: '411001',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.add_location),
                                counterText: '',
                                helperText: '6-digit pincode',
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              onSubmitted: (_) => _addPincode(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _addPincode,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.add),
                            label: const Text('Add'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Pincodes list header with search
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pincodes (${_allPincodes.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_filteredPincodes.length} found',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Search bar
                      if (_allPincodes.length > 5)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _filterPincodes,
                            decoration: InputDecoration(
                              hintText: 'Search pincodes...',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                              prefixIcon: const Icon(Icons.search, size: 20),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 20),
                                      onPressed: _clearSearch,
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              isDense: true,
                            ),
                          ),
                        ),

                      // Pincodes list with scrolling
                      if (_allPincodes.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.location_off,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No pincodes added yet',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (_filteredPincodes.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No pincodes found matching "$_searchQuery"',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                TextButton.icon(
                                  onPressed: _clearSearch,
                                  icon: const Icon(Icons.clear),
                                  label: const Text('Clear Search'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Container(
                          constraints: const BoxConstraints(
                            maxHeight: 350,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: _filteredPincodes.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final pincode = _filteredPincodes[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    radius: 20,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    pincode,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: _isLoading
                                        ? null
                                        : () => _removePincode(pincode),
                                    tooltip: 'Remove pincode',
                                  ),
                                  tileColor: index.isEven
                                      ? Colors.transparent
                                      : Colors.grey.shade50,
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_allPincodes.length} pincode${_allPincodes.length == 1 ? '' : 's'} in region',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      widget.onSaved();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
          ],
        ),
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ============================================================================
// QUICK PINCODE LOOKUP DIALOG
// ============================================================================

class _QuickPincodeLookupDialog extends StatefulWidget {
  final Dio dio;

  const _QuickPincodeLookupDialog({required this.dio});

  @override
  State<_QuickPincodeLookupDialog> createState() =>
      _QuickPincodeLookupDialogState();
}

class _QuickPincodeLookupDialogState extends State<_QuickPincodeLookupDialog> {
  final _controller = TextEditingController();
  bool _isSearching = false;
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final pincode = _controller.text.trim();

    if (pincode.isEmpty || pincode.length != 6) {
      setState(() {
        _error = 'Enter a valid 6-digit pincode';
        _result = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
      _result = null;
    });

    try {
      final response = await widget.dio.get(
        '/ServiceRegions/by-pincode/$pincode',
      );

      if (response.statusCode == 200) {
        setState(() {
          _result = response.data;
          _isSearching = false;
        });
      }
    } on DioException catch (e) {
      setState(() {
        _error = e.response?.statusCode == 404
            ? 'No region found for this pincode'
            : 'Error: ${e.message}';
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.search, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Search Pincode',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Pincode',
                hintText: '411001',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSearching ? null : _search,
                icon: _isSearching
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.search),
                label: const Text('Search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_result != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Found!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildResultRow(Icons.business, 'Region', _result!['name']),
                    const SizedBox(height: 8),
                    _buildResultRow(
                        Icons.location_city, 'City', _result!['city']),
                    const SizedBox(height: 8),
                    _buildResultRow(Icons.map, 'Code', _result!['regionName']),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(IconData icon, String label, String? value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value ?? 'N/A',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
