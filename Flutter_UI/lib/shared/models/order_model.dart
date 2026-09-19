import 'dart:io';
import 'package:pharmaish/shared/models/delivery_address_model.dart';
import 'package:pharmaish/shared/models/order_assignment_history_model.dart';
import 'package:pharmaish/utils/app_logger.dart';

import 'order_enums.dart';

class OrderModel {
  final String orderId;
  final String customerId;

  /// Customer's full name, supplied by endpoints whose callers can't read the
  /// customer record directly (e.g. the delivery boy's order list). May be null
  /// on payloads that don't include it.
  final String? customerName;
  final String? medicalStoreId;
  final OrderType orderType;
  final OrderInputType orderInputType;
  final String? prescriptionFileUrl;
  final String? prescriptionText;
  final String? voiceNoteUrl;
  final String status;
  final double? totalAmount;

  /// Payment status (separate from order [status]): 0=NotPaid, 1=PartiallyPaid,
  /// 2=FullyPaid. Mirrors the backend OrderPaymentStatus enum.
  final int orderPaymentStatus;
  final String? billFileUrl;
  final String? completionOtp;
  final DateTime? completedOn;
  final String? rejectionReason;
  final String? customerRejectionReason;
  final String? customerRejectionPhotoUrl;
  final String? orderNumber;

// ✨ NEW: Assignment History
  final List<OrderAssignmentHistoryModel> assignmentHistory;

  /// Id of the customer address this order is delivered to. Kept so screens can
  /// correlate with the address book without digging through raw JSON.
  final String? customerAddressId;

  /// Where this order is to be delivered, embedded in every `/Orders` payload by
  /// the backend. Null only when the order's address record is missing.
  ///
  /// Prefer this over re-fetching `/CustomerAddresses/{id}`: that endpoint is
  /// gated on `CustomerRead`, so it 403s for chemists and delivery partners.
  final DeliveryAddressModel? deliveryAddress;

  final bool isActive;
  final DateTime createdOn;
  final DateTime? updatedOn;

  OrderModel({
    required this.orderId,
    required this.customerId,
    this.customerName,
    this.medicalStoreId,
    required this.orderType,
    required this.orderInputType,
    this.prescriptionFileUrl,
    this.prescriptionText,
    this.voiceNoteUrl,
    required this.status,
    this.totalAmount,
    this.orderPaymentStatus = 0,
    this.billFileUrl,
    this.completionOtp,
    this.completedOn,
    this.rejectionReason,
    this.customerRejectionReason,
    this.customerRejectionPhotoUrl,
    this.customerAddressId,
    this.deliveryAddress,
    required this.isActive,
    required this.createdOn,
    this.updatedOn,
    this.orderNumber,
    this.assignmentHistory = const [],
  });

  /// Parse OrderType from int value (backend sends: 0, 1, 2)
  static OrderType _parseOrderType(dynamic value) {
    if (value == null) return OrderType.notSet;

    try {
      if (value is int) {
        return OrderType.fromValue(value);
      } else if (value is String) {
        final intValue = int.tryParse(value);
        if (intValue != null) {
          return OrderType.fromValue(intValue);
        }
      }

      AppLogger.warning(
          'Unexpected OrderType value: $value (${value.runtimeType})');
      return OrderType.notSet;
    } catch (e) {
      AppLogger.error('Error parsing OrderType: $e');
      return OrderType.notSet;
    }
  }

  /// Parse OrderInputType from int value (backend sends: 0, 1, 2)
  static OrderInputType _parseOrderInputType(dynamic value) {
    if (value == null) return OrderInputType.image;

    try {
      if (value is int) {
        return OrderInputType.fromValue(value);
      } else if (value is String) {
        final intValue = int.tryParse(value);
        if (intValue != null) {
          return OrderInputType.fromValue(intValue);
        }
      }

      AppLogger.warning(
          'Unexpected OrderInputType value: $value (${value.runtimeType})');
      return OrderInputType.image;
    } catch (e) {
      AppLogger.error('Error parsing OrderInputType: $e');
      return OrderInputType.image;
    }
  }

  /// Helper to safely convert any value to String
  /// Handles cases where backend sends int but we need String
  static String _toString(dynamic value, String defaultValue) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    return value.toString();
  }

  /// Helper to safely convert any value to String (nullable version)
  static String? _toStringOrNull(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Debug: Print to see what we're getting
    AppLogger.info('📦 Parsing OrderModel for order: ${json['orderId']}');
    AppLogger.info('📋 Raw assignmentHistory: ${json['assignmentHistory']}');

    return OrderModel(
      // ✅ FIXED: Use _toString to handle if these come as int
      orderId: _toString(json['orderId'] ?? json['id'], ''),
      customerId: _toString(json['customerId'], ''),
      customerName: _toStringOrNull(json['customerName']),
      medicalStoreId: _toStringOrNull(json['medicalStoreId']),

      // Parse enums
      orderType: _parseOrderType(json['orderType']),
      orderInputType: _parseOrderInputType(json['orderInputType']),

      prescriptionFileUrl: _toStringOrNull(
          json['prescriptionFileUrl'] ?? json['orderInputFileLocation']),
      prescriptionText:
          _toStringOrNull(json['prescriptionText'] ?? json['orderInputText']),

      // Handle status as int or string
      status: _parseOrderStatus(json['orderStatus']),

      totalAmount: json['totalAmount']?.toDouble(),
      orderPaymentStatus: _parseOrderPaymentStatus(json['orderPaymentStatus']),
      billFileUrl: _toStringOrNull(json['billFileUrl']),

      // Delivery-verification OTP. The backend serializes it as "otp"
      // (camelCased "OTP"); keep the older keys as fallbacks. Value may be an
      // int or string.
      completionOtp: _toStringOrNull(
          json['otp'] ?? json['completionOtp'] ?? json['OTP']),

      // ✨ NEW: Parse assignment history
      assignmentHistory: _parseAssignmentHistory(json['AssignmentHistory'] ??
              json['assignmentHistory'] // Try both cases
          ),

      completedOn: _parseDateAsLocal(json['completedOn']),

      rejectionReason: _toStringOrNull(json['rejectionReason']),
      customerRejectionReason: _toStringOrNull(json['customerRejectionReason']),
      customerRejectionPhotoUrl:
          _toStringOrNull(json['customerRejectionPhotoUrl']),

      orderNumber: _toStringOrNull(json['orderNumber']),

      customerAddressId: _toStringOrNull(
          json['customerAddressId'] ?? json['CustomerAddressId']),
      deliveryAddress: _parseDeliveryAddress(
          json['deliveryAddress'] ?? json['DeliveryAddress']),

      isActive: json['isActive'] ?? true,
      createdOn: _parseDateAsLocal(json['createdOn']) ?? DateTime.now(),
      updatedOn: _parseDateAsLocal(json['updatedOn']),
    );
  }

  /// Parses a backend timestamp into the device's local time zone.
  ///
  /// Backend timestamps are UTC (`DateTime.UtcNow`), but they can arrive without
  /// a `Z`/offset, in which case [DateTime.parse] would treat them as local and
  /// show the UTC wall-clock unchanged. We re-tag any zone-less value as UTC
  /// before converting to local. Returns null for null/empty input.
  static DateTime? _parseDateAsLocal(dynamic value) {
    if (value == null) return null;
    final raw = value.toString();
    if (raw.isEmpty) return null;

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return null;

    // A 'Z' or numeric offset makes [DateTime.parse] return a UTC value; a
    // zone-less string returns a local value whose wall-clock is really UTC.
    final utc = parsed.isUtc
        ? parsed
        : DateTime.utc(parsed.year, parsed.month, parsed.day, parsed.hour,
            parsed.minute, parsed.second, parsed.millisecond, parsed.microsecond);
    return utc.toLocal();
  }

  /// Parse assignment history from JSON array
  static List<OrderAssignmentHistoryModel> _parseAssignmentHistory(
      dynamic value) {
    AppLogger.info('🔍 Starting to parse assignmentHistory');
    AppLogger.info('🔍 Value type: ${value?.runtimeType}');
    AppLogger.info('🔍 Value: $value');

    // Check if null or not a list
    if (value == null) {
      AppLogger.warning('⚠️ assignmentHistory is null');
      return [];
    }

    if (value is! List) {
      AppLogger.error(
          '❌ assignmentHistory is not a List, it is: ${value.runtimeType}');
      return [];
    }

    AppLogger.info('✅ assignmentHistory is a List with ${value.length} items');

    try {
      final results = <OrderAssignmentHistoryModel>[];

      for (var i = 0; i < value.length; i++) {
        try {
          AppLogger.info('📝 Parsing item $i: ${value[i]}');
          final item = OrderAssignmentHistoryModel.fromJson(
              value[i] as Map<String, dynamic>);
          results.add(item);
          AppLogger.info('✅ Successfully parsed item $i');
        } catch (e, stackTrace) {
          AppLogger.error('❌ Error parsing assignment history item $i: $e');
          AppLogger.error('Stack trace: $stackTrace');
          AppLogger.error('Item data: ${value[i]}');
        }
      }

      AppLogger.info(
          '✅ Total parsed: ${results.length} out of ${value.length}');
      return results;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Error parsing assignment history array: $e');
      AppLogger.error('Stack trace: $stackTrace');
      return [];
    }
  }

  /// Parse the inline delivery address, tolerating a missing or malformed object
  /// rather than failing the whole order parse over it.
  static DeliveryAddressModel? _parseDeliveryAddress(dynamic value) {
    if (value is! Map) return null;
    try {
      return DeliveryAddressModel.fromJson(Map<String, dynamic>.from(value));
    } catch (e) {
      AppLogger.error('Error parsing deliveryAddress: $e');
      return null;
    }
  }

  // Helper getters
  String get orderTypeDisplayName => orderType.displayName;

  /// True when there is a delivery address worth rendering.
  bool get hasDeliveryAddress => deliveryAddress?.isNotEmpty ?? false;

  /// The delivery address on one line, or null when none is available.
  /// Screens showing a placeholder should fall back to their own wording.
  String? get deliveryAddressLine =>
      hasDeliveryAddress ? deliveryAddress!.singleLine : null;

  /// True when the order is waiting on the chemist to accept or reject it.
  ///
  /// Only "Pending"/"Assigned to Chemist" count. An order the chemist rejected
  /// and the system escalated keeps this store's [medicalStoreId] but is now
  /// "Assigned to Customer Support" (or a Manager), so it is no longer the
  /// chemist's to act on and must not show as a new order.
  bool get isAwaitingChemistAction {
    final s = status.toLowerCase();
    if (s.contains('support') || s.contains('manager')) return false;
    return s.contains('pending') || s.contains('assigned');
  }

  /// True when this chemist rejected the order.
  ///
  /// Rejecting an order escalates it to Customer Support (or a Manager) in the
  /// same request, so by the time a list loads the status reads "Assigned to
  /// Customer Support" rather than "Rejected by Chemist". The store's id stays
  /// on the order until support reassigns it elsewhere, so an escalated order
  /// fetched for this store is one this store rejected. Once support hands it
  /// to another chemist it leaves this store's lists altogether.
  bool get isRejectedByChemist {
    final s = status.toLowerCase();
    return s.contains('rejected') ||
        s.contains('support') ||
        s.contains('manager');
  }

  /// ✨ NEW: Assignment history helpers
  bool get hasAssignmentHistory {
    final result = assignmentHistory.isNotEmpty;
    AppLogger.info(
        '🔍 hasAssignmentHistory: $result (count: ${assignmentHistory.length})');
    return result;
  }

  int get assignmentCount {
    return assignmentHistory.length;
  }

  /// Get most recent assignment (null-safe)
  OrderAssignmentHistoryModel? get latestAssignment {
    if (assignmentHistory.isEmpty) {
      AppLogger.info('📭 No assignment history available');
      return null;
    }

    try {
      final sorted = List<OrderAssignmentHistoryModel>.from(assignmentHistory)
        ..sort((a, b) => b.assignedOn.compareTo(a.assignedOn));
      return sorted.first;
    } catch (e) {
      AppLogger.error('Error getting latest assignment: $e');
      return null;
    }
  }

  /// True when the order has been fully paid (OrderPaymentStatus.FullyPaid).
  bool get isFullyPaid => orderPaymentStatus == 2;

  /// True when the delivery OTP should be shown to the customer: the order has
  /// been paid for but is not yet completed (delivered), and an OTP is present.
  /// The customer shares this OTP with the delivery boy to confirm delivery.
  bool get shouldShowDeliveryOtp =>
      isFullyPaid &&
      status.toLowerCase() != 'completed' &&
      (completionOtp?.trim().isNotEmpty ?? false);

  /// Parse the backend OrderPaymentStatus (int enum, or its name) to an int.
  static int _parseOrderPaymentStatus(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    final s = value.toString();
    final asInt = int.tryParse(s);
    if (asInt != null) return asInt;
    switch (s.toLowerCase()) {
      case 'notpaid':
        return 0;
      case 'partiallypaid':
        return 1;
      case 'fullypaid':
        return 2;
      default:
        return 0;
    }
  }

  /// Parse orderStatus integer to readable string
  static String _parseOrderStatus(dynamic value) {
    if (value == null) return 'Pending';

    try {
      int statusCode;
      if (value is int) {
        statusCode = value;
      } else if (value is String) {
        statusCode = int.tryParse(value) ?? 0;
      } else {
        return 'Unknown';
      }

      // Based on OrderStatus enum values from backend
      switch (statusCode) {
        case 0:
          return 'Pending Payment';
        case 1:
          return 'Assigned to Chemist';
        case 2:
          return 'Rejected by Chemist';
        case 3:
          return 'Accepted by Chemist';
        case 4:
          return 'Bill Uploaded';
        case 5:
          return 'Paid';
        case 6:
          return 'Out for Delivery';
        case 7:
          return 'Completed';
        case 8:
          return 'Assigned to Customer Support'; // ← add this
        case 9:
          return 'Assigned to Manager';
        case 10:
          return 'Cancelled';

        default:
          AppLogger.warning('Unknown order status code: $statusCode');
          return 'Unknown Status ($statusCode)';
      }
    } catch (e) {
      AppLogger.error('Error parsing order status: $e');
      return 'Unknown';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'customerId': customerId,
      'customerName': customerName,
      // ✨ NEW: Include assignment history
      'assignmentHistory': assignmentHistory.map((h) => h.toJson()).toList(),
      'medicalStoreId': medicalStoreId,
      'orderType': orderType.value,
      'orderInputType': orderInputType.value,
      'prescriptionFileUrl': prescriptionFileUrl,
      'prescriptionText': prescriptionText,
      'voiceNoteUrl': voiceNoteUrl,
      'status': status,
      'totalAmount': totalAmount,
      'orderPaymentStatus': orderPaymentStatus,
      'billFileUrl': billFileUrl,
      'completionOtp': completionOtp,
      'completedOn': completedOn?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'customerRejectionReason': customerRejectionReason,
      'customerRejectionPhotoUrl': customerRejectionPhotoUrl,
      'customerAddressId': customerAddressId,
      'deliveryAddress': deliveryAddress?.toJson(),
      'isActive': isActive,
      'createdOn': createdOn.toIso8601String(),
      'updatedOn': updatedOn?.toIso8601String(),
    };
  }

  String get orderInputTypeDisplayName {
    switch (orderInputType) {
      case OrderInputType.image:
        return 'Image';
      case OrderInputType.voice:
        return 'Voice';
      case OrderInputType.text:
        return 'Text';
    }
  }
}

/// Request model for creating orders
/// Matches backend CreateOrderDto structure
class CreateOrderRequest {
  final String customerId;
  final String customerAddressId;
  final OrderType orderType;
  final OrderInputType orderInputType;
  final String? orderInputFileLocation;
  final String? orderInputText;
  final File? orderInputFile;

  CreateOrderRequest({
    required this.customerId,
    required this.customerAddressId,
    required this.orderType,
    required this.orderInputType,
    this.orderInputFileLocation,
    this.orderInputText,
    this.orderInputFile,
  });

  Map<String, dynamic> toFormData() {
    return {
      'CustomerId': customerId,
      'CustomerAddressId': customerAddressId,
      'OrderType': orderType.value,
      'OrderInputType': orderInputType.value,
      if (orderInputFileLocation != null)
        'OrderInputFileLocation': orderInputFileLocation,
      if (orderInputText != null) 'OrderInputText': orderInputText,
    };
  }

  @override
  String toString() {
    return 'CreateOrderRequest('
        'customerId: $customerId, '
        'customerAddressId: $customerAddressId, '
        'orderType: $orderType, '
        'orderInputType: $orderInputType, '
        'hasFile: ${orderInputFile != null})';
  }
}
