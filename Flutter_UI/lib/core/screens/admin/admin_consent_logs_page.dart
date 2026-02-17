import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:pharmaish/config/environment_config.dart';

class AdminConsentLogsPage extends StatefulWidget {
  const AdminConsentLogsPage({Key? key}) : super(key: key);

  @override
  State<AdminConsentLogsPage> createState() => _AdminConsentLogsPageState();
}

class _AdminConsentLogsPageState extends State<AdminConsentLogsPage> {
  late Dio _dio;

  List<Map<String, dynamic>> _allLogs = [];
  List<Map<String, dynamic>> _filteredLogs = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _totalConsents = 0;
  int _loadedConsents = 0;
  // Filters
  String? _selectedUserType;
  String? _selectedAction;
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final List<String> _userTypes = [
    'Customer',
    'Chemist',
    'CustomerSupport',
    'Delivery',
    'Admin', // ✨ ADD THIS
  ];
  @override
  void initState() {
    super.initState();
    _setupDio();
    _loadConsentLogs();
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
    ));
  }

  Future<void> _loadConsentLogs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _totalConsents = 0;
      _loadedConsents = 0;
    });

    try {
      // Step 1: Fetch all consents
      final consentsResponse = await _dio.get('/Consents');

      if (consentsResponse.statusCode != 200) {
        throw Exception('Failed to load consents');
      }

      final consents = (consentsResponse.data as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      setState(() {
        _totalConsents = consents.length;
      });

      AppLogger.info('Loading logs from ${consents.length} consents...');

      // Step 2: Fetch logs sequentially with progress updates
      final List<Map<String, dynamic>> allLogs = [];

      for (var consent in consents) {
        final consentId = consent['consentId'];
        if (consentId == null) {
          setState(() => _loadedConsents++);
          continue;
        }

        try {
          final logsResponse = await _dio.get('/Consents/$consentId/logs');

          if (logsResponse.statusCode == 200 && logsResponse.data is List) {
            final consentLogs = (logsResponse.data as List).map((e) {
              final log = Map<String, dynamic>.from(e);
              if (log['consent'] == null) {
                log['consent'] = consent;
              }
              return log;
            }).toList();

            allLogs.addAll(consentLogs);
          }
        } catch (e) {
          AppLogger.error('Error fetching logs for consent $consentId: $e');
        }

        // Update progress
        setState(() => _loadedConsents++);
      }

      setState(() {
        _allLogs = allLogs;
        _isLoading = false;
      });

      AppLogger.info('Total logs loaded: ${_allLogs.length}');
      _applyFilters();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e is DioException
            ? (e.response?.statusCode == 403
                ? 'Access denied'
                : 'Failed to load logs')
            : 'An error occurred';
      });
      AppLogger.error('Error: $e');
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredLogs = _allLogs.where((log) {
        // Filter by user type
        if (_selectedUserType != null) {
          final userType = _getUserTypeFromLog(log);
          if (userType != _selectedUserType) return false;
        }

        // Filter by action
        if (_selectedAction != null) {
          final action = _getActionFromLog(log);
          if (action != _selectedAction) return false;
        }

        // Filter by date range
        if (_startDate != null || _endDate != null) {
          final createdOn = log['createdOn'] != null
              ? DateTime.parse(log['createdOn'])
              : null;
          if (createdOn != null) {
            if (_startDate != null && createdOn.isBefore(_startDate!))
              return false;
            if (_endDate != null &&
                createdOn.isAfter(_endDate!.add(const Duration(days: 1))))
              return false;
          }
        }

        // Filter by search query
        if (_searchQuery.isNotEmpty) {
          final userId = log['userId']?.toString().toLowerCase() ?? '';
          final consentName =
              log['consent']?['name']?.toString().toLowerCase() ?? '';
          final searchLower = _searchQuery.toLowerCase();
          if (!userId.contains(searchLower) &&
              !consentName.contains(searchLower)) return false;
        }

        return true;
      }).toList();

      // Sort by date (newest first)
      _filteredLogs.sort((a, b) {
        final aDate = a['createdOn'] != null
            ? DateTime.parse(a['createdOn'])
            : DateTime.now();
        final bDate = b['createdOn'] != null
            ? DateTime.parse(b['createdOn'])
            : DateTime.now();
        return bDate.compareTo(aDate);
      });
    });
  }

  String _getUserTypeFromLog(Map<String, dynamic> log) {
    final userType = log['userType'];
    if (userType == null) return 'Unknown';

    if (userType is int) {
      switch (userType) {
        case 0:
          return 'Customer';
        case 1:
          return 'Chemist';
        case 2:
          return 'CustomerSupport';
        case 3:
          return 'Delivery';
        case 4:
          return 'Admin'; // ✨ ADD THIS
        default:
          return 'Unknown';
      }
    }

    // Handle string values too
    final typeStr = userType.toString();
    if (typeStr == 'Customer' || typeStr == '0') return 'Customer';
    if (typeStr == 'Chemist' || typeStr == '1') return 'Chemist';
    if (typeStr == 'CustomerSupport' || typeStr == '2')
      return 'CustomerSupport';
    if (typeStr == 'Delivery' || typeStr == '3') return 'Delivery';
    if (typeStr == 'Admin' || typeStr == '4') return 'Admin'; // ✨ ADD THIS

    return 'Unknown';
  }

  String _getActionFromLog(Map<String, dynamic> log) {
    final action = log['action'];
    if (action == null) return 'Unknown';

    if (action is int) {
      // ✨ FIXED: 0 = Accept, 1 = Reject
      return action == 1 ? 'Accept' : 'Reject';
    }

    // Handle string values
    final actionStr = action.toString().toLowerCase();
    if (actionStr == 'accept' || actionStr == '1') return 'Accept';
    if (actionStr == 'reject' || actionStr == '2') return 'Reject';

    return 'Unknown';
  }

  void _clearFilters() {
    setState(() {
      _selectedUserType = null;
      _selectedAction = null;
      _startDate = null;
      _endDate = null;
      _searchQuery = '';
      _searchController.clear();
    });
    _applyFilters();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: const Text(
          'Consent Logs',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadConsentLogs,
              tooltip: 'Refresh'),
        ],
      ),
      body: Column(
        children: [
          _buildFiltersSection(),
          if (!_isLoading) _buildStatsBar(),
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Loading consent logs...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        if (_totalConsents > 0) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Processing $_loadedConsents of $_totalConsents consents',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 200,
                            child: LinearProgressIndicator(
                              value: _totalConsents > 0
                                  ? _loadedConsents / _totalConsents
                                  : null,
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : _errorMessage != null
                    ? _buildErrorView()
                    : _filteredLogs.isEmpty
                        ? _buildEmptyView()
                        : _buildLogsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by User ID or Consent Name...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                        _applyFilters();
                      },
                    )
                  : null,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade50,
              isDense: true,
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
              _applyFilters();
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  'User Type',
                  _selectedUserType,
                  ['Customer', 'Chemist', 'CustomerSupport', 'Delivery'],
                  (value) {
                    setState(() => _selectedUserType = value);
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Action',
                  _selectedAction,
                  ['Accept', 'Reject'],
                  (value) {
                    setState(() => _selectedAction = value);
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _selectDateRange,
                  icon: const Icon(Icons.date_range, size: 18),
                  label: Text(
                    _startDate != null && _endDate != null
                        ? '${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d').format(_endDate!)}'
                        : 'Date Range',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                if (_selectedUserType != null ||
                    _selectedAction != null ||
                    _startDate != null ||
                    _searchQuery.isNotEmpty)
                  IconButton(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear_all),
                    tooltip: 'Clear Filters',
                    color: Colors.red,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? selected, List<String> options,
      Function(String?) onSelected) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected != null ? Colors.blue.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected != null ? Colors.blue : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selected ?? label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    selected != null ? FontWeight.w600 : FontWeight.normal,
                color: selected != null ? Colors.blue.shade700 : Colors.black87,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down,
                size: 18,
                color:
                    selected != null ? Colors.blue.shade700 : Colors.black54),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(value: null, child: Text('All $label')),
        ...options.map((opt) => PopupMenuItem(value: opt, child: Text(opt))),
      ],
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Text(
            'Showing ${_filteredLogs.length} of ${_allLogs.length} logs',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade900),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList() {
    return RefreshIndicator(
      onRefresh: _loadConsentLogs,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredLogs.length,
        itemBuilder: (context, index) => _buildLogCard(_filteredLogs[index]),
      ),
    );
  }

  Widget _buildLogCard(Map<String, dynamic> log) {
    final action = _getActionFromLog(log);
    final userType = _getUserTypeFromLog(log);
    final consentName = log['consent']?['title'] ??
        log['consent']?['description'] ??
        'Unknown Consent'; // ✨ Use 'title' field
    final createdOn = log['createdOn'] != null
        ? DateTime.parse(log['createdOn'])
        : DateTime.now();
    final userId = log['userId']?.toString() ?? '';
    final ipAddress = log['ipAddress']?.toString() ?? '';
    final userAgent = log['userAgent']?.toString() ?? '';
    final isAccept = action == 'Accept';
    final actionColor = isAccept ? Colors.green : Colors.red;
    final actionIcon = isAccept ? Icons.check_circle : Icons.cancel;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: actionColor.withOpacity(0.2),
          child: Icon(actionIcon, color: actionColor, size: 24),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(consentName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            _buildUserTypeBadge(userType),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(isAccept ? Icons.check : Icons.close,
                    size: 14, color: actionColor),
                const SizedBox(width: 4),
                Text(action,
                    style: TextStyle(
                        color: actionColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                const Spacer(),
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(DateFormat('MMM d, yyyy • h:mm a').format(createdOn),
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(Icons.fingerprint, 'Log ID',
                    log['consentLogId']?.toString() ?? 'N/A'),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.person, 'User ID', userId),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.computer, 'IP Address', ipAddress),
                const SizedBox(height: 8),
                 _buildDetailRow(Icons.computer, 'User Agent', userAgent),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.devices, 'Device',
                    log['deviceInfo']?.toString() ?? 'Not provided'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeBadge(String userType) {
    Color color;
    IconData icon;
    String label;

    switch (userType) {
      case 'Customer':
        color = Colors.blue;
        icon = Icons.person;
        label = 'Customer';
        break;
      case 'Chemist':
        color = Colors.purple;
        icon = Icons.medication;
        label = 'Chemist';
        break;
      case 'CustomerSupport':
        color = Colors.orange;
        icon = Icons.support_agent;
        label = 'Support'; // Shorter label
        break;
      case 'Delivery':
        color = Colors.teal;
        icon = Icons.delivery_dining;
        label = 'Delivery';
        break;
      case 'Admin': // ✨ ADD THIS CASE
        color = Colors.red;
        icon = Icons.admin_panel_settings;
        label = 'Admin';
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
        label = userType;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No consent logs found',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          Text('Try adjusting your filters',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(_errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.red.shade700)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadConsentLogs,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}
