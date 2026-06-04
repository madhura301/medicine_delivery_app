import 'package:flutter/material.dart';
import 'package:pharmaish/shared/widgets/app_button.dart';

class RejectOrderDialog extends StatefulWidget {
  final String orderId;

  const RejectOrderDialog({super.key, required this.orderId});

  @override
  State<RejectOrderDialog> createState() => _RejectOrderDialogState();
}

class _RejectOrderDialogState extends State<RejectOrderDialog> {
  String? _selectedReason;
  final _controller = TextEditingController();
  final _reasons = [
    'Out of stock',
    'Prescription not clear',
    'Invalid prescription',
    'Restricted medication',
    'Delivery location not serviceable',
    'Other'
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Reject Order ${widget.orderId}'),
      content: RadioGroup<String>(
        groupValue: _selectedReason,
        onChanged: (value) => setState(() => _selectedReason = value),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please select a reason for rejection:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              ..._reasons.map((reason) => RadioListTile<String>(
                    title: Text(reason),
                    value: reason,
                    contentPadding: EdgeInsets.zero,
                    activeColor: Colors.black,
                  )),
              if (_selectedReason == 'Other') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Custom reason',
                    border: OutlineInputBorder(),
                    hintText: 'Enter your reason...',
                  ),
                  maxLines: 3,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedReason == null
              ? null
              : () {
                  final reason = _selectedReason == 'Other'
                      ? _controller.text
                      : _selectedReason!;
                  Navigator.pop(context, reason);
                },
          style: AppButton.danger(),
          child: const Text('Reject'),
        ),
      ],
    );
  }
}
