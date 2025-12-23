// Complete Delivery Screen
// Delivery boy enters OTP from customer to complete delivery
// Verifies OTP against order.completionOtp
// Changes order status to "Completed"

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:pharmaish/shared/models/order_model.dart';

class CompleteDeliveryScreen extends StatefulWidget {
  final OrderModel order;
  final String customerName;
  final String? customerPhone;

  const CompleteDeliveryScreen({
    Key? key,
    required this.order,
    required this.customerName,
    this.customerPhone,
  }) : super(key: key);

  @override
  State<CompleteDeliveryScreen> createState() => _CompleteDeliveryScreenState();
}

class _CompleteDeliveryScreenState extends State<CompleteDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  final List<TextEditingController> _digitControllers =
      List.generate(4, (index) => TextEditingController());

  bool _isCompleting = false;
  late Dio _dio;

  @override
  void initState() {
    super.initState();
    _setupDio();
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

  Future<void> _completeDelivery() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Build OTP from individual digits
    final otp = _digitControllers.map((c) => c.text).join();

    if (otp.length != 4) {
      _showErrorDialog('Please enter complete 4-digit OTP');
      return;
    }

    setState(() {
      _isCompleting = true;
    });

    try {
      AppLogger.info('Completing delivery for order ${widget.order.orderId} with OTP: $otp');

      // PUT /api/Orders/{orderId}/complete
      final response = await _dio.put(
        '/Orders/${widget.order.orderId}/complete',
        data: {
          'OTP': otp,
        },
      );

      if (response.statusCode == 200) {
        AppLogger.info('Delivery completed successfully');

        if (mounted) {
          // Show success dialog
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 32),
                  SizedBox(width: 12),
                  Text('Delivery Complete!'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${widget.order.orderNumber ?? widget.order.orderId} has been successfully delivered.',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Colors.green.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.customerName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(true); // Return to dashboard with success
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Done'),
                ),
              ],
            ),
          );
        }
      }
    } on DioException catch (e) {
      AppLogger.error('Error completing delivery: ${e.message}');

      String errorMsg = 'Failed to complete delivery';
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

      // Check if it's an OTP mismatch error
      if (errorMsg.toLowerCase().contains('otp') ||
          errorMsg.toLowerCase().contains('invalid') ||
          e.response?.statusCode == 400) {
        _showErrorDialog('Invalid OTP. Please check with customer and try again.');
      } else {
        _showErrorDialog(errorMsg);
      }
    } catch (e) {
      AppLogger.error('Unexpected error: $e');
      _showErrorDialog('An unexpected error occurred');
    } finally {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    for (var controller in _digitControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Delivery'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.receipt_long, color: Colors.purple.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Order #${widget.order.orderNumber ?? widget.order.orderId}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Customer', widget.customerName),
                    if (widget.customerPhone != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow('Phone', widget.customerPhone!),
                    ],
                    if (widget.order.totalAmount != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Amount',
                        '₹${widget.order.totalAmount!.toStringAsFixed(2)}',
                      ),
                    ],
                    if (widget.order.shippingAddressLine1 != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow('Address', widget.order.shippingAddressLine1!, maxLines: 3),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Instructions
              Center(
                child: Icon(
                  Icons.verified_user,
                  size: 64,
                  color: Colors.purple.shade700,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Enter OTP from Customer',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Ask the customer for their 4-digit delivery OTP to complete the order',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // OTP Input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 60,
                    height: 70,
                    child: TextFormField(
                      controller: _digitControllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        if (value.length == 1 && index < 3) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        
                        // Auto-submit when all 4 digits entered
                        if (index == 3 && value.isNotEmpty) {
                          final allFilled = _digitControllers.every((c) => c.text.isNotEmpty);
                          if (allFilled) {
                            FocusScope.of(context).unfocus();
                          }
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '';
                        }
                        return null;
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 40),

              // Complete button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isCompleting ? null : _completeDelivery,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey.shade400,
                  ),
                  child: _isCompleting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Verify OTP & Complete',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Help text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'The customer should have received their OTP when the order was placed. Ask them to share it with you.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {int maxLines = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}