import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class PincodeLookupDialog extends StatefulWidget {
  final Dio dio;
  final TextEditingController pincodeController;
  final List<Map<String, dynamic>> allRegions;

  const PincodeLookupDialog({
    required this.dio,
    required this.pincodeController,
    required this.allRegions,
  });

  @override
  State<PincodeLookupDialog> createState() => PincodeLookupDialogState();
}

class PincodeLookupDialogState extends State<PincodeLookupDialog> {
  bool _isSearching = false;
  Map<String, dynamic>? _foundRegion;
  String? _errorMessage;
  String? _searchedPincode;

  Future<void> _searchPincode() async {
    final pincode = widget.pincodeController.text.trim();

    if (pincode.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a pincode';
        _foundRegion = null;
      });
      return;
    }

    if (pincode.length != 6) {
      setState(() {
        _errorMessage = 'Pincode must be 6 digits';
        _foundRegion = null;
      });
      return;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(pincode)) {
      setState(() {
        _errorMessage = 'Pincode must contain only numbers';
        _foundRegion = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _foundRegion = null;
      _searchedPincode = pincode;
    });

    try {
      final response = await widget.dio.get(
        '/CustomerSupportRegions/by-pincode/$pincode',
      );

      if (response.statusCode == 200) {
        setState(() {
          _foundRegion = response.data;
          _isSearching = false;
        });
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        setState(() {
          _errorMessage = 'No region found for pincode $pincode';
          _foundRegion = null;
          _isSearching = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Error searching pincode: ${e.message}';
          _foundRegion = null;
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Unexpected error: $e';
        _foundRegion = null;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.search, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Search Pincode',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Find which region a pincode belongs to',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Search input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.pincodeController,
                    decoration: InputDecoration(
                      labelText: 'Enter Pincode',
                      hintText: '411001',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.location_on),
                      counterText: '',
                      helperText: '6-digit pincode',
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    onSubmitted: (_) => _searchPincode(),
                    autofocus: true,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isSearching ? null : _searchPincode,
                  icon: _isSearching
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.search),
                  label: const Text('Search'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Results
            if (_isSearching)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Searching...'),
                    ],
                  ),
                ),
              )
            else if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
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
              )
            else if (_foundRegion != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Region Found!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900,
                                ),
                              ),
                              Text(
                                'Pincode $_searchedPincode belongs to:',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.business,
                      'Region Name',
                      _foundRegion!['name'] ?? 'N/A',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.location_city,
                      'City',
                      _foundRegion!['city'] ?? 'N/A',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.map,
                      'Region Code',
                      _foundRegion!['regionName'] ?? 'N/A',
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            // Scroll to the region in the main list
                            _scrollToRegion(_foundRegion!['id']);
                          },
                          icon: const Icon(Icons.visibility),
                          label: const Text('View Region'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.location_searching,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Enter a pincode to search',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Footer with tips
            if (_foundRegion == null && _errorMessage == null && !_isSearching)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tip: You can press Enter to search quickly',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _scrollToRegion(int regionId) {
    // This will be implemented in the parent widget
    // For now, just close the dialog
  }
}