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
      case 3:
        return 'Assigned Orders';
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
          AssignedOrdersPage(dio: _dio),
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
                ListTile(
                  leading: const Icon(Icons.assignment_ind, color: Colors.blue),
                  title: const Text('Assigned Orders'),
                  selected: _selectedIndex == 3,
                  selectedTileColor: Colors.black.withOpacity(0.1),
                  onTap: () {
                    setState(() => _selectedIndex = 3);
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
            const SizedBox(height: 16),
            _buildQuickActionCard(
              icon: Icons.assignment_ind,
              title: 'Assigned Orders',
              subtitle: 'View orders assigned to you',
              color: Colors.blue,
              onTap: () => setState(() => _selectedIndex = 3),
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
    if (pincode.isEmpty ||
        pincode.length != 6 ||
        !RegExp(r'^[0-9]+$').hasMatch(pincode)) {
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

        final customerResponse =
            await widget.dio.post('/Customers/register', data: {
          'mobileNumber': _mobileController.text.trim(),
          'emailId': '',
          'customerFirstName':
              _customerData?['customerFirstName'] ?? 'Customer',
          'customerLastName': _customerData?['customerLastName'] ?? '',
          'password': 'Temp@123',
        });

        if (customerResponse.statusCode == 200 ||
            customerResponse.statusCode == 201) {
          customerIdToUse = customerResponse.data['customerId'] ??
              customerResponse.data['id'];
          AppLogger.info('[STEP 1] Customer created: $customerIdToUse');
        } else {
          throw Exception('Failed to create customer');
        }
      } else {
        AppLogger.info('[STEP 1] Using existing customer: $customerIdToUse');
      }

      // Step 2: Create address
      AppLogger.info('[STEP 2] Creating address');
      final addressResponse =
          await widget.dio.post('/CustomerAddresses', data: {
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

      if (addressResponse.statusCode == 200 ||
          addressResponse.statusCode == 201) {
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
      formData.fields.add(MapEntry('OrderType', '2')); // PrescriptionDrugs
      formData.fields.add(MapEntry('OrderInputType', '0')); // Image

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
        formData.fields[2] = MapEntry('OrderInputType', '2'); // Change to Text
        formData.fields.add(MapEntry(
            'OrderInputText', _prescriptionNotesController.text.trim()));
        AppLogger.info('[STEP 3] Text-only order');
      } else {
        _showError('Please provide prescription');
        setState(() => _isSubmitting = false);
        return;
      }

      // Log everything for debugging
      AppLogger.info('=== FINAL REQUEST ===');
      AppLogger.info(
          'CustomerId: $customerIdToUse (${customerIdToUse.runtimeType})');
      AppLogger.info(
          'AddressId: $addressIdToUse (${addressIdToUse.runtimeType})');
      AppLogger.info('Fields:');
      for (var field in formData.fields) {
        AppLogger.info(
            '  ${field.key}: ${field.value} (${field.value.runtimeType})');
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
          final orderId =
              response.data['orderId'] ?? response.data['id'] ?? 'N/A';

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
          errorMessage =
              data['error'] ?? data['message'] ?? data['title'] ?? errorMessage;

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
      isActive: json['isActive'] ?? true,
    );
  }
}

// ============================================================================
// ASSIGNED ORDERS PAGE
// ============================================================================

class AssignedOrdersPage extends StatefulWidget {
  final Dio dio;

  const AssignedOrdersPage({Key? key, required this.dio}) : super(key: key);

  @override
  State<AssignedOrdersPage> createState() => _AssignedOrdersPageState();
}

class _AssignedOrdersPageState extends State<AssignedOrdersPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isLoading = true;
  String? _errorMessage;
  List<OrderModel> _assignedOrders = [];
  String _customerSupportId = '';
  final Map<String, Map<String, String>> _customerCache = {};

  // Track which orders are currently being reassigned (loading state per card)
  final Set<String> _reassigningOrders = {};

  @override
  void initState() {
    super.initState();
    _loadCustomerSupportIdAndOrders();
  }

  // ─────────────────────────────── DATA LOADING ────────────────────────────

  Future<void> _loadCustomerSupportIdAndOrders() async {
    try {
      final userId = await StorageService.getUserId();
      if (userId == null || userId.isEmpty) {
        setState(() {
          _errorMessage = 'Customer Support ID not found. Please login again.';
          _isLoading = false;
        });
        return;
      }
      setState(() => _customerSupportId = userId);
      await _loadAssignedOrders();
    } catch (e) {
      AppLogger.error('Error loading customer support ID', e);
      setState(() {
        _errorMessage = 'Error loading user information';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAssignedOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      AppLogger.info(
          'Fetching assigned orders for customer support: $_customerSupportId');
      final response = await widget.dio.get(
        '/Orders/customersupport/$_customerSupportId/assignedtocustomersupport',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> ordersList;
        if (data is List) {
          ordersList = data;
        } else if (data is Map && data.containsKey('data')) {
          ordersList = data['data'] as List;
        } else if (data is Map && data.containsKey('orders')) {
          ordersList = data['orders'] as List;
        } else {
          throw Exception('Unexpected response format');
        }

        final orders =
            ordersList.map((json) => OrderModel.fromJson(json)).toList();
        orders.sort((a, b) => b.createdOn.compareTo(a.createdOn));

        await _loadCustomerInfo(orders);

        setState(() {
          _assignedOrders = orders;
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      AppLogger.error('Error loading assigned orders', e);
      String errorMsg = 'Failed to load assigned orders';
      if (e.response?.statusCode == 401) {
        errorMsg = 'Authentication failed. Please login again.';
      } else if (e.response?.statusCode == 404) {
        errorMsg = 'No assigned orders found';
      }
      setState(() {
        _errorMessage = errorMsg;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Unexpected error loading assigned orders', e);
      setState(() {
        _errorMessage = 'An unexpected error occurred';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCustomerInfo(List<OrderModel> orders) async {
    for (var order in orders) {
      if (!_customerCache.containsKey(order.customerId)) {
        try {
          final response =
              await widget.dio.get('/Customers/${order.customerId}');
          if (response.statusCode == 200) {
            final d = response.data;
            final firstName = d['customerFirstName'] ?? '';
            final lastName = d['customerLastName'] ?? '';
            final fullName = '$firstName $lastName'.trim();
            _customerCache[order.customerId] = {
              'name': fullName.isEmpty ? 'Customer' : fullName,
              'email': d['emailId']?.toString() ?? '',
              'phone': d['mobileNumber']?.toString() ?? '',
            };
          }
        } catch (_) {
          _customerCache[order.customerId] = {
            'name': 'Customer',
            'email': '',
            'phone': '',
          };
        }
      }
    }
  }

  // ──────────────────────────── REASSIGN LOGIC ─────────────────────────────

  /// Fetches chemists near the order's delivery pincode via the dedicated endpoint.
  Future<List<ChemistModel>> _fetchNearbyChemists(int orderId) async {
    final response =
        await widget.dio.get('/Orders/$orderId/medical-stores-by-pincode');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['data'] ?? response.data['stores'] ?? []);
      return data.map((json) => ChemistModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> _showReassignDialog(
      OrderModel order, String customerName) async {
    final int? parsedId = int.tryParse(order.orderId);
    if (parsedId == null) {
      _showSnackBar('Invalid order ID', isError: true);
      return;
    }

    List<ChemistModel> chemists = [];
    bool isLoadingChemists = true;
    String? fetchError;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
          // Kick off the fetch once
          if (isLoadingChemists && fetchError == null) {
            _fetchNearbyChemists(parsedId).then((result) {
              setDialogState(() {
                chemists = result;
                isLoadingChemists = false;
              });
            }).catchError((e) {
              setDialogState(() {
                fetchError =
                    'Could not load nearby chemists.\nPlease try again.';
                isLoadingChemists = false;
              });
            });
          }

          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Dialog header ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.store_outlined,
                              color: Colors.white, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Reassign Order',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close,
                                color: Colors.white70, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Order #${order.orderNumber ?? order.orderId} • $customerName',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_pin,
                                color: Colors.white70, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'Showing stores near delivery pincode',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Content ──
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
                  child: isLoadingChemists
                      ? const SizedBox(
                          height: 120,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : fetchError != null
                          ? Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.error_outline,
                                      color: Colors.red.shade300, size: 44),
                                  const SizedBox(height: 12),
                                  Text(fetchError!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 13)),
                                ],
                              ),
                            )
                          : chemists.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.store_mall_directory_outlined,
                                          color: Colors.grey.shade300,
                                          size: 52),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No active chemists found\nnear this delivery pincode.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  itemCount: chemists.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1, indent: 56),
                                  itemBuilder: (ctx, index) {
                                    final chemist = chemists[index];
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            const Color(0xFFE3F2FD),
                                        radius: 20,
                                        child: const Icon(Icons.store,
                                            color: Color(0xFF1565C0), size: 20),
                                      ),
                                      title: Text(
                                        chemist.medicalName,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: Text(
                                        '${chemist.city}, ${chemist.state}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600),
                                      ),
                                      trailing: const Icon(Icons.chevron_right,
                                          color: Colors.grey),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        _reassignOrder(order, chemist);
                                      },
                                    );
                                  },
                                ),
                ),

                // ── Footer ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> _reassignOrder(OrderModel order, ChemistModel chemist) async {
    setState(() => _reassigningOrders.add(order.orderId));
    try {
      await widget.dio.put('/Orders/assign', data: {
        'orderId': int.parse(order.orderId),
        'medicalStoreId': chemist.medicalStoreId,
      });

      _showSnackBar('Order reassigned to ${chemist.medicalName}');
      await _loadAssignedOrders();
    } catch (e) {
      _showSnackBar('Failed to reassign order', isError: true);
    } finally {
      setState(() => _reassigningOrders.remove(order.orderId));
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ──────────────────────────── BUILD ──────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF1565C0)));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadCustomerSupportIdAndOrders,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_assignedOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_ind, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'No Assigned Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Orders assigned to you will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAssignedOrders,
      color: const Color(0xFF1565C0),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: _assignedOrders.length,
        itemBuilder: (context, index) {
          final order = _assignedOrders[index];
          final customerInfo = _customerCache[order.customerId];
          final customerName = customerInfo?['name'] ?? 'Customer';
          final customerPhone = customerInfo?['phone'] ?? '';
          return _AssignedOrderCard(
            key: ValueKey(order.orderId),
            order: order,
            customerName: customerName,
            customerPhone: customerPhone,
            isReassigning: _reassigningOrders.contains(order.orderId),
            onReassign: () => _showReassignDialog(order, customerName),
          );
        },
      ),
    );
  }
}

// ─────────────────────────── ORDER CARD WIDGET ───────────────────────────────

class _AssignedOrderCard extends StatelessWidget {
  final OrderModel order;
  final String customerName;
  final String customerPhone;
  final bool isReassigning;
  final VoidCallback onReassign;

  const _AssignedOrderCard({
    Key? key,
    required this.order,
    required this.customerName,
    required this.customerPhone,
    required this.isReassigning,
    required this.onReassign,
  }) : super(key: key);

  // ── Status helpers ──────────────────────────────────────────────────────

  // NOTE: 'assigned to customer support' MUST come before 'assigned' in this
  // map because _resolveStatus uses contains(), and the longer key would
  // otherwise be shadowed by the shorter one.
  static const Map<String, _StatusStyle> _statusMap = {
    'pending': _StatusStyle(
        label: 'Pending',
        bg: Color(0xFFFFF3E0),
        fg: Color(0xFFE65100),
        dot: Color(0xFFFF6F00)),
    'assigned to customer support': _StatusStyle(
        label: 'Needs Reassignment',
        bg: Color(0xFFE3F2FD),
        fg: Color(0xFF0D47A1),
        dot: Color(0xFF1565C0)),
    'assigned': _StatusStyle(
        label: 'Assigned',
        bg: Color(0xFFFFF3E0),
        fg: Color(0xFFE65100),
        dot: Color(0xFFFF6F00)),
    'accepted': _StatusStyle(
        label: 'Accepted',
        bg: Color(0xFFE8F5E9),
        fg: Color(0xFF1B5E20),
        dot: Color(0xFF2E7D32)),
    'rejected': _StatusStyle(
        label: 'Rejected',
        bg: Color(0xFFFFEBEE),
        fg: Color(0xFFB71C1C),
        dot: Color(0xFFC62828)),
    'bill': _StatusStyle(
        label: 'Bill Uploaded',
        bg: Color(0xFFF3E5F5),
        fg: Color(0xFF4A148C),
        dot: Color(0xFF6A1B9A)),
    'delivery': _StatusStyle(
        label: 'Out for Delivery',
        bg: Color(0xFFE0F2F1),
        fg: Color(0xFF004D40),
        dot: Color(0xFF00695C)),
    'completed': _StatusStyle(
        label: 'Completed',
        bg: Color(0xFFE8F5E9),
        fg: Color(0xFF1B5E20),
        dot: Color(0xFF2E7D32)),
  };

  _StatusStyle _resolveStatus() {
    final s = order.status.toLowerCase();
    for (final key in _statusMap.keys) {
      if (s.contains(key)) return _statusMap[key]!;
    }
    return _StatusStyle(
        label: order.status,
        bg: const Color(0xFFF5F5F5),
        fg: Colors.grey.shade700,
        dot: Colors.grey.shade500);
  }

  // Reassign button shown for:
  //  - status 8  → "Assigned to Customer Support" (parsed correctly)
  //  - legacy fallback if parsing ever fails
  bool get _needsReassign =>
      order.status.toLowerCase().contains('assigned to customer support') ||
      order.status.toLowerCase().contains('unknown status (8)');

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour < 12 ? 'AM' : 'PM';
    return '${months[local.month - 1]} $day  •  $hour:$minute $ampm';
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final style = _resolveStatus();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: _needsReassign
            ? Border.all(color: const Color(0xFFBBDEFB), width: 1.5)
            : Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Colour-coded top stripe ───────────────────────────────────────
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: style.dot,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Row 1: avatar  +  customer name  +  status badge ─────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFE3F2FD),
                      child: Text(
                        customerName.isNotEmpty
                            ? customerName[0].toUpperCase()
                            : 'C',
                        style: const TextStyle(
                          color: Color(0xFF1565C0),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customerName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          if (customerPhone.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.phone,
                                    size: 11, color: Colors.grey.shade500),
                                const SizedBox(width: 3),
                                Text(
                                  customerPhone,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: style.bg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: style.dot,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            style.label.toUpperCase(),
                            style: TextStyle(
                              color: style.fg,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                const SizedBox(height: 12),

                // ── Row 2: order meta chips ───────────────────────────────
                Row(
                  children: [
                    _MetaChip(
                      icon: Icons.tag,
                      label: '#${order.orderNumber ?? order.orderId}',
                    ),
                    const SizedBox(width: 8),
                    _MetaChip(
                      icon: Icons.category_outlined,
                      label: order.orderInputType.name,
                    ),
                    if (order.totalAmount != null) ...[
                      const SizedBox(width: 8),
                      _MetaChip(
                        icon: Icons.currency_rupee,
                        label: order.totalAmount!.toStringAsFixed(2),
                        highlight: true,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 8),

                // ── Row 3: date ───────────────────────────────────────────
                Row(
                  children: [
                    Icon(Icons.schedule, size: 13, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(order.createdOn),
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),

                // ── Delivery city + pincode ───────────────────────────────
                if (order.shippingPincode != null &&
                    order.shippingPincode!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        [order.shippingCity, order.shippingPincode]
                            .where((s) => s != null && s.isNotEmpty)
                            .join(' – '),
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ],

                // ── Rejection reason (shown whenever present, any status) ─
                if (order.rejectionReason != null &&
                    order.rejectionReason!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8F8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFCDD2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline,
                            size: 14, color: Color(0xFFB71C1C)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Rejection reason: ${order.rejectionReason}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFB71C1C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Reassign button (status 8 = AssignedToCustomerSupport) ─
                if (_needsReassign) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isReassigning ? null : onReassign,
                      icon: isReassigning
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.autorenew, size: 16),
                      label: Text(
                        isReassigning
                            ? 'Reassigning…'
                            : 'Reassign to Nearby Chemist',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────────

class _StatusStyle {
  final String label;
  final Color bg;
  final Color fg;
  final Color dot;
  const _StatusStyle(
      {required this.label,
      required this.bg,
      required this.fg,
      required this.dot});
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlight;

  const _MetaChip({
    required this.icon,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: highlight ? const Color(0xFF2E7D32) : Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: highlight ? const Color(0xFF1B5E20) : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
