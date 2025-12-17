import 'dart:io';
import 'package:pharmaish/utils/app_logger.dart';

import 'order_enums.dart';

class OrderModel {
  final String orderId;
  final String customerId;
  final String? medicalStoreId;
  final OrderType orderType;
  final OrderInputType orderInputType;
  final String? prescriptionFileUrl;
  final String? prescriptionText;
  final String? voiceNoteUrl;
  final String status;
  final double? totalAmount;
  final String? billFileUrl;
  final String? completionOtp;
  final DateTime? completedOn;
  final String? rejectionReason;
  final String? customerRejectionReason;
  final String? customerRejectionPhotoUrl;
  final String? orderNumber;

  // Shipping Address
  final String? shippingAddressLine1;
  final String? shippingAddressLine2;
  final String? shippingArea;
  final String? shippingCity;
  final String? shippingPincode;
  final double? shippingLatitude;
  final double? shippingLongitude;

  final bool isActive;
  final DateTime createdOn;
  final DateTime? updatedOn;

  OrderModel({
    required this.orderId,
    required this.customerId,
    this.medicalStoreId,
    required this.orderType,
    required this.orderInputType,
    this.prescriptionFileUrl,
    this.prescriptionText,
    this.voiceNoteUrl,
    required this.status,
    this.totalAmount,
    this.billFileUrl,
    this.completionOtp,
    this.completedOn,
    this.rejectionReason,
    this.customerRejectionReason,
    this.customerRejectionPhotoUrl,
    this.shippingAddressLine1,
    this.shippingAddressLine2,
    this.shippingArea,
    this.shippingCity,
    this.shippingPincode,
    this.shippingLatitude,
    this.shippingLongitude,
    required this.isActive,
    required this.createdOn,
    this.updatedOn,
    this.orderNumber,
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
    return OrderModel(
      // ✅ FIXED: Use _toString to handle if these come as int
      orderId: _toString(json['orderId'] ?? json['id'], ''),
      customerId: _toString(json['customerId'], ''),
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
      billFileUrl: _toStringOrNull(json['billFileUrl']),

      // Handle completionOtp as int or string
      completionOtp: _toStringOrNull(json['completionOtp']),

      completedOn: json['completedOn'] != null
          ? DateTime.parse(json['completedOn'])
          : null,

      rejectionReason: _toStringOrNull(json['rejectionReason']),
      customerRejectionReason: _toStringOrNull(json['customerRejectionReason']),
      customerRejectionPhotoUrl:
          _toStringOrNull(json['customerRejectionPhotoUrl']),

      orderNumber:
          _toStringOrNull(json['orderNumber']),

      // Shipping Address - all using safe string conversion
      shippingAddressLine1: _toStringOrNull(json['shippingAddressLine1']),
      shippingAddressLine2: _toStringOrNull(json['shippingAddressLine2']),
      shippingArea: _toStringOrNull(json['shippingArea']),
      shippingCity: _toStringOrNull(json['shippingCity']),

      // Handle pincode as int or string
      shippingPincode: _toStringOrNull(json['shippingPincode']),

      shippingLatitude: json['shippingLatitude']?.toDouble(),
      shippingLongitude: json['shippingLongitude']?.toDouble(),

      isActive: json['isActive'] ?? true,
      createdOn:
          DateTime.parse(json['createdOn'] ?? DateTime.now().toIso8601String()),
      updatedOn:
          json['updatedOn'] != null ? DateTime.parse(json['updatedOn']) : null,
    );
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
      'medicalStoreId': medicalStoreId,
      'orderType': orderType.value,
      'orderInputType': orderInputType.value,
      'prescriptionFileUrl': prescriptionFileUrl,
      'prescriptionText': prescriptionText,
      'voiceNoteUrl': voiceNoteUrl,
      'status': status,
      'totalAmount': totalAmount,
      'billFileUrl': billFileUrl,
      'completionOtp': completionOtp,
      'completedOn': completedOn?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'customerRejectionReason': customerRejectionReason,
      'customerRejectionPhotoUrl': customerRejectionPhotoUrl,
      'shippingAddressLine1': shippingAddressLine1,
      'shippingAddressLine2': shippingAddressLine2,
      'shippingArea': shippingArea,
      'shippingCity': shippingCity,
      'shippingPincode': shippingPincode,
      'shippingLatitude': shippingLatitude,
      'shippingLongitude': shippingLongitude,
      'isActive': isActive,
      'createdOn': createdOn.toIso8601String(),
      'updatedOn': updatedOn?.toIso8601String(),
    };
  }

  // Helper getters for displaying order types in UI
  String get orderTypeDisplayName => orderType.displayName;

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
