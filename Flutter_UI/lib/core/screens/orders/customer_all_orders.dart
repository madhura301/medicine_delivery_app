import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:pharmaish/core/app_routes.dart';
import 'package:pharmaish/core/screens/payment/payment_summary_page.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:pharmaish/shared/models/order_model.dart';
import 'package:pharmaish/shared/widgets/app_snackbar.dart';
import 'package:pharmaish/shared/widgets/order_payments_dialog.dart';
import 'package:pharmaish/core/theme/app_theme.dart';
import 'package:pharmaish/core/services/dio_client.dart';
import 'package:pharmaish/core/services/order_service.dart';
import 'package:pharmaish/shared/widgets/order_status_chip.dart';

class CustomerAllOrders extends StatefulWidget {
  const CustomerAllOrders({super.key});

  @override
  State<CustomerAllOrders> createState() => _CustomerAllOrdersState();
}

class _CustomerAllOrdersState extends State<CustomerAllOrders> {
  List<OrderModel> _allOrders = [];
  List<OrderModel> _filteredOrders = [];
  bool _isLoading = true;
  String? _errorMessage;
  final Dio _dio = DioClient.instance;
  int _selectedFilterIndex = 0;
  String _customerId = '';

  // Chemist info cache
  final Map<String, Map<String, String>> _chemistCache = {};

  // Orders currently being rejected (shows spinner, disables buttons)
  final Set<String> _rejectingOrders = {};

  @override
  void initState() {
    super.initState();
    _loadCustomerIdAndOrders();
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

      final ordersList =
          await OrderService.getOrdersForCustomer(_customerId);

      AppLogger.info('Received ${ordersList.length} orders');

      final allOrders =
          ordersList.map((json) => OrderModel.fromJson(json)).toList();

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
              'name': chemistData['medicalName']?.toString() ?? 'Chemist',
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
        case 0: // All — Out for Delivery pinned to top, rest sorted by date desc
          final ofd = _allOrders
              .where((o) => _isOutForDelivery(o.status))
              .toList()
            ..sort((a, b) => b.createdOn.compareTo(a.createdOn));
          final rest = _allOrders
              .where((o) => !_isOutForDelivery(o.status))
              .toList()
            ..sort((a, b) => b.createdOn.compareTo(a.createdOn));
          _filteredOrders = [...ofd, ...rest];
          break;
        case 1: // Out for Delivery
          _filteredOrders = _allOrders
              .where((o) => _isOutForDelivery(o.status))
              .toList()
            ..sort((a, b) => b.createdOn.compareTo(a.createdOn));
          break;
        case 2: // Active (Pending + Accepted + Bill + OFD)
          _filteredOrders = _allOrders
              .where((o) =>
                  o.status.toLowerCase().contains('pending') ||
                  o.status.toLowerCase().contains('assigned') ||
                  o.status.toLowerCase().contains('accepted') ||
                  o.status.toLowerCase().contains('bill') ||
                  _isOutForDelivery(o.status))
              .toList();
          break;
        case 3: // Pending
          _filteredOrders = _allOrders
              .where((o) =>
                  o.status.toLowerCase().contains('pending') ||
                  o.status.toLowerCase().contains('assigned'))
              .toList();
          break;
        case 4: // Completed
          _filteredOrders = _allOrders
              .where((o) => o.status.toLowerCase().contains('completed'))
              .toList();
          break;
        case 5: // Rejected
          _filteredOrders = _allOrders
              .where((o) => o.status.toLowerCase().contains('rejected'))
              .toList();
          break;
      }
    });
  }

  // Helper — true for OutForDelivery status string from backend
  bool _isOutForDelivery(String status) {
    final s = status.toLowerCase();
    return s.contains('outfordelivery') ||
        (s.contains('delivery') && !s.contains('completed'));
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
            color: Colors.black.withValues(alpha: 0.05),
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
            _buildFilterChip('Out for Delivery', 1, Colors.deepPurple),
            const SizedBox(width: 8),
            _buildFilterChip('Active', 2, Colors.blue),
            const SizedBox(width: 8),
            _buildFilterChip('Pending', 3, Colors.orange),
            const SizedBox(width: 8),
            _buildFilterChip('Completed', 4, Colors.green),
            const SizedBox(width: 8),
            _buildFilterChip('Rejected', 5, Colors.red),
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
      case 1: // Out for Delivery
        return _allOrders.where((o) => _isOutForDelivery(o.status)).length;
      case 2: // Active
        return _allOrders
            .where((o) =>
                o.status.toLowerCase().contains('pending') ||
                o.status.toLowerCase().contains('assigned') ||
                o.status.toLowerCase().contains('accepted') ||
                o.status.toLowerCase().contains('bill') ||
                _isOutForDelivery(o.status))
            .length;
      case 3: // Pending
        return _allOrders
            .where((o) =>
                o.status.toLowerCase().contains('pending') ||
                o.status.toLowerCase().contains('assigned'))
            .length;
      case 4: // Completed
        return _allOrders
            .where((o) => o.status.toLowerCase().contains('completed'))
            .length;
      case 5: // Rejected
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
        return 'Out for Delivery';
      case 2:
        return 'Active';
      case 3:
        return 'Pending';
      case 4:
        return 'Completed';
      case 5:
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
                          'Order #${order.orderNumber ?? order.orderId}',
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
                  if (order.isFullyPaid) ...[
                    const SizedBox(height: 10),
                    _buildPaidBadge(),
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

              // ─── Action buttons ──────────────────────────────────────────
              if (!order.status.toLowerCase().contains('completed') &&
                  !order.status.toLowerCase().contains('rejected')) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                _buildActionButtons(order),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─── Smart action buttons based on order status ─────────────────────────────

  /// Opens the payment-history dialog for an order that has been paid.
  void _showPaymentHistory(OrderModel order) {
    final id = int.tryParse(order.orderId);
    if (id == null) return;
    OrderPaymentsDialog.show(
      context,
      orderId: id,
      orderNumber: order.orderNumber,
    );
  }

  Widget _buildActionButtons(OrderModel order) {
    final statusLower = order.status.toLowerCase();
    final isOutForDelivery = statusLower.contains('outfordelivery') ||
        (statusLower.contains('delivery') && !statusLower.contains('completed'));
    final isBillUploaded = statusLower.contains('bill');
    final isRejecting = _rejectingOrders.contains(order.orderId);

    // OUT FOR DELIVERY — show Reject + Pay Now
    if (isOutForDelivery && order.totalAmount != null && order.totalAmount! > 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Delivery banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.deepPurple.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.delivery_dining, color: Colors.deepPurple.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.isFullyPaid
                        ? 'Payment received. Your order is on its way.'
                        : 'Your order is out for delivery! Please pay to complete.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.deepPurple.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Reject button
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: isRejecting
                      ? null
                      : () => _showRejectDeliveryDialog(order),
                  icon: isRejecting
                      ? const SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                        )
                      : const Icon(Icons.cancel_outlined, size: 16),
                  label: Text(isRejecting ? 'Rejecting...' : 'Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Pay Now button — replaced by Payment History once fully paid
              Expanded(
                flex: 3,
                child: order.isFullyPaid
                    ? ElevatedButton.icon(
                        onPressed: () => _showPaymentHistory(order),
                        icon: const Icon(Icons.receipt_long, size: 16),
                        label: const Text(
                          'Payment History',
                          style:
                              TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: 2,
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: isRejecting ? null : () => _goToPayment(order),
                        icon: const Icon(Icons.payment, size: 16),
                        label: Text(
                          'Pay ₹${order.totalAmount!.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: 2,
                        ),
                      ),
              ),
            ],
          ),
        ],
      );
    }

    // BILL UPLOADED — show Pay Now
    if (isBillUploaded && order.totalAmount != null && order.totalAmount! > 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () => _showOrderDetails(order),
            icon: const Icon(Icons.visibility, size: 18),
            label: const Text('View Details'),
            style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
          ),
          order.isFullyPaid
              ? ElevatedButton.icon(
                  onPressed: () => _showPaymentHistory(order),
                  icon: const Icon(Icons.receipt_long, size: 16),
                  label: const Text(
                    'Payment History',
                    style: TextStyle(fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                )
              : ElevatedButton.icon(
                  onPressed: () => _goToPayment(order),
                  icon: const Icon(Icons.payment, size: 16),
                  label: Text(
                    'Pay ₹${order.totalAmount!.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
        ],
      );
    }

    // DEFAULT — View Details only
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => _showOrderDetails(order),
        icon: const Icon(Icons.visibility, size: 18),
        label: const Text('View Details'),
        style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
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

  /// Green "Payment Completed" pill shown on the tile once the order is fully paid.
  Widget _buildPaidBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 16, color: Colors.green.shade700),
          const SizedBox(width: 6),
          Text(
            'Payment Completed',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) => OrderStatusChip(status);

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

  // ─── Reject delivery ────────────────────────────────────────────────────────

  Future<void> _showRejectDeliveryDialog(OrderModel order) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 28),
            const SizedBox(width: 10),
            const Text('Reject Delivery?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order #${order.orderNumber ?? order.orderId}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Please tell us why you are rejecting this delivery.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              maxLength: 250,
              decoration: InputDecoration(
                hintText: 'e.g. Wrong medicines delivered, damaged packaging...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Please provide a reason')),
                );
                return;
              }
              Navigator.of(ctx).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Confirm Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _rejectOrder(order, reasonController.text.trim());
    }
    reasonController.dispose();
  }

  Future<void> _rejectOrder(OrderModel order, String reason) async {
    setState(() => _rejectingOrders.add(order.orderId));

    try {
      await OrderService.rejectOrder(
        orderId: order.orderId,
        rejectNote: reason,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Order #${order.orderNumber ?? order.orderId} rejected. Our team will contact you.',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
        await _loadAllOrders();
      }
    } on DioException catch (e) {
      AppLogger.error('Error rejecting order', e);
      String msg = 'Failed to reject order. Please try again.';
      if (e.response?.data is Map) {
        final d = e.response!.data as Map;
        msg = d['error']?.toString() ?? d['message']?.toString() ?? msg;
      }
      if (mounted) {
        AppSnackBar.error(context, msg);
      }
    } catch (e) {
      AppLogger.error('Unexpected error rejecting order', e);
      if (mounted) {
        AppSnackBar.error(context, 'An unexpected error occurred');
      }
    } finally {
      if (mounted) setState(() => _rejectingOrders.remove(order.orderId));
    }
  }

  // ─── Navigate to pay ─────────────────────────────────────────────────────────

  void _goToPayment(OrderModel order) {
    final amount = order.totalAmount!;
    // Convenience fee is currently a flat ₹20. The percentage-based logic
    // (2.5%, min ₹20) is retained for future use:
    //   final fee = (amount * 0.025) < 20 ? 20.0 : amount * 0.025;
    const double fee = 20.0;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSummaryPage(
          orderId: int.tryParse(order.orderId) ?? 0,
          medicinesTotal: amount,
          convenienceFee: fee,
          orderNumber: order.orderNumber ?? order.orderId,
          onPaymentSuccess: _loadAllOrders,
        ),
      ),
    );
  }

  void _showOrderDetails(OrderModel order) {
    Navigator.pushNamed(
      context,
      AppRoutes.customerOrderDetails,
      arguments: order,
    );
  }

}