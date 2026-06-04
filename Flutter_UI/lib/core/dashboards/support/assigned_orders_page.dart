import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pharmaish/shared/models/chemist_model.dart';
import 'package:pharmaish/shared/models/order_model.dart';
import 'package:pharmaish/shared/widgets/app_button.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/storage.dart';

// ============================================================================
// ASSIGNED ORDERS PAGE
// ============================================================================

class AssignedOrdersPage extends StatefulWidget {
  final Dio dio;

  const AssignedOrdersPage({super.key, required this.dio});

  @override
  State<AssignedOrdersPage> createState() => _AssignedOrdersPageState();
}

class _AssignedOrdersPageState extends State<AssignedOrdersPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isLoading = true;
  String? _errorMessage;
  List<OrderModel> _assignedOrders = [];
  String _customerSupportId = '';
  final Map<String, Map<String, String>> _customerCache = {};

  // Track which orders are currently being reassigned (loading state per card)
  final Set<String> _reassigningOrders = {};

  @override
  void initState() {
    super.initState();
    _loadCustomerSupportIdAndOrders();
  }

  // ─────────────────────────────── DATA LOADING ────────────────────────────

  Future<void> _loadCustomerSupportIdAndOrders() async {
    try {
      final userId = await StorageService.getUserId();
      if (userId == null || userId.isEmpty) {
        setState(() {
          _errorMessage = 'Customer Support ID not found. Please login again.';
          _isLoading = false;
        });
        return;
      }
      setState(() => _customerSupportId = userId);
      await _loadAssignedOrders();
    } catch (e) {
      AppLogger.error('Error loading customer support ID', e);
      setState(() {
        _errorMessage = 'Error loading user information';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAssignedOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      AppLogger.info(
          'Fetching assigned orders for customer support: $_customerSupportId');
      final response = await widget.dio.get(
        '/Orders/customersupport/$_customerSupportId/assignedtocustomersupport',
      );

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

        final orders =
            ordersList.map((json) => OrderModel.fromJson(json)).toList();
        orders.sort((a, b) => b.createdOn.compareTo(a.createdOn));

        await _loadCustomerInfo(orders);

        setState(() {
          _assignedOrders = orders;
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      AppLogger.error('Error loading assigned orders', e);
      String errorMsg = 'Failed to load assigned orders';
      if (e.response?.statusCode == 401) {
        errorMsg = 'Authentication failed. Please login again.';
      } else if (e.response?.statusCode == 404) {
        errorMsg = 'No assigned orders found';
      }
      setState(() {
        _errorMessage = errorMsg;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Unexpected error loading assigned orders', e);
      setState(() {
        _errorMessage = 'An unexpected error occurred';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCustomerInfo(List<OrderModel> orders) async {
    for (var order in orders) {
      if (!_customerCache.containsKey(order.customerId)) {
        try {
          final response =
              await widget.dio.get('/Customers/${order.customerId}');
          if (response.statusCode == 200) {
            final d = response.data;
            final firstName = d['customerFirstName'] ?? '';
            final lastName = d['customerLastName'] ?? '';
            final fullName = '$firstName $lastName'.trim();
            _customerCache[order.customerId] = {
              'name': fullName.isEmpty ? 'Customer' : fullName,
              'email': d['emailId']?.toString() ?? '',
              'phone': d['mobileNumber']?.toString() ?? '',
            };
          }
        } catch (_) {
          _customerCache[order.customerId] = {
            'name': 'Customer',
            'email': '',
            'phone': '',
          };
        }
      }
    }
  }

  // ──────────────────────────── REASSIGN LOGIC ─────────────────────────────

  /// Fetches nearby chemists via /Orders/nearby-chemists/{orderNumber}.
  /// Returns chemists with distance (5KM radius) or postal-code fallback.
  Future<List<ChemistModel>> _fetchNearbyChemists(String orderNumber) async {
    final response =
        await widget.dio.get('/Orders/nearby-chemists/$orderNumber');

    if (response.statusCode == 200) {
      final body = response.data;
      final List<dynamic> data = body is Map
          ? (body['chemists'] ?? body['Chemists'] ?? [])
          : (body is List ? body : []);
      return data.map((json) => ChemistModel.fromJson(json)).toList();
    }
    return [];
  }

  /// Checks whether at least one chemist is within 5KM of the customer address.
  Future<bool?> _checkChemistAvailability(String customerId) async {
    try {
      final response =
          await widget.dio.get('/MedicalStores/check-availability/$customerId');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map) {
          final v = data['isChemistAvailable'] ?? data['IsChemistAvailable'];
          if (v is bool) return v;
        }
      }
    } catch (_) {
      // Swallow — banner just won't show.
    }
    return null;
  }

  Future<void> _showReassignDialog(
      OrderModel order, String customerName) async {
    final orderNumber = order.orderNumber;
    if (orderNumber == null || orderNumber.isEmpty) {
      _showSnackBar('Order number missing — cannot fetch nearby chemists',
          isError: true);
      return;
    }

    List<ChemistModel> chemists = [];
    bool isLoadingChemists = true;
    String? fetchError;
    bool? chemistAvailable;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
          // Kick off the fetches once (nearby chemists + availability check in parallel)
          if (isLoadingChemists && fetchError == null && chemists.isEmpty) {
            Future.wait([
              _fetchNearbyChemists(orderNumber),
              _checkChemistAvailability(order.customerId),
            ]).then((results) {
              setDialogState(() {
                chemists = results[0] as List<ChemistModel>;
                chemistAvailable = results[1] as bool?;
                isLoadingChemists = false;
              });
            }).catchError((e) {
              setDialogState(() {
                fetchError =
                    'Could not load nearby chemists.\nPlease try again.';
                isLoadingChemists = false;
              });
            });
          }

          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Dialog header ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.store_outlined,
                              color: Colors.white, size: 22),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Reassign Order',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close,
                                color: Colors.white70, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Order #${order.orderNumber ?? order.orderId} • $customerName',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_pin,
                                color: Colors.white70, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'Showing chemists within 5 KM (or same pincode)',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Availability banner ──
                if (!isLoadingChemists && chemistAvailable != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    color: chemistAvailable!
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF3E0),
                    child: Row(
                      children: [
                        Icon(
                          chemistAvailable!
                              ? Icons.check_circle_outline
                              : Icons.warning_amber_outlined,
                          size: 18,
                          color: chemistAvailable!
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFEF6C00),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            chemistAvailable!
                                ? 'A chemist is available within 5 KM of the customer address.'
                                : 'No chemist within 5 KM of the customer address.',
                            style: TextStyle(
                              fontSize: 12,
                              color: chemistAvailable!
                                  ? const Color(0xFF1B5E20)
                                  : const Color(0xFFE65100),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── Content ──
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
                  child: isLoadingChemists
                      ? const SizedBox(
                          height: 120,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : fetchError != null
                          ? Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.error_outline,
                                      color: Colors.red.shade300, size: 44),
                                  const SizedBox(height: 12),
                                  Text(fetchError!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 13)),
                                ],
                              ),
                            )
                          : chemists.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.store_mall_directory_outlined,
                                          color: Colors.grey.shade300,
                                          size: 52),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No active chemists found\nnear this delivery pincode.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  itemCount: chemists.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1, indent: 56),
                                  itemBuilder: (ctx, index) {
                                    final chemist = chemists[index];
                                    final isPostalMatch = chemist.matchType ==
                                        ChemistMatchType.postalCode;
                                    return ListTile(
                                      leading: const CircleAvatar(
                                        backgroundColor:
                                            Color(0xFFE3F2FD),
                                        radius: 20,
                                        child: Icon(Icons.store,
                                            color: Color(0xFF1565C0), size: 20),
                                      ),
                                      title: Text(
                                        chemist.medicalName,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            [
                                              chemist.addressLine1,
                                              chemist.city,
                                              chemist.state,
                                              chemist.postalCode,
                                            ]
                                                .where((s) => s.isNotEmpty)
                                                .join(', '),
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600),
                                          ),
                                          if (chemist.mobileNumber.isNotEmpty)
                                            Text(
                                              chemist.mobileNumber,
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade500),
                                            ),
                                        ],
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isPostalMatch
                                                  ? const Color(0xFFFFF8E1)
                                                  : const Color(0xFFE3F2FD),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              chemist.distanceLabel,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: isPostalMatch
                                                    ? const Color(0xFFF57F17)
                                                    : const Color(0xFF1565C0),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Icon(Icons.chevron_right,
                                              color: Colors.grey, size: 18),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        _reassignOrder(order, chemist);
                                      },
                                    );
                                  },
                                ),
                ),

                // ── Footer ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> _reassignOrder(OrderModel order, ChemistModel chemist) async {
    setState(() => _reassigningOrders.add(order.orderId));
    try {
      await widget.dio.put('/Orders/assign', data: {
        'orderId': int.parse(order.orderId),
        'medicalStoreId': chemist.medicalStoreId,
      });

      _showSnackBar('Order reassigned to ${chemist.medicalName}');
      await _loadAssignedOrders();
    } catch (e) {
      _showSnackBar('Failed to reassign order', isError: true);
    } finally {
      setState(() => _reassigningOrders.remove(order.orderId));
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ──────────────────────────── BUILD ──────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF1565C0)));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadCustomerSupportIdAndOrders,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: AppButton.primary(),
              ),
            ],
          ),
        ),
      );
    }

    if (_assignedOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_ind, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'No Assigned Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Orders assigned to you will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAssignedOrders,
      color: const Color(0xFF1565C0),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: _assignedOrders.length,
        itemBuilder: (context, index) {
          final order = _assignedOrders[index];
          final customerInfo = _customerCache[order.customerId];
          final customerName = customerInfo?['name'] ?? 'Customer';
          final customerPhone = customerInfo?['phone'] ?? '';
          return _AssignedOrderCard(
            key: ValueKey(order.orderId),
            order: order,
            customerName: customerName,
            customerPhone: customerPhone,
            isReassigning: _reassigningOrders.contains(order.orderId),
            onReassign: () => _showReassignDialog(order, customerName),
          );
        },
      ),
    );
  }
}

// ─────────────────────────── ORDER CARD WIDGET ───────────────────────────────

class _AssignedOrderCard extends StatelessWidget {
  final OrderModel order;
  final String customerName;
  final String customerPhone;
  final bool isReassigning;
  final VoidCallback onReassign;

  const _AssignedOrderCard({
    super.key,
    required this.order,
    required this.customerName,
    required this.customerPhone,
    required this.isReassigning,
    required this.onReassign,
  });

  // ── Status helpers ──────────────────────────────────────────────────────

  // NOTE: 'assigned to customer support' MUST come before 'assigned' in this
  // map because _resolveStatus uses contains(), and the longer key would
  // otherwise be shadowed by the shorter one.
  static const Map<String, _StatusStyle> _statusMap = {
    'pending': _StatusStyle(
        label: 'Pending',
        bg: Color(0xFFFFF3E0),
        fg: Color(0xFFE65100),
        dot: Color(0xFFFF6F00)),
    'assigned to customer support': _StatusStyle(
        label: 'Needs Reassignment',
        bg: Color(0xFFE3F2FD),
        fg: Color(0xFF0D47A1),
        dot: Color(0xFF1565C0)),
    'assigned': _StatusStyle(
        label: 'Assigned',
        bg: Color(0xFFFFF3E0),
        fg: Color(0xFFE65100),
        dot: Color(0xFFFF6F00)),
    'accepted': _StatusStyle(
        label: 'Accepted',
        bg: Color(0xFFE8F5E9),
        fg: Color(0xFF1B5E20),
        dot: Color(0xFF2E7D32)),
    'rejected': _StatusStyle(
        label: 'Rejected',
        bg: Color(0xFFFFEBEE),
        fg: Color(0xFFB71C1C),
        dot: Color(0xFFC62828)),
    'bill': _StatusStyle(
        label: 'Bill Uploaded',
        bg: Color(0xFFF3E5F5),
        fg: Color(0xFF4A148C),
        dot: Color(0xFF6A1B9A)),
    'delivery': _StatusStyle(
        label: 'Out for Delivery',
        bg: Color(0xFFE0F2F1),
        fg: Color(0xFF004D40),
        dot: Color(0xFF00695C)),
    'completed': _StatusStyle(
        label: 'Completed',
        bg: Color(0xFFE8F5E9),
        fg: Color(0xFF1B5E20),
        dot: Color(0xFF2E7D32)),
  };

  _StatusStyle _resolveStatus() {
    final s = order.status.toLowerCase();
    for (final key in _statusMap.keys) {
      if (s.contains(key)) return _statusMap[key]!;
    }
    return _StatusStyle(
        label: order.status,
        bg: const Color(0xFFF5F5F5),
        fg: Colors.grey.shade700,
        dot: Colors.grey.shade500);
  }

  // Reassign button shown for:
  //  - status 8  → "Assigned to Customer Support" (parsed correctly)
  //  - legacy fallback if parsing ever fails
  bool get _needsReassign =>
      order.status.toLowerCase().contains('assigned to customer support') ||
      order.status.toLowerCase().contains('unknown status (8)');

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour < 12 ? 'AM' : 'PM';
    return '${months[local.month - 1]} $day  •  $hour:$minute $ampm';
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final style = _resolveStatus();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: _needsReassign
            ? Border.all(color: const Color(0xFFBBDEFB), width: 1.5)
            : Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Colour-coded top stripe ───────────────────────────────────────
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: style.dot,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Row 1: avatar  +  customer name  +  status badge ─────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFE3F2FD),
                      child: Text(
                        customerName.isNotEmpty
                            ? customerName[0].toUpperCase()
                            : 'C',
                        style: const TextStyle(
                          color: Color(0xFF1565C0),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customerName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          if (customerPhone.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.phone,
                                    size: 11, color: Colors.grey.shade500),
                                const SizedBox(width: 3),
                                Text(
                                  customerPhone,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: style.bg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: style.dot,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            style.label.toUpperCase(),
                            style: TextStyle(
                              color: style.fg,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                const SizedBox(height: 12),

                // ── Row 2: order meta chips ───────────────────────────────
                Row(
                  children: [
                    _MetaChip(
                      icon: Icons.tag,
                      label: '#${order.orderNumber ?? order.orderId}',
                    ),
                    const SizedBox(width: 8),
                    _MetaChip(
                      icon: Icons.category_outlined,
                      label: order.orderInputType.name,
                    ),
                    if (order.totalAmount != null) ...[
                      const SizedBox(width: 8),
                      _MetaChip(
                        icon: Icons.currency_rupee,
                        label: order.totalAmount!.toStringAsFixed(2),
                        highlight: true,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 8),

                // ── Row 3: date ───────────────────────────────────────────
                Row(
                  children: [
                    Icon(Icons.schedule, size: 13, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(order.createdOn),
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),

                // ── Delivery city + pincode ───────────────────────────────
                if (order.shippingPincode != null &&
                    order.shippingPincode!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        [order.shippingCity, order.shippingPincode]
                            .where((s) => s != null && s.isNotEmpty)
                            .join(' – '),
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ],

                // ── Rejection reason (shown whenever present, any status) ─
                if (order.rejectionReason != null &&
                    order.rejectionReason!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8F8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFCDD2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline,
                            size: 14, color: Color(0xFFB71C1C)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Rejection reason: ${order.rejectionReason}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFB71C1C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Reassign button (status 8 = AssignedToCustomerSupport) ─
                if (_needsReassign) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isReassigning ? null : onReassign,
                      icon: isReassigning
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.autorenew, size: 16),
                      label: Text(
                        isReassigning
                            ? 'Reassigning…'
                            : 'Reassign to Nearby Chemist',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────────

class _StatusStyle {
  final String label;
  final Color bg;
  final Color fg;
  final Color dot;
  const _StatusStyle(
      {required this.label,
      required this.bg,
      required this.fg,
      required this.dot});
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlight;

  const _MetaChip({
    required this.icon,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: highlight ? const Color(0xFF2E7D32) : Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: highlight ? const Color(0xFF1B5E20) : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
