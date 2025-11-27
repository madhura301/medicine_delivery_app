import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmaish/core/screens/profiles/customer_profile_page.dart';
import 'dart:convert';
import 'package:pharmaish/core/theme/app_theme.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:pharmaish/utils/constants.dart';

class CustomerAddressDto {
  final String? addressId;
  final String customerId;
  final String? address;
  final String? addressLine1;
  final String? addressLine2;
  final String? addressLine3;
  final String? city;
  final String? state;
  final String? postalCode;
  final bool isDefault;
  final bool isActive;
  final DateTime createdOn;
  final DateTime? updatedOn;

  CustomerAddressDto({
    this.addressId,
    required this.customerId,
    this.address,
    this.addressLine1,
    this.addressLine2,
    this.addressLine3,
    this.city,
    this.state,
    this.postalCode,
    this.isDefault = false,
    this.isActive = true,
    required this.createdOn,
    this.updatedOn,
  });

  factory CustomerAddressDto.fromJson(Map<String, dynamic> json) {
    return CustomerAddressDto(
      addressId: json['id'] ?? json['addressId'],
      customerId: json['customerId'] ?? '',
      address: json['address'],
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      addressLine3: json['addressLine3'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      isDefault: json['isDefault'] ?? false,
      isActive: json['isActive'] ?? true,
      createdOn:
          DateTime.parse(json['createdOn'] ?? DateTime.now().toIso8601String()),
      updatedOn:
          json['updatedOn'] != null ? DateTime.parse(json['updatedOn']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addressId': addressId,
      'customerId': customerId,
      'address': address,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'addressLine3': addressLine3,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'isDefault': isDefault,
      'isActive': isActive,
      'createdOn': createdOn.toIso8601String(),
      'updatedOn': updatedOn?.toIso8601String(),
    };
  }

  String get fullAddress {
    List<String> parts = [];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (addressLine1 != null && addressLine1!.isNotEmpty)
      parts.add(addressLine1!);
    if (addressLine2 != null && addressLine2!.isNotEmpty)
      parts.add(addressLine2!);
    if (addressLine3 != null && addressLine3!.isNotEmpty)
      parts.add(addressLine3!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (postalCode != null && postalCode!.isNotEmpty) parts.add(postalCode!);
    return parts.join(', ');
  }
}

/// Reusable widget for address selection in order screens
class AddressSelectorWidget extends StatefulWidget {
  final String customerId;
  final Function(CustomerAddressDto?) onAddressSelected;
  final Color? themeColor;

  const AddressSelectorWidget({
    super.key,
    required this.customerId,
    required this.onAddressSelected,
    this.themeColor,
  });

  @override
  State<AddressSelectorWidget> createState() => _AddressSelectorWidgetState();
}

class _AddressSelectorWidgetState extends State<AddressSelectorWidget> {
  List<CustomerAddressDto> _addresses = [];
  CustomerAddressDto? _selectedAddress;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final token = await StorageService.getAuthToken();
      if (token == null) {
        setState(() {
          _errorMessage = 'Authentication required';
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(
            '${AppConstants.apiBaseUrl}/CustomerAddresses/customer/${widget.customerId}'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      AppLogger.info('Response body: ${response.body}');
      AppLogger.info(
          'Fetching customer addresses for ID: ${widget.customerId}');
      AppLogger.info(
          'Customer addresses response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        AppLogger.info('Decoded JSON list: $jsonList');
        setState(() {
          _addresses = jsonList
              .map((json) => CustomerAddressDto.fromJson(json))
              .toList();
          AppLogger.info('Parsed ${_addresses.length} addresses');
          // Auto-select default address
          _selectedAddress = _addresses.isNotEmpty
              ? _addresses.firstWhere(
                  (addr) => addr.isDefault,
                  orElse: () => _addresses.first,
                )
              : null;

          _isLoading = false;

          // Notify parent
          widget.onAddressSelected(_selectedAddress);
        });

        AppLogger.info('Loaded ${_addresses.length} addresses');
      } else {
        setState(() {
          _errorMessage = 'Failed to load addresses';
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Error loading addresses: $e');
      setState(() {
        _errorMessage = 'Network error. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _showAddAddressDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddAddressDialog(
          customerId: widget.customerId,
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

  @override
  Widget build(BuildContext context) {
    final color = widget.themeColor ?? AppTheme.primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Delivery Address',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: _showAddAddressDialog,
              icon: Icon(Icons.add, color: color, size: 20),
              label: Text(
                'Add New',
                style: TextStyle(color: color),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Loading State
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          ),

        // Error State
        if (!_isLoading && _errorMessage.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
                TextButton(
                  onPressed: _loadAddresses,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),

        // No Addresses State
        if (!_isLoading && _errorMessage.isEmpty && _addresses.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Icon(Icons.location_off, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'No delivery addresses found',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please add a delivery address to continue',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _showAddAddressDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Address'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

        // Address List
        if (!_isLoading && _errorMessage.isEmpty && _addresses.isNotEmpty)
          Column(
            children: _addresses.map((address) {
              final isSelected =
                  _selectedAddress?.addressId == address.addressId;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: isSelected ? 4 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? color : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedAddress = address;
                    });
                    widget.onAddressSelected(address);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Radio Button
                        Radio<String?>(
                          value: address.addressId,
                          groupValue: _selectedAddress?.addressId,
                          activeColor: color,
                          onChanged: (value) {
                            setState(() => _selectedAddress = address);
                            widget.onAddressSelected(address);
                          },
                        ),
                        const SizedBox(width: 12),

                        // Address Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Address Label
                              if (address.address != null &&
                                  address.address!.isNotEmpty)
                                Row(
                                  children: [
                                    Text(
                                      address.address!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color:
                                            isSelected ? color : Colors.black,
                                      ),
                                    ),
                                    if (address.isDefault) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(color: color),
                                        ),
                                        child: Text(
                                          'Default',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: color,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              const SizedBox(height: 4),

                              // Full Address
                              Text(
                                address.fullAddress,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Selection Icon
                        if (isSelected)
                          Icon(Icons.check_circle, color: color, size: 24),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
