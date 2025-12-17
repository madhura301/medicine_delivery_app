// Customer All Orders Page
// Shows all orders for the logged-in customer with filtering

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:pharmaish/config/environment_config.dart';
import 'package:pharmaish/shared/models/order_model.dart';
import 'package:pharmaish/core/theme/app_theme.dart';

class CustomerAllOrders extends StatefulWidget {
  const CustomerAllOrders({Key? key}) : super(key: key);

  @override
  State<CustomerAllOrders> createState() => _CustomerAllOrdersState();
}

class _CustomerAllOrdersState extends State<CustomerAllOrders> {
  List<OrderModel> _allOrders = [];
  List<OrderModel> _filteredOrders = [];
  bool _isLoading = true;
  String? _errorMessage;
  late Dio _dio;
  int _selectedFilterIndex = 0;
  String _customerId = '';

  // Chemist info cache
  final Map<String, Map<String, String>> _chemistCache = {};

  @override
  void initState() {
    super.initState();
    _setupDio();
    _loadCustomerIdAndOrders();
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

  Future<void> _loadCustomerIdAndOrders() async {
    try {
      final customerId = await StorageService.getUserId();
      if (customerId == null || customerId.isEmpty) {
        setState(() {
          _errorMessage = 'Customer ID not found. Please login again.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _customerId = customerId;
      });

      await _loadAllOrders();
    } catch (e) {
      AppLogger.error('Error loading customer ID', e);
      setState(() {
        _errorMessage = 'Error loading customer information';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAllOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      AppLogger.info('Fetching all orders for customer: $_customerId');

      // GET /api/Orders/customer/{customerId}
      final response = await _dio.get('/Orders/customer/$_customerId');

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

        // Load chemist info
        await _loadChemistInfo(allOrders);

        setState(() {
          _allOrders = allOrders;
          _filteredOrders = allOrders;
          _isLoading = false;
        });

        _applyFilter(_selectedFilterIndex);
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
        errorMsg = 'No orders found';
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

  Future<void> _loadChemistInfo(List<OrderModel> orders) async {
    for (var order in orders) {
      if (order.medicalStoreId != null &&
          !_chemistCache.containsKey(order.medicalStoreId!)) {
        try {
          final response =
              await _dio.get('/MedicalStores/${order.medicalStoreId}');
          if (response.statusCode == 200) {
            final chemistData = response.data;
            _chemistCache[order.medicalStoreId!] = {
              'name': chemistData['pharmacyName']?.toString() ?? 'Chemist',
              'phone': chemistData['mobileNumber']?.toString() ?? '',
              'address': chemistData['address']?.toString() ?? '',
            };
          }
        } catch (e) {
          _chemistCache[order.medicalStoreId!] = {
            'name': 'Chemist',
            'phone': '',
            'address': '',
          };
        }
      }
    }
  }

  void _applyFilter(int index) {
    setState(() {
      _selectedFilterIndex = index;

      switch (index) {
        case 0: // All
          _filteredOrders = _allOrders;
          break;
        case 1: // Active (Pending + Accepted)
          _filteredOrders = _allOrders
              .where((o) =>
                  o.status.toLowerCase().contains('pending') ||
                  o.status.toLowerCase().contains('assigned') ||
                  o.status.toLowerCase().contains('accepted') ||
                  o.status.toLowerCase().contains('bill') ||
                  o.status.toLowerCase().contains('delivery'))
              .toList();
          break;
        case 2: // Pending
          _filteredOrders = _allOrders
              .where((o) =>
                  o.status.toLowerCase().contains('pending') ||
                  o.status.toLowerCase().contains('assigned'))
              .toList();
          break;
        case 3: // Completed
          _filteredOrders = _allOrders
              .where((o) => o.status.toLowerCase().contains('completed'))
              .toList();
          break;
        case 4: // Rejected
          _filteredOrders = _allOrders
              .where((o) => o.status.toLowerCase().contains('rejected'))
              .toList();
          break;
      }
    });
  }

  String getChemistName(OrderModel order) {
    if (order.medicalStoreId == null) return 'Not Assigned Yet';
    return _chemistCache[order.medicalStoreId]?['name'] ?? 'Chemist';
  }

  String? getChemistPhone(OrderModel order) {
    if (order.medicalStoreId == null) return null;
    final phone = _chemistCache[order.medicalStoreId]?['phone'];
    return (phone != null && phone.isNotEmpty) ? phone : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,
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
          _buildFilterChips(),
          Expanded(child: _buildBody()),
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
            _buildFilterChip('All', 0, AppTheme.primaryColor),
            const SizedBox(width: 8),
            _buildFilterChip('Active', 1, Colors.blue),
            const SizedBox(width: 8),
            _buildFilterChip('Pending', 2, Colors.orange),
            const SizedBox(width: 8),
            _buildFilterChip('Completed', 3, Colors.green),
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
      onSelected: (selected) => _applyFilter(index),
      backgroundColor: Colors.white,
      selectedColor: color,
      checkmarkColor: Colors.white,
      side: BorderSide(color: color, width: 1.5),
    );
  }

  int _getFilterCount(int index) {
    switch (index) {
      case 0:
        return _allOrders.length;
      case 1: // Active
        return _allOrders
            .where((o) =>
                o.status.toLowerCase().contains('pending') ||
                o.status.toLowerCase().contains('assigned') ||
                o.status.toLowerCase().contains('accepted') ||
                o.status.toLowerCase().contains('bill') ||
                o.status.toLowerCase().contains('delivery'))
            .length;
      case 2: // Pending
        return _allOrders
            .where((o) =>
                o.status.toLowerCase().contains('pending') ||
                o.status.toLowerCase().contains('assigned'))
            .length;
      case 3: // Completed
        return _allOrders
            .where((o) => o.status.toLowerCase().contains('completed'))
            .length;
      case 4: // Rejected
        return _allOrders
            .where((o) => o.status.toLowerCase().contains('rejected'))
            .length;
      default:
        return 0;
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryColor),
            SizedBox(height: 16),
            Text('Loading your orders...'),
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
                  backgroundColor: AppTheme.primaryColor,
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

    if (_filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined,
                size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _selectedFilterIndex == 0
                  ? 'No orders yet'
                  : 'No ${_getFilterLabel(_selectedFilterIndex).toLowerCase()} orders',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            if (_selectedFilterIndex == 0)
              Text(
                'Place your first order to get started!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
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
          final order = _filteredOrders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  String _getFilterLabel(int index) {
    switch (index) {
      case 0:
        return 'All';
      case 1:
        return 'Active';
      case 2:
        return 'Pending';
      case 3:
        return 'Completed';
      case 4:
        return 'Rejected';
      default:
        return '';
    }
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _showOrderDetails(order);
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
                          'Order #${order.orderId}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM dd, yyyy • hh:mm a')
                              .format(order.createdOn),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    Icons.local_pharmacy,
                    'Pharmacy',
                    getChemistName(order),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.list_alt,
                    'Order Type',
                    _getOrderTypeLabel(order.orderInputTypeDisplayName),
                  ),
                  if (order.totalAmount != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.currency_rupee,
                      'Amount',
                      '₹${order.totalAmount!.toStringAsFixed(2)}',
                    ),
                  ],
                  if (getChemistPhone(order) != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.phone,
                      'Pharmacy Phone',
                      getChemistPhone(order)!,
                    ),
                  ],
                ],
              ),

              // Action button for active orders
              if (!order.status.toLowerCase().contains('completed') &&
                  !order.status.toLowerCase().contains('rejected')) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showOrderDetails(order),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('View Details'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
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
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
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
      chipColor = Colors.blue;
      statusText = 'Accepted';
    } else if (statusLower.contains('rejected')) {
      chipColor = Colors.red;
      statusText = 'Rejected';
    } else if (statusLower.contains('completed')) {
      chipColor = Colors.green;
      statusText = 'Completed';
    } else if (statusLower.contains('delivery')) {
      chipColor = Colors.purple;
      statusText = 'Out for Delivery';
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

  String _getOrderTypeLabel(String? type) {
    if (type == null) return 'N/A';
    switch (type.toLowerCase()) {
      case 'upload':
        return '📄 Upload';
      case 'camera':
        return '📷 Camera';
      case 'voice':
        return '🎤 Voice';
      case 'whatsapp':
        return '💬 WhatsApp';
      default:
        return type;
    }
  }

  void _showOrderDetails(OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order.orderId}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildStatusChip(order.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('MMMM dd, yyyy • hh:mm a')
                      .format(order.createdOn),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Order Details
                _buildDetailSection('Order Information', [
                  _buildDetailRow('Order ID', order.orderId.toString()),
                  _buildDetailRow('Order Type',
                      _getOrderTypeLabel(order.orderInputTypeDisplayName)),
                  _buildDetailRow('Status', order.status),
                  if (order.totalAmount != null)
                    _buildDetailRow('Amount',
                        '₹${order.totalAmount!.toStringAsFixed(2)}'),
                ]),

                const SizedBox(height: 20),

                // Pharmacy Details
                _buildDetailSection('Pharmacy Details', [
                  _buildDetailRow('Name', getChemistName(order)),
                  if (getChemistPhone(order) != null)
                    _buildDetailRow('Phone', getChemistPhone(order)!),
                ]),

                const SizedBox(height: 20),

                // Delivery Address
                if (order.shippingAddressLine1 != null) ...[
                  _buildDetailSection('Delivery Address', [
                    _buildDetailRow('Address', order.shippingAddressLine1! + (order.shippingAddressLine2 != null ? ', ' + order.shippingAddressLine2! : '')),
                  ]),
                  const SizedBox(height: 20),
                ],

                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}