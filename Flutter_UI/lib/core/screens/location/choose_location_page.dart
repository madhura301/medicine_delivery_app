import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pharmaish/core/services/location_service.dart';
import 'package:pharmaish/core/theme/app_theme.dart';
import 'package:pharmaish/core/screens/profiles/customer_profile_page.dart' show AddAddressDialog;
import 'package:pharmaish/shared/widgets/address_selector_widget.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/app_logger.dart';

class ChooseLocationPage extends StatefulWidget {
  final String? customerId;

  const ChooseLocationPage({super.key, this.customerId});

  @override
  State<ChooseLocationPage> createState() => _ChooseLocationPageState();
}

class _ChooseLocationPageState extends State<ChooseLocationPage> {
  static const Color _greenAccent = Color(0xFF2E7D32);

  final TextEditingController _pincodeController = TextEditingController();
  final LocationService _locationService = LocationService();

  List<CustomerAddressDto> _addresses = [];
  bool _isLoadingAddresses = true;
  bool _isCheckingPincode = false;
  bool _isLocating = false;
  String? _customerId;

  // Pincode check result
  String? _pincodeMessage;
  bool _pincodeServiceable = false;

  @override
  void initState() {
    super.initState();
    _initCustomerId();
  }

  Future<void> _initCustomerId() async {
    _customerId = widget.customerId ?? await StorageService.getUserId();
    if (_customerId != null && _customerId!.isNotEmpty) {
      _loadAddresses();
    } else {
      setState(() => _isLoadingAddresses = false);
    }
  }

  @override
  void dispose() {
    _pincodeController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // API: Load saved addresses
  // ---------------------------------------------------------------------------
  Future<void> _loadAddresses() async {
    setState(() {
      _isLoadingAddresses = true;
    });

    try {
      final token = await StorageService.getAuthToken();
      if (token == null) {
        setState(() => _isLoadingAddresses = false);
        return;
      }

      final response = await http.get(
        Uri.parse(
            '${AppConstants.apiBaseUrl}/CustomerAddresses/customer/$_customerId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        setState(() {
          _addresses = jsonList
              .map((j) => CustomerAddressDto.fromJson(j))
              .toList();
          _isLoadingAddresses = false;
        });
      } else {
        AppLogger.error(
            'Failed to load addresses: ${response.statusCode}');
        setState(() => _isLoadingAddresses = false);
      }
    } catch (e) {
      AppLogger.error('Error loading addresses: $e');
      setState(() => _isLoadingAddresses = false);
    }
  }

  // ---------------------------------------------------------------------------
  // API: Check pincode serviceability
  // ---------------------------------------------------------------------------
  Future<void> _checkPincode(String pincode) async {
    if (pincode.trim().length != 6) {
      setState(() {
        _pincodeMessage = 'Please enter a valid 6-digit pincode';
        _pincodeServiceable = false;
      });
      return;
    }

    setState(() {
      _isCheckingPincode = true;
      _pincodeMessage = null;
    });

    try {
      final token = await StorageService.getAuthToken();
      final response = await http.get(
        Uri.parse(
            '${AppConstants.apiBaseUrl}/ServiceRegions/by-pincode/${pincode.trim()}'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _pincodeServiceable = true;
          _pincodeMessage = 'Great! We deliver to this area';
        });
      } else {
        setState(() {
          _pincodeServiceable = false;
          _pincodeMessage = 'This area is not serviceable yet';
        });
      }
    } catch (e) {
      AppLogger.error('Pincode check error: $e');
      setState(() {
        _pincodeServiceable = false;
        _pincodeMessage = 'This area is not serviceable yet';
      });
    } finally {
      setState(() => _isCheckingPincode = false);
    }
  }

  // ---------------------------------------------------------------------------
  // GPS: Select current location
  // ---------------------------------------------------------------------------
  Future<void> _selectCurrentLocation() async {
    setState(() => _isLocating = true);

    try {
      final result = await _locationService.getCurrentLocation();

      if (result.hasError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error!),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
        setState(() => _isLocating = false);
        return;
      }

      // Auto-fill pincode if available and check serviceability
      if (result.postalCode != null && result.postalCode!.isNotEmpty) {
        _pincodeController.text = result.postalCode!;
        await _checkPincode(result.postalCode!);
      } else {
        setState(() {
          _pincodeMessage = 'Could not detect pincode from your location';
          _pincodeServiceable = false;
        });
      }
    } catch (e) {
      AppLogger.error('Location error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to get current location'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  // ---------------------------------------------------------------------------
  // API: Set default address and pop
  // ---------------------------------------------------------------------------
  Future<void> _selectAddress(CustomerAddressDto address) async {
    try {
      final token = await StorageService.getAuthToken();
      if (token != null && _customerId != null) {
        await http.put(
          Uri.parse(
              '${AppConstants.apiBaseUrl}/CustomerAddresses/customer/$_customerId/set-default/${address.addressId}'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      AppLogger.error('Error setting default address: $e');
    }

    if (mounted) {
      Navigator.pop(context, address);
    }
  }

  // ---------------------------------------------------------------------------
  // UI: Add new address dialog
  // ---------------------------------------------------------------------------
  void _showAddAddressDialog() {
    if (_customerId == null || _customerId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to add an address'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AddAddressDialog(
          customerId: _customerId!,
          onAddressAdded: () {
            _loadAddresses();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Address added successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildPincodeSection(),
                    const SizedBox(height: 20),
                    _buildCurrentLocationRow(),
                    const Divider(height: 32),
                    _buildSavedAddressesSection(),
                    const SizedBox(height: 16),
                    _buildAddNewAddressCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, size: 24, color: Colors.black87),
            tooltip: 'Back',
          ),
          const SizedBox(width: 4),
          const Text(
            'Choose your Location',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Pincode check section
  // ---------------------------------------------------------------------------
  Widget _buildPincodeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Check delivery availability',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'Enter pincode',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  counterText: '',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _greenAccent, width: 2),
                  ),
                  prefixIcon: Icon(Icons.pin_drop_outlined,
                      color: Colors.grey.shade500),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isCheckingPincode
                    ? null
                    : () => _checkPincode(_pincodeController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _greenAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: _isCheckingPincode
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Check',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
        if (_pincodeMessage != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                _pincodeServiceable
                    ? Icons.check_circle_outline
                    : Icons.error_outline,
                size: 18,
                color: _pincodeServiceable ? _greenAccent : AppTheme.errorColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _pincodeMessage!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _pincodeServiceable
                        ? _greenAccent
                        : AppTheme.errorColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Select current location
  // ---------------------------------------------------------------------------
  Widget _buildCurrentLocationRow() {
    return InkWell(
      onTap: _isLocating ? null : _selectCurrentLocation,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _greenAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _isLocating
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(_greenAccent),
                      ),
                    )
                  : const Icon(Icons.my_location, color: _greenAccent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isLocating ? 'Detecting location...' : 'Select Current Location',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _greenAccent,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Using GPS to find your area',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Saved addresses section
  // ---------------------------------------------------------------------------
  Widget _buildSavedAddressesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Saved Addresses',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        if (_isLoadingAddresses)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: _greenAccent),
            ),
          )
        else if (_addresses.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Icon(Icons.location_off_outlined,
                      size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Text(
                    'No saved addresses yet',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ..._addresses.map(_buildAddressCard),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Single address card
  // ---------------------------------------------------------------------------
  Widget _buildAddressCard(CustomerAddressDto address) {
    final bool isDefault = address.isDefault;
    final String label = (address.address != null && address.address!.isNotEmpty)
        ? address.address!
        : 'Address';

    // Build subtitle lines
    final List<String> lines = [];
    final line1Parts = <String>[];
    if (address.addressLine1 != null && address.addressLine1!.isNotEmpty) {
      line1Parts.add(address.addressLine1!);
    }
    if (address.addressLine2 != null && address.addressLine2!.isNotEmpty) {
      line1Parts.add(address.addressLine2!);
    }
    if (address.addressLine3 != null && address.addressLine3!.isNotEmpty) {
      line1Parts.add(address.addressLine3!);
    }
    if (line1Parts.isNotEmpty) lines.add(line1Parts.join(', '));

    final cityPin = <String>[];
    if (address.city != null && address.city!.isNotEmpty) {
      cityPin.add(address.city!);
    }
    if (address.postalCode != null && address.postalCode!.isNotEmpty) {
      cityPin.add(address.postalCode!);
    }
    if (cityPin.isNotEmpty) lines.add(cityPin.join(' - '));

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => _selectAddress(address),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDefault
                ? _greenAccent.withOpacity(0.04)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDefault ? _greenAccent.withOpacity(0.4) : Colors.grey.shade200,
              width: isDefault ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _greenAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.location_on,
                    color: _greenAccent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _greenAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Default',
                              style: TextStyle(
                                fontSize: 10,
                                color: _greenAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (lines.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      ...lines.map(
                        (line) => Text(
                          line,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isDefault)
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.check_circle, color: _greenAccent, size: 22),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Add new address card (dashed border)
  // ---------------------------------------------------------------------------
  Widget _buildAddNewAddressCard() {
    return InkWell(
      onTap: _showAddAddressDialog,
      borderRadius: BorderRadius.circular(14),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: Colors.grey.shade400,
          borderRadius: 14,
          dashWidth: 6,
          dashSpace: 4,
          strokeWidth: 1.5,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _greenAccent.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: _greenAccent, size: 26),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add New Address',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _greenAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Dashed border painter
// =============================================================================
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  _DashedBorderPainter({
    required this.color,
    required this.borderRadius,
    required this.dashWidth,
    required this.dashSpace,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, end.clamp(0, metric.length)),
          paint,
        );
        distance = end + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
