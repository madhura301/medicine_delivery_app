import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pharmaish/shared/models/delivery_address_model.dart';
import 'package:pharmaish/utils/app_logger.dart';

/// Renders an order's delivery address the same way everywhere it appears.
///
/// Every order screen used to format the address by hand, and each did it a
/// little differently (some dropped the postcode, some showed only line 1). This
/// is the single place that decides how a destination looks.
class DeliveryAddressView extends StatelessWidget {
  final DeliveryAddressModel? address;

  /// Shown when there is no address to render.
  final String emptyText;

  /// Adds "Copy" and, when the address has coordinates, "Navigate" actions.
  /// On for the people who have to physically get there.
  final bool showActions;

  final TextStyle? textStyle;

  const DeliveryAddressView({
    super.key,
    required this.address,
    this.emptyText = 'Delivery address not available',
    this.showActions = false,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final addr = address;
    if (addr == null || addr.isEmpty) {
      return Text(
        emptyText,
        style: TextStyle(fontSize: 13, color: Colors.grey[600], fontStyle: FontStyle.italic),
      );
    }

    final style = textStyle ?? const TextStyle(fontSize: 14, height: 1.35);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...addr.displayLines.map(
          (line) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(line, style: style),
          ),
        ),
        if (showActions) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              _action(
                icon: Icons.copy,
                label: 'Copy',
                onTap: () => _copy(context, addr.singleLine),
              ),
              if (addr.hasCoordinates) ...[
                const SizedBox(width: 8),
                _action(
                  icon: Icons.directions,
                  label: 'Navigate',
                  onTap: () => _navigate(context, addr),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _action({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address copied'), duration: Duration(seconds: 2)),
    );
  }

  Future<void> _navigate(BuildContext context, DeliveryAddressModel addr) async {
    // geo: is handled by any Android maps app; Apple Maps and the web fall back
    // to the Google Maps URL, which works on both platforms.
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${addr.latitude},${addr.longitude}',
    );
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (launched || !context.mounted) return;
    } catch (e) {
      AppLogger.error('Could not open maps for delivery address: $e');
      if (!context.mounted) return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open maps')),
    );
  }
}

/// A titled card wrapping [DeliveryAddressView], for detail pages that show the
/// address as its own section.
class DeliveryAddressCard extends StatelessWidget {
  final DeliveryAddressModel? address;
  final String title;
  final bool showActions;
  final String emptyText;

  const DeliveryAddressCard({
    super.key,
    required this.address,
    this.title = 'Delivery Address',
    this.showActions = false,
    this.emptyText = 'Delivery address not available',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, size: 18, color: Colors.red.shade600),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DeliveryAddressView(
              address: address,
              showActions: showActions,
              emptyText: emptyText,
            ),
          ],
        ),
      ),
    );
  }
}
