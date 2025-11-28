// File: lib/shared/widgets/delivery_location_selector.dart
import 'package:flutter/material.dart';
import 'package:pharmaish/core/services/location_service.dart';
import 'package:pharmaish/core/theme/app_theme.dart';
import 'package:pharmaish/utils/app_logger.dart';

/// Model class to hold delivery location data
class DeliveryLocationData {
  final bool useCurrentLocation;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final String? formattedAddress;

  DeliveryLocationData({
    required this.useCurrentLocation,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.formattedAddress,
  });

  bool get isValid {
    if (useCurrentLocation) {
      return latitude != null && longitude != null;
    } else {
      return addressLine1 != null &&
          addressLine1!.isNotEmpty &&
          city != null &&
          city!.isNotEmpty &&
          state != null &&
          state!.isNotEmpty;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'useCurrentLocation': useCurrentLocation,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

/// Reusable widget for selecting delivery location
class DeliveryLocationSelector extends StatefulWidget {
  final Function(DeliveryLocationData) onLocationSelected;
  final String title;
  final String subtitle;
  final DeliveryLocationData? initialLocation;

  const DeliveryLocationSelector({
    Key? key,
    required this.onLocationSelected,
    this.title = 'Delivery Location',
    this.subtitle = 'Where should we deliver your order?',
    this.initialLocation,
  }) : super(key: key);

  @override
  State<DeliveryLocationSelector> createState() =>
      _DeliveryLocationSelectorState();
}

class _DeliveryLocationSelectorState extends State<DeliveryLocationSelector> {
  final LocationService _locationService = LocationService();

  bool _useCurrentLocation = true;
  bool _isLoadingLocation = false;
  String? _errorMessage;

  // Current location data
  double? _latitude;
  double? _longitude;
  String? _currentLocationAddress;

  // Manual address controllers
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  String? _selectedState;

  final List<String> _states = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
  ];

  @override
  void initState() {
    super.initState();
    _initializeWithPreviousLocation();
  }

  void _initializeWithPreviousLocation() {
    if (widget.initialLocation != null) {
      setState(() {
        _useCurrentLocation = widget.initialLocation!.useCurrentLocation;
        if (_useCurrentLocation) {
          _latitude = widget.initialLocation!.latitude;
          _longitude = widget.initialLocation!.longitude;
          _currentLocationAddress = widget.initialLocation!.formattedAddress;
        } else {
          _addressLine1Controller.text =
              widget.initialLocation!.addressLine1 ?? '';
          _addressLine2Controller.text =
              widget.initialLocation!.addressLine2 ?? '';
          _cityController.text = widget.initialLocation!.city ?? '';
          _postalCodeController.text = widget.initialLocation!.postalCode ?? '';
          _selectedState = widget.initialLocation!.state;
        }
      });
    }
  }

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _errorMessage = null;
    });

    try {
      final LocationResult result = await _locationService.getCurrentLocation(
        includeAddress: true,
        timeLimit: const Duration(seconds: 20),
      );

      if (result.isValid) {
        setState(() {
          _latitude = result.latitude;
          _longitude = result.longitude;
          _currentLocationAddress = result.address;
          _isLoadingLocation = false;
        });

        _notifyLocationChange();
        AppLogger.info('Current location obtained for delivery');
      } else {
        setState(() {
          _errorMessage = result.error ?? 'Unable to get current location';
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: ${e.toString()}';
        _isLoadingLocation = false;
      });
      AppLogger.error('Location error: $e');
    }
  }

  void _notifyLocationChange() {
    final locationData = DeliveryLocationData(
      useCurrentLocation: _useCurrentLocation,
      addressLine1:
          _useCurrentLocation ? null : _addressLine1Controller.text.trim(),
      addressLine2:
          _useCurrentLocation ? null : _addressLine2Controller.text.trim(),
      city: _useCurrentLocation ? null : _cityController.text.trim(),
      state: _useCurrentLocation ? null : _selectedState,
      postalCode:
          _useCurrentLocation ? null : _postalCodeController.text.trim(),
      latitude: _useCurrentLocation ? _latitude : null,
      longitude: _useCurrentLocation ? _longitude : null,
      formattedAddress: _useCurrentLocation ? _currentLocationAddress : null,
    );

    widget.onLocationSelected(locationData);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.subtitle,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 24),

        // Location type selector
        _buildLocationTypeSelector(),

        const SizedBox(height: 24),

        // Show error if any
        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Content based on selection
        if (_useCurrentLocation)
          _buildCurrentLocationContent()
        else
          _buildManualAddressForm(),
      ],
    );
  }

  Widget _buildLocationTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildLocationOption(
            title: 'Deliver to Current Location',
            subtitle: 'Use GPS to get your current address',
            icon: Icons.my_location,
            iconColor: AppTheme.primaryColor,
            isSelected: _useCurrentLocation,
            onTap: () {
              setState(() {
                _useCurrentLocation = true;
                _errorMessage = null;
              });
              if (_latitude == null || _longitude == null) {
                _getCurrentLocation();
              } else {
                _notifyLocationChange();
              }
            },
          ),
          Divider(height: 1, color: Colors.grey.shade300),
          _buildLocationOption(
            title: 'Enter Address Manually',
            subtitle: 'Provide your delivery address',
            icon: Icons.edit_location_alt,
            iconColor: Colors.orange,
            isSelected: !_useCurrentLocation,
            onTap: () {
              setState(() {
                _useCurrentLocation = false;
                _errorMessage = null;
              });
              _notifyLocationChange();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? iconColor.withValues(alpha: 0.15)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? iconColor : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Radio<bool>(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onTap(),
              activeColor: iconColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLocationContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: AppTheme.primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Current Location',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoadingLocation)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_latitude != null && _longitude != null) ...[
            Text(
              _currentLocationAddress ?? 'Location obtained',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lat: ${_latitude!.toStringAsFixed(6)}, Long: ${_longitude!.toStringAsFixed(6)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.refresh),
                label: const Text('Update Location'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ),
          ] else ...[
            const Text(
              'No location detected yet',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Get Current Location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildManualAddressForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _addressLine1Controller,
          label: 'Address Line 1 *',
          hint: 'Building name, flat number',
          icon: Icons.home,
          onChanged: (_) => _notifyLocationChange(),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _addressLine2Controller,
          label: 'Address Line 2',
          hint: 'Area, landmark',
          icon: Icons.location_on_outlined,
          onChanged: (_) => _notifyLocationChange(),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _cityController,
          label: 'City *',
          hint: 'Enter city',
          icon: Icons.location_city,
          onChanged: (_) => _notifyLocationChange(),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _postalCodeController,
          label: 'Postal Code',
          hint: 'Enter postal code',
          icon: Icons.pin_drop,
          keyboardType: TextInputType.number,
          maxLength: 6,
          onChanged: (_) => _notifyLocationChange(),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        counterText: '',
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedState != null && _states.contains(_selectedState)
          ? _selectedState
          : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'State *',
        prefixIcon: const Icon(Icons.map, color: AppTheme.primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
      items: _states.map((String state) {
        return DropdownMenuItem<String>(
          value: state,
          child: Text(state, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedState = newValue;
        });
        _notifyLocationChange();
      },
    );
  }
}