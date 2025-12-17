// Rejected Orders Screen - Customer Support
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pharmaish/core/theme/app_theme.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:intl/intl.dart';

class RejectedOrdersScreen extends StatefulWidget {
  const RejectedOrdersScreen({super.key});

  @override
  State<RejectedOrdersScreen> createState() => _RejectedOrdersScreenState();
}

class _RejectedOrdersScreenState extends State<RejectedOrdersScreen> {
  bool _isLoading = false;
  bool _isReassigning = false;
  List<dynamic> _rejectedOrders = [];
  List<dynamic> _medicalStores = [];

  @override
  void initState() {
    super.initState();
    _loadRejectedOrders();
    _loadMedicalStores();
  }

  Future<void> _loadRejectedOrders() async {
    setState(() => _isLoading = true);

    try {
      final token = await StorageService.getAuthToken();
      final dio = Dio();

      final response = await dio.get(
        '${AppConstants.apiBaseUrl}/Orders/rejected',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _rejectedOrders = response.data is List ? response.data : [];
          _isLoading = false;
        });
        AppLogger.info('Loaded ${_rejectedOrders.length} rejected orders');
      }
    } catch (e) {
      AppLogger.error('Error loading rejected orders: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load rejected orders: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadMedicalStores() async {
    try {
      final token = await StorageService.getAuthToken();
      final dio = Dio();

      final response = await dio.get(
        '${AppConstants.apiBaseUrl}/MedicalStores',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          final stores = response.data is List ? response.data : [];
          _medicalStores = stores.where((store) => 
            store is Map && (store['isActive'] == true || store['isActive'] == 'true')
          ).toList();
        });
        AppLogger.info('Loaded ${_medicalStores.length} active medical stores');
      }
    } catch (e) {
      AppLogger.error('Error loading medical stores: $e');
    }
  }

  Future<void> _reassignOrder(String orderId, String newMedicalStoreId) async {
    setState(() => _isReassigning = true);

    try {
      final token = await StorageService.getAuthToken();
      final dio = Dio();

      final response = await dio.put(
        '${AppConstants.apiBaseUrl}/Orders/$orderId/reassign',
        data: {
          'orderId': int.tryParse(orderId) ?? orderId,
          'medicalStoreId': newMedicalStoreId,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      setState(() => _isReassigning = false);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order reassigned successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Reload the list
          _loadRejectedOrders();
        }
      }
    } catch (e) {
      AppLogger.error('Error reassigning order: $e');
      setState(() => _isReassigning = false);

      String errorMessage = 'Failed to reassign order';
      if (e is DioException && e.response != null) {
        errorMessage = e.response?.data['message'] ?? 
                      e.response?.data['error'] ?? 
                      errorMessage;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showOrderDetails(dynamic order) {
    if (order is! Map) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid order data'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Order ID
              Text(
                'Order #${order['orderNumber'] ?? order['orderId'] ?? 'N/A'}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Order Details
              _buildInfoSection(
                'Order Information',
                [
                  _buildInfoRow('Order Type', _safeGet(order, 'orderType', 'N/A')),
                  _buildInfoRow('Input Type', _safeGet(order, 'orderInputType', 'N/A')),
                  _buildInfoRow('Status', _safeGet(order, 'orderStatus', 'N/A')),
                  _buildInfoRow('Created', _formatDate(_safeGet(order, 'createdAt', ''))),
                  if (_safeGet(order, 'updatedAt', '').isNotEmpty)
                    _buildInfoRow('Updated', _formatDate(_safeGet(order, 'updatedAt', ''))),
                ],
              ),
              const SizedBox(height: 16),

              // Customer Info (if available)
              if (_safeGet(order, 'customerName', '').isNotEmpty || 
                  _safeGet(order, 'customerEmail', '').isNotEmpty)
                Column(
                  children: [
                    _buildInfoSection(
                      'Customer Information',
                      [
                        if (_safeGet(order, 'customerName', '').isNotEmpty)
                          _buildInfoRow('Name', _safeGet(order, 'customerName', 'N/A')),
                        if (_safeGet(order, 'customerEmail', '').isNotEmpty)
                          _buildInfoRow('Email', _safeGet(order, 'customerEmail', 'N/A')),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Order Text
              if (_safeGet(order, 'orderInputText', '').isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Message',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        _safeGet(order, 'orderInputText', ''),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Reassign Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showReassignDialog(order);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text(
                    'Reassign Order',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showReassignDialog(dynamic order) {
    if (order is! Map) return;

    String? selectedStoreId;
    final currentStoreId = _safeGet(order, 'medicalStoreId', '');

    // Filter out the current/rejecting store
    final availableStores = _medicalStores
        .where((store) => store is Map && _safeGet(store, 'id', '') != currentStoreId)
        .toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Reassign Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select a medical store to reassign this order:',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              if (availableStores.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No other medical stores available',
                          style: TextStyle(color: Colors.orange.shade700),
                        ),
                      ),
                    ],
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  value: selectedStoreId,
                  decoration: InputDecoration(
                    hintText: 'Select medical store',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: availableStores.map((store) {
                    if (store is! Map) return null;
                    return DropdownMenuItem<String>(
                      value: _safeGet(store, 'id', ''),
                      child: Text(
                        _safeGet(store, 'name', 'Unnamed Store'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).whereType<DropdownMenuItem<String>>().toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedStoreId = value);
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: availableStores.isEmpty || selectedStoreId == null
                  ? null
                  : () {
                      Navigator.pop(context);
                      _reassignOrder(
                        _safeGet(order, 'id', '').toString(),
                        selectedStoreId!,
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reassign'),
            ),
          ],
        ),
      ),
    );
  }

  String _safeGet(dynamic obj, String key, String defaultValue) {
    if (obj is Map && obj.containsKey(key)) {
      final value = obj[key];
      if (value == null) return defaultValue;
      return value.toString();
    }
    return defaultValue;
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejected Orders'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRejectedOrders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rejectedOrders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: Colors.green.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Rejected Orders',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'All orders are being processed',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRejectedOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _rejectedOrders.length,
                    itemBuilder: (context, index) {
                      final order = _rejectedOrders[index];
                      if (order is! Map) return const SizedBox();
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.red.shade200, width: 1),
                        ),
                        child: InkWell(
                          onTap: () => _showOrderDetails(order),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Order Header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Order #${_safeGet(order, 'orderNumber', 'N/A')}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'REJECTED',
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Customer Info
                                if (_safeGet(order, 'customerName', '').isNotEmpty)
                                  Row(
                                    children: [
                                      Icon(Icons.person, size: 20, color: Colors.grey.shade600),
                                      const SizedBox(width: 8),
                                      Text(
                                        _safeGet(order, 'customerName', 'N/A'),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                if (_safeGet(order, 'customerName', '').isNotEmpty)
                                  const SizedBox(height: 8),

                                // Email
                                if (_safeGet(order, 'customerEmail', '').isNotEmpty)
                                  Row(
                                    children: [
                                      Icon(Icons.email, size: 20, color: Colors.grey.shade600),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _safeGet(order, 'customerEmail', 'N/A'),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                if (_safeGet(order, 'customerEmail', '').isNotEmpty)
                                  const SizedBox(height: 8),

                                // Created Date
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 20, color: Colors.grey.shade600),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatDate(_safeGet(order, 'createdAt', '')),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Action Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _showOrderDetails(order),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppTheme.primaryColor,
                                          side: const BorderSide(color: AppTheme.primaryColor),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        icon: const Icon(Icons.info_outline, size: 18),
                                        label: const Text('Details'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _isReassigning
                                            ? null
                                            : () => _showReassignDialog(order),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primaryColor,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        icon: const Icon(Icons.swap_horiz, size: 18),
                                        label: const Text('Reassign'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}