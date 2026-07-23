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
import 'package:pharmaish/core/screens/admin/quick_pincode_lookup_dialog.dart';
import 'package:pharmaish/core/screens/admin/view_all_pincodes.dart';
import 'package:pharmaish/core/services/region_service.dart';
import 'package:pharmaish/shared/widgets/app_button.dart';
import 'package:pharmaish/shared/widgets/app_snackbar.dart';
import 'package:pharmaish/shared/widgets/confirm_dialog.dart';
import 'package:pharmaish/utils/app_logger.dart';

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
  const AdminServiceRegionsPage({super.key});

  @override
  State<AdminServiceRegionsPage> createState() =>
      _AdminServiceRegionsPageState();
}

class _AdminServiceRegionsPageState extends State<AdminServiceRegionsPage> {

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
    _checkPermissionAndLoad();
  }

  @override
  void dispose() {
    _regionSearchController.dispose();
    super.dispose();
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
        await _loadDeliveryBoys();
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
      final loadedRegions = await RegionService.getRegions();

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
      final supports = await RegionService.getActiveCustomerSupports();
      setState(() {
        _customerSupports = supports;
      });
      AppLogger.info('Loaded ${_customerSupports.length} customer supports');
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
      final deliveryBoys = await RegionService.getDeliveryBoys();
      setState(() {
        _deliveryBoys = deliveryBoys;
      });
      AppLogger.info('Loaded ${_deliveryBoys.length} delivery boys');
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
                  initialValue: selectedRegionType,
                  decoration: InputDecoration(
                    labelText: 'Region Type',
                    border: const OutlineInputBorder(),
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
                          const SizedBox(width: 8),
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
                  AppSnackBar.error(context, 'Please fill all required fields');
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

      await RegionService.createRegion(
        name: name,
        city: city,
        regionName: regionName,
        regionType: regionType.value,
        pinCodes: pinCodes,
      );

      if (mounted) {
        AppSnackBar.success(
            context, 'Service region "$name" created successfully');
      }
      await _loadRegions();
    } catch (e) {
      AppLogger.error('Error creating region: $e');
      if (mounted) {
        AppSnackBar.error(context, 'Failed to create service region');
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

    final confirm = await confirmAction(
      context,
      title: 'Confirm Deletion',
      message:
          'Are you sure you want to delete "${region['name']}"?\n\nThis will unassign all customer support staff from this region.',
      confirmLabel: 'Delete',
    );

    if (!confirm) return;

    try {
      final regionId = region['id'] ?? region['Id'];
      await RegionService.deleteRegion((regionId as num).toInt());
      if (mounted) {
        _showSuccess('Region deleted successfully');
        await _checkPermissionAndLoad();
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
      builder: (context) => const QuickPincodeLookupDialog(),
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
                color: Colors.black.withValues(alpha: 0.05),
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
                          const Text('All'),
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
                          const Text('Support'),
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
                          const Text('Delivery'),
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
              style: AppButton.primary(),
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
                AppSnackBar.error(context, 'PIN code must be exactly 6 digits');
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
      await RegionService.addPincodeToRegion(
        regionId: (regionId as num).toInt(),
        pinCode: pinCode,
      );
      if (mounted) {
        AppSnackBar.success(context, 'PIN $pinCode added successfully');
        await _loadRegions();
      }
    } on DioException catch (e) {
      if (mounted) {
        final msg =
            e.response?.data?['error'] ?? 'Failed to add PIN code';
        AppSnackBar.error(context, msg);
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
            style: AppButton.danger(),
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
      await RegionService.removePincodeFromRegion(
        regionId: (regionId as num).toInt(),
        pinCode: pinCode,
      );
      if (mounted) {
        AppSnackBar.success(context, 'PIN $pinCode removed successfully');
        await _loadRegions();
      }
    } on DioException catch (e) {
      if (mounted) {
        final msg =
            e.response?.data?['error'] ?? 'Failed to remove PIN code';
        AppSnackBar.error(context, msg);
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
                AppSnackBar.error(context, 'Please fill all fields');
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
      await RegionService.updateRegion(
        regionId: regionId,
        name: name,
        city: city,
        regionName: regionName,
      );

      if (mounted) {
        AppSnackBar.success(context, 'Region updated successfully');
      }
      await _checkPermissionAndLoad();
    } catch (e) {
      AppLogger.error('Error updating region: $e');
      if (mounted) {
        AppSnackBar.error(context, 'Failed to update region');
      }
    }
  }

  Future<void> _confirmDeleteRegion(Map<String, dynamic> region) async {
    final confirmed = await confirmAction(
      context,
      title: 'Delete Region',
      message: 'Are you sure you want to delete "${region['name']}"?\n\n'
          'This action cannot be undone.',
      confirmLabel: 'Delete',
    );

    if (confirmed) {
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
    AppLogger.info(
        'Assign person dialog — region keys: ${region.keys.toList()}, id: ${region['id'] ?? region['Id']}');
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
        AppSnackBar.warning(
          context,
          regionType == RegionType.customerSupport
              ? 'All customer supports are already assigned'
              : 'All delivery boys are already assigned',
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

  /// Delivery boys are keyed by the integer `id` of their Delivery record,
  /// customer supports by a GUID string — JSON hands us `num` or `String`
  /// depending on the payload, so normalise before hitting the API.
  static int? _asDeliveryId(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
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
        await RegionService.assignCustomerSupportToRegion(
          regionId: id,
          customerSupportId: personId.toString(),
        );
      } else {
        final deliveryId = _asDeliveryId(personId);
        if (deliveryId == null) {
          AppLogger.error('Invalid delivery boy id: $personId');
          if (mounted) {
            AppSnackBar.error(context, 'Failed to assign: invalid delivery boy');
          }
          return;
        }
        await RegionService.setDeliveryBoyServiceRegion(
          deliveryId: deliveryId,
          serviceRegionId: id,
        );
      }

      if (mounted) {
        AppSnackBar.success(
          context,
          regionType == RegionType.customerSupport
              ? 'Customer support assigned successfully'
              : 'Delivery boy assigned successfully',
        );
      }

      await _checkPermissionAndLoad();
    } catch (e) {
      AppLogger.error('Error assigning person: $e');
      if (mounted) {
        AppSnackBar.error(context, 'Failed to assign');
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
        await RegionService.assignCustomerSupportToRegion(
          regionId: null,
          customerSupportId: personId.toString(),
        );
      } else {
        final deliveryId = _asDeliveryId(personId);
        if (deliveryId == null) {
          AppLogger.error('Invalid delivery boy id: $personId');
          if (mounted) {
            AppSnackBar.error(
                context, 'Failed to unassign: invalid delivery boy');
          }
          return;
        }
        await RegionService.setDeliveryBoyServiceRegion(
          deliveryId: deliveryId,
          serviceRegionId: null,
        );
      }

      if (mounted) {
        AppSnackBar.success(
          context,
          regionType == RegionType.customerSupport
              ? 'Customer support unassigned'
              : 'Delivery boy unassigned',
        );
      }

      await _checkPermissionAndLoad();
    } catch (e) {
      AppLogger.error('Error unassigning person: $e');
      if (mounted) {
        AppSnackBar.error(context, 'Failed to unassign');
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
