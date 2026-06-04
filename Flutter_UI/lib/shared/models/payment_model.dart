import 'package:flutter/material.dart';

/// Status of a recorded payment. Mirrors the backend `PaymentStatus` enum
/// (Pending = 0, Success = 1, Failed = 2).
enum PaymentStatus {
  pending,
  success,
  failed;

  static PaymentStatus fromValue(dynamic value) {
    if (value == null) return PaymentStatus.pending;

    // Backend serializes the enum as an int, but tolerate a string too.
    int? code;
    if (value is int) {
      code = value;
    } else if (value is String) {
      code = int.tryParse(value);
      if (code == null) {
        switch (value.toLowerCase()) {
          case 'success':
            return PaymentStatus.success;
          case 'failed':
            return PaymentStatus.failed;
          case 'pending':
            return PaymentStatus.pending;
        }
      }
    }

    switch (code) {
      case 1:
        return PaymentStatus.success;
      case 2:
        return PaymentStatus.failed;
      case 0:
      default:
        return PaymentStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case PaymentStatus.success:
        return 'Success';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.pending:
        return 'Pending';
    }
  }

  Color get color {
    switch (this) {
      case PaymentStatus.success:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.pending:
        return Colors.orange;
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentStatus.success:
        return Icons.check_circle;
      case PaymentStatus.failed:
        return Icons.cancel;
      case PaymentStatus.pending:
        return Icons.hourglass_top;
    }
  }
}

/// A single payment recorded against an order. Matches the backend `PaymentDto`.
class PaymentModel {
  final int paymentId;
  final int orderId;
  final String paymentMode;
  final String transactionId;
  final double amount;
  final PaymentStatus status;
  final DateTime paidOn;

  const PaymentModel({
    required this.paymentId,
    required this.orderId,
    required this.paymentMode,
    required this.transactionId,
    required this.amount,
    required this.status,
    required this.paidOn,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      paymentId: (json['paymentId'] ?? json['PaymentId'] ?? 0) as int,
      orderId: (json['orderId'] ?? json['OrderId'] ?? 0) as int,
      paymentMode: (json['paymentMode'] ?? json['PaymentMode'] ?? '').toString(),
      transactionId:
          (json['transactionId'] ?? json['TransactionId'] ?? '').toString(),
      amount: ((json['amount'] ?? json['Amount'] ?? 0) as num).toDouble(),
      status: PaymentStatus.fromValue(
          json['paymentStatus'] ?? json['PaymentStatus']),
      paidOn: DateTime.parse(
          (json['paidOn'] ?? json['PaidOn'] ?? DateTime.now().toIso8601String())
              .toString()),
    );
  }
}
