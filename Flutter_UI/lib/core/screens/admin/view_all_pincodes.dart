
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pharmaish/utils/app_logger.dart';

class ViewAllPincodesPage extends StatefulWidget {
  final Dio dio;
  final List<Map<String, dynamic>> regions;

  const ViewAllPincodesPage({
    Key? key,
    required this.dio,
    required this.regions,
  }) : super(key: key);

  @override
  State<ViewAllPincodesPage> createState() => _ViewAllPincodesPageState();
}

class _ViewAllPincodesPageState extends State<ViewAllPincodesPage> {
  Map<String, Map<String, dynamic>> _pincodeToRegion = {};
  List<MapEntry<String, Map<String, dynamic>>> _filteredPincodes = [];
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllPincodes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllPincodes() async {
    setState(() => _isLoading = true);

    try {
      for (var region in widget.regions) {
        final regionId = region['id'] ?? region['Id'];
        final response = await widget.dio.get(
          '/ServiceRegions/$regionId/pincodes',
        );

        if (response.statusCode == 200) {
          final pincodes =
              (response.data as List).map((e) => e.toString()).toList();
          for (var pincode in pincodes) {
            _pincodeToRegion[pincode] = region;
          }
        }
      }

      _filterPincodes('');
    } catch (e) {
      AppLogger.error('Error loading pincodes: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterPincodes(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredPincodes = _pincodeToRegion.entries.toList();
      } else {
        _filteredPincodes = _pincodeToRegion.entries
            .where((entry) =>
                entry.key.contains(query) ||
                entry.value['name']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                entry.value['city']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }

      _filteredPincodes.sort((a, b) => a.key.compareTo(b.key));
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterPincodes('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Pincodes'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllPincodes,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterPincodes,
                    decoration: InputDecoration(
                      hintText: 'Search by pincode, region, or city...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_filteredPincodes.length}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Stats bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_pincodeToRegion.length} total pincodes',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${widget.regions.length} regions',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPincodes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No pincodes found'
                                  : 'No results for "$_searchQuery"',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _filteredPincodes.length,
                        itemBuilder: (context, index) {
                          final entry = _filteredPincodes[index];
                          final pincode = entry.key;
                          final region = entry.value;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Text(
                                  region['regionName']
                                          ?.toString()
                                          .substring(0, 1)
                                          .toUpperCase() ??
                                      'R',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                pincode,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    region['name'] ?? 'Unknown Region',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    '${region['city']} - ${region['regionName']}',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
