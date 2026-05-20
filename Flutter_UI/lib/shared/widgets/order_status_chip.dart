import 'package:flutter/material.dart';

/// Pill-shaped chip showing an order's status with consistent color & label.
///
/// Replaces three near-duplicate `_buildStatusChip` implementations that had
/// drifted on color choices (e.g. completed=Teal vs Green vs Blue, accepted=
/// Green vs Blue) and on which statuses were handled at all.
///
/// Status string is matched case-insensitively against substring keywords
/// (the backend returns names like "Pending", "BillUploaded", "OutForDelivery",
/// "AssignedToCustomerSupport"). Unknown statuses fall through to grey.
class OrderStatusChip extends StatelessWidget {
  final String status;

  const OrderStatusChip(this.status, {super.key});

  static _StatusStyle _styleFor(String status) {
    final s = status.toLowerCase();
    if (s.contains('pending') || s.contains('assigned')) {
      return const _StatusStyle('Pending', Colors.orange);
    }
    if (s.contains('rejected')) {
      return const _StatusStyle('Rejected', Colors.red);
    }
    if (s.contains('outfordelivery') ||
        (s.contains('delivery') && !s.contains('completed'))) {
      return const _StatusStyle('Out for Delivery', Colors.deepPurple);
    }
    if (s.contains('billuploaded') || s.contains('bill')) {
      return const _StatusStyle('Bill Uploaded', Colors.purple);
    }
    if (s.contains('completed')) {
      return const _StatusStyle('Completed', Colors.blue);
    }
    if (s.contains('accepted')) {
      return const _StatusStyle('Accepted', Colors.green);
    }
    return _StatusStyle(status, Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: style.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: style.color, width: 1),
      ),
      child: Text(
        style.label,
        style: TextStyle(
          color: style.color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatusStyle {
  final String label;
  final Color color;
  const _StatusStyle(this.label, this.color);
}
