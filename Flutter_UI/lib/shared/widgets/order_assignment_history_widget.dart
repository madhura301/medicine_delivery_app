// File: lib/shared/widgets/order_assignment_history_widget.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharmaish/shared/models/order_assignment_history_model.dart';
import 'package:pharmaish/shared/models/order_model.dart';

/// Display order assignment history from OrderModel
/// No API call needed - uses assignmentHistory from order object
class OrderAssignmentHistoryWidget extends StatelessWidget {
  final OrderModel order;
  final bool isAdminView; // Admin sees more details than customer

  const OrderAssignmentHistoryWidget({
    super.key,
    required this.order,
    this.isAdminView = false,
  });

  @override
  Widget build(BuildContext context) {
    // Check if order has assignment history
    if (!order.hasAssignmentHistory) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey.shade600),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No assignment history available',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(Icons.timeline, color: Colors.indigo.shade700),
              const SizedBox(width: 8),
              Text(
                'Assignment History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${order.assignmentCount} entries',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: order.assignmentHistory.length,
          itemBuilder: (context, index) {
            return _buildAssignmentHistoryItem(
              order.assignmentHistory[index],
              index,
              order.assignmentHistory.length,
            );
          },
        ),
      ],
    );
  }

  Widget _buildAssignmentHistoryItem(
    OrderAssignmentHistoryModel history,
    int index,
    int totalCount,
  ) {
    final isFirst = index == 0;
    final isLast = index == totalCount - 1;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              if (!isFirst)
                Container(
                  width: 2,
                  height: 8,
                  color: Colors.indigo.shade200,
                ),
              _buildStatusIcon(history.status),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.indigo.shade200,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(history.status).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(history.status).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status and assignment type
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(history.status),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          history.status.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getAssignToText(history.assignTo),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Timestamp
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, yyyy • hh:mm a')
                            .format(history.assignedOn.toLocal()),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),

                  // Assigned by info (Admin view only)
                  if (isAdminView) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'Assigned by: ${history.assignedByType.displayName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Assignee name
                  if (history.assigneeName != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          history.assignmentTypeIcon,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            history.displayAssigneeName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Assignment ID (Admin view only)
                  if (isAdminView) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Assignment ID: ${history.assignmentId}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],

                  // Reject note
                  if (history.rejectNote != null &&
                      history.rejectNote!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline,
                              size: 16, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rejection Reason:',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  history.rejectNote!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Updated timestamp
                  if (history.updatedOn != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Updated: ${DateFormat('MMM dd • hh:mm a').format(history.updatedOn!.toLocal())}',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(AssignmentStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case AssignmentStatus.assigned:
        icon = Icons.assignment;
        color = Colors.blue;
        break;
      case AssignmentStatus.accepted:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case AssignmentStatus.rejected:
        icon = Icons.cancel;
        color = Colors.red;
        break;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Color _getStatusColor(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.assigned:
        return Colors.blue;
      case AssignmentStatus.accepted:
        return Colors.green;
      case AssignmentStatus.rejected:
        return Colors.red;
    }
  }

  String _getAssignToText(AssignTo assignTo) {
    switch (assignTo) {
      case AssignTo.chemist:
        return 'To Chemist';
      case AssignTo.delivery:
        return 'To Delivery';
      case AssignTo.customerSupport:
        return 'To Support';
      case AssignTo.customer:
        return 'To Customer';
    }
  }
}