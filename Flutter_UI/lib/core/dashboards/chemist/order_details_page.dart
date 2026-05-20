import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharmaish/core/services/order_service.dart';
import 'package:pharmaish/shared/models/order_enums.dart';
import 'package:pharmaish/shared/models/order_model.dart';
import 'package:pharmaish/shared/widgets/authenticated_image.dart';
import 'package:pharmaish/shared/widgets/order_assignment_history_widget.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/consent_manager.dart';

class OrderDetailsPage extends StatefulWidget {
  final OrderModel order;
  final String customerName;
  final String? customerEmail;
  final String? customerPhone;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onRefresh;

  const OrderDetailsPage({
    super.key,
    required this.order,
    required this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.onAccept,
    this.onReject,
    this.onRefresh,
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  bool _isPlaying = false;
late OrderModel _currentOrder;
  bool _isLoadingHistory = true;

   @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _fetchFullOrder();
  }

  Future<void> _fetchFullOrder() async {
    try {
      final json = await OrderService.getOrderById(_currentOrder.orderId);
      setState(() {
        _currentOrder = OrderModel.fromJson(json);
        _isLoadingHistory = false;
      });
    } catch (e) {
      AppLogger.error('Error fetching full order: $e');
      setState(() => _isLoadingHistory = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Order #${_currentOrder.orderNumber ?? _currentOrder.orderId}',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusBanner(),
            _buildOrderInfoCard(),
            _buildPrescriptionSection(),
            _buildDeliveryAddressCard(),
            if (_currentOrder.rejectionReason != null &&
                _currentOrder.rejectionReason!.isNotEmpty)
              _buildRejectionReasonCard(),
            if (_currentOrder.totalAmount != null) _buildTotalAmountCard(),
            OrderAssignmentHistoryWidget(
              order: _currentOrder,
              isAdminView: false,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _isPendingStatus(_currentOrder.status)
          ? _buildBottomActionBar()
          : null,
    );
  }

  bool _isPendingStatus(String status) {
    final statusLower = status.toLowerCase();
    return statusLower.contains('pending') || statusLower.contains('assigned');
  }

  Widget _buildStatusBanner() {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    final statusLower = _currentOrder.status.toLowerCase();

    if (statusLower.contains('pending') || statusLower.contains('assigned')) {
      backgroundColor = Colors.orange.shade100;
      textColor = Colors.orange.shade900;
      icon = Icons.pending_actions;
    } else if (statusLower.contains('accepted') ||
        statusLower.contains('bill') ||
        statusLower.contains('delivery')) {
      backgroundColor = Colors.green.shade100;
      textColor = Colors.green.shade900;
      icon = Icons.check_circle;
    } else if (statusLower.contains('rejected')) {
      backgroundColor = Colors.red.shade100;
      textColor = Colors.red.shade900;
      icon = Icons.cancel;
    } else if (statusLower.contains('completed')) {
      backgroundColor = Colors.blue.shade100;
      textColor = Colors.blue.shade900;
      icon = Icons.done_all;
    } else {
      backgroundColor = Colors.grey.shade200;
      textColor = Colors.grey.shade900;
      icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(width: 8),
          Text(
            _currentOrder.status.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.person, 'Name', widget.customerName),
            if (widget.customerEmail != null &&
                widget.customerEmail!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.email, 'Email', widget.customerEmail!),
            ],
            if (widget.customerPhone != null &&
                widget.customerPhone!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.phone, 'Phone', widget.customerPhone!),
            ],
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.calendar_today,
              'Order Date',
              DateFormat('MMM dd, yyyy - hh:mm a')
                  .format(_currentOrder.createdOn),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrescriptionSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Prescription',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildInputTypeChip(_currentOrder.orderInputType),
              ],
            ),
            const SizedBox(height: 16),
            _buildPrescriptionContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputTypeChip(OrderInputType type) {
    IconData icon;
    Color color;
    String label;

    switch (type) {
      case OrderInputType.image:
        icon = Icons.image;
        color = Colors.blue;
        label = 'Image';
        break;
      case OrderInputType.voice:
        icon = Icons.mic;
        color = Colors.purple;
        label = 'Voice';
        break;
      case OrderInputType.text:
        icon = Icons.text_fields;
        color = Colors.green;
        label = 'Text';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionContent() {
    switch (_currentOrder.orderInputType) {
      case OrderInputType.image:
        return _buildImagePrescription();
      case OrderInputType.voice:
        return _buildVoicePrescription();
      case OrderInputType.text:
        return _buildTextPrescription();
    }
  }

  Future<void> _viewPrescriptionWithConsent() async {
    final accepted =
        await PharmacistConsentManager.showPrescriptionAccessPermission(
      context,
      orderId: _currentOrder.orderId,
      customerId: _currentOrder.customerId,
    );

    if (!accepted) {
      return;
    }

    if (_currentOrder.prescriptionFileUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No prescription image available')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text('Prescription'),
            backgroundColor: Colors.black,
            actions: [
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () {
                  // TODO: Implement download
                },
              ),
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4,
              child: AuthNetworkImage(
                url: getOrderInputFileUrl(_currentOrder.orderId),
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'Failed to load prescription image',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadPrescriptionImage() async {
    await downloadPrescriptionImage(
      context,
      orderId: _currentOrder.orderId,
      prescriptionFileUrl: _currentOrder.prescriptionFileUrl,
    );
  }

  Widget _buildImagePrescription() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _viewPrescriptionWithConsent(),
          child: Container(
            constraints: const BoxConstraints(minHeight: 250),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AuthNetworkImage(
                url: getOrderInputFileUrl(_currentOrder.orderId),
                fit: BoxFit.contain,
                width: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    height: 250,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return SizedBox(
                    height: 250,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            extractFileName(_currentOrder.prescriptionFileUrl).isNotEmpty
                                ? extractFileName(_currentOrder.prescriptionFileUrl)
                                : 'Failed to load prescription',
                            style: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton.icon(
            onPressed: () => _downloadPrescriptionImage(),
            icon: const Icon(Icons.download),
            label: const Text('Download'),
          ),
        ),
      ],
    );
  }

  Widget _buildVoicePrescription() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        children: [
          Icon(
            _isPlaying ? Icons.pause_circle : Icons.play_circle,
            size: 60,
            color: Colors.purple.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            _currentOrder.voiceNoteUrl ?? 'Voice Recording',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() => _isPlaying = !_isPlaying);
                  // TODO: Implement actual audio playback
                },
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 32,
                ),
                color: Colors.purple,
              ),
              Expanded(
                child: Slider(
                  value: 0.3,
                  onChanged: (value) {
                    // TODO: Implement seek functionality
                  },
                  activeColor: Colors.purple,
                ),
              ),
              const Text('0:45 / 2:30'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () {
                  // TODO: Implement download
                },
                icon: const Icon(Icons.download),
                label: const Text('Download'),
              ),
              TextButton.icon(
                onPressed: () {
                  // TODO: Implement speed control
                },
                icon: const Icon(Icons.speed),
                label: const Text('Speed'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextPrescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.text_fields, color: Colors.green.shade700),
              const SizedBox(width: 8),
              Text(
                'Text Prescription',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _currentOrder.prescriptionText ?? 'No prescription text available',
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                // TODO: Implement copy to clipboard
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressCard() {
    final address = [
      _currentOrder.shippingAddressLine1,
      _currentOrder.shippingAddressLine2,
      _currentOrder.shippingArea,
      _currentOrder.shippingCity,
     _currentOrder.shippingPincode,
    ].where((e) => e != null && e.isNotEmpty).join(', ');

    if (address.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Address',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Colors.black, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    address,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectionReasonCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Text(
                  'Rejection Reason',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                _currentOrder.rejectionReason!,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalAmountCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Amount',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '₹${_currentOrder.totalAmount!.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.onReject,
                icon: const Icon(Icons.close, color: Colors.white),
                label: const Text(
                  'Reject Order',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.onAccept,
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text(
                  'Accept Order',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
