// Accepted Order Bill Upload Screen - WITH PDF SUPPORT
// For chemist to upload bill (IMAGE or PDF) and enter amount for accepted orders
// Supports: JPEG, PNG, PDF files
// Uses POST /api/Orders/{orderId}/upload-bill endpoint

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:pharmaish/shared/models/order_model.dart';

class AcceptedOrderBillScreen extends StatefulWidget {
  final OrderModel order;
  final String customerName;
  final String? customerEmail;
  final String? customerPhone;
  final VoidCallback? onComplete;

  const AcceptedOrderBillScreen({
    Key? key,
    required this.order,
    required this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.onComplete,
  }) : super(key: key);

  @override
  State<AcceptedOrderBillScreen> createState() =>
      _AcceptedOrderBillScreenState();
}

class _AcceptedOrderBillScreenState extends State<AcceptedOrderBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  File? _billFile;
  String? _billFileName;
  String? _billFileType; // 'image' or 'pdf'
  bool _isUploading = false;
  
  late Dio _dio;

  @override
  void initState() {
    super.initState();
    _setupDio();
    
    // Pre-fill amount if available
    if (widget.order.totalAmount != null) {
      _amountController.text = widget.order.totalAmount.toString();
    }
  }

  void _setupDio() {
    _dio = Dio();
    _dio.options.baseUrl = AppConstants.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 60);
    _dio.options.receiveTimeout = const Duration(seconds: 60);

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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _billFile = File(image.path);
          _billFileName = image.name;
          _billFileType = 'image';
        });
        AppLogger.info('Image selected: ${image.name}');
      }
    } catch (e) {
      AppLogger.error('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // Check file size (max 10MB)
        if (file.size > 10 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PDF file is too large. Maximum size is 10MB.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }

        setState(() {
          _billFile = File(file.path!);
          _billFileName = file.name;
          _billFileType = 'pdf';
        });
        
        AppLogger.info('PDF selected: ${file.name}, Size: ${(file.size / 1024).toStringAsFixed(2)} KB');
      }
    } catch (e) {
      AppLogger.error('Error picking PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showFileSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Upload Bill/Invoice',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose image or PDF file',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            
            // Image options
            Row(
              children: [
                Expanded(
                  child: _buildFileSourceOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFileSourceOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    color: Colors.green,
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // PDF option
            SizedBox(
              width: double.infinity,
              child: _buildFileSourceOption(
                icon: Icons.picture_as_pdf,
                label: 'PDF File',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _pickPdfFile();
                },
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSourceOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadBillAndAmount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_billFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Please select a bill file to upload')),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      final notes = _notesController.text.trim();

      // Determine file extension
      String fileExtension;
      if (_billFileType == 'pdf') {
        fileExtension = 'pdf';
      } else {
        // Get extension from file path
        final path = _billFile!.path.toLowerCase();
        if (path.endsWith('.jpg') || path.endsWith('.jpeg')) {
          fileExtension = 'jpg';
        } else if (path.endsWith('.png')) {
          fileExtension = 'png';
        } else {
          fileExtension = 'jpg'; // default
        }
      }

      // Create FormData matching the backend UploadOrderBillDto
      // Required fields: OrderId, OrderAmount, BillFile
      // Optional: Notes
      final formDataMap = {
        'OrderId': widget.order.orderId,
        'OrderAmount': amount,
        'BillFile': await MultipartFile.fromFile(
          _billFile!.path,
          filename: 'bill_order_${widget.order.orderId}.$fileExtension',
        ),
      };

      // Add notes if provided
      if (notes.isNotEmpty) {
        formDataMap['Notes'] = notes;
      }

      FormData formData = FormData.fromMap(formDataMap);

      AppLogger.info(
          'Uploading bill for order ${widget.order.orderId} - Type: $_billFileType, Amount: ₹$amount');

      // POST request to /api/Orders/{orderId}/upload-bill
      final response = await _dio.post(
        '/Orders/${widget.order.orderId}/upload-bill',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        AppLogger.info(
            'Bill uploaded successfully for order ${widget.order.orderId}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text('Bill uploaded successfully!')),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );

          // Call onComplete callback if provided
          if (widget.onComplete != null) {
            widget.onComplete!();
          }

          // Go back with success result
          Navigator.pop(context, true);
        }
      }
    } on DioException catch (e) {
      AppLogger.error('DioException uploading bill: ${e.message}');
      AppLogger.error('Response status: ${e.response?.statusCode}');
      AppLogger.error('Response data: ${e.response?.data}');

      String errorMessage = 'Failed to upload bill';

      if (e.response?.data != null) {
        if (e.response?.data is Map) {
          final errorData = e.response?.data as Map;

          // Handle ModelState validation errors
          if (errorData.containsKey('errors')) {
            final errors = errorData['errors'] as Map;
            final errorMessages = <String>[];
            errors.forEach((key, value) {
              if (value is List) {
                errorMessages.addAll(value.map((e) => e.toString()));
              } else {
                errorMessages.add(value.toString());
              }
            });
            errorMessage = errorMessages.join('\n');
          }
          // Handle general error message
          else if (errorData.containsKey('error')) {
            errorMessage = errorData['error'].toString();
          } else if (errorData.containsKey('message')) {
            errorMessage = errorData['message'].toString();
          }
        } else if (e.response?.data is String) {
          errorMessage = e.response?.data as String;
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Upload timeout. The file might be too large.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Connection error. Please check your internet connection.';
      } else if (e.type == DioExceptionType.badResponse) {
        errorMessage =
            'Server error (${e.response?.statusCode}). Please try again.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _uploadBillAndAmount,
            ),
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Unexpected error uploading bill: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Unexpected error: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Upload Bill',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Order number banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            child: Row(
              children: [
                const Icon(Icons.receipt_long, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Order #${widget.order.orderNumber ?? widget.order.orderId}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Info Card
                    _buildInfoCard(
                      title: 'Customer Information',
                      icon: Icons.person,
                      children: [
                        _buildInfoRow('Name', widget.customerName),
                        if (widget.customerEmail != null)
                          _buildInfoRow('Email', widget.customerEmail!),
                        if (widget.customerPhone != null)
                          _buildInfoRow('Phone', widget.customerPhone!),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Order Info Card
                    _buildInfoCard(
                      title: 'Order Information',
                      icon: Icons.shopping_bag,
                      children: [
                        _buildInfoRow('Order ID',
                            widget.order.orderNumber ?? widget.order.orderId.toString()),
                        _buildInfoRow('Status', widget.order.status),
                        if (widget.order.orderInputType.name.isNotEmpty)
                          _buildInfoRow('Type', widget.order.orderInputType.name),
                        if (widget.order.shippingAddressLine1 != null)
                          _buildInfoRow('Address', widget.order.shippingAddressLine1!,
                              maxLines: 3),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Bill Upload Section
                    const Text(
                      'Bill/Invoice Upload',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Upload an image (JPEG, PNG) or PDF file',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // File Upload Button/Preview
                    if (_billFile == null)
                      InkWell(
                        onTap: _showFileSourceDialog,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Tap to Upload Bill',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Image or PDF (max 10MB)',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      _buildFilePreview(),

                    const SizedBox(height: 24),

                    // Amount Input
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: InputDecoration(
                        hintText: 'Enter total amount',
                        prefixIcon: const Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Notes Input (Optional)
                    const Text(
                      'Notes (Optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add any additional notes...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Upload Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : _uploadBillAndAmount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey.shade400,
                        ),
                        child: _isUploading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.upload_file, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Upload Bill & Amount',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Icon(icon, size: 20, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
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
      ),
    );
  }

  Widget _buildFilePreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // File icon and info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _billFileType == 'pdf'
                      ? Colors.red.shade50
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _billFileType == 'pdf'
                      ? Icons.picture_as_pdf
                      : Icons.image,
                  size: 32,
                  color: _billFileType == 'pdf'
                      ? Colors.red.shade700
                      : Colors.blue.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _billFileName ?? 'Bill file',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _billFileType == 'pdf' ? 'PDF Document' : 'Image File',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Image preview (only for images)
          if (_billFileType == 'image' && _billFile != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _billFile!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          const SizedBox(height: 12),

          // Change file button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showFileSourceDialog,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Change File'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}