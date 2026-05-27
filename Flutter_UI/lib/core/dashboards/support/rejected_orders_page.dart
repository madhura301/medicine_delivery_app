import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pharmaish/shared/models/chemist_model.dart';
import 'package:pharmaish/shared/models/order_model.dart';
import 'package:pharmaish/shared/widgets/app_button.dart';
import 'package:pharmaish/shared/widgets/app_snackbar.dart';
import 'package:pharmaish/utils/app_logger.dart';

// ============================================================================
// REJECTED ORDERS PAGE
// ============================================================================

class RejectedOrdersPage extends StatefulWidget {
  final Dio dio;

  const RejectedOrdersPage({super.key, required this.dio});

  @override
  State<RejectedOrdersPage> createState() => _RejectedOrdersPageState();
}

class _RejectedOrdersPageState extends State<RejectedOrdersPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isLoading = true;
  String? _errorMessage;
  List<OrderModel> _rejectedOrders = [];
  final Map<String, Map<String, String>> _customerCache = {};

  @override
  void initState() {
    super.initState();
    _loadRejectedOrders();
  }

  Future<void> _loadRejectedOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      AppLogger.info('Fetching rejected orders');
      final response = await widget.dio.get('/Orders');
      AppLogger.info(response.data.toString());

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> ordersList;
        if (data is List) {
          ordersList = data;
        } else if (data is Map && data.containsKey('data')) {
          ordersList = data['data'] as List;
        } else {
          ordersList = data['orders'] as List;
        }

        final allOrders =
            ordersList.map((json) => OrderModel.fromJson(json)).toList();
        AppLogger.info('Total orders fetched: \${allOrders.length}');
        final rejected = allOrders
            .where((o) => o.status.toLowerCase().contains('rejected'))
            .toList();
        AppLogger.info('Found ${rejected.length} rejected orders' ' out of ${allOrders.length} total orders');
        rejected.sort((a, b) => b.createdOn.compareTo(a.createdOn));

        await _loadCustomerInfo(rejected);

        setState(() {
          _rejectedOrders = rejected;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Error loading rejected orders', e);
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load rejected orders';
      });
    }
  }

  Future<void> _loadCustomerInfo(List<OrderModel> orders) async {
    for (var order in orders) {
      if (!_customerCache.containsKey(order.customerId)) {
        try {
          final response =
              await widget.dio.get('/Customers/\${order.customerId}');

          if (response.statusCode == 200) {
            final customerData = response.data;
            final firstName = customerData['customerFirstName'] ?? '';
            final lastName = customerData['customerLastName'] ?? '';
            final fullName = '$firstName $lastName'.trim();

            _customerCache[order.customerId] = {
              'name': fullName.isEmpty ? 'Customer' : fullName,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadRejectedOrders,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: AppButton.primary(),
            ),
          ],
        ),
      );
    }

    if (_rejectedOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 80, color: Colors.green.shade300),
            const SizedBox(height: 16),
            const Text(
              'No Rejected Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRejectedOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _rejectedOrders.length,
        itemBuilder: (context, index) {
          final order = _rejectedOrders[index];
          final customerName =
              _customerCache[order.customerId]?['name'] ?? 'Customer';
          return _buildOrderCard(order, customerName);
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, String customerName) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'REJECTED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    customerName,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Order #\${order.orderNumber ?? order.orderId}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (order.rejectionReason != null &&
                order.rejectionReason!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Reason: \${order.rejectionReason}',
                        style: TextStyle(fontSize: 13, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showReassignDialog(order, customerName),
                icon: const Icon(Icons.autorenew, size: 18),
                label: const Text('Reassign to Another Chemist'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showReassignDialog(
      OrderModel order, String customerName) async {
    // Load available chemists
    List<ChemistModel> chemists = [];
    bool isLoadingChemists = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            if (isLoadingChemists) {
              widget.dio.get('/MedicalStores').then((response) {
                if (response.statusCode == 200) {
                  final List<dynamic> data = response.data;
                  setDialogState(() {
                    chemists = data
                        .map((json) => ChemistModel.fromJson(json))
                        .where((c) => c.isActive)
                        .toList();
                    isLoadingChemists = false;
                  });
                }
              });
            }

            return AlertDialog(
              title: const Text(
                  'Reassign Order #\${order.orderNumber ?? order.orderId}'),
              content: isLoadingChemists
                  ? const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: chemists.length,
                        itemBuilder: (context, index) {
                          final chemist = chemists[index];
                          return ListTile(
                            leading:
                                const Icon(Icons.store, color: Colors.blue),
                            title: Text(chemist.medicalName),
                            subtitle:
                                const Text('\${chemist.city}, \${chemist.state}'),
                            onTap: () {
                              Navigator.pop(context);
                              _reassignOrder(order, chemist);
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
            );
          },
        );
      },
    );
  }

  Future<void> _reassignOrder(OrderModel order, ChemistModel chemist) async {
    try {
      // This would be your reassign API call
      // For now, we'll update the status
      await widget.dio.put('/Orders/\${order.orderId}/reassign', data: {
        'medicalStoreId': chemist.medicalStoreId,
      });

      AppSnackBar.success(context, 'Order reassigned to \${chemist.medicalName}');
      _loadRejectedOrders();
    } catch (e) {
      AppSnackBar.error(context, 'Failed to reassign order');
    }
  }
}
