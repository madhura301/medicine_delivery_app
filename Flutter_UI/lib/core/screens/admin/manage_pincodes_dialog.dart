import 'package:flutter/material.dart';
import 'package:pharmaish/core/services/region_service.dart';
import 'package:pharmaish/shared/widgets/confirm_dialog.dart';

class ManagePincodesDialog extends StatefulWidget {
  final Map<String, dynamic> region;
  final List<String> initialPincodes;
  final VoidCallback onSaved;

  const ManagePincodesDialog({super.key, 
    required this.region,
    required this.initialPincodes,
    required this.onSaved,
  });

  @override
  State<ManagePincodesDialog> createState() => ManagePincodesDialogState();
}

class ManagePincodesDialogState extends State<ManagePincodesDialog> {
  late List<String> _allPincodes;
  List<String> _filteredPincodes = [];
  final _pincodeController = TextEditingController();
  final _searchController = TextEditingController();
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _allPincodes = List.from(widget.initialPincodes);
    _filteredPincodes = List.from(_allPincodes);
  }

  @override
  void dispose() {
    _pincodeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterPincodes(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredPincodes = List.from(_allPincodes);
      } else {
        _filteredPincodes =
            _allPincodes.where((pincode) => pincode.contains(query)).toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterPincodes('');
  }

  Future<void> _addPincode() async {
    final pincode = _pincodeController.text.trim();

    if (pincode.isEmpty) {
      _showError('Please enter a pincode');
      return;
    }

    if (pincode.length != 6) {
      _showError('Pincode must be 6 digits');
      return;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(pincode)) {
      _showError('Pincode must contain only numbers');
      return;
    }

    if (_allPincodes.contains(pincode)) {
      _showError('Pincode already added');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final regionId = widget.region['id'] ?? widget.region['Id'];
      await RegionService.addPincodeToRegion(
        regionId: (regionId as num).toInt(),
        pinCode: pincode,
      );
      setState(() {
        _allPincodes.add(pincode);
        _pincodeController.clear();
        _filterPincodes(_searchQuery);
      });
      _showSuccess('Pincode added');
    } catch (e) {
      _showError('Failed to add pincode: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removePincode(String pincode) async {
    final confirm = await confirmAction(
      context,
      title: 'Confirm Deletion',
      message: 'Are you sure you want to remove pincode $pincode?',
      confirmLabel: 'Remove',
    );

    if (!confirm) return;

    setState(() => _isLoading = true);

    try {
      final regionId = widget.region['id'] ?? widget.region['Id'];
      await RegionService.removePincodeFromRegion(
        regionId: (regionId as num).toInt(),
        pinCode: pincode,
      );
      setState(() {
        _allPincodes.remove(pincode);
        _filterPincodes(_searchQuery);
      });
      _showSuccess('Pincode removed');
    } catch (e) {
      _showError('Failed to remove pincode: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 550,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.pin_drop, color: Colors.blue, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Manage Pincodes',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.region['name'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      widget.onSaved();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Add pincode section
                      const Text(
                        'Add New Pincode',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _pincodeController,
                              decoration: const InputDecoration(
                                labelText: 'Pincode',
                                hintText: '411001',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.add_location),
                                counterText: '',
                                helperText: '6-digit pincode',
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              onSubmitted: (_) => _addPincode(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _addPincode,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.add),
                            label: const Text('Add'),
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
                      const Divider(),
                      const SizedBox(height: 16),

                      // Pincodes list header with search
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pincodes (${_allPincodes.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_filteredPincodes.length} found',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Search bar
                      if (_allPincodes.length > 5)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _filterPincodes,
                            decoration: InputDecoration(
                              hintText: 'Search pincodes...',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                              prefixIcon: const Icon(Icons.search, size: 20),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 20),
                                      onPressed: _clearSearch,
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              isDense: true,
                            ),
                          ),
                        ),

                      // Pincodes list with scrolling
                      if (_allPincodes.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.location_off,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No pincodes added yet',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (_filteredPincodes.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No pincodes found matching "$_searchQuery"',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                TextButton.icon(
                                  onPressed: _clearSearch,
                                  icon: const Icon(Icons.clear),
                                  label: const Text('Clear Search'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Container(
                          constraints: const BoxConstraints(
                            maxHeight: 350,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: _filteredPincodes.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final pincode = _filteredPincodes[index];
                                return ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    radius: 20,
                                    child: Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    pincode,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: _isLoading
                                        ? null
                                        : () => _removePincode(pincode),
                                    tooltip: 'Remove pincode',
                                  ),
                                  tileColor: index.isEven
                                      ? Colors.transparent
                                      : Colors.grey.shade50,
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_allPincodes.length} pincode${_allPincodes.length == 1 ? '' : 's'} in region',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      widget.onSaved();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
