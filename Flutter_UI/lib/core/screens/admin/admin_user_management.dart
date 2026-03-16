// ============================================================================
// ADMIN USER MANAGEMENT PAGE - WITH SEARCH AND FILTERS
// Tabs: Customers | Customer Support | Chemists | Managers | Delivery Boys
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

  // ── Tab management ─────────────────────────────────────────────────────────
  // 0: Customers | 1: Customer Support | 2: Chemists | 3: Managers | 4: Delivery Boys
  int _selectedTabIndex = 0;
  final List<String> _tabs = [
    'Customers',
    'Cust. Support',
    'Chemists',
    'Managers',
    'Delivery Boys',
  ];

  // ── Filter indices (0: All, 1: Active, 2: Inactive, 3: Deleted) ───────────
  int _customerFilterIndex = 0;
  int _supportFilterIndex = 0;
  int _chemistFilterIndex = 0;
  int _managerFilterIndex = 0;
  int _deliveryFilterIndex = 0;

  // ── Raw data lists ─────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _allCustomers = [];
  List<Map<String, dynamic>> _allCustomerSupports = [];
  List<Map<String, dynamic>> _allMedicalStores = [];
  List<Map<String, dynamic>> _allManagers = [];
  List<Map<String, dynamic>> _allDeliveryBoys = [];

  // ── Filtered data lists ────────────────────────────────────────────────────
  List<Map<String, dynamic>> _filteredCustomers = [];
  List<Map<String, dynamic>> _filteredCustomerSupports = [];
  List<Map<String, dynamic>> _filteredMedicalStores = [];
  List<Map<String, dynamic>> _filteredManagers = [];
  List<Map<String, dynamic>> _filteredDeliveryBoys = [];

  // ── Medical stores for Delivery Boy assignment dropdown ────────────────────
  List<Map<String, dynamic>> _medicalStoresForDropdown = [];

  bool _isLoading = false;
  String? _errorMessage;

  // ── Search ─────────────────────────────────────────────────────────────────
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

  // ==========================================================================
  // NAVIGATION
  // ==========================================================================

  Future<void> _navigateToCreateUser() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateUserScreen(dio: widget.dio),
      ),
    );
    if (result == true) _loadAllData();
  }

  // ==========================================================================
  // DATA LOADING
  // ==========================================================================

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
        _loadManagers(),
        _loadDeliveryBoys(),
      ]);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Sort helper (active first, deleted last) ───────────────────────────────
  List<Map<String, dynamic>> _sorted(List<Map<String, dynamic>> list) {
    final copy = List<Map<String, dynamic>>.from(list);
    copy.sort((a, b) {
      final aD = a['isDeleted'] ?? false;
      final bD = b['isDeleted'] ?? false;
      final aA = a['isActive'] ?? false;
      final bA = b['isActive'] ?? false;
      if (aD && !bD) return 1;
      if (!aD && bD) return -1;
      if (aA && !bA) return -1;
      if (!aA && bA) return 1;
      return 0;
    });
    return copy;
  }

  Future<void> _loadCustomers() async {
    try {
      final r = await widget.dio.get('/Customers');
      if (r.statusCode == 200) {
        setState(() {
          _allCustomers = _sorted(
              (r.data as List).map((e) => e as Map<String, dynamic>).toList());
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
      final r = await widget.dio.get('/CustomerSupports');
      if (r.statusCode == 200) {
        setState(() {
          _allCustomerSupports = _sorted(
              (r.data as List).map((e) => e as Map<String, dynamic>).toList());
        });
        AppLogger.info('Loaded ${_allCustomerSupports.length} customer supports');
        _filterCustomerSupports();
      }
    } catch (e) {
      AppLogger.error('Error loading customer supports: $e');
      rethrow;
    }
  }

  Future<void> _loadMedicalStores() async {
    try {
      final r = await widget.dio.get('/MedicalStores');
      if (r.statusCode == 200) {
        final list = _sorted(
            (r.data as List).map((e) => e as Map<String, dynamic>).toList());
        setState(() {
          _allMedicalStores = list;
          // keep a clean active-only copy for the delivery boy dropdown
          _medicalStoresForDropdown = list
              .where((s) =>
                  (s['isActive'] ?? false) && !(s['isDeleted'] ?? false))
              .toList();
        });
        AppLogger.info('Loaded ${_allMedicalStores.length} medical stores');
        _filterMedicalStores();
      }
    } catch (e) {
      AppLogger.error('Error loading medical stores: $e');
      rethrow;
    }
  }

  Future<void> _loadManagers() async {
    try {
      final r = await widget.dio.get('/Managers');
      if (r.statusCode == 200) {
        setState(() {
          _allManagers = _sorted(
              (r.data as List).map((e) => e as Map<String, dynamic>).toList());
        });
        AppLogger.info('Loaded ${_allManagers.length} managers');
        _filterManagers();
      }
    } catch (e) {
      AppLogger.error('Error loading managers: $e');
      // Non-fatal – tab simply shows empty
    }
  }

  Future<void> _loadDeliveryBoys() async {
    try {
      final r = await widget.dio.get('/Deliveries');
      if (r.statusCode == 200) {
        setState(() {
          _allDeliveryBoys = _sorted(
              (r.data as List).map((e) => e as Map<String, dynamic>).toList());
        });
        AppLogger.info('Loaded ${_allDeliveryBoys.length} delivery boys');
        _filterDeliveryBoys();
      }
    } catch (e) {
      AppLogger.error('Error loading delivery boys: $e');
      // Non-fatal – tab simply shows empty
    }
  }

  // ==========================================================================
  // SEARCH & FILTER
  // ==========================================================================

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    _refilterCurrentTab();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
    _refilterCurrentTab();
  }

  void _refilterCurrentTab() {
    switch (_selectedTabIndex) {
      case 0: _filterCustomers(); break;
      case 1: _filterCustomerSupports(); break;
      case 2: _filterMedicalStores(); break;
      case 3: _filterManagers(); break;
      case 4: _filterDeliveryBoys(); break;
    }
  }

  // ── Filter appliers ────────────────────────────────────────────────────────
  void _applyCustomerFilter(int i) { setState(() => _customerFilterIndex = i); _filterCustomers(); }
  void _applySupportFilter(int i)  { setState(() => _supportFilterIndex  = i); _filterCustomerSupports(); }
  void _applyChemistFilter(int i)  { setState(() => _chemistFilterIndex  = i); _filterMedicalStores(); }
  void _applyManagerFilter(int i)  { setState(() => _managerFilterIndex  = i); _filterManagers(); }
  void _applyDeliveryFilter(int i) { setState(() => _deliveryFilterIndex = i); _filterDeliveryBoys(); }

  List<Map<String, dynamic>> _applyStatusFilter(
      List<Map<String, dynamic>> all, int filterIdx) {
    switch (filterIdx) {
      case 1: return all.where((c) =>  (c['isActive']??false) && !(c['isDeleted']??false)).toList();
      case 2: return all.where((c) => !(c['isActive']??false) && !(c['isDeleted']??false)).toList();
      case 3: return all.where((c) =>  (c['isDeleted']??false)).toList();
      default: return List.from(all);
    }
  }

  void _filterCustomers() {
    var f = _applyStatusFilter(_allCustomers, _customerFilterIndex);
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      f = f.where((c) {
        return (c['customerFirstName']??'').toString().toLowerCase().contains(q) ||
               (c['customerLastName'] ??'').toString().toLowerCase().contains(q) ||
               (c['emailId']          ??'').toString().toLowerCase().contains(q) ||
               (c['mobileNumber']     ??'').toString().toLowerCase().contains(q);
      }).toList();
    }
    setState(() => _filteredCustomers = f);
  }

  void _filterCustomerSupports() {
    var f = _applyStatusFilter(_allCustomerSupports, _supportFilterIndex);
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      f = f.where((c) {
        return (c['customerSupportFirstName']??'').toString().toLowerCase().contains(q) ||
               (c['customerSupportLastName'] ??'').toString().toLowerCase().contains(q) ||
               (c['emailId']                 ??'').toString().toLowerCase().contains(q) ||
               (c['mobileNumber']            ??'').toString().toLowerCase().contains(q) ||
               (c['employeeId']              ??'').toString().toLowerCase().contains(q);
      }).toList();
    }
    setState(() => _filteredCustomerSupports = f);
  }

  void _filterMedicalStores() {
    var f = _applyStatusFilter(_allMedicalStores, _chemistFilterIndex);
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      f = f.where((s) {
        return (s['medicalName']   ??'').toString().toLowerCase().contains(q) ||
               (s['ownerFirstName']??'').toString().toLowerCase().contains(q) ||
               (s['ownerLastName'] ??'').toString().toLowerCase().contains(q) ||
               (s['emailId']       ??'').toString().toLowerCase().contains(q) ||
               (s['mobileNumber']  ??'').toString().toLowerCase().contains(q) ||
               (s['city']          ??'').toString().toLowerCase().contains(q);
      }).toList();
    }
    setState(() => _filteredMedicalStores = f);
  }

  void _filterManagers() {
    var f = _applyStatusFilter(_allManagers, _managerFilterIndex);
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      f = f.where((m) {
        return (m['managerFirstName']??'').toString().toLowerCase().contains(q) ||
               (m['managerLastName'] ??'').toString().toLowerCase().contains(q) ||
               (m['emailId']         ??'').toString().toLowerCase().contains(q) ||
               (m['mobileNumber']    ??'').toString().toLowerCase().contains(q) ||
               (m['employeeId']      ??'').toString().toLowerCase().contains(q);
      }).toList();
    }
    setState(() => _filteredManagers = f);
  }

  void _filterDeliveryBoys() {
    var f = _applyStatusFilter(_allDeliveryBoys, _deliveryFilterIndex);
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      f = f.where((d) {
        return (d['firstName']             ??'').toString().toLowerCase().contains(q) ||
               (d['lastName']              ??'').toString().toLowerCase().contains(q) ||
               (d['mobileNumber']          ??'').toString().toLowerCase().contains(q) ||
               (d['drivingLicenceNumber']  ??'').toString().toLowerCase().contains(q);
      }).toList();
    }
    setState(() => _filteredDeliveryBoys = f);
  }

  // ── Filter counts ──────────────────────────────────────────────────────────
  int _filterCount(List<Map<String, dynamic>> all, int filterIdx) {
    switch (filterIdx) {
      case 1: return all.where((c) =>  (c['isActive']??false) && !(c['isDeleted']??false)).length;
      case 2: return all.where((c) => !(c['isActive']??false) && !(c['isDeleted']??false)).length;
      case 3: return all.where((c) =>  (c['isDeleted']??false)).length;
      default: return all.length;
    }
  }

  int _getCurrentFilteredCount() {
    switch (_selectedTabIndex) {
      case 0: return _filteredCustomers.length;
      case 1: return _filteredCustomerSupports.length;
      case 2: return _filteredMedicalStores.length;
      case 3: return _filteredManagers.length;
      case 4: return _filteredDeliveryBoys.length;
      default: return 0;
    }
  }

  // ==========================================================================
  // DELETE
  // ==========================================================================

  Future<void> _deleteUser(
      Map<String, dynamic> user, String userType) async {
    // Resolve the entity id and display name per type
    dynamic entityId;
    String userName = '';

    switch (userType) {
      case 'Customer':
        entityId = user['userId'];
        userName = '${user['customerFirstName']} ${user['customerLastName']}';
        break;
      case 'CustomerSupport':
        entityId = user['userId'];
        userName = '${user['customerSupportFirstName']} ${user['customerSupportLastName']}';
        break;
      case 'MedicalStore':
        entityId = user['userId'];
        userName = user['medicalName'] ?? '';
        break;
      case 'Manager':
        // Managers use managerId, not userId
        entityId = user['managerId'];
        userName = '${user['managerFirstName']} ${user['managerLastName']}';
        break;
      case 'DeliveryBoy':
        // Delivery boys use int id
        entityId = user['id'];
        userName = '${user['firstName']} ${user['lastName']}';
        break;
    }

    if (entityId == null) {
      _showError('ID not found for this record');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete ${userName.trim()}?'),
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
                          fontWeight: FontWeight.w500),
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
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
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
          deleted = await _manager.deleteCustomerByUserId(entityId);
          entityName = 'Customer';
          break;
        case 'CustomerSupport':
          deleted = await _manager.deleteCustomerSupportByUserId(entityId);
          entityName = 'Customer Support';
          break;
        case 'MedicalStore':
          deleted = await _manager.deleteMedicalStoreByUserId(entityId);
          entityName = 'Medical Store';
          break;
        case 'Manager':
          // DELETE /api/Managers/{managerId}
          final r = await widget.dio.delete('/Managers/$entityId');
          deleted = r.statusCode == 204 || r.statusCode == 200;
          entityName = 'Manager';
          break;
        case 'DeliveryBoy':
          // DELETE /api/Deliveries/{id}
          final r = await widget.dio.delete('/Deliveries/$entityId');
          deleted = r.statusCode == 204 || r.statusCode == 200;
          entityName = 'Delivery Boy';
          break;
      }

      if (mounted) Navigator.pop(context); // close progress

      if (deleted) {
        if (mounted) {
          _showSuccess('$entityName deleted successfully');
          await _loadAllData();
        }
      } else {
        if (mounted) _showError('Failed to delete $entityName');
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) _showError('Error: $e');
    }
  }

  // ==========================================================================
  // EDIT – MANAGER
  // ==========================================================================

  Future<void> _editManager(Map<String, dynamic> manager) async {
    final formKey = GlobalKey<FormState>();
    final firstCtrl  = TextEditingController(text: manager['managerFirstName']  ?? '');
    final middleCtrl = TextEditingController(text: manager['managerMiddleName'] ?? '');
    final lastCtrl   = TextEditingController(text: manager['managerLastName']   ?? '');
    final mobileCtrl = TextEditingController(text: manager['mobileNumber']      ?? '');
    final altCtrl    = TextEditingController(text: manager['alternativeMobileNumber'] ?? '');
    final emailCtrl  = TextEditingController(text: manager['emailId']           ?? '');
    final empCtrl    = TextEditingController(text: manager['employeeId']        ?? '');
    final addrCtrl   = TextEditingController(text: manager['address']           ?? '');
    final cityCtrl   = TextEditingController(text: manager['city']              ?? '');
    final stateCtrl  = TextEditingController(text: manager['state']             ?? '');

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditSheet(
        title: 'Edit Manager',
        formKey: formKey,
        onSave: () async {
          if (!formKey.currentState!.validate()) return false;
          final id = manager['managerId'];
          final body = {
            'managerFirstName':        firstCtrl.text.trim(),
            'managerMiddleName':       middleCtrl.text.trim(),
            'managerLastName':         lastCtrl.text.trim(),
            'mobileNumber':            mobileCtrl.text.trim(),
            'alternativeMobileNumber': altCtrl.text.trim(),
            'emailId':                 emailCtrl.text.trim(),
            'employeeId':              empCtrl.text.trim(),
            'address':                 addrCtrl.text.trim(),
            'city':                    cityCtrl.text.trim(),
            'state':                   stateCtrl.text.trim(),
          };
          final r = await widget.dio.put('/Managers/$id', data: body);
          return r.statusCode == 200;
        },
        fields: [
          _EditSheet.row([
            _EditSheet.field(firstCtrl,  'First Name *',  required: true),
            _EditSheet.field(middleCtrl, 'Middle Name'),
          ]),
          _EditSheet.field(lastCtrl,  'Last Name *',  required: true),
          _EditSheet.field(empCtrl,   'Employee ID'),
          _EditSheet.field(mobileCtrl,'Mobile *', required: true,
              keyboard: TextInputType.phone,
              validator: (v) => (v??'').length == 10 ? null : 'Enter 10-digit mobile'),
          _EditSheet.field(altCtrl,   'Alt. Mobile', keyboard: TextInputType.phone),
          _EditSheet.field(emailCtrl, 'Email', keyboard: TextInputType.emailAddress),
          _EditSheet.field(addrCtrl,  'Address', maxLines: 2),
          _EditSheet.row([
            _EditSheet.field(cityCtrl,  'City'),
            _EditSheet.field(stateCtrl, 'State'),
          ]),
        ],
      ),
    );

    for (final c in [firstCtrl,middleCtrl,lastCtrl,mobileCtrl,altCtrl,
                      emailCtrl,empCtrl,addrCtrl,cityCtrl,stateCtrl]) {
      c.dispose();
    }

    if (result == true) {
      _showSuccess('Manager updated successfully');
      await _loadManagers();
    }
  }

  // ==========================================================================
  // EDIT – DELIVERY BOY
  // ==========================================================================

  Future<void> _editDeliveryBoy(Map<String, dynamic> boy) async {
    final formKey    = GlobalKey<FormState>();
    final firstCtrl  = TextEditingController(text: boy['firstName']  ?? '');
    final middleCtrl = TextEditingController(text: boy['middleName'] ?? '');
    final lastCtrl   = TextEditingController(text: boy['lastName']   ?? '');
    final mobileCtrl = TextEditingController(text: boy['mobileNumber']         ?? '');
    final licCtrl    = TextEditingController(text: boy['drivingLicenceNumber'] ?? '');

    // For the status toggle we use a ValueNotifier so it can update inside the sheet
    final isActiveNotifier = ValueNotifier<bool>(boy['isActive'] ?? false);

    // Store ID – Delivery boys expose medicalStoreId (Guid)
    String? selectedStoreId = boy['medicalStoreId']?.toString();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => _EditSheet(
          title: 'Edit Delivery Boy',
          formKey: formKey,
          onSave: () async {
            if (!formKey.currentState!.validate()) return false;
            final id = boy['id'];
            final body = <String, dynamic>{
              'firstName':            firstCtrl.text.trim(),
              'middleName':           middleCtrl.text.trim(),
              'lastName':             lastCtrl.text.trim(),
              'mobileNumber':         mobileCtrl.text.trim(),
              'drivingLicenceNumber': licCtrl.text.trim(),
              'isActive':             isActiveNotifier.value,
              if (selectedStoreId != null) 'medicalStoreId': selectedStoreId,
            };
            final r = await widget.dio.put('/Deliveries/$id', data: body);
            return r.statusCode == 200;
          },
          fields: [
            _EditSheet.row([
              _EditSheet.field(firstCtrl,  'First Name *', required: true),
              _EditSheet.field(middleCtrl, 'Middle Name'),
            ]),
            _EditSheet.field(lastCtrl,   'Last Name *',  required: true),
            _EditSheet.field(mobileCtrl, 'Mobile *', required: true,
                keyboard: TextInputType.phone,
                validator: (v) => (v??'').length == 10 ? null : 'Enter 10-digit mobile'),
            _EditSheet.field(licCtrl, 'Driving Licence No.'),
            // Active status toggle
            ValueListenableBuilder<bool>(
              valueListenable: isActiveNotifier,
              builder: (_, active, __) => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active Status'),
                subtitle: Text(active ? 'Currently active' : 'Currently inactive'),
                value: active,
                activeColor: Colors.green,
                onChanged: (v) => isActiveNotifier.value = v,
              ),
            ),
            // Store dropdown
            StatefulBuilder(
              builder: (_, setSt) => DropdownButtonFormField<String>(
                value: selectedStoreId,
                decoration: InputDecoration(
                  labelText: 'Assigned Pharmacy',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('-- None --',
                        style: TextStyle(color: Colors.grey)),
                  ),
                  ..._medicalStoresForDropdown.map((s) => DropdownMenuItem(
                        value: s['medicalStoreId']?.toString(),
                        child: Text(s['medicalName'] ?? ''),
                      )),
                ],
                onChanged: (v) { setSt(() => selectedStoreId = v); },
              ),
            ),
          ],
        ),
      ),
    );

    for (final c in [firstCtrl,middleCtrl,lastCtrl,mobileCtrl,licCtrl]) {
      c.dispose();
    }
    isActiveNotifier.dispose();

    if (result == true) {
      _showSuccess('Delivery boy updated successfully');
      await _loadDeliveryBoys();
    }
  }

  // ==========================================================================
  // UI BUILD
  // ==========================================================================

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

  // ── Tab bar ────────────────────────────────────────────────────────────────
  Widget _buildTabs() {
    return Container(
      color: Colors.grey.shade200,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final isSelected = _selectedTabIndex == index;
            // colour per tab: 0=green,1=blue,2=purple,3=indigo,4=teal
            final colors = [Colors.green, Colors.blue, Colors.purple, Colors.indigo, Colors.teal];
            final tabColor = colors[index];
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                  _searchController.clear();
                  _searchQuery = '';
                });
                _refilterCurrentTab();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                decoration: BoxDecoration(
                  color: isSelected ? tabColor : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? tabColor : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  _tabs[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Search bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by name, email, mobile...',
                hintStyle:
                    TextStyle(fontSize: 14, color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide:
                        const BorderSide(color: Colors.blue, width: 2)),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                isDense: true,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(width: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Filter chips ───────────────────────────────────────────────────────────
  Widget _buildFilterChips() {
    int currentFilter;
    Function(int) onChanged;
    List<Map<String, dynamic>> sourceList;

    switch (_selectedTabIndex) {
      case 0:
        currentFilter = _customerFilterIndex; onChanged = _applyCustomerFilter; sourceList = _allCustomers; break;
      case 1:
        currentFilter = _supportFilterIndex;  onChanged = _applySupportFilter;  sourceList = _allCustomerSupports; break;
      case 2:
        currentFilter = _chemistFilterIndex;  onChanged = _applyChemistFilter;  sourceList = _allMedicalStores; break;
      case 3:
        currentFilter = _managerFilterIndex;  onChanged = _applyManagerFilter;  sourceList = _allManagers; break;
      case 4:
        currentFilter = _deliveryFilterIndex; onChanged = _applyDeliveryFilter; sourceList = _allDeliveryBoys; break;
      default:
        currentFilter = 0; onChanged = (_) {}; sourceList = [];
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip('All',      0, Colors.black, currentFilter, onChanged, sourceList),
            const SizedBox(width: 8),
            _chip('Active',   1, Colors.green, currentFilter, onChanged, sourceList),
            const SizedBox(width: 8),
            _chip('Inactive', 2, Colors.grey,  currentFilter, onChanged, sourceList),
            const SizedBox(width: 8),
            _chip('Deleted',  3, Colors.red,   currentFilter, onChanged, sourceList),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, int idx, Color color, int current,
      Function(int) onChanged, List<Map<String, dynamic>> source) {
    final isSelected = current == idx;
    final count = _filterCount(source, idx);
    return FilterChip(
      label: Text(
        '$label ($count)',
        style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.w600,
            fontSize: 13),
      ),
      selected: isSelected,
      onSelected: (sel) { if (sel) onChanged(idx); },
      backgroundColor: Colors.white,
      selectedColor: color,
      checkmarkColor: Colors.white,
      side: BorderSide(color: color, width: 1.5),
    );
  }

  // ── Content router ─────────────────────────────────────────────────────────
  Widget _buildContent() {
    switch (_selectedTabIndex) {
      case 0: return _buildList(_filteredCustomers,      _buildCustomerCard);
      case 1: return _buildList(_filteredCustomerSupports, _buildCustomerSupportCard);
      case 2: return _buildList(_filteredMedicalStores,  _buildMedicalStoreCard);
      case 3: return _buildList(_filteredManagers,       _buildManagerCard);
      case 4: return _buildList(_filteredDeliveryBoys,   _buildDeliveryBoyCard);
      default: return const SizedBox();
    }
  }

  Widget _buildList(List<Map<String, dynamic>> items,
      Widget Function(Map<String, dynamic>) cardBuilder) {
    if (items.isEmpty) return _buildEmptyState();
    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (_, i) {
          if (i < 0 || i >= items.length) return const SizedBox.shrink();
          return cardBuilder(items[i]);
        },
      ),
    );
  }

  // ── Error / Empty ──────────────────────────────────────────────────────────
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(_errorMessage ?? 'An error occurred',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadAllData, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final labels = ['customers','customer support staff','medical stores','managers','delivery boys'];
    final label  = _selectedTabIndex < labels.length ? labels[_selectedTabIndex] : 'users';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty ? Icons.search_off : Icons.person_outline,
            size: 80, color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No $label found matching "$_searchQuery"'
                : 'No $label found',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (_searchQuery.isNotEmpty)
            ElevatedButton.icon(
              onPressed: _clearSearch,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, foregroundColor: Colors.white),
            )
          else
            ElevatedButton(
              onPressed: _refilterCurrentTab,
              child: const Text('Show All'),
            ),
        ],
      ),
    );
  }

  // ==========================================================================
  // CARD BUILDERS
  // ==========================================================================

  // ── Shared status helpers ──────────────────────────────────────────────────
  _StatusStyle _statusStyle(bool isActive, bool isDeleted, Color activeColor) {
    if (isDeleted) return _StatusStyle(Colors.red.shade800,   Colors.red.shade100,   'Deleted');
    if (isActive)  return _StatusStyle(activeColor,           activeColor.withOpacity(0.15), 'Active');
    return             _StatusStyle(Colors.grey.shade700,  Colors.grey.shade200,  'Inactive');
  }

  Widget _statusBadge(_StatusStyle s) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
        color: s.bg, borderRadius: BorderRadius.circular(12)),
    child: Text(s.label,
        style: TextStyle(
            fontSize: 11, color: s.fg, fontWeight: FontWeight.w600)),
  );

  CircleAvatar _avatar(String letter, Color color) => CircleAvatar(
      backgroundColor: color, child: Text(letter, style: const TextStyle(color: Colors.white)));

  // ── Customer card (unchanged) ──────────────────────────────────────────────
  Widget _buildCustomerCard(Map<String, dynamic> customer) {
    final isActive  = customer['isActive']  ?? false;
    final isDeleted = customer['isDeleted'] ?? false;
    final firstName = customer['customerFirstName'] ?? '';
    final lastName  = customer['customerLastName']  ?? '';
    final mobile    = customer['mobileNumber'] ?? '';
    final email     = customer['emailId']      ?? '';
    final s = _statusStyle(isActive, isDeleted, Colors.green.shade800);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDeleted ? Colors.red.shade50 : null,
      child: ListTile(
        leading: _avatar(
          firstName.isNotEmpty ? firstName[0].toUpperCase() : 'C',
          isDeleted ? Colors.red : (isActive ? Colors.green : Colors.grey),
        ),
        title: Text('$firstName $lastName',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: isDeleted ? TextDecoration.lineThrough : null,
                color: isDeleted ? Colors.grey : null)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 4),
          Text('📱 $mobile', style: TextStyle(color: isDeleted ? Colors.grey : null)),
          if (email.isNotEmpty)
            Text('📧 $email', style: TextStyle(color: isDeleted ? Colors.grey : null)),
          const SizedBox(height: 4),
          _statusBadge(s),
        ]),
        trailing: isDeleted
            ? const Icon(Icons.delete_forever, color: Colors.red)
            : PopupMenuButton(
                itemBuilder: (_) => [
                  _menuItem('delete', Icons.delete, 'Delete', Colors.red),
                ],
                onSelected: (v) {
                  if (v == 'delete') _deleteUser(customer, 'Customer');
                },
              ),
      ),
    );
  }

  // ── Customer Support card (unchanged) ─────────────────────────────────────
  Widget _buildCustomerSupportCard(Map<String, dynamic> support) {
    final isActive  = support['isActive']  ?? false;
    final isDeleted = support['isDeleted'] ?? false;
    final firstName  = support['customerSupportFirstName'] ?? '';
    final lastName   = support['customerSupportLastName']  ?? '';
    final mobile     = support['mobileNumber'] ?? '';
    final employeeId = support['employeeId']   ?? '';
    final s = _statusStyle(isActive, isDeleted, Colors.blue.shade800);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDeleted ? Colors.red.shade50 : null,
      child: ListTile(
        leading: _avatar('S',
            isDeleted ? Colors.red : (isActive ? Colors.blue : Colors.grey)),
        title: Text('$firstName $lastName',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: isDeleted ? TextDecoration.lineThrough : null,
                color: isDeleted ? Colors.grey : null)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 4),
          Text('📱 $mobile', style: TextStyle(color: isDeleted ? Colors.grey : null)),
          Text('🏷️ Emp ID: $employeeId',
              style: TextStyle(color: isDeleted ? Colors.grey : null)),
          const SizedBox(height: 4),
          _statusBadge(s),
        ]),
        trailing: isDeleted
            ? const Icon(Icons.delete_forever, color: Colors.red)
            : PopupMenuButton(
                itemBuilder: (_) => [
                  _menuItem('delete', Icons.delete, 'Delete', Colors.red),
                ],
                onSelected: (v) {
                  if (v == 'delete') _deleteUser(support, 'CustomerSupport');
                },
              ),
      ),
    );
  }

  // ── Medical Store card (unchanged) ────────────────────────────────────────
  Widget _buildMedicalStoreCard(Map<String, dynamic> store) {
    final isActive   = store['isActive']  ?? false;
    final isDeleted  = store['isDeleted'] ?? false;
    final medName    = store['medicalName']   ?? '';
    final ownerFirst = store['ownerFirstName']?? '';
    final ownerLast  = store['ownerLastName'] ?? '';
    final mobile     = store['mobileNumber']  ?? '';
    final city       = store['city']          ?? '';
    final s = _statusStyle(isActive, isDeleted, Colors.purple.shade800);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDeleted ? Colors.red.shade50 : null,
      child: ListTile(
        leading: _avatar('P',
            isDeleted ? Colors.red : (isActive ? Colors.purple : Colors.grey)),
        title: Text(medName,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: isDeleted ? TextDecoration.lineThrough : null,
                color: isDeleted ? Colors.grey : null)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 4),
          Text('👤 Owner: $ownerFirst $ownerLast',
              style: TextStyle(color: isDeleted ? Colors.grey : null)),
          Text('📱 $mobile', style: TextStyle(color: isDeleted ? Colors.grey : null)),
          if (city.isNotEmpty)
            Text('📍 $city', style: TextStyle(color: isDeleted ? Colors.grey : null)),
          const SizedBox(height: 4),
          _statusBadge(s),
        ]),
        trailing: isDeleted
            ? const Icon(Icons.delete_forever, color: Colors.red)
            : PopupMenuButton(
                itemBuilder: (_) => [
                  _menuItem('delete', Icons.delete, 'Delete', Colors.red),
                ],
                onSelected: (v) {
                  if (v == 'delete') _deleteUser(store, 'MedicalStore');
                },
              ),
      ),
    );
  }

  // ── Manager card (NEW) ────────────────────────────────────────────────────
  Widget _buildManagerCard(Map<String, dynamic> manager) {
    final isActive   = manager['isActive']  ?? false;
    final isDeleted  = manager['isDeleted'] ?? false;
    final firstName  = manager['managerFirstName'] ?? '';
    final lastName   = manager['managerLastName']  ?? '';
    final mobile     = manager['mobileNumber']     ?? '';
    final email      = manager['emailId']           ?? '';
    final employeeId = manager['employeeId']        ?? '';
    final city       = manager['city']              ?? '';
    final s = _statusStyle(isActive, isDeleted, Colors.indigo.shade800);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDeleted ? Colors.red.shade50 : null,
      child: ListTile(
        leading: _avatar(
          firstName.isNotEmpty ? firstName[0].toUpperCase() : 'M',
          isDeleted ? Colors.red : (isActive ? Colors.indigo : Colors.grey),
        ),
        title: Text('$firstName $lastName',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: isDeleted ? TextDecoration.lineThrough : null,
                color: isDeleted ? Colors.grey : null)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 4),
          Text('📱 $mobile', style: TextStyle(color: isDeleted ? Colors.grey : null)),
          if (email.isNotEmpty)
            Text('📧 $email', style: TextStyle(color: isDeleted ? Colors.grey : null)),
          if (employeeId.isNotEmpty)
            Text('🏷️ Emp ID: $employeeId',
                style: TextStyle(color: isDeleted ? Colors.grey : null)),
          if (city.isNotEmpty)
            Text('📍 $city', style: TextStyle(color: isDeleted ? Colors.grey : null)),
          const SizedBox(height: 4),
          _statusBadge(s),
        ]),
        trailing: isDeleted
            ? const Icon(Icons.delete_forever, color: Colors.red)
            : PopupMenuButton(
                itemBuilder: (_) => [
                  _menuItem('edit',   Icons.edit,   'Edit',   Colors.blue),
                  _menuItem('delete', Icons.delete, 'Delete', Colors.red),
                ],
                onSelected: (v) {
                  if (v == 'edit')   _editManager(manager);
                  if (v == 'delete') _deleteUser(manager, 'Manager');
                },
              ),
      ),
    );
  }

  // ── Delivery Boy card (NEW) ───────────────────────────────────────────────
  Widget _buildDeliveryBoyCard(Map<String, dynamic> boy) {
    final isActive  = boy['isActive']  ?? false;
    final isDeleted = boy['isDeleted'] ?? false;
    final firstName = boy['firstName'] ?? '';
    final lastName  = boy['lastName']  ?? '';
    final mobile    = boy['mobileNumber']         ?? '';
    final licence   = boy['drivingLicenceNumber'] ?? '';
    final storeId   = boy['medicalStoreId'];
    final storeName = storeId != null
        ? (_medicalStoresForDropdown
                .where((s) => s['medicalStoreId']?.toString() == storeId.toString())
                .map((s) => s['medicalName'] as String? ?? storeId.toString())
                .firstOrNull ??
            storeId.toString())
        : null;
    final s = _statusStyle(isActive, isDeleted, Colors.teal.shade800);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDeleted ? Colors.red.shade50 : null,
      child: ListTile(
        leading: _avatar(
          firstName.isNotEmpty ? firstName[0].toUpperCase() : 'D',
          isDeleted ? Colors.red : (isActive ? Colors.teal : Colors.grey),
        ),
        title: Text('$firstName $lastName',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: isDeleted ? TextDecoration.lineThrough : null,
                color: isDeleted ? Colors.grey : null)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 4),
          Text('📱 $mobile', style: TextStyle(color: isDeleted ? Colors.grey : null)),
          if (licence.isNotEmpty)
            Text('🪪 DL: $licence',
                style: TextStyle(color: isDeleted ? Colors.grey : null)),
          if (storeName != null)
            Text('🏥 $storeName',
                style: TextStyle(color: isDeleted ? Colors.grey : null)),
          const SizedBox(height: 4),
          _statusBadge(s),
        ]),
        trailing: isDeleted
            ? const Icon(Icons.delete_forever, color: Colors.red)
            : PopupMenuButton(
                itemBuilder: (_) => [
                  _menuItem('edit',   Icons.edit,   'Edit',   Colors.blue),
                  _menuItem('delete', Icons.delete, 'Delete', Colors.red),
                ],
                onSelected: (v) {
                  if (v == 'edit')   _editDeliveryBoy(boy);
                  if (v == 'delete') _deleteUser(boy, 'DeliveryBoy');
                },
              ),
      ),
    );
  }

  // ── Shared popup menu item ─────────────────────────────────────────────────
  PopupMenuItem _menuItem(String value, IconData icon, String label, Color color) {
    return PopupMenuItem(
      value: value,
      child: Row(children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color)),
      ]),
    );
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating));
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating));
    }
  }
}

// ============================================================================
// STATUS STYLE HELPER
// ============================================================================

class _StatusStyle {
  final Color fg;
  final Color bg;
  final String label;
  _StatusStyle(this.fg, this.bg, this.label);
}

// ============================================================================
// REUSABLE EDIT BOTTOM SHEET
// Accepts a list of pre-built field widgets so each edit call only defines
// what's different, while the sheet chrome (drag handle, title, Save button)
// is always consistent.
// ============================================================================

class _EditSheet extends StatefulWidget {
  final String title;
  final GlobalKey<FormState> formKey;
  final Future<bool> Function() onSave;
  final List<Widget> fields;

  const _EditSheet({
    required this.title,
    required this.formKey,
    required this.onSave,
    required this.fields,
  });

  // ── Static factory helpers so callers can build fields concisely ──────────
  static Widget field(
    TextEditingController ctrl,
    String label, {
    bool required = false,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey.shade50,
          isDense: true,
        ),
        validator: validator ??
            (required
                ? (v) => (v == null || v.trim().isEmpty)
                    ? '$label is required'
                    : null
                : null),
      ),
    );
  }

  static Widget row(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Row(
        children: children
            .map((w) => Expanded(child: w))
            .toList()
            .expand((w) => [w, const SizedBox(width: 12)])
            .toList()
          ..removeLast(),
      ),
    );
  }

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  bool _saving = false;
  String? _error;

  Future<void> _handleSave() async {
    setState(() { _saving = true; _error = null; });
    try {
      final ok = await widget.onSave();
      if (!mounted) return;
      if (ok) {
        Navigator.pop(context, true);
      } else {
        setState(() { _saving = false; _error = 'Update failed. Please try again.'; });
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      String msg = 'Update failed';
      if (data is Map) {
        msg = data['error']?.toString() ??
              data['errors']?.toString() ??
              data['message']?.toString() ??
              msg;
      }
      setState(() { _saving = false; _error = msg; });
    } catch (e) {
      setState(() { _saving = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.96,
      minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            // Title row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
              child: Row(
                children: [
                  Text(widget.title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close)),
                ],
              ),
            ),
            const Divider(height: 20),
            // Scrollable form
            Expanded(
              child: SingleChildScrollView(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Form(
                  key: widget.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error banner
                      if (_error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_error!,
                                style: const TextStyle(color: Colors.red))),
                          ]),
                        ),
                      ],
                      // Fields
                      ...widget.fields,
                      const SizedBox(height: 16),
                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            disabledBackgroundColor: Colors.black45,
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 22, height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Text('Save Changes',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}