// File: lib/shared/models/order_assignment_history_model.dart

import 'package:pharmaish/utils/app_logger.dart';

/// Enum for Assignment Status
enum AssignmentStatus {
  assigned(0, 'Assigned'),
  accepted(1, 'Accepted'),
  rejected(2, 'Rejected');

  final int value;
  final String displayName;

  const AssignmentStatus(this.value, this.displayName);

  static AssignmentStatus fromValue(int value) {
    return AssignmentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AssignmentStatus.assigned,
    );
  }
}

/// Enum for Assigned By Type
enum AssignedByType {
  system(0, 'System'),
  customerSupport(1, 'Customer Support');

  final int value;
  final String displayName;

  const AssignedByType(this.value, this.displayName);

  static AssignedByType fromValue(int value) {
    return AssignedByType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AssignedByType.system,
    );
  }
}

/// Enum for Assign To
enum AssignTo {
  customer(0, 'Customer'),
  chemist(1, 'Chemist'),
  customerSupport(2, 'Customer Support'),
  delivery(3, 'Delivery');

  final int value;
  final String displayName;

  const AssignTo(this.value, this.displayName);

  static AssignTo fromValue(int value) {
    return AssignTo.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AssignTo.chemist,
    );
  }
  
  /// Parse from string value (from API: "Customer", "Chemist", "Delivery")
  static AssignTo fromString(String value) {
    switch (value.toLowerCase()) {
      case 'customer':
        return AssignTo.customer;
      case 'chemist':
        return AssignTo.chemist;
      case 'customersupport':
      case 'customer support':
        return AssignTo.customerSupport;
      case 'delivery':
        return AssignTo.delivery;
      default:
        return AssignTo.chemist;
    }
  }
}

/// Model for Order Assignment History
/// Matches the API response from /api/Orders/{id}
class OrderAssignmentHistoryModel {
  final int assignmentId;
  final int orderId;
  final String customerId;
  final String? medicalStoreId;
  final AssignedByType assignedByType;
  final String? assignedByCustomerSupportId;
  final int? deliveryId;
  final AssignTo assignTo;
  final DateTime assignedOn;
  final AssignmentStatus status;
  final String? rejectNote;
  final DateTime? updatedOn;
  
  // Additional info from API (assignee name and assignment status as string)
  final String? assigneeName;
  final String? assignmentStatusString;

  OrderAssignmentHistoryModel({
    required this.assignmentId,
    required this.orderId,
    required this.customerId,
    this.medicalStoreId,
    required this.assignedByType,
    this.assignedByCustomerSupportId,
    this.deliveryId,
    required this.assignTo,
    required this.assignedOn,
    required this.status,
    this.rejectNote,
    this.updatedOn,
    this.assigneeName,
    this.assignmentStatusString,
  });

  factory OrderAssignmentHistoryModel.fromJson(Map<String, dynamic> json) {
    try {
      return OrderAssignmentHistoryModel(
        assignmentId: json['assignmentId'] ?? 0,
        orderId: json['orderId'] ?? 0,
        customerId: json['customerId']?.toString() ?? '',
        medicalStoreId: json['medicalStoreId']?.toString(),
        assignedByType: AssignedByType.fromValue(json['assignedByType'] ?? 0),
        assignedByCustomerSupportId: json['assignedByCustomerSupportId']?.toString(),
        deliveryId: json['deliveryId'],
        
        // Parse assignTo - can be int or string
        assignTo: json['assignTo'] is int 
            ? AssignTo.fromValue(json['assignTo'])
            : AssignTo.fromString(json['assignTo']?.toString() ?? 'Chemist'),
        
        assignedOn: DateTime.parse(json['assignedOn'] ?? DateTime.now().toIso8601String()),
        
        // Parse status - can be int or from string "assignmentStatus"
        status: json['status'] != null
            ? AssignmentStatus.fromValue(json['status'])
            : _parseStatusFromString(json['assignmentStatus']),
        
        rejectNote: json['rejectNote'],
        updatedOn: json['updatedOn'] != null ? DateTime.parse(json['updatedOn']) : null,
        
        // Additional fields from API
        assigneeName: json['assigneeName'],
        assignmentStatusString: json['assignmentStatus'],
      );
    } catch (e) {
      AppLogger.error('Error parsing OrderAssignmentHistoryModel: $e');
      AppLogger.error('JSON data: $json');
      rethrow;
    }
  }
  
  /// Parse assignment status from string value
  static AssignmentStatus _parseStatusFromString(String? statusString) {
    if (statusString == null) return AssignmentStatus.assigned;
    
    switch (statusString.toLowerCase()) {
      case 'assigned':
        return AssignmentStatus.assigned;
      case 'accepted':
        return AssignmentStatus.accepted;
      case 'rejected':
        return AssignmentStatus.rejected;
      default:
        return AssignmentStatus.assigned;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'assignmentId': assignmentId,
      'orderId': orderId,
      'customerId': customerId,
      'medicalStoreId': medicalStoreId,
      'assignedByType': assignedByType.value,
      'assignedByCustomerSupportId': assignedByCustomerSupportId,
      'deliveryId': deliveryId,
      'assignTo': assignTo.value,
      'assignedOn': assignedOn.toIso8601String(),
      'status': status.value,
      'rejectNote': rejectNote,
      'updatedOn': updatedOn?.toIso8601String(),
      'assigneeName': assigneeName,
      'assignmentStatus': assignmentStatusString,
    };
  }
  
  /// Get display name for assignee
  String get displayAssigneeName {
    return assigneeName ?? 'Unknown';
  }
  
  /// Get icon for assignment type
  String get assignmentTypeIcon {
    switch (assignTo) {
      case AssignTo.customer:
        return '👤';
      case AssignTo.chemist:
        return '💊';
      case AssignTo.customerSupport:
        return '🎧';
      case AssignTo.delivery:
        return '🚚';
    }
  }
}