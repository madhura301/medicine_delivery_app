// COMPLETE CUSTOMER SUPPORT DASHBOARD
// Copy this entire file to replace lib/core/dashboards/support_dashboard.dart

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pharmaish/config/environment_config.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/storage.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/shared/widgets/step_progress_indicator.dart';
import 'package:pharmaish/shared/models/order_model.dart';

// ============================================================================
// CUSTOMER SUPPORT DASHBOARD - MAIN
// ============================================================================

class CustomerSupportDashboard extends StatefulWidget {
  const CustomerSupportDashboard({Key? key}) : super(key: key);

  @override
  State<CustomerSupportDashboard> createState() =>
      _CustomerSupportDashboardState();
}

class _CustomerSupportDashboardState extends State<CustomerSupportDashboard> {
  int _selectedIndex = 0;
  late Dio _dio;

  @override
  void initState() {
    super.initState();
    _setupDio();
  }

  void _setupDio() {
    _dio = Dio();
    _dio.options.baseUrl = AppConstants.apiBaseUrl;
    _dio.options.connectTimeout = EnvironmentConfig.timeoutDuration;
    _dio.options.receiveTimeout = EnvironmentConfig.timeoutDuration;

    if (EnvironmentConfig.shouldLog) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        logPrint: (object) => AppLogger.info('API: ${object.toString()}'),
      ));
    }

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (EnvironmentConfig.shouldLog) {
          AppLogger.error('API Error: ${error.message}');
          AppLogger.error('Status Code: ${error.response?.statusCode}');
          AppLogger.error('Response Data: ${error.response?.data}');
        }
        handler.next(error);
      },
    ));
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.clearAll();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Support Dashboard';
      case 1:
        return 'Rejected Orders';
      case 2:
        return 'Create WhatsApp Order';
      default:
        return 'Customer Support';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getPageTitle(),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {});
            },
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboardHome(),
          RejectedOrdersPage(dio: _dio),
          WhatsAppOrderCreationPage(dio: _dio),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            decoration: const BoxDecoration(color: Colors.black),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child:
                      Icon(Icons.support_agent, size: 40, color: Colors.black),
                ),
                const SizedBox(height: 12),
                FutureBuilder<String?>(
                  future: StorageService.getUserName(),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? 'Support Agent',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  'Customer Support',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.dashboard, color: Colors.black),
                  title: const Text('Dashboard'),
                  selected: _selectedIndex == 0,
                  selectedTileColor: Colors.black.withOpacity(0.1),
                  onTap: () {
                    setState(() => _selectedIndex = 0);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.assignment_return, color: Colors.red),
                  title: const Text('Rejected Orders'),
                  selected: _selectedIndex == 1,
                  selectedTileColor: Colors.black.withOpacity(0.1),
                  onTap: () {
                    setState(() => _selectedIndex = 1);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.message, color: Colors.green),
                  title: const Text('WhatsApp Orders'),
                  selected: _selectedIndex == 2,
                  selectedTileColor: Colors.black.withOpacity(0.1),
                  onTap: () {
                    setState(() => _selectedIndex = 2);
                    Navigator.of(context).pop();
                  },
                ),
                const Divider(height: 1),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () => _handleLogout(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDashboardHome() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.support_agent, size: 100, color: Colors.black),
            const SizedBox(height: 24),
            const Text(
              'Customer Support Dashboard',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Manage rejected orders and create WhatsApp orders',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 40),
            _buildQuickActionCard(
              icon: Icons.assignment_return,
              title: 'Rejected Orders',
              subtitle: 'Reassign to another chemist',
              color: Colors.red,
              onTap: () => setState(() => _selectedIndex = 1),
            ),
            const SizedBox(height: 16),
            _buildQuickActionCard(
              icon: Icons.message,
              title: 'WhatsApp Orders',
              subtitle: 'Create order on behalf of customer',
              color: Colors.green,
              onTap: () => setState(() => _selectedIndex = 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 20, color: color),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// REJECTED ORDERS PAGE
// ============================================================================

class RejectedOrdersPage extends StatefulWidget {
  final Dio dio;

  const RejectedOrdersPage({Key? key, required this.dio}) : super(key: key);

  @override
  State<RejectedOrdersPage> createState() => _RejectedOrdersPageState();
}

class _RejectedOrdersPageState extends State<RejectedOrdersPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isLoading = true;
  String? _errorMessage;
  List<OrderModel> _rejectedOrders = [];
  final Map<String, Map<String, String>> _customerCache = {};

  @override
  void initState() {
    super.initState();
    _loadRejectedOrders();
  }

  Future<void> _loadRejectedOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      AppLogger.info('Fetching rejected orders');
      final response = await widget.dio.get('/Orders');
      AppLogger.info(response.data.toString());

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> ordersList;
        if (data is List) {
          ordersList = data;
        } else if (data is Map && data.containsKey('data')) {
          ordersList = data['data'] as List;
        } else {
          ordersList = data['orders'] as List;
        }

        final allOrders =
            ordersList.map((json) => OrderModel.fromJson(json)).toList();
        AppLogger.info('Total orders fetched: \${allOrders.length}');
        final rejected = allOrders
            .where((o) => o.status.toLowerCase().contains('rejected'))
            .toList();
        AppLogger.info('Found ${rejected.length} rejected orders' +
            ' out of ${allOrders.length} total orders');
        rejected.sort((a, b) => b.createdOn.compareTo(a.createdOn));

        await _loadCustomerInfo(rejected);

        setState(() {
          _rejectedOrders = rejected;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Error loading rejected orders', e);
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load rejected orders';
      });
    }
  }

  Future<void> _loadCustomerInfo(List<OrderModel> orders) async {
    for (var order in orders) {
      if (!_customerCache.containsKey(order.customerId)) {
        try {
          final response =
              await widget.dio.get('/Customers/\${order.customerId}');

          if (response.statusCode == 200) {
            final customerData = response.data;
            final firstName = customerData['customerFirstName'] ?? '';
            final lastName = customerData['customerLastName'] ?? '';
            final fullName = '$firstName $lastName'.trim();

            _customerCache[order.customerId] = {
              'name': fullName.isEmpty ? 'Customer' : fullName,
              'email': customerData['emailId']?.toString() ?? '',
              'phone': customerData['mobileNumber']?.toString() ?? '',
            };
          }
        } catch (e) {
          _customerCache[order.customerId] = {
            'name': 'Customer',
            'email': '',
            'phone': '',
          };
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadRejectedOrders,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_rejectedOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 80, color: Colors.green.shade300),
            const SizedBox(height: 16),
            const Text(
              'No Rejected Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRejectedOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _rejectedOrders.length,
        itemBuilder: (context, index) {
          final order = _rejectedOrders[index];
          final customerName =
              _customerCache[order.customerId]?['name'] ?? 'Customer';
          return _buildOrderCard(order, customerName);
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, String customerName) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'REJECTED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    customerName,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Order #\${order.orderNumber ?? order.orderId}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (order.rejectionReason != null &&
                order.rejectionReason!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Reason: \${order.rejectionReason}',
                        style: const TextStyle(fontSize: 13, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showReassignDialog(order, customerName),
                icon: const Icon(Icons.autorenew, size: 18),
                label: const Text('Reassign to Another Chemist'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showReassignDialog(
      OrderModel order, String customerName) async {
    // Load available chemists
    List<ChemistModel> chemists = [];
    bool isLoadingChemists = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            if (isLoadingChemists) {
              widget.dio.get('/MedicalStores').then((response) {
                if (response.statusCode == 200) {
                  final List<dynamic> data = response.data;
                  setDialogState(() {
                    chemists = data
                        .map((json) => ChemistModel.fromJson(json))
                        .where((c) => c.isActive)
                        .toList();
                    isLoadingChemists = false;
                  });
                }
              });
            }

            return AlertDialog(
              title: Text(
                  'Reassign Order #\${order.orderNumber ?? order.orderId}'),
              content: isLoadingChemists
                  ? const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: chemists.length,
                        itemBuilder: (context, index) {
                          final chemist = chemists[index];
                          return ListTile(
                            leading:
                                const Icon(Icons.store, color: Colors.blue),
                            title: Text(chemist.medicalName),
                            subtitle:
                                Text('\${chemist.city}, \${chemist.state}'),
                            onTap: () {
                              Navigator.pop(context);
                              _reassignOrder(order, chemist);
                            },
                          );
                        },
                      ),
                    ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _reassignOrder(OrderModel order, ChemistModel chemist) async {
    try {
      // This would be your reassign API call
      // For now, we'll update the status
      await widget.dio.put('/Orders/\${order.orderId}/reassign', data: {
        'medicalStoreId': chemist.medicalStoreId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order reassigned to \${chemist.medicalName}'),
          backgroundColor: Colors.green,
        ),
      );
      _loadRejectedOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to reassign order'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// ============================================================================
// WHATSAPP ORDER CREATION PAGE
// ============================================================================

// COMPLETE WHATSAPP ORDER CREATION WITH CUSTOMER LOOKUP
// Replace the entire WhatsAppOrderCreationPage class in support_dashboard.dart

// Required imports - Add these at the top of support_dashboard.dart if not already present:
// import 'package:file_picker/file_picker.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// ============================================================================
// WHATSAPP ORDER CREATION PAGE - 3-STEP WIZARD WITH CUSTOMER LOOKUP
// ============================================================================

class WhatsAppOrderCreationPage extends StatefulWidget {
  final Dio dio;

  const WhatsAppOrderCreationPage({Key? key, required this.dio})
      : super(key: key);

  @override
  State<WhatsAppOrderCreationPage> createState() =>
      _WhatsAppOrderCreationPageState();
}

class _WhatsAppOrderCreationPageState extends State<WhatsAppOrderCreationPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Customer Lookup
  final _mobileController = TextEditingController();
  bool _isLoadingCustomer = false;
  Map<String, dynamic>? _customerData;
  String? _customerId;

  // Step 2: Prescription Details
  final _prescriptionNotesController = TextEditingController();
  File? _prescriptionFile;
  String? _prescriptionFileName;
  String? _prescriptionFileType; // 'image' or 'pdf'

  // Step 3: Delivery Address (from fetched customer or new)
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  String? _selectedState;
  double? _latitude;
  double? _longitude;

  bool _isSubmitting = false;
  final ImagePicker _imagePicker = ImagePicker();

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
    'Delhi',
  ];

  @override
  void dispose() {
    _mobileController.dispose();
    _prescriptionNotesController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ========== CUSTOMER LOOKUP ==========

  Future<void> _lookupCustomer() async {
    final mobile = _mobileController.text.trim();

    // Validation
    if (mobile.isEmpty) {
      _showError('Please enter mobile number');
      return;
    }

    if (mobile.length != 10) {
      _showError('Mobile number must be 10 digits');
      return;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(mobile)) {
      _showError('Mobile number must contain only digits');
      return;
    }

    setState(() => _isLoadingCustomer = true);

    try {
      AppLogger.info('Looking up customer with mobile: $mobile');

      // CORRECT ENDPOINT: /api/Customers/by-mobile/{mobileNumber}
      final response = await widget.dio.get('/Customers/by-mobile/$mobile');

      if (response.statusCode == 200) {
        final customerData = response.data;

        AppLogger.info('Customer found: ${customerData['customerId']}');

        setState(() {
          _customerData = customerData;
          _customerId = customerData['customerId'];
          _isLoadingCustomer = false;
        });

        // Load customer's default address if available
        await _loadCustomerAddress();

        final firstName = customerData['customerFirstName'] ?? '';
        final lastName = customerData['customerLastName'] ?? '';
        //final customerNumber = customerData['customerNumber'] ?? '';
        final fullName = '$firstName $lastName'.trim();

        _showSuccess(
            'Customer found: ${fullName.isNotEmpty ? fullName : "Customer"}');

        // Auto-advance to next step
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _nextStep();
        });
      }
    } on DioException catch (e) {
      setState(() => _isLoadingCustomer = false);

      AppLogger.error('Customer lookup error: ${e.response?.statusCode}');

      // Handle different error scenarios
      if (e.response?.statusCode == 404) {
        // Customer not found - this is expected, show dialog
        _showCustomerNotFoundDialog();
      } else if (e.response?.statusCode == 403) {
        _showError('Permission denied. Please contact administrator.');
      } else if (e.response?.statusCode == 401) {
        _showError('Session expired. Please login again.');
      } else {
        _showError('Failed to lookup customer. Please try again.');
      }
    } catch (e) {
      setState(() => _isLoadingCustomer = false);
      AppLogger.error('Unexpected error during customer lookup', e);
      _showError('An unexpected error occurred');
    }
  }

  Future<void> _loadCustomerAddress() async {
    if (_customerId == null) return;

    try {
      AppLogger.info('Loading customer default address for: $_customerId');

      // CORRECT ENDPOINT: /api/CustomerAddresses/customer/{customerId}/default
      final response = await widget.dio
          .get('/CustomerAddresses/customer/$_customerId/default');

      if (response.statusCode == 200) {
        final address = response.data;

        AppLogger.info('Default address loaded successfully');

        setState(() {
          _addressLine1Controller.text = address['addressLine1'] ?? '';
          _addressLine2Controller.text = address['addressLine2'] ?? '';
          _cityController.text = address['city'] ?? '';
          _selectedState = address['state'];
          _pincodeController.text = address['postalCode'] ?? '';
          _latitude = address['latitude'];
          _longitude = address['longitude'];
        });
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        AppLogger.info('No default address found for customer');
        // This is fine - user will enter address manually
      } else {
        AppLogger.error(
            'Error loading customer address: ${e.response?.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Unexpected error loading customer address', e);
    }
  }

  void _showCustomerNotFoundDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Customer Not Found'),
        content: Text(
          'No customer found with mobile number ${_mobileController.text}.\n\n'
          'You can still create the order, and a new customer will be created.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Proceed to next step even without customer
              _nextStep();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  // ========== FILE PICKER METHODS ==========
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        setState(() {
          _prescriptionFile = File(image.path);
          _prescriptionFileName = image.name;
          _prescriptionFileType = 'image';
        });
        AppLogger.info('Image captured: ${image.name}');
        _showSuccess('Image attached successfully');
      }
    } catch (e) {
      AppLogger.error('Error capturing image', e);
      _showError('Failed to capture image');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        setState(() {
          _prescriptionFile = File(image.path);
          _prescriptionFileName = image.name;
          _prescriptionFileType = 'image';
        });
        AppLogger.info('Image selected: ${image.name}');
        _showSuccess('Image attached successfully');
      }
    } catch (e) {
      AppLogger.error('Error selecting image', e);
      _showError('Failed to select image');
    }
  }

  Future<void> _pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSizeInMB = file.lengthSync() / (1024 * 1024);

        // Validate file size (max 10MB)
        if (fileSizeInMB > 10) {
          _showError('PDF file size must be less than 10MB');
          return;
        }

        setState(() {
          _prescriptionFile = file;
          _prescriptionFileName = result.files.single.name;
          _prescriptionFileType = 'pdf';
        });
        AppLogger.info('PDF selected: ${result.files.single.name}');
        _showSuccess('PDF attached successfully');
      }
    } catch (e) {
      AppLogger.error('Error selecting PDF', e);
      _showError('Failed to select PDF');
    }
  }

  void _removeAttachment() {
    setState(() {
      _prescriptionFile = null;
      _prescriptionFileName = null;
      _prescriptionFileType = null;
    });
    _showSuccess('Attachment removed');
  }

  void _showAttachmentOptions() {
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
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Attach Prescription',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.blue),
              ),
              title: const Text('Take Photo'),
              subtitle: const Text('Capture prescription with camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.photo_library, color: Colors.green),
              ),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Select image from device'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.picture_as_pdf, color: Colors.red),
              ),
              title: const Text('Choose PDF'),
              subtitle: const Text('Select PDF document (max 10MB)'),
              onTap: () {
                Navigator.pop(context);
                _pickPdfFile();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ========== NAVIGATION ==========
  void _nextStep() {
    if (_currentStep == 0) {
      // Step 1 validation already done in _lookupCustomer
      // Just check if mobile is entered
      if (_mobileController.text.trim().isEmpty) {
        _showError('Please enter mobile number');
        return;
      }
    } else if (_currentStep == 1) {
      // Step 2 validation - At least file OR notes required
      if (_prescriptionFile == null &&
          _prescriptionNotesController.text.trim().isEmpty) {
        _showError('Please attach prescription file OR enter order notes');
        return;
      }
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // ========== ORDER SUBMISSION ==========
  // FIXED ORDER SUBMISSION - Remove OrderInputType
// COMPLETE FIXED ORDER SUBMISSION
// Replace the _submitOrder() method in WhatsAppOrderCreationPage

// COMPLETE FIXED ORDER SUBMISSION - NO DUPLICATES
// Replace the entire _submitOrder() method in WhatsAppOrderCreationPage

// COMPLETE FIX - Use enum indices instead of enum names
// Replace the entire _submitOrder() method
// DIAGNOSTIC VERSION - Matches customer app EXACTLY
// Replace _submitOrder() with this version

Future<void> _submitOrder() async {
  // Validation
  if (_addressLine1Controller.text.trim().isEmpty) {
    _showError('Please enter Address Line 1');
    return;
  }

  if (_cityController.text.trim().isEmpty) {
    _showError('Please enter city');
    return;
  }

  if (_selectedState == null || _selectedState!.isEmpty) {
    _showError('Please select state');
    return;
  }

  final pincode = _pincodeController.text.trim();
  if (pincode.isEmpty || pincode.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(pincode)) {
    _showError('Please enter valid 6-digit pincode');
    return;
  }

  setState(() => _isSubmitting = true);

  try {
    String? customerIdToUse = _customerId;
    String? addressIdToUse;

    // Step 1: Ensure customer exists
    if (customerIdToUse == null) {
      AppLogger.info('[STEP 1] Creating new customer');
      
      final customerResponse = await widget.dio.post('/Customers/register', data: {
        'mobileNumber': _mobileController.text.trim(),
        'emailId': '',
        'customerFirstName': _customerData?['customerFirstName'] ?? 'Customer',
        'customerLastName': _customerData?['customerLastName'] ?? '',
        'password': 'Temp@123',
      });

      if (customerResponse.statusCode == 200 || customerResponse.statusCode == 201) {
        customerIdToUse = customerResponse.data['customerId'] ?? customerResponse.data['id'];
        AppLogger.info('[STEP 1] Customer created: $customerIdToUse');
      } else {
        throw Exception('Failed to create customer');
      }
    } else {
      AppLogger.info('[STEP 1] Using existing customer: $customerIdToUse');
    }

    // Step 2: Create address
    AppLogger.info('[STEP 2] Creating address');
    final addressResponse = await widget.dio.post('/CustomerAddresses', data: {
      'customerId': customerIdToUse,
      'addressLine1': _addressLine1Controller.text.trim(),
      'addressLine2': _addressLine2Controller.text.trim(),
      'addressLine3': '',
      'city': _cityController.text.trim(),
      'state': _selectedState,
      'postalCode': pincode,
      'latitude': _latitude,
      'longitude': _longitude,
      'isDefault': true,
      'isActive': true,
    });

    if (addressResponse.statusCode == 200 || addressResponse.statusCode == 201) {
      addressIdToUse = addressResponse.data['id'];
      AppLogger.info('[STEP 2] Address created: $addressIdToUse');
    } else {
      throw Exception('Failed to create address');
    }

    // Step 3: Create order - EXACTLY like customer app
    AppLogger.info('[STEP 3] Creating order');
    
    final formData = FormData();

    // Add fields in same order as customer app
    formData.fields.add(MapEntry('CustomerId', customerIdToUse!));
    formData.fields.add(MapEntry('CustomerAddressId', addressIdToUse!));
    formData.fields.add(MapEntry('OrderType', '2'));  // PrescriptionDrugs
    formData.fields.add(MapEntry('OrderInputType', '0'));  // Image

    // Add file if present - customer app ALWAYS uses OrderInputType=0 for files
    if (_prescriptionFile != null) {
      formData.files.add(
        MapEntry(
          'OrderInputFile',
          await MultipartFile.fromFile(
            _prescriptionFile!.path,
            filename: _prescriptionFileName ?? 'prescription.jpg',
          ),
        ),
      );
      AppLogger.info('[STEP 3] File added: $_prescriptionFileName');
    } else if (_prescriptionNotesController.text.trim().isNotEmpty) {
      // Text only
      formData.fields[2] = MapEntry('OrderInputType', '2');  // Change to Text
      formData.fields.add(MapEntry('OrderInputText', _prescriptionNotesController.text.trim()));
      AppLogger.info('[STEP 3] Text-only order');
    } else {
      _showError('Please provide prescription');
      setState(() => _isSubmitting = false);
      return;
    }

    // Log everything for debugging
    AppLogger.info('=== FINAL REQUEST ===');
    AppLogger.info('CustomerId: $customerIdToUse (${customerIdToUse.runtimeType})');
    AppLogger.info('AddressId: $addressIdToUse (${addressIdToUse.runtimeType})');
    AppLogger.info('Fields:');
    for (var field in formData.fields) {
      AppLogger.info('  ${field.key}: ${field.value} (${field.value.runtimeType})');
    }
    AppLogger.info('Files: ${formData.files.length}');
    for (var file in formData.files) {
      AppLogger.info('  ${file.key}: ${file.value.filename}');
    }
    AppLogger.info('====================');

    // Submit
    final response = await widget.dio.post(
      '/Orders',
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      AppLogger.info('[SUCCESS] Order created!');
      AppLogger.info('Response: ${response.data}');
      
      if (mounted) {
        final orderId = response.data['orderId'] ?? response.data['id'] ?? 'N/A';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order Created! ID: $orderId'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) _clearForm();
        });
      }
    }
  } on DioException catch (e) {
    AppLogger.error('[ERROR] DioException');
    AppLogger.error('Status: ${e.response?.statusCode}');
    AppLogger.error('Message: ${e.message}');
    AppLogger.error('Response: ${e.response?.data}');
    
    // Check for specific backend errors
    String errorMessage = 'Failed to create order';
    
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        errorMessage = data['error'] ?? data['message'] ?? data['title'] ?? errorMessage;
        
        // Check for validation errors
        if (data['errors'] != null) {
          AppLogger.error('Validation Errors: ${data['errors']}');
          if (data['errors'] is Map) {
            final errors = data['errors'] as Map;
            errorMessage = errors.values.first.toString();
          }
        }
      }
    }
    
    if (mounted) {
      _showError(errorMessage);
    }
  } catch (e, stack) {
    AppLogger.error('[ERROR] Unexpected: $e');
    AppLogger.error('Stack: $stack');
    
    if (mounted) {
      _showError('Unexpected error occurred');
    }
  } finally {
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }
}

// ALSO ADD THIS HELPER METHOD to show address selection dialog if customer has multiple addresses:

  Future<String?> _selectOrCreateAddress(String customerId) async {
    try {
      // Try to get customer's addresses
      final response =
          await widget.dio.get('/CustomerAddresses/customer/$customerId');

      if (response.statusCode == 200) {
        final List addresses = response.data;

        if (addresses.isEmpty) {
          // No addresses, create new one
          return await _createNewAddress(customerId);
        } else if (addresses.length == 1) {
          // Only one address, use it
          return addresses.first['id'];
        } else {
          // Multiple addresses - show selection dialog
          return await _showAddressSelectionDialog(addresses, customerId);
        }
      }
    } catch (e) {
      AppLogger.error('Error getting addresses', e);
    }

    // Default: create new address
    return await _createNewAddress(customerId);
  }

  Future<String?> _createNewAddress(String customerId) async {
    try {
      final response = await widget.dio.post('/CustomerAddresses', data: {
        'customerId': customerId,
        'addressLine1': _addressLine1Controller.text.trim(),
        'addressLine2': _addressLine2Controller.text.trim(),
        'city': _cityController.text.trim(),
        'state': _selectedState,
        'postalCode': _pincodeController.text.trim(),
        'latitude': _latitude,
        'longitude': _longitude,
        'isDefault': true,
        'isActive': true,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['id'];
      }
    } catch (e) {
      AppLogger.error('Error creating address', e);
    }
    return null;
  }

  Future<String?> _showAddressSelectionDialog(
      List addresses, String customerId) async {
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Delivery Address'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...addresses.map((addr) => ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(addr['addressLine1']),
                    subtitle: Text(
                        '${addr['city']}, ${addr['state']} - ${addr['postalCode']}'),
                    onTap: () => Navigator.pop(context, addr['id']),
                  )),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add_location),
                title: const Text('Use New Address'),
                onTap: () async {
                  final newAddressId = await _createNewAddress(customerId);
                  if (context.mounted) {
                    Navigator.pop(context, newAddressId);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearForm() {
    _mobileController.clear();
    _prescriptionNotesController.clear();
    _addressLine1Controller.clear();
    _addressLine2Controller.clear();
    _cityController.clear();
    _pincodeController.clear();

    setState(() {
      _customerData = null;
      _customerId = null;
      _prescriptionFile = null;
      _prescriptionFileName = null;
      _prescriptionFileType = null;
      _selectedState = null;
      _latitude = null;
      _longitude = null;
      _currentStep = 0;
    });

    _pageController.jumpToPage(0);
  }

  // ========== UI HELPERS ==========
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      color: Colors.green.shade50,
      child: Column(
        children: [
          // Step Progress Indicator
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: StepProgressIndicator(
              steps: const [
                StepItem(label: 'Customer', icon: Icons.person_search),
                StepItem(label: 'Prescription', icon: Icons.medical_services),
                StepItem(label: 'Address', icon: Icons.location_on),
              ],
              currentStep: _currentStep,
              activeColor: Colors.green,
            ),
          ),

          // Page Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                _buildStep1CustomerLookup(),
                _buildStep2PrescriptionDetails(),
                _buildStep3Address(),
              ],
            ),
          ),

          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  // ========== STEP 1: CUSTOMER LOOKUP ==========
  Widget _buildStep1CustomerLookup() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Find Customer',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter customer mobile number to lookup',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          // Mobile Number Input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.shade100,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: _mobileController,
              decoration: InputDecoration(
                labelText: 'Mobile Number *',
                hintText: 'Enter 10-digit mobile number',
                prefixIcon: Icon(Icons.phone, color: Colors.green.shade700),
                suffixIcon: _isLoadingCustomer
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              keyboardType: TextInputType.phone,
              maxLength: 10,
              onChanged: (value) {
                // Auto-lookup when 10 digits entered
                if (value.length == 10 && RegExp(r'^[0-9]+$').hasMatch(value)) {
                  _lookupCustomer();
                }
              },
            ),
          ),
          const SizedBox(height: 16),

          // Lookup Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoadingCustomer ? null : _lookupCustomer,
              icon: const Icon(Icons.search),
              label: const Text('Search Customer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Customer Details (if found)
          if (_customerData != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.green.shade700,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Customer Found',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_customerData!['customerFirstName'] ?? ''} ${_customerData!['customerLastName'] ?? ''}'
                                  .trim(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.email,
                    'Email',
                    _customerData!['emailId'] ?? 'Not provided',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.phone,
                    'Mobile',
                    _customerData!['mobileNumber'] ?? '',
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Info Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'If customer not found, you can continue and create a new customer',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ========== STEP 2: PRESCRIPTION DETAILS WITH FILE ATTACHMENT ==========
  Widget _buildStep2PrescriptionDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prescription Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Attach prescription file or enter notes',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          // File Attachment Section
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _prescriptionFile != null
                    ? Colors.green
                    : Colors.green.shade200,
                width: _prescriptionFile != null ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Prescription File',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                if (_prescriptionFile == null) ...[
                  // No file attached
                  InkWell(
                    onTap: _showAttachmentOptions,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.shade200,
                          style: BorderStyle.solid,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 48,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tap to Attach Prescription',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Camera • Gallery • PDF',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // File attached - Show preview
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _prescriptionFileType == 'pdf'
                                ? Icons.picture_as_pdf
                                : Icons.image,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _prescriptionFileName ?? 'File attached',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _prescriptionFileType == 'pdf'
                                          ? 'PDF'
                                          : 'IMAGE',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.check_circle,
                                    size: 14,
                                    color: Colors.green.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Attached',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _removeAttachment,
                          icon: const Icon(Icons.close, color: Colors.red),
                          tooltip: 'Remove',
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Optional Notes Section
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Notes (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _prescriptionNotesController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Example:\n'
                        'Paracetamol 500mg - 1 strip\n'
                        'Crocin Cold - 1 bottle\n'
                        'Vicks Vaporub - 1 box\n\n'
                        'Additional instructions or special requests...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Colors.green, width: 2),
                    ),
                  ),
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Info Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline,
                    size: 20, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You must provide either a prescription file OR order notes (or both)',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== STEP 3: DELIVERY ADDRESS ==========
  Widget _buildStep3Address() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Address',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _customerData != null
                ? 'Confirm or update delivery address'
                : 'Enter delivery address',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          _buildTextField(
            controller: _addressLine1Controller,
            label: 'Address Line 1 *',
            icon: Icons.home,
            hint: 'House/Flat No., Building Name',
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _addressLine2Controller,
            label: 'Address Line 2',
            icon: Icons.home_outlined,
            hint: 'Street, Area, Landmark (Optional)',
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _cityController,
            label: 'City *',
            icon: Icons.location_city,
            hint: 'Enter city name',
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedState,
              decoration: InputDecoration(
                labelText: 'State *',
                prefixIcon: Icon(Icons.map, color: Colors.green.shade700),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              isExpanded: true,
              items: _states.map((state) {
                return DropdownMenuItem(
                  value: state,
                  child: Text(state, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedState = value),
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _pincodeController,
            label: 'Pincode *',
            icon: Icons.pin_drop,
            hint: 'Enter 6-digit pincode',
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.green.shade700),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          counterText: maxLength != null ? '' : null,
        ),
        keyboardType: keyboardType,
        maxLength: maxLength,
      ),
    );
  }

  // ========== NAVIGATION BUTTONS ==========
  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : _previousStep,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Previous',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : (_currentStep == 2 ? _submitOrder : _nextStep),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentStep == 2 ? 'Create Order' : 'Next',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentStep == 2
                                ? Icons.check
                                : Icons.arrow_forward,
                            size: 20,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// CHEMIST MODEL
// ============================================================================

class ChemistModel {
  final String medicalStoreId;
  final String medicalName;
  final String city;
  final String state;
  final bool isActive;

  ChemistModel({
    required this.medicalStoreId,
    required this.medicalName,
    required this.city,
    required this.state,
    required this.isActive,
  });

  factory ChemistModel.fromJson(Map<String, dynamic> json) {
    return ChemistModel(
      medicalStoreId: json['medicalStoreId'] ?? '',
      medicalName: json['medicalName'] ?? 'Unknown',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }
}
