// ============================================================================
// ADMIN CUSTOMER SUPPORT REGIONS - COMPLETE VERSION
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
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:pharmaish/config/environment_config.dart';

class AdminCustomerSupportRegionsPage extends StatefulWidget {
  const AdminCustomerSupportRegionsPage({Key? key}) : super(key: key);

  @override
  State<AdminCustomerSupportRegionsPage> createState() =>
      _AdminCustomerSupportRegionsPageState();
}

class _AdminCustomerSupportRegionsPageState
    extends State<AdminCustomerSupportRegionsPage> {
  late Dio _dio;
  
  List<Map<String, dynamic>> _regions = [];
  List<Map<String, dynamic>> _customerSupports = <Map<String, dynamic>>[];
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasPermission = true;

  // Region search & filter
  String _regionSearchQuery = '';
  final _regionSearchController = TextEditingController();
  String _selectedCityFilter = 'All Cities';
  List<String> _availableCities = ['All Cities'];

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
      final response = await _dio.get('/CustomerSupportRegions');
      
      if (response.statusCode == 200) {
            final loadedRegions = response.data is List
    ? (response.data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList()
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
          _errorMessage = 'Access Denied: This feature is only available to Admin users.';
        });
        AppLogger.error('403 Forbidden - User lacks permission to view regions');
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
    .where((cs) => (cs['isActive'] ?? false) && 
                             !(cs['isDeleted'] ?? false))
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

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.wait([
        _loadRegions(),
        _loadCustomerSupports(),
      ]);
    } catch (e) {
      // Error already handled in individual load methods
    } finally {
      setState(() {
        _isLoading = false;
      });
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

    // Apply search filter
    if (_regionSearchQuery.isNotEmpty) {
      final query = _regionSearchQuery.toLowerCase();
      filtered = filtered.where((region) {
        final name = (region['name'] ?? '').toString().toLowerCase();
        final city = (region['city'] ?? '').toString().toLowerCase();
        final regionName = (region['regionName'] ?? '').toString().toLowerCase();
        
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
    if (!_hasPermission) {
      _showError('You do not have permission to create regions');
      return;
    }

    final nameController = TextEditingController();
    final cityController = TextEditingController();
    final regionNameController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Region'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Region Name *',
                  hintText: 'e.g., Pune West Region',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: 'City *',
                  hintText: 'e.g., Pune',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: regionNameController,
                decoration: const InputDecoration(
                  labelText: 'Region Display Name *',
                  hintText: 'e.g., West',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty ||
                  cityController.text.isEmpty ||
                  regionNameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All fields are required')),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _createRegion(
        nameController.text,
        cityController.text,
        regionNameController.text,
      );
    }
  }

  Future<void> _createRegion(String name, String city, String regionName) async {
    try {
      final response = await _dio.post(
        '/CustomerSupportRegions',
        data: {
          'name': name,
          'city': city,
          'regionName': regionName,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          _showSuccess('Region created successfully');
          await _loadRegions();
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        if (e.response?.statusCode == 403) {
          _showError('Access Denied: You do not have permission to create regions');
        } else {
          _showError('Failed to create region: ${e.response?.data?['error'] ?? e.message}');
        }
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

    final regionId = region['id'];
    List<String> pincodes = [];

    try {
      final response = await _dio.get('/CustomerSupportRegions/$regionId/pincodes');
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

  Future<void> _showAssignCustomerSupportDialog(Map<String, dynamic> region) async {
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
                    final currentRegionId = cs['customerSupportRegionId'];

                    return DropdownMenuItem<String>(
                      value: cs['customerSupportId'],
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
      await _assignCustomerSupport(region['id'], result);
    }
  }

  Future<void> _assignCustomerSupport(int regionId, String customerSupportId) async {
    try {
      final response = await _dio.post(
        '/CustomerSupportRegions/assign',
        data: {
          'customerSupportRegionId': regionId,
          'customerSupportId': customerSupportId,
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          _showSuccess('Customer support assigned successfully');
          await _loadData();
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        if (e.response?.statusCode == 403) {
          _showError('Access Denied: You do not have permission to assign staff');
        } else {
          _showError('Failed to assign: ${e.response?.data?['error'] ?? e.message}');
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
      final response = await _dio.delete('/CustomerSupportRegions/${region['id']}');

      if (response.statusCode == 204 || response.statusCode == 200) {
        if (mounted) {
          _showSuccess('Region deleted successfully');
          await _loadData();
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        if (e.response?.statusCode == 403) {
          _showError('Access Denied: You do not have permission to delete regions');
        } else {
          _showError('Failed to delete: ${e.response?.data?['error'] ?? e.message}');
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
        title: const Text('Customer Support Regions'),
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
            onPressed: _loadData,
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
              _errorMessage ?? 'You do not have permission to access this feature.',
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
                    'Customer Support Regions is an Admin-only feature',
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
            onPressed: _loadData,
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
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
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
    final assignedSupports = _customerSupports
        .where((cs) => cs['customerSupportRegionId'] == region['id'])
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            region['regionName']?.toString().substring(0, 1).toUpperCase() ?? 'R',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          region['name'] ?? 'Unnamed Region',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_city, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${region['city']} - ${region['regionName']}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.people, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${assignedSupports.length} assigned'),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'pincodes',
              child: Row(
                children: [
                  Icon(Icons.pin_drop, size: 20),
                  SizedBox(width: 8),
                  Text('Manage Pincodes'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'assign',
              child: Row(
                children: [
                  Icon(Icons.person_add, size: 20),
                  SizedBox(width: 8),
                  Text('Assign Staff'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'pincodes':
                _showManagePincodesDialog(region);
                break;
              case 'assign':
                _showAssignCustomerSupportDialog(region);
                break;
              case 'delete':
                _deleteRegion(region);
                break;
            }
          },
        ),
        children: [
          if (assignedSupports.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No customer support staff assigned to this region',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            )
          else
            ...assignedSupports.map((cs) => _buildAssignedStaffTile(cs, region)),
        ],
      ),
    );
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
        '/CustomerSupportRegions/assign',
        data: {
          'customerSupportRegionId': null,
          'customerSupportId': cs['customerSupportId'],
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          _showSuccess('Customer support unassigned successfully');
          await _loadData();
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
        _filteredPincodes = _allPincodes
            .where((pincode) => pincode.contains(query))
            .toList();
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
        '/CustomerSupportRegions/add-pincode',
        data: {
          'customerSupportRegionId': widget.region['id'],
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
        '/CustomerSupportRegions/remove-pincode',
        data: {
          'customerSupportRegionId': widget.region['id'],
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
        '/CustomerSupportRegions/by-pincode/$pincode',
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
                    _buildResultRow(
                        Icons.business, 'Region', _result!['name']),
                    const SizedBox(height: 8),
                    _buildResultRow(
                        Icons.location_city, 'City', _result!['city']),
                    const SizedBox(height: 8),
                    _buildResultRow(
                        Icons.map, 'Code', _result!['regionName']),
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

// ============================================================================
// VIEW ALL PINCODES PAGE - Add this as separate file or import
// ============================================================================

class ViewAllPincodesPage extends StatefulWidget {
  final Dio dio;
  final List<Map<String, dynamic>> regions;

  const ViewAllPincodesPage({
    Key? key,
    required this.dio,
    required this.regions,
  }) : super(key: key);

  @override
  State<ViewAllPincodesPage> createState() => _ViewAllPincodesPageState();
}

class _ViewAllPincodesPageState extends State<ViewAllPincodesPage> {
  Map<String, Map<String, dynamic>> _pincodeToRegion = {};
  List<MapEntry<String, Map<String, dynamic>>> _filteredPincodes = [];
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllPincodes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllPincodes() async {
    setState(() => _isLoading = true);

    try {
      for (var region in widget.regions) {
        final regionId = region['id'];
        final response = await widget.dio.get(
          '/CustomerSupportRegions/$regionId/pincodes',
        );

        if (response.statusCode == 200) {
          final pincodes = (response.data as List).map((e) => e.toString()).toList();
          for (var pincode in pincodes) {
            _pincodeToRegion[pincode] = region;
          }
        }
      }

      _filterPincodes('');
    } catch (e) {
      AppLogger.error('Error loading pincodes: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterPincodes(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredPincodes = _pincodeToRegion.entries.toList();
      } else {
        _filteredPincodes = _pincodeToRegion.entries
            .where((entry) =>
                entry.key.contains(query) ||
                entry.value['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
                entry.value['city'].toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
      }

      _filteredPincodes.sort((a, b) => a.key.compareTo(b.key));
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterPincodes('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Pincodes'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllPincodes,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterPincodes,
                    decoration: InputDecoration(
                      hintText: 'Search by pincode, region, or city...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty) ...[
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
                    child: Text(
                      '${_filteredPincodes.length}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
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
                  '${_pincodeToRegion.length} total pincodes',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${widget.regions.length} regions',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPincodes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No pincodes found'
                                  : 'No results for "$_searchQuery"',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _filteredPincodes.length,
                        itemBuilder: (context, index) {
                          final entry = _filteredPincodes[index];
                          final pincode = entry.key;
                          final region = entry.value;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Text(
                                  region['regionName']
                                          ?.toString()
                                          .substring(0, 1)
                                          .toUpperCase() ??
                                      'R',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                pincode,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    region['name'] ?? 'Unknown Region',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    '${region['city']} - ${region['regionName']}',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}