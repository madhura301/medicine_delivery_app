// Admin All Orders Page
// Shows all orders in the system with filtering and search capabilities

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:pharmaish/core/screens/admin/admin_order_details.dart' show AdminOrderDetailsPage;
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:pharmaish/config/environment_config.dart';
import 'package:pharmaish/shared/models/order_model.dart';

class AdminAllOrders extends StatefulWidget {
  const AdminAllOrders({Key? key}) : super(key: key);

  @override
  State<AdminAllOrders> createState() => _AdminAllOrdersState();
}

class _AdminAllOrdersState extends State<AdminAllOrders> {
  List<OrderModel> _allOrders = [];
  List<OrderModel> _filteredOrders = [];
  bool _isLoading = true;
  String? _errorMessage;
  late Dio _dio;
  int _selectedFilterIndex = 0;

  // Customer info cache
  final Map<String, Map<String, String>> _customerCache = {};
  final Map<String, Map<String, String>> _chemistCache = {};

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _setupDio();
    _loadAllOrders();
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
      onError: (error, handler) {
        if (EnvironmentConfig.shouldLog) {
          AppLogger.error('API Error: ${error.message}');
          AppLogger.error('Status Code: ${error.response?.statusCode}');
          AppLogger.error('Response Data: ${error.response?.data}');
        }
        handler.next(error);
      },
    ));
  }

  Future<void> _loadAllOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      AppLogger.info('Fetching all orders for admin');

      final response = await _dio.get('/Orders');

      if (response.statusCode == 200) {
        final data = response.data;

        List<dynamic> ordersList;
        if (data is List) {
          ordersList = data;
        } else if (data is Map && data.containsKey('data')) {
          ordersList = data['data'] as List;
        } else if (data is Map && data.containsKey('orders')) {
          ordersList = data['orders'] as List;
        } else {
          throw Exception('Unexpected response format');
        }

        AppLogger.info('Received ${ordersList.length} orders');

        final allOrders = ordersList.map((json) {
          return OrderModel.fromJson(json);
        }).toList();

        // Sort by date (most recent first)
        allOrders.sort((a, b) => b.createdOn.compareTo(a.createdOn));

        // Load customer and chemist info
        await _loadAdditionalInfo(allOrders);

        setState(() {
          _allOrders = allOrders;
          _isLoading = false;
        });

        _filterOrders();
      }
    } on DioException catch (e) {
      AppLogger.error('Error loading orders', e);

      String errorMsg = 'Failed to load orders';
      if (e.response?.statusCode == 401) {
        errorMsg = 'Authentication failed. Please login again.';
        await StorageService.clearAll();
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
        return;
      } else if (e.response?.statusCode == 404) {
        errorMsg = 'Orders endpoint not found. Please contact administrator.';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMsg = 'Connection timeout. Please check your internet.';
      }

      setState(() {
        _errorMessage = errorMsg;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Unexpected error', e);
      setState(() {
        _errorMessage = 'An unexpected error occurred: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAdditionalInfo(List<OrderModel> orders) async {
    for (var order in orders) {
      // Load customer info
      if (!_customerCache.containsKey(order.customerId)) {
        try {
          final response = await _dio.get('/Customers/${order.customerId}');
          if (response.statusCode == 200) {
            final customerData = response.data;
            _customerCache[order.customerId] = {
              'name':
                  '${customerData['customerFirstName'] ?? ''} ${customerData['customerLastName'] ?? ''}'
                      .trim(),
              'email': customerData['emailId']?.toString() ?? '',
              'phone': customerData['mobileNumber']?.toString() ?? '',
            };
          }
        } catch (e) {
          _customerCache[order.customerId] = {
            'name': 'Customer',
            'email': '',
            'phone': '',
          };
        }
      }

      // Load chemist info if assigned
      if (order.medicalStoreId != null &&
          !_chemistCache.containsKey(order.medicalStoreId!)) {
        try {
          final response =
              await _dio.get('/MedicalStores/${order.medicalStoreId}');
          if (response.statusCode == 200) {
            final chemistData = response.data;
            _chemistCache[order.medicalStoreId!] = {
              'name': chemistData['medicalName']?.toString() ?? 'Chemist',
              'phone': chemistData['mobileNumber']?.toString() ?? '',
            };
          }
        } catch (e) {
          _chemistCache[order.medicalStoreId!] = {
            'name': 'Chemist',
            'phone': '',
          };
        }
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterOrders();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
    _filterOrders();
  }

  void _applyFilter(int index) {
    setState(() {
      _selectedFilterIndex = index;
    });
    _filterOrders();
  }

  void _filterOrders() {
    List<OrderModel> filtered;

    // Apply status filter
    switch (_selectedFilterIndex) {
      case 0: // All
        filtered = List.from(_allOrders);
        break;
      case 1: // Pending
        filtered = _allOrders
            .where((o) =>
                o.status.toLowerCase().contains('pending') ||
                o.status.toLowerCase().contains('assigned'))
            .toList();
        break;
      case 2: // Accepted
        filtered = _allOrders
            .where((o) =>
                o.status.toLowerCase().contains('accepted') ||
                o.status.toLowerCase().contains('bill') ||
                o.status.toLowerCase().contains('delivery'))
            .toList();
        break;
      case 3: // Completed
        filtered = _allOrders
            .where((o) => o.status.toLowerCase().contains('completed'))
            .toList();
        break;
      case 4: // Rejected
        filtered = _allOrders
            .where((o) => o.status.toLowerCase().contains('rejected'))
            .toList();
        break;
      default:
        filtered = List.from(_allOrders);
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();

      filtered = filtered.where((order) {
        // Basic order fields (always available)
        if (order.orderId.toLowerCase().contains(query)) return true;
        if ((order.orderNumber ?? '').toLowerCase().contains(query))
          return true;
        if ((order.shippingAddressLine1 ?? '').toLowerCase().contains(query))
          return true;
        if ((order.shippingCity ?? '').toLowerCase().contains(query))
          return true;
        if ((order.shippingArea ?? '').toLowerCase().contains(query))
          return true;

        // Customer info (if cached)
        if (_customerCache.containsKey(order.customerId)) {
          final customerData = _customerCache[order.customerId]!;
          if ((customerData['name'] ?? '').toLowerCase().contains(query))
            return true;
          if ((customerData['email'] ?? '').toLowerCase().contains(query))
            return true;
          if ((customerData['phone'] ?? '').toLowerCase().contains(query))
            return true;
        }

        // Chemist info (if cached)
        if (order.medicalStoreId != null &&
            _chemistCache.containsKey(order.medicalStoreId)) {
          final chemistData = _chemistCache[order.medicalStoreId]!;
          if ((chemistData['name'] ?? '').toLowerCase().contains(query))
            return true;
          if ((chemistData['phone'] ?? '').toLowerCase().contains(query))
            return true;
        }

        return false;
      }).toList();
    }

    setState(() {
      _filteredOrders = filtered;
    });

    AppLogger.info(
        'Filter $_selectedFilterIndex with search "$_searchQuery": ${_filteredOrders.length} orders');
  }

  String getCustomerName(OrderModel order) {
    return _customerCache[order.customerId]?['name'] ?? 'Customer';
  }

  String? getCustomerEmail(OrderModel order) {
    final email = _customerCache[order.customerId]?['email'];
    return (email != null && email.isNotEmpty) ? email : null;
  }

  String getChemistName(OrderModel order) {
    if (order.medicalStoreId == null) return 'Not Assigned';
    return _chemistCache[order.medicalStoreId]?['name'] ?? 'Chemist';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Orders', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAllOrders,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(child: _buildBody()),
        ],
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
                hintText: 'Search by customer, phone, order ID, address...',
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
                  borderSide: const BorderSide(color: Colors.black, width: 2),
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
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.filter_list, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    '${_filteredOrders.length}',
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

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(12),
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
            _buildFilterChip('All', 0, Colors.black),
            const SizedBox(width: 8),
            _buildFilterChip('Pending', 1, Colors.orange),
            const SizedBox(width: 8),
            _buildFilterChip('Accepted', 2, Colors.green),
            const SizedBox(width: 8),
            _buildFilterChip('Completed', 3, Colors.blue),
            const SizedBox(width: 8),
            _buildFilterChip('Rejected', 4, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, Color color) {
    final isSelected = _selectedFilterIndex == index;
    final count = _getFilterCount(index);

    return FilterChip(
      label: Text(
        '$label ($count)',
        style: TextStyle(
          color: isSelected ? Colors.white : color,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _applyFilter(index);
        }
      },
      backgroundColor: Colors.white,
      selectedColor: color,
      checkmarkColor: Colors.white,
      side: BorderSide(color: color, width: 1.5),
    );
  }

  int _getFilterCount(int index) {
    try {
      switch (index) {
        case 0:
          return _allOrders.length;
        case 1:
          return _allOrders
              .where((o) =>
                  o.status.toLowerCase().contains('pending') ||
                  o.status.toLowerCase().contains('assigned'))
              .length;
        case 2:
          return _allOrders
              .where((o) =>
                  o.status.toLowerCase().contains('accepted') ||
                  o.status.toLowerCase().contains('bill') ||
                  o.status.toLowerCase().contains('delivery'))
              .length;
        case 3:
          return _allOrders
              .where((o) => o.status.toLowerCase().contains('completed'))
              .length;
        case 4:
          return _allOrders
              .where((o) => o.status.toLowerCase().contains('rejected'))
              .length;
        default:
          return 0;
      }
    } catch (e) {
      AppLogger.error('Error calculating filter count: $e');
      return 0;
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.black),
            SizedBox(height: 16),
            Text('Loading orders...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error Loading Orders',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadAllOrders,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Check if filtered orders is empty
    if (_filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty
                  ? Icons.search_off
                  : Icons.inbox_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No orders found matching "$_searchQuery"'
                  : _getEmptyStateMessage(),
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try different search terms'
                  : 'Try selecting a different filter',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _clearSearch,
                icon: const Icon(Icons.clear),
                label: const Text('Clear Search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _filteredOrders.length,
        itemBuilder: (context, index) {
          if (index < 0 || index >= _filteredOrders.length) {
            return const SizedBox.shrink();
          }
          final order = _filteredOrders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  String _getEmptyStateMessage() {
    switch (_selectedFilterIndex) {
      case 0:
        return 'No orders found';
      case 1:
        return 'No pending orders';
      case 2:
        return 'No accepted orders';
      case 3:
        return 'No completed orders';
      case 4:
        return 'No rejected orders';
      default:
        return 'No orders found';
    }
  }

  Widget _buildOrderCard(OrderModel order) {
    // Safe order ID display
    String getSafeOrderId() {
      if (order.orderNumber != null && order.orderNumber!.isNotEmpty) {
        return order.orderNumber!;
      }

      final orderId = order.orderId;
      if (orderId.length <= 8) {
        return orderId;
      }
      return orderId.substring(0, 8);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to order details
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AdminOrderDetailsPage(order: order),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${getSafeOrderId()}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          getCustomerName(order),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),

              // Details
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          Icons.local_pharmacy,
                          'Chemist',
                          getChemistName(order),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Date',
                          DateFormat('MMM dd, yyyy').format(order.createdOn),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          Icons.list_alt,
                          'Type',
                          order.orderInputTypeDisplayName ?? 'N/A',
                        ),
                        const SizedBox(height: 8),
                        if (order.totalAmount != null)
                          _buildInfoRow(
                            Icons.currency_rupee,
                            'Amount',
                            '₹${order.totalAmount!.toStringAsFixed(2)}',
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              // View Details indicator
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Tap to view details',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.blue[700],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String statusText = status;

    final statusLower = status.toLowerCase();
    if (statusLower.contains('pending') || statusLower.contains('assigned')) {
      chipColor = Colors.orange;
      statusText = 'Pending';
    } else if (statusLower.contains('accepted')) {
      chipColor = Colors.green;
      statusText = 'Accepted';
    } else if (statusLower.contains('rejected')) {
      chipColor = Colors.red;
      statusText = 'Rejected';
    } else if (statusLower.contains('completed')) {
      chipColor = Colors.blue;
      statusText = 'Completed';
    } else {
      chipColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor, width: 1),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}