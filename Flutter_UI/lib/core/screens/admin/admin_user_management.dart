// ============================================================================
// ADMIN USER MANAGEMENT PAGE - WITH SEARCH AND FILTERS
// ============================================================================

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/role-entity-manager.dart';
import 'package:pharmaish/core/screens/admin/create_user_screen.dart';

class AdminUserManagementPage extends StatefulWidget {
  final Dio dio;

  const AdminUserManagementPage({Key? key, required this.dio})
      : super(key: key);

  @override
  State<AdminUserManagementPage> createState() =>
      _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  late RoleEntityManager _manager;

  // Tab management
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Customers', 'Customer Support', 'Chemists'];

  // Filter management
  int _customerFilterIndex = 0; // 0: All, 1: Active, 2: Inactive, 3: Deleted
  int _supportFilterIndex = 0;
  int _chemistFilterIndex = 0;

  // Data lists (unfiltered)
  List<Map<String, dynamic>> _allCustomers = [];
  List<Map<String, dynamic>> _allCustomerSupports = [];
  List<Map<String, dynamic>> _allMedicalStores = [];

  // Filtered data lists
  List<Map<String, dynamic>> _filteredCustomers = [];
  List<Map<String, dynamic>> _filteredCustomerSupports = [];
  List<Map<String, dynamic>> _filteredMedicalStores = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _manager = RoleEntityManager(widget.dio);
    _loadAllData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // =========================================================================
  // NAVIGATION
  // =========================================================================

  Future<void> _navigateToCreateUser() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateUserScreen(dio: widget.dio),
      ),
    );

    if (result == true) {
      _loadAllData();
    }
  }

  // =========================================================================
  // DATA LOADING
  // =========================================================================

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.wait([
        _loadCustomers(),
        _loadCustomerSupports(),
        _loadMedicalStores(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCustomers() async {
    try {
      final response = await widget.dio.get('/Customers');
      if (response.statusCode == 200) {
        setState(() {
          _allCustomers = (response.data as List<dynamic>)
              .map((e) => e as Map<String, dynamic>)
              .toList();

          _allCustomers.sort((a, b) {
            final aDeleted = a['isDeleted'] ?? false;
            final bDeleted = b['isDeleted'] ?? false;
            final aActive = a['isActive'] ?? false;
            final bActive = b['isActive'] ?? false;

            if (aDeleted && !bDeleted) return 1;
            if (!aDeleted && bDeleted) return -1;
            if (aActive && !bActive) return -1;
            if (!aActive && bActive) return 1;
            return 0;
          });
        });
        AppLogger.info('Loaded ${_allCustomers.length} customers');
        _filterCustomers();
      }
    } catch (e) {
      AppLogger.error('Error loading customers: $e');
      rethrow;
    }
  }

  Future<void> _loadCustomerSupports() async {
    try {
      final response = await widget.dio.get('/CustomerSupports');
      if (response.statusCode == 200) {
        setState(() {
          _allCustomerSupports = (response.data as List<dynamic>)
              .map((e) => e as Map<String, dynamic>)
              .toList();

          _allCustomerSupports.sort((a, b) {
            final aDeleted = a['isDeleted'] ?? false;
            final bDeleted = b['isDeleted'] ?? false;
            final aActive = a['isActive'] ?? false;
            final bActive = b['isActive'] ?? false;

            if (aDeleted && !bDeleted) return 1;
            if (!aDeleted && bDeleted) return -1;
            if (aActive && !bActive) return -1;
            if (!aActive && bActive) return 1;
            return 0;
          });
        });
        AppLogger.info(
            'Loaded ${_allCustomerSupports.length} customer supports');
        _filterCustomerSupports();
      }
    } catch (e) {
      AppLogger.error('Error loading customer supports: $e');
      rethrow;
    }
  }

  Future<void> _loadMedicalStores() async {
    try {
      final response = await widget.dio.get('/MedicalStores');
      if (response.statusCode == 200) {
        setState(() {
          _allMedicalStores = (response.data as List<dynamic>)
              .map((e) => e as Map<String, dynamic>)
              .toList();

          _allMedicalStores.sort((a, b) {
            final aDeleted = a['isDeleted'] ?? false;
            final bDeleted = b['isDeleted'] ?? false;
            final aActive = a['isActive'] ?? false;
            final bActive = b['isActive'] ?? false;

            if (aDeleted && !bDeleted) return 1;
            if (!aDeleted && bDeleted) return -1;
            if (aActive && !bActive) return -1;
            if (!aActive && bActive) return 1;
            return 0;
          });
        });
        AppLogger.info('Loaded ${_allMedicalStores.length} medical stores');
        _filterMedicalStores();
      }
    } catch (e) {
      AppLogger.error('Error loading medical stores: $e');
      rethrow;
    }
  }

  // =========================================================================
  // SEARCH & FILTER LOGIC
  // =========================================================================

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });

    switch (_selectedTabIndex) {
      case 0:
        _filterCustomers();
        break;
      case 1:
        _filterCustomerSupports();
        break;
      case 2:
        _filterMedicalStores();
        break;
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
    _onSearchChanged('');
  }

  void _applyCustomerFilter(int index) {
    setState(() {
      _customerFilterIndex = index;
    });
    _filterCustomers();
  }

  void _filterCustomers() {
    List<Map<String, dynamic>> filtered;

    // Apply status filter
    switch (_customerFilterIndex) {
      case 0: // All
        filtered = List.from(_allCustomers);
        break;
      case 1: // Active
        filtered = _allCustomers
            .where((c) =>
                (c['isActive'] ?? false) && !(c['isDeleted'] ?? false))
            .toList();
        break;
      case 2: // Inactive
        filtered = _allCustomers
            .where((c) =>
                !(c['isActive'] ?? false) && !(c['isDeleted'] ?? false))
            .toList();
        break;
      case 3: // Deleted
        filtered =
            _allCustomers.where((c) => c['isDeleted'] ?? false).toList();
        break;
      default:
        filtered = List.from(_allCustomers);
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((customer) {
        final firstName =
            (customer['customerFirstName'] ?? '').toString().toLowerCase();
        final lastName =
            (customer['customerLastName'] ?? '').toString().toLowerCase();
        final email = (customer['emailId'] ?? '').toString().toLowerCase();
        final mobile =
            (customer['mobileNumber'] ?? '').toString().toLowerCase();

        return firstName.contains(query) ||
            lastName.contains(query) ||
            email.contains(query) ||
            mobile.contains(query);
      }).toList();
    }

    setState(() {
      _filteredCustomers = filtered;
    });

    AppLogger.info(
        'Customer filter $_customerFilterIndex with search "$_searchQuery": ${_filteredCustomers.length} results');
  }

  void _applySupportFilter(int index) {
    setState(() {
      _supportFilterIndex = index;
    });
    _filterCustomerSupports();
  }

  void _filterCustomerSupports() {
    List<Map<String, dynamic>> filtered;

    // Apply status filter
    switch (_supportFilterIndex) {
      case 0: // All
        filtered = List.from(_allCustomerSupports);
        break;
      case 1: // Active
        filtered = _allCustomerSupports
            .where((c) =>
                (c['isActive'] ?? false) && !(c['isDeleted'] ?? false))
            .toList();
        break;
      case 2: // Inactive
        filtered = _allCustomerSupports
            .where((c) =>
                !(c['isActive'] ?? false) && !(c['isDeleted'] ?? false))
            .toList();
        break;
      case 3: // Deleted
        filtered = _allCustomerSupports
            .where((c) => c['isDeleted'] ?? false)
            .toList();
        break;
      default:
        filtered = List.from(_allCustomerSupports);
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((support) {
        final firstName = (support['customerSupportFirstName'] ?? '')
            .toString()
            .toLowerCase();
        final lastName = (support['customerSupportLastName'] ?? '')
            .toString()
            .toLowerCase();
        final email = (support['emailId'] ?? '').toString().toLowerCase();
        final mobile = (support['mobileNumber'] ?? '').toString().toLowerCase();
        final employeeId =
            (support['employeeId'] ?? '').toString().toLowerCase();

        return firstName.contains(query) ||
            lastName.contains(query) ||
            email.contains(query) ||
            mobile.contains(query) ||
            employeeId.contains(query);
      }).toList();
    }

    setState(() {
      _filteredCustomerSupports = filtered;
    });

    AppLogger.info(
        'Support filter $_supportFilterIndex with search "$_searchQuery": ${_filteredCustomerSupports.length} results');
  }

  void _applyChemistFilter(int index) {
    setState(() {
      _chemistFilterIndex = index;
    });
    _filterMedicalStores();
  }

  void _filterMedicalStores() {
    List<Map<String, dynamic>> filtered;

    // Apply status filter
    switch (_chemistFilterIndex) {
      case 0: // All
        filtered = List.from(_allMedicalStores);
        break;
      case 1: // Active
        filtered = _allMedicalStores
            .where((c) =>
                (c['isActive'] ?? false) && !(c['isDeleted'] ?? false))
            .toList();
        break;
      case 2: // Inactive
        filtered = _allMedicalStores
            .where((c) =>
                !(c['isActive'] ?? false) && !(c['isDeleted'] ?? false))
            .toList();
        break;
      case 3: // Deleted
        filtered = _allMedicalStores
            .where((c) => c['isDeleted'] ?? false)
            .toList();
        break;
      default:
        filtered = List.from(_allMedicalStores);
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((store) {
        final medicalName =
            (store['medicalName'] ?? '').toString().toLowerCase();
        final ownerFirst =
            (store['ownerFirstName'] ?? '').toString().toLowerCase();
        final ownerLast =
            (store['ownerLastName'] ?? '').toString().toLowerCase();
        final email = (store['emailId'] ?? '').toString().toLowerCase();
        final mobile = (store['mobileNumber'] ?? '').toString().toLowerCase();
        final city = (store['city'] ?? '').toString().toLowerCase();

        return medicalName.contains(query) ||
            ownerFirst.contains(query) ||
            ownerLast.contains(query) ||
            email.contains(query) ||
            mobile.contains(query) ||
            city.contains(query);
      }).toList();
    }

    setState(() {
      _filteredMedicalStores = filtered;
    });

    AppLogger.info(
        'Chemist filter $_chemistFilterIndex with search "$_searchQuery": ${_filteredMedicalStores.length} results');
  }

  int _getCustomerFilterCount(int index) {
    switch (index) {
      case 0:
        return _allCustomers.length;
      case 1:
        return _allCustomers
            .where((c) =>
                (c['isActive'] ?? false) && !(c['isDeleted'] ?? false))
            .length;
      case 2:
        return _allCustomers
            .where((c) =>
                !(c['isActive'] ?? false) && !(c['isDeleted'] ?? false))
            .length;
      case 3:
        return _allCustomers.where((c) => c['isDeleted'] ?? false).length;
      default:
        return 0;
    }
  }

  int _getSupportFilterCount(int index) {
    switch (index) {
      case 0:
        return _allCustomerSupports.length;
      case 1:
        return _allCustomerSupports
            .where((c) =>
                (c['isActive'] ?? false) && !(c['isDeleted'] ?? false))
            .length;
      case 2:
        return _allCustomerSupports
            .where((c) =>
                !(c['isActive'] ?? false) && !(c['isDeleted'] ?? false))
            .length;
      case 3:
        return _allCustomerSupports
            .where((c) => c['isDeleted'] ?? false)
            .length;
      default:
        return 0;
    }
  }

  int _getChemistFilterCount(int index) {
    switch (index) {
      case 0:
        return _allMedicalStores.length;
      case 1:
        return _allMedicalStores
            .where((c) =>
                (c['isActive'] ?? false) && !(c['isDeleted'] ?? false))
            .length;
      case 2:
        return _allMedicalStores
            .where((c) =>
                !(c['isActive'] ?? false) && !(c['isDeleted'] ?? false))
            .length;
      case 3:
        return _allMedicalStores.where((c) => c['isDeleted'] ?? false).length;
      default:
        return 0;
    }
  }

  // =========================================================================
  // DELETE USER
  // =========================================================================

  Future<void> _deleteUser(Map<String, dynamic> user, String userType) async {
    final userId = user['userId'];
    if (userId == null) {
      _showError('User ID not found');
      return;
    }

    String userName = '';
    if (userType == 'Customer') {
      userName = '${user['customerFirstName']} ${user['customerLastName']}';
    } else if (userType == 'CustomerSupport') {
      userName =
          '${user['customerSupportFirstName']} ${user['customerSupportLastName']}';
    } else if (userType == 'MedicalStore') {
      userName = user['medicalName'] ?? '';
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete $userName?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone!',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
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

    if (confirm != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Deleting...'),
          ],
        ),
      ),
    );

    try {
      bool deleted = false;
      String entityName = '';

      switch (userType) {
        case 'Customer':
          deleted = await _manager.deleteCustomerByUserId(userId);
          entityName = 'Customer';
          break;
        case 'CustomerSupport':
          deleted = await _manager.deleteCustomerSupportByUserId(userId);
          entityName = 'Customer Support';
          break;
        case 'MedicalStore':
          deleted = await _manager.deleteMedicalStoreByUserId(userId);
          entityName = 'Medical Store';
          break;
      }

      if (mounted) Navigator.pop(context);

      if (deleted) {
        if (mounted) {
          _showSuccess('$entityName deleted successfully');
          await _loadAllData();
        }
      } else {
        if (mounted) {
          _showError('Failed to delete $entityName');
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        _showError('Error: $e');
      }
    }
  }

  // =========================================================================
  // UI BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _navigateToCreateUser,
            tooltip: 'Create New User',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabs(),
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildErrorView()
                    : _buildContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateUser,
        icon: const Icon(Icons.add),
        label: const Text('Create User'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.grey.shade200,
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTabIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  _tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by name, email, or mobile...',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: _clearSearch,
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
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
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
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.filter_list, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    '${_getCurrentFilteredCount()}',
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
    );
  }

  int _getCurrentFilteredCount() {
    switch (_selectedTabIndex) {
      case 0:
        return _filteredCustomers.length;
      case 1:
        return _filteredCustomerSupports.length;
      case 2:
        return _filteredMedicalStores.length;
      default:
        return 0;
    }
  }

  Widget _buildFilterChips() {
    int currentFilter;
    Function(int) onFilterChanged;
    Function(int) getCount;

    switch (_selectedTabIndex) {
      case 0: // Customers
        currentFilter = _customerFilterIndex;
        onFilterChanged = _applyCustomerFilter;
        getCount = _getCustomerFilterCount;
        break;
      case 1: // Customer Support
        currentFilter = _supportFilterIndex;
        onFilterChanged = _applySupportFilter;
        getCount = _getSupportFilterCount;
        break;
      case 2: // Chemists
        currentFilter = _chemistFilterIndex;
        onFilterChanged = _applyChemistFilter;
        getCount = _getChemistFilterCount;
        break;
      default:
        currentFilter = 0;
        onFilterChanged = (_) {};
        getCount = (_) => 0;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', 0, Colors.black, currentFilter,
                onFilterChanged, getCount),
            const SizedBox(width: 8),
            _buildFilterChip('Active', 1, Colors.green, currentFilter,
                onFilterChanged, getCount),
            const SizedBox(width: 8),
            _buildFilterChip('Inactive', 2, Colors.grey, currentFilter,
                onFilterChanged, getCount),
            const SizedBox(width: 8),
            _buildFilterChip('Deleted', 3, Colors.red, currentFilter,
                onFilterChanged, getCount),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    int index,
    Color color,
    int currentFilter,
    Function(int) onFilterChanged,
    Function(int) getCount,
  ) {
    final isSelected = currentFilter == index;
    final count = getCount(index);

    return FilterChip(
      label: Text(
        '$label ($count)',
        style: TextStyle(
          color: isSelected ? Colors.white : color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onFilterChanged(index);
        }
      },
      backgroundColor: Colors.white,
      selectedColor: color,
      checkmarkColor: Colors.white,
      side: BorderSide(color: color, width: 1.5),
    );
  }

  Widget _buildContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildCustomersList();
      case 1:
        return _buildCustomerSupportsList();
      case 2:
        return _buildMedicalStoresList();
      default:
        return const SizedBox();
    }
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
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAllData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _getEmptyStateMessage() {
    String userType;
    switch (_selectedTabIndex) {
      case 0:
        userType = 'customers';
        break;
      case 1:
        userType = 'customer support staff';
        break;
      case 2:
        userType = 'medical stores';
        break;
      default:
        userType = 'users';
    }

    if (_searchQuery.isNotEmpty) {
      return 'No $userType found matching "$_searchQuery"';
    }

    int currentFilter;
    switch (_selectedTabIndex) {
      case 0:
        currentFilter = _customerFilterIndex;
        break;
      case 1:
        currentFilter = _supportFilterIndex;
        break;
      case 2:
        currentFilter = _chemistFilterIndex;
        break;
      default:
        currentFilter = 0;
    }

    switch (currentFilter) {
      case 0:
        return 'No $userType found';
      case 1:
        return 'No active $userType';
      case 2:
        return 'No inactive $userType';
      case 3:
        return 'No deleted $userType';
      default:
        return 'No $userType found';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty ? Icons.search_off : Icons.person_outline,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _getEmptyStateMessage(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (_searchQuery.isNotEmpty) ...[
            const Text(
              'Try different search terms',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _clearSearch,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ] else ...[
            const Text(
              'Try selecting a different filter',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                switch (_selectedTabIndex) {
                  case 0:
                    _applyCustomerFilter(0);
                    break;
                  case 1:
                    _applySupportFilter(0);
                    break;
                  case 2:
                    _applyChemistFilter(0);
                    break;
                }
              },
              child: const Text('Show All'),
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================================
  // CUSTOMERS LIST
  // =========================================================================

  Widget _buildCustomersList() {
    if (_filteredCustomers.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredCustomers.length,
        itemBuilder: (context, index) {
          if (index < 0 || index >= _filteredCustomers.length) {
            return const SizedBox.shrink();
          }
          final customer = _filteredCustomers[index];
          return _buildCustomerCard(customer);
        },
      ),
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> customer) {
    final isActive = customer['isActive'] ?? false;
    final isDeleted = customer['isDeleted'] ?? false;
    final firstName = customer['customerFirstName'] ?? '';
    final lastName = customer['customerLastName'] ?? '';
    final mobile = customer['mobileNumber'] ?? '';
    final email = customer['emailId'] ?? '';

    Color statusColor;
    Color statusBgColor;
    String statusText;

    if (isDeleted) {
      statusColor = Colors.red.shade800;
      statusBgColor = Colors.red.shade100;
      statusText = 'Deleted';
    } else if (isActive) {
      statusColor = Colors.green.shade800;
      statusBgColor = Colors.green.shade100;
      statusText = 'Active';
    } else {
      statusColor = Colors.grey.shade700;
      statusBgColor = Colors.grey.shade200;
      statusText = 'Inactive';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDeleted ? Colors.red.shade50 : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isDeleted ? Colors.red : (isActive ? Colors.green : Colors.grey),
          child: Text(
            firstName.isNotEmpty ? firstName[0].toUpperCase() : 'C',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          '$firstName $lastName',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isDeleted ? TextDecoration.lineThrough : null,
            color: isDeleted ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '📱 $mobile',
              style: TextStyle(color: isDeleted ? Colors.grey : null),
            ),
            if (email.isNotEmpty)
              Text(
                '📧 $email',
                style: TextStyle(color: isDeleted ? Colors.grey : null),
              ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 11,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: isDeleted
            ? const Icon(Icons.delete_forever, color: Colors.red)
            : PopupMenuButton(
                itemBuilder: (context) => [
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
                  if (value == 'delete') {
                    _deleteUser(customer, 'Customer');
                  }
                },
              ),
      ),
    );
  }

  // =========================================================================
  // CUSTOMER SUPPORTS LIST
  // =========================================================================

  Widget _buildCustomerSupportsList() {
    if (_filteredCustomerSupports.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredCustomerSupports.length,
        itemBuilder: (context, index) {
          if (index < 0 || index >= _filteredCustomerSupports.length) {
            return const SizedBox.shrink();
          }
          final support = _filteredCustomerSupports[index];
          return _buildCustomerSupportCard(support);
        },
      ),
    );
  }

  Widget _buildCustomerSupportCard(Map<String, dynamic> support) {
    final isActive = support['isActive'] ?? false;
    final isDeleted = support['isDeleted'] ?? false;
    final firstName = support['customerSupportFirstName'] ?? '';
    final lastName = support['customerSupportLastName'] ?? '';
    final mobile = support['mobileNumber'] ?? '';
    final employeeId = support['employeeId'] ?? '';

    Color statusColor;
    Color statusBgColor;
    String statusText;

    if (isDeleted) {
      statusColor = Colors.red.shade800;
      statusBgColor = Colors.red.shade100;
      statusText = 'Deleted';
    } else if (isActive) {
      statusColor = Colors.blue.shade800;
      statusBgColor = Colors.blue.shade100;
      statusText = 'Active';
    } else {
      statusColor = Colors.grey.shade700;
      statusBgColor = Colors.grey.shade200;
      statusText = 'Inactive';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDeleted ? Colors.red.shade50 : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isDeleted ? Colors.red : (isActive ? Colors.blue : Colors.grey),
          child: const Icon(Icons.support_agent, color: Colors.white),
        ),
        title: Text(
          '$firstName $lastName',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isDeleted ? TextDecoration.lineThrough : null,
            color: isDeleted ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '📱 $mobile',
              style: TextStyle(color: isDeleted ? Colors.grey : null),
            ),
            Text(
              '🏷️ Emp ID: $employeeId',
              style: TextStyle(color: isDeleted ? Colors.grey : null),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 11,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: isDeleted
            ? const Icon(Icons.delete_forever, color: Colors.red)
            : PopupMenuButton(
                itemBuilder: (context) => [
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
                  if (value == 'delete') {
                    _deleteUser(support, 'CustomerSupport');
                  }
                },
              ),
      ),
    );
  }

  // =========================================================================
  // MEDICAL STORES LIST
  // =========================================================================

  Widget _buildMedicalStoresList() {
    if (_filteredMedicalStores.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredMedicalStores.length,
        itemBuilder: (context, index) {
          if (index < 0 || index >= _filteredMedicalStores.length) {
            return const SizedBox.shrink();
          }
          final store = _filteredMedicalStores[index];
          return _buildMedicalStoreCard(store);
        },
      ),
    );
  }

  Widget _buildMedicalStoreCard(Map<String, dynamic> store) {
    final isActive = store['isActive'] ?? false;
    final isDeleted = store['isDeleted'] ?? false;
    final medicalName = store['medicalName'] ?? '';
    final ownerFirst = store['ownerFirstName'] ?? '';
    final ownerLast = store['ownerLastName'] ?? '';
    final mobile = store['mobileNumber'] ?? '';
    final city = store['city'] ?? '';

    Color statusColor;
    Color statusBgColor;
    String statusText;

    if (isDeleted) {
      statusColor = Colors.red.shade800;
      statusBgColor = Colors.red.shade100;
      statusText = 'Deleted';
    } else if (isActive) {
      statusColor = Colors.purple.shade800;
      statusBgColor = Colors.purple.shade100;
      statusText = 'Active';
    } else {
      statusColor = Colors.grey.shade700;
      statusBgColor = Colors.grey.shade200;
      statusText = 'Inactive';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDeleted ? Colors.red.shade50 : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDeleted
              ? Colors.red
              : (isActive ? Colors.purple : Colors.grey),
          child: const Icon(Icons.local_pharmacy, color: Colors.white),
        ),
        title: Text(
          medicalName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isDeleted ? TextDecoration.lineThrough : null,
            color: isDeleted ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '👤 Owner: $ownerFirst $ownerLast',
              style: TextStyle(color: isDeleted ? Colors.grey : null),
            ),
            Text(
              '📱 $mobile',
              style: TextStyle(color: isDeleted ? Colors.grey : null),
            ),
            if (city.isNotEmpty)
              Text(
                '📍 $city',
                style: TextStyle(color: isDeleted ? Colors.grey : null),
              ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 11,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: isDeleted
            ? const Icon(Icons.delete_forever, color: Colors.red)
            : PopupMenuButton(
                itemBuilder: (context) => [
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
                  if (value == 'delete') {
                    _deleteUser(store, 'MedicalStore');
                  }
                },
              ),
      ),
    );
  }

  // =========================================================================
  // HELPER METHODS
  // =========================================================================

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
        ),
      );
    }
  }
}