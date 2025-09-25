import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:medicine_delivery_app/core/services/location-service.dart';
import 'package:medicine_delivery_app/utils/constants.dart';

class PharmacistProfilePage extends StatefulWidget {
  final String pharmacistId;

  const PharmacistProfilePage({super.key, required this.pharmacistId});

  @override
  State<PharmacistProfilePage> createState() => _PharmacistProfilePageState();
}

class _PharmacistProfilePageState extends State<PharmacistProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final LocationService _locationService = LocationService();
  // Controllers for all form fields
  final _pharmacyNameController = TextEditingController();
  final _ownerFirstNameController = TextEditingController();
  final _ownerLastNameController = TextEditingController();
  final _ownerMiddleNameController = TextEditingController();
  final _gstNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _alternativeMobileController = TextEditingController();
  final _panController = TextEditingController();
  final _fssaiController = TextEditingController();
  final _dlController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _pharmacistFirstNameController = TextEditingController();
  final _pharmacistLastNameController = TextEditingController();
  final _pharmacistRegNumberController = TextEditingController();
  final _pharmacistMobileController = TextEditingController();

  // Form state variables
  bool _isGstRegistered = false;
  bool _isLoading = false;
  bool _isLoadingProfile = true;
  bool _isEditMode = false;
  String _errorMessage = '';
  String _successMessage = '';
  double? _latitude;
  double? _longitude;
  String _locationText = 'No location selected';
  String? _selectedState;
  String _userName = ''; // Store username (cannot be edited)

  final List<String> _states = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand',
    'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur',
    'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan',
    'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh',
    'Uttarakhand', 'West Bengal', 'Delhi', 'Jammu and Kashmir', 'Ladakh',
    'Lakshadweep', 'Puducherry'
  ];

  @override
  void initState() {
    super.initState();
    _loadPharmacistProfile();
  }

  Future<void> _loadPharmacistProfile() async {
    setState(() {
      _isLoadingProfile = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/Pharmacist/profile/${widget.pharmacistId}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final profileData = jsonDecode(response.body);
        _populateFormFields(profileData);
      } else {
        setState(() {
          _errorMessage = 'Failed to load profile data';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Please check your connection.';
      });
      print('Profile load error: $e');
    } finally {
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  void _populateFormFields(Map<String, dynamic> data) {
    setState(() {
      _pharmacyNameController.text = data['pharmacyName'] ?? '';
      _ownerFirstNameController.text = data['ownerFirstName'] ?? '';
      _ownerLastNameController.text = data['ownerLastName'] ?? '';
      _ownerMiddleNameController.text = data['ownerMiddleName'] ?? '';
      _isGstRegistered = data['isGstRegistered'] ?? false;
      _gstNumberController.text = data['gstNumber'] ?? '';
      _userName = data['userName'] ?? '';
      _emailController.text = data['email'] ?? '';
      _alternativeMobileController.text = data['alternativeMobile'] ?? '';
      _panController.text = data['panNumber'] ?? '';
      _fssaiController.text = data['fssaiNumber'] ?? '';
      _dlController.text = data['dlNumber'] ?? '';
      _addressLine1Controller.text = data['addressLine1'] ?? '';
      _addressLine2Controller.text = data['addressLine2'] ?? '';
      _cityController.text = data['city'] ?? '';
      _selectedState = data['state'];
      _latitude = data['latitude']?.toDouble();
      _longitude = data['longitude']?.toDouble();
      _pharmacistFirstNameController.text = data['pharmacistFirstName'] ?? '';
      _pharmacistLastNameController.text = data['pharmacistLastName'] ?? '';
      _pharmacistRegNumberController.text = data['pharmacistRegNumber'] ?? '';
      _pharmacistMobileController.text = data['pharmacistMobile'] ?? '';
      
      if (_latitude != null && _longitude != null) {
        _locationText = 'Lat: ${_latitude!.toStringAsFixed(6)}, Long: ${_longitude!.toStringAsFixed(6)}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isEditMode && !_isLoadingProfile)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _isEditMode = true;
                  _errorMessage = '';
                  _successMessage = '';
                });
              },
              icon: const Icon(Icons.edit, color: Colors.white, size: 18),
              label: const Text(
                'Edit',
                style: TextStyle(color: Colors.white),
              ),
            ),
          if (_isEditMode)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _isEditMode = false;
                  _errorMessage = '';
                  _successMessage = '';
                });
                _loadPharmacistProfile(); // Reload original data
              },
              icon: const Icon(Icons.close, color: Colors.white, size: 18),
              label: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoadingProfile
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF2E7D32)),
                  SizedBox(height: 16),
                  Text('Loading profile...'),
                ],
              ),
            )
          : Column(
              children: [
                // Edit Mode Indicator
                if (_isEditMode)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    child: Row(
                      children: [
                        const Icon(Icons.edit, color: Color(0xFF2E7D32), size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'Edit Mode - Make changes to your profile',
                          style: TextStyle(
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Messages
                if (_errorMessage.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red.shade600, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (_successMessage.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _successMessage,
                            style: TextStyle(color: Colors.green.shade600, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Form Content
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pharmacy Details Section
                          _buildSection(
                            title: 'Pharmacy Details',
                            icon: Icons.local_pharmacy,
                            children: [
                              _buildTextField(
                                controller: _pharmacyNameController,
                                label: 'Pharmacy/Firm Name',
                                icon: Icons.store,
                                enabled: _isEditMode,
                                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _ownerFirstNameController,
                                      label: 'Owner First Name',
                                      icon: Icons.person,
                                      enabled: _isEditMode,
                                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _ownerLastNameController,
                                      label: 'Owner Last Name',
                                      icon: Icons.person,
                                      enabled: _isEditMode,
                                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _ownerMiddleNameController,
                                label: 'Owner Middle Name (Optional)',
                                icon: Icons.person_outline,
                                enabled: _isEditMode,
                              ),
                              const SizedBox(height: 16),
                              
                              // GST Section
                              if (_isEditMode) ...[
                                const Text(
                                  'GST Registration',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      RadioListTile<bool>(
                                        title: const Text('GST Registered'),
                                        value: true,
                                        groupValue: _isGstRegistered,
                                        activeColor: const Color(0xFF2E7D32),
                                        onChanged: (value) {
                                          setState(() {
                                            _isGstRegistered = value!;
                                          });
                                        },
                                      ),
                                      RadioListTile<bool>(
                                        title: const Text('GST Un-Registered'),
                                        value: false,
                                        groupValue: _isGstRegistered,
                                        activeColor: const Color(0xFF2E7D32),
                                        onChanged: (value) {
                                          setState(() {
                                            _isGstRegistered = value!;
                                            if (!_isGstRegistered) {
                                              _gstNumberController.clear();
                                            }
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ] else ...[
                                _buildReadOnlyField('GST Status', _isGstRegistered ? 'Registered' : 'Un-Registered'),
                                const SizedBox(height: 16),
                              ],

                              if (_isGstRegistered) ...[
                                _buildTextField(
                                  controller: _gstNumberController,
                                  label: 'GST Number',
                                  icon: Icons.receipt_long,
                                  enabled: _isEditMode,
                                  validator: (value) {
                                    if (_isGstRegistered && (value?.isEmpty ?? true)) {
                                      return 'GST number is required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],

                              _buildReadOnlyField('Mobile Number (Username)', _userName),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _emailController,
                                label: 'Email (Optional)',
                                icon: Icons.email,
                                enabled: _isEditMode,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return null;
                                  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                                  return emailRegex.hasMatch(value) ? null : 'Invalid email';
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _alternativeMobileController,
                                label: 'Alternative Mobile',
                                icon: Icons.phone_android,
                                enabled: _isEditMode,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) return 'Required';
                                  final phoneRegex = RegExp(r'^[6-9]\d{9}$');
                                  return phoneRegex.hasMatch(value!) ? null : 'Invalid mobile number';
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // License Details Section
                          _buildSection(
                            title: 'License Details',
                            icon: Icons.verified_user,
                            children: [
                              _buildTextField(
                                controller: _panController,
                                label: 'PAN Number',
                                icon: Icons.credit_card,
                                enabled: _isEditMode,
                                textCapitalization: TextCapitalization.characters,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) return 'Required';
                                  final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
                                  return panRegex.hasMatch(value!) ? null : 'Invalid PAN format';
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _fssaiController,
                                label: 'FSSAI Number',
                                icon: Icons.verified_user,
                                enabled: _isEditMode,
                                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _dlController,
                                label: 'Drug License Number',
                                icon: Icons.medical_services,
                                enabled: _isEditMode,
                                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Address Section
                          _buildSection(
                            title: 'Address Details',
                            icon: Icons.location_on,
                            children: [
                              _buildTextField(
                                controller: _addressLine1Controller,
                                label: 'Address Line 1',
                                icon: Icons.home,
                                enabled: _isEditMode,
                                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _addressLine2Controller,
                                label: 'Address Line 2 (Optional)',
                                icon: Icons.home_outlined,
                                enabled: _isEditMode,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _cityController,
                                      label: 'City',
                                      icon: Icons.location_city,
                                      enabled: _isEditMode,
                                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _isEditMode 
                                        ? _buildDropdownField()
                                        : _buildTextField(
                                            controller: TextEditingController(text: _selectedState ?? ''),
                                            label: 'State',
                                            icon: Icons.map,
                                            enabled: false,
                                          ),
                                  ),
                                ],
                              ),
                              if (_isEditMode) ...[
                                const SizedBox(height: 20),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.map, color: Color(0xFF2E7D32)),
                                          const SizedBox(width: 8),
                                          const Text('Location:', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(_locationText),
                                      const SizedBox(height: 12),
                                      ElevatedButton.icon(
                                        onPressed: _checkLocationAndRequest,//_getCurrentLocation,
                                        icon: const Icon(Icons.my_location),
                                        label: const Text('Update Location'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF2E7D32),
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else if (_latitude != null && _longitude != null) ...[
                                const SizedBox(height: 16),
                                _buildReadOnlyField('Location', _locationText),
                              ],
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Pharmacist Details Section
                          _buildSection(
                            title: 'Pharmacist Details',
                            icon: Icons.person_pin,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _pharmacistFirstNameController,
                                      label: 'Pharmacist First Name',
                                      icon: Icons.person,
                                      enabled: _isEditMode,
                                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _pharmacistLastNameController,
                                      label: 'Pharmacist Last Name',
                                      icon: Icons.person,
                                      enabled: _isEditMode,
                                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _pharmacistRegNumberController,
                                label: 'Registration Number',
                                icon: Icons.badge,
                                enabled: _isEditMode,
                                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _pharmacistMobileController,
                                label: 'Pharmacist Mobile',
                                icon: Icons.phone,
                                enabled: _isEditMode,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) return 'Required';
                                  final phoneRegex = RegExp(r'^[6-9]\d{9}$');
                                  return phoneRegex.hasMatch(value!) ? null : 'Invalid mobile number';
                                },
                              ),
                            ],
                          ),

                          if (_isEditMode) const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),

                // Save Button (only show in edit mode)
                if (_isEditMode)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF2E7D32)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool enabled = true,
    TextInputType? keyboardType,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null 
            ? Icon(icon, color: enabled ? const Color(0xFF2E7D32) : Colors.grey) 
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: !enabled,
        fillColor: Colors.grey.shade50,
        counterText: maxLength != null ? '' : null,
      ),
      validator: validator,
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isNotEmpty ? value : 'Not provided',
            style: TextStyle(
              fontSize: 16,
              color: value.isNotEmpty ? Colors.black : Colors.grey.shade500,
              fontStyle: value.isNotEmpty ? FontStyle.normal : FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedState,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'State',
        prefixIcon: const Icon(Icons.map, color: Color(0xFF2E7D32)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
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
      },
      validator: (value) => value == null ? 'Please select a state' : null,
    );
  }


Future<void> _getCurrentLocation() async {
    setState(() {
      _locationText = 'Getting your location...';
      _errorMessage = '';
    });

    try {
      final LocationResult result = await _locationService.getCurrentLocation(
        includeAddress: true,
        timeLimit: const Duration(seconds: 20),
      );

      setState(() {
        if (result.isValid) {
          _latitude = result.latitude;
          _longitude = result.longitude;
          
          // Format the location text based on whether we have an address
          if (result.address != null && result.address!.isNotEmpty) {
            _locationText = '${result.address}\n'
                'Lat: ${result.latitude.toStringAsFixed(6)}, '
                'Long: ${result.longitude.toStringAsFixed(6)}';
          } else {
            _locationText = 'Location selected\n'
                'Lat: ${result.latitude.toStringAsFixed(6)}, '
                'Long: ${result.longitude.toStringAsFixed(6)}';
          }
          _errorMessage = '';
        } else {
          _errorMessage = result.error ?? 'Unable to get location';
          _locationText = 'Tap to select location';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Please check your connection and try again.';
        _locationText = 'Tap to select location';
      });
      print('Location error: $e');
    }
  }

Future<void> _checkLocationAndRequest() async {
    bool isAvailable = await _locationService.isLocationServiceAvailable();
    
    if (!isAvailable) {
      // Try to request permission first
      bool granted = await _locationService.requestLocationPermission();
      if (granted) {
        _getCurrentLocation();
      } else {
        setState(() {
          _errorMessage = 'Location permission is required to continue.';
          _locationText = 'Tap to select location';
        });
      }
    } else {
      _getCurrentLocation();
    }
  }


  Future<void> _updateProfile() async {
    if (widget.pharmacistId == null) {
      setState(() {
        _errorMessage = 'Profile not available. Please login again.';
      });
      return;
    }

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = 'Please fix the errors above';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      final updateData = {
        'pharmacistId': widget.pharmacistId,
        'pharmacyDetails': {
          'pharmacyName': _pharmacyNameController.text.trim(),
          'ownerFirstName': _ownerFirstNameController.text.trim(),
          'ownerLastName': _ownerLastNameController.text.trim(),
          'ownerMiddleName': _ownerMiddleNameController.text.trim(),
          'isGstRegistered': _isGstRegistered,
          'gstNumber': _isGstRegistered ? _gstNumberController.text.trim() : null,
          'email': _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
          'alternativeMobile': _alternativeMobileController.text.trim(),
          'panNumber': _panController.text.trim(),
          'fssaiNumber': _fssaiController.text.trim(),
          'dlNumber': _dlController.text.trim(),
        },
        'addressDetails': {
          'addressLine1': _addressLine1Controller.text.trim(),
          'addressLine2': _addressLine2Controller.text.trim(),
          'city': _cityController.text.trim(),
          'state': _selectedState,
          'latitude': _latitude,
          'longitude': _longitude,
        },
        'pharmacistDetails': {
          'firstName': _pharmacistFirstNameController.text.trim(),
          'lastName': _pharmacistLastNameController.text.trim(),
          'registrationNumber': _pharmacistRegNumberController.text.trim(),
          'mobileNumber': _pharmacistMobileController.text.trim(),
        }
      };

      final response = await http.put(
        Uri.parse('${AppConstants.apiBaseUrl}/Pharmacist/update-profile/${widget.pharmacistId}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Add authorization header if needed
          // 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updateData),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        setState(() {
          _successMessage = 'Profile updated successfully!';
          _isEditMode = false;
        });
        
        // Optional: Show success dialog
        _showSuccessDialog();
      } else if (response.statusCode == 400) {
        try {
          final errorData = jsonDecode(response.body);
          final errors = errorData['errors'] as List<dynamic>?;
          setState(() {
            _errorMessage = errors?.isNotEmpty == true
                ? errors!.first.toString()
                : 'Invalid update data. Please check your inputs.';
          });
        } catch (e) {
          setState(() {
            _errorMessage = 'Invalid update data. Please check your inputs.';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Server error. Please try again later.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Network error. Please check your connection.';
      });
      print('Update error: $e');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Success!',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Your profile has been updated successfully.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _pharmacyNameController.dispose();
    _ownerFirstNameController.dispose();
    _ownerLastNameController.dispose();
    _ownerMiddleNameController.dispose();
    _gstNumberController.dispose();
    _emailController.dispose();
    _alternativeMobileController.dispose();
    _panController.dispose();
    _fssaiController.dispose();
    _dlController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _pharmacistFirstNameController.dispose();
    _pharmacistLastNameController.dispose();
    _pharmacistRegNumberController.dispose();
    _pharmacistMobileController.dispose();
    super.dispose();
  }
}