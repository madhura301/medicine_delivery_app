// lib/shared/models/order_enums.dart

/// Matches backend OrderInputType enum
enum OrderInputType {
  image(0),    // For both File Upload and Camera
  voice(1),    // For Voice Recording
  text(2);     // For Text and WhatsApp

  final int value;
  const OrderInputType(this.value);

  static OrderInputType fromValue(int value) {
    return OrderInputType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => OrderInputType.image,
    );
  }
}

/// Matches backend OrderType enum
enum OrderType {
  notSet(0),
  otc(1),                    // Over-the-Counter
  prescriptionDrugs(2);      // Requires prescription

  final int value;
  const OrderType(this.value);

  String get displayName {
    switch (this) {
      case OrderType.otc:
        return 'Over-the-Counter (OTC)';
      case OrderType.prescriptionDrugs:
        return 'Prescription Required';
      default:
        return 'Not Set';
    }
  }

  static OrderType fromValue(int value) {
    return OrderType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => OrderType.notSet,
    );
  }
}

/// Order status enum
enum OrderStatus {
  pendingPayment(0),
  assignedToChemist(1),
  rejectedByChemist(2),
  acceptedByChemist(3),
  billUploaded(4),
  paid(5),
  outForDelivery(6),
  completed(7);

  final int value;
  const OrderStatus(this.value);

  String get displayName {
    switch (this) {
      case OrderStatus.pendingPayment:
        return 'Pending Payment';
      case OrderStatus.paid:
        return 'Paid';
      case OrderStatus.assignedToChemist:
        return 'Assigned to Chemist';
      case OrderStatus.rejectedByChemist:
        return 'Rejected by Chemist';
      case OrderStatus.acceptedByChemist:
        return 'Accepted by Chemist';
      case OrderStatus.billUploaded:
        return 'Bill Uploaded';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.completed:
        return 'Completed';
    }
  }

  static OrderStatus fromValue(int value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pendingPayment,
    );
  }
}

enum DeliveryType {
  homeDelivery,  // 0
  storePickup,   // 1
}

enum OrderUrgency {
  regular,  // 0
  urgent,   // 1
}