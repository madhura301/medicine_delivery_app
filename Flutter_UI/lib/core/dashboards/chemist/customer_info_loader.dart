import 'package:pharmaish/core/services/customer_service.dart';
import 'package:pharmaish/shared/models/order_model.dart';
import 'package:pharmaish/utils/app_logger.dart';

/// Fills [cache] (customerId -> {name, email, phone}) for every customer
/// referenced by [orders] that is not already cached.
///
/// Shared by the chemist dashboard and the chemist orders list so both can
/// refresh from the server independently while sharing one cache instance.
Future<void> loadCustomerInfoInto(
  Map<String, Map<String, String>> cache,
  List<OrderModel> orders,
) async {
  for (final order in orders) {
    if (cache.containsKey(order.customerId)) continue;
    try {
      final customerData = await CustomerService.getCustomer(order.customerId);
      cache[order.customerId] = {
        'name':
            '${customerData['customerFirstName'] ?? ''} ${customerData['customerLastName'] ?? ''}'
                .trim(),
        'email': customerData['emailId']?.toString() ?? '',
        'phone': customerData['mobileNumber']?.toString() ?? '',
      };
      AppLogger.info('Loaded customer info for ${order.customerId}');
    } catch (e) {
      AppLogger.error('Error loading customer ${order.customerId}: $e');
      cache[order.customerId] = {'name': 'Customer', 'email': '', 'phone': ''};
    }
  }
}
