// Assign Delivery Boy Screen
// For chemist to assign delivery boy to accepted orders with uploaded bill
// Order status must be "BillUploaded"
// After assignment, order status changes to "OutForDelivery"

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:pharmaish/shared/models/order_model.dart';

class AssignDeliveryBoyScreen extends StatefulWidget {
  final OrderModel order;
  final String customerName;
  final VoidCallback? onComplete;

  const AssignDeliveryBoyScreen({
    Key? key,
    required this.order,
    required this.customerName,
    this.onComplete,
  }) : super(key: key);

  @override
  State<AssignDeliveryBoyScreen> createState() =>
      _AssignDeliveryBoyScreenState();
}

class _AssignDeliveryBoyScreenState extends State<AssignDeliveryBoyScreen> {
  late Dio _dio;
  List<DeliveryBoy> _deliveryBoys = [];
  DeliveryBoy? _selectedDeliveryBoy;
  bool _isLoading = true;
  bool _isAssigning = false;
  String? _errorMessage;
  String? _medicalStoreId;

  @override
  void initState() {
    super.initState();
    _setupDio();
    _loadMedicalStoreId();
  }

  void _setupDio() {
    _dio = Dio();
    _dio.options.baseUrl = AppConstants.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

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

  Future<void> _loadMedicalStoreId() async {
    try {
      final userId = await StorageService.getUserId();
      if (userId != null) {
        setState(() {
          _medicalStoreId = userId;
        });
        await _loadDeliveryBoys();
      }
    } catch (e) {
      AppLogger.error('Error loading medical store ID: $e');
      setState(() {
        _errorMessage = 'Failed to load medical store information';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDeliveryBoys() async {
    if (_medicalStoreId == null) {
      setState(() {
        _errorMessage = 'Medical store ID not found';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      AppLogger.info('Fetching active delivery boys for medical store: $_medicalStoreId');

      // GET /api/Delivery/medicalstore/{medicalStoreId}/active
      final response = await _dio.get('/Deliveries/medicalstore/$_medicalStoreId/active');

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> deliveryList;

        if (data is List) {
          deliveryList = data;
        } else if (data is Map && data.containsKey('data')) {
          deliveryList = data['data'] as List;
        } else {
          deliveryList = [];
        }

        AppLogger.info('Received ${deliveryList.length} active delivery boys');

        final deliveryBoys = deliveryList
            .map((json) => DeliveryBoy.fromJson(json))
            .toList();

        setState(() {
          _deliveryBoys = deliveryBoys;
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      AppLogger.error('Error loading delivery boys: ${e.message}');

      String errorMsg = 'Failed to load delivery boys';
      if (e.response?.statusCode == 401) {
        errorMsg = 'Authentication failed. Please login again.';
      } else if (e.response?.statusCode == 404) {
        errorMsg = 'No active delivery boys found';
      }

      setState(() {
        _errorMessage = errorMsg;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Unexpected error: $e');
      setState(() {
        _errorMessage = 'An unexpected error occurred';
        _isLoading = false;
      });
    }
  }

  Future<void> _assignDeliveryBoy() async {
    if (_selectedDeliveryBoy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a delivery boy'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isAssigning = true;
    });

    try {
      AppLogger.info(
          'Assigning order ${widget.order.orderId} to delivery boy ${_selectedDeliveryBoy!.id}');

      // POST /api/Orders/assign-to-delivery
      final response = await _dio.post(
        '/Orders/assign-to-delivery',
        data: {
          'OrderId': widget.order.orderId,
          'DeliveryId': _selectedDeliveryBoy!.id,
        },
      );

      if (response.statusCode == 200) {
        AppLogger.info('Order assigned to delivery boy successfully');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                        'Order assigned to ${_selectedDeliveryBoy!.fullName}'),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          if (widget.onComplete != null) {
            widget.onComplete!();
          }

          Navigator.pop(context, true);
        }
      }
    } on DioException catch (e) {
      AppLogger.error('Error assigning delivery boy: ${e.message}');

      String errorMsg = 'Failed to assign delivery boy';
      if (e.response?.data != null) {
        if (e.response?.data is Map) {
          final errorData = e.response?.data as Map;
          if (errorData.containsKey('error')) {
            errorMsg = errorData['error'].toString();
          } else if (errorData.containsKey('message')) {
            errorMsg = errorData['message'].toString();
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Unexpected error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAssigning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Delivery Boy'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Order info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Order #${widget.order.orderNumber ?? widget.order.orderId}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Customer: ${widget.customerName}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                if (widget.order.totalAmount != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Amount: ₹${widget.order.totalAmount!.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Content
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
      bottomNavigationBar: _selectedDeliveryBoy != null
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: _isAssigning ? null : _assignDeliveryBoy,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isAssigning
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Assign & Send for Delivery',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.black),
            SizedBox(height: 16),
            Text('Loading delivery boys...'),
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
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadDeliveryBoys,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_deliveryBoys.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delivery_dining, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'No Active Delivery Boys',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please add delivery boys to your medical store first',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _deliveryBoys.length,
      itemBuilder: (context, index) {
        final deliveryBoy = _deliveryBoys[index];
        final isSelected = _selectedDeliveryBoy?.id == deliveryBoy.id;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDeliveryBoy = deliveryBoy;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delivery_dining,
                    color: isSelected ? Colors.white : Colors.black,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deliveryBoy.fullName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        deliveryBoy.mobileNumber,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected
                              ? Colors.white.withOpacity(0.9)
                              : Colors.grey.shade700,
                        ),
                      ),
                      if (deliveryBoy.drivingLicenceNumber != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'DL: ${deliveryBoy.drivingLicenceNumber}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? Colors.white.withOpacity(0.8)
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 28,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Delivery Boy Model
class DeliveryBoy {
  final int id;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String mobileNumber;
  final String? drivingLicenceNumber;
  final bool isActive;

  DeliveryBoy({
    required this.id,
    this.firstName,
    this.middleName,
    this.lastName,
    required this.mobileNumber,
    this.drivingLicenceNumber,
    required this.isActive,
  });

  String get fullName {
    final parts = [
      firstName,
      middleName,
      lastName,
    ].where((part) => part != null && part.isNotEmpty).toList();

    return parts.isEmpty ? 'Delivery Boy #$id' : parts.join(' ');
  }

  factory DeliveryBoy.fromJson(Map<String, dynamic> json) {
    return DeliveryBoy(
      id: json['id'] as int,
      firstName: json['firstName'] as String?,
      middleName: json['middleName'] as String?,
      lastName: json['lastName'] as String?,
      mobileNumber: json['mobileNumber'] as String? ?? '',
      drivingLicenceNumber: json['drivingLicenceNumber'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}