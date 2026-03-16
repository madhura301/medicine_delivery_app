// Shown when a user taps "Register as Pharmacy/Pharmacist"

import 'package:flutter/material.dart';
import 'package:pharmaish/core/app_routes.dart';

class TransparentPricingDialog extends StatefulWidget {
  const TransparentPricingDialog();

  @override
  State<TransparentPricingDialog> createState() =>
      TransparentPricingDialogState();
}

class TransparentPricingDialogState extends State<TransparentPricingDialog> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Title ──────────────────────────────────────────
                Center(
                  child: Text(
                    'Transparent Pricing',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                // ── Pricing items ──────────────────────────────────
                _pricingItem(
                  boldPrefix: 'One-time',
                  rest: ' Platform Onboarding Fee: ₹199',
                ),
                const Divider(height: 24),

                _pricingItem(
                  text: 'Platform Access & Technology Usage Fee:\n',
                  trailing: Text.rich(
                    TextSpan(children: [
                      const TextSpan(
                        text: '2%',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text: ' per successful order',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ]),
                  ),
                ),
                const Divider(height: 24),

                _pricingItem(
                  boldText:
                      'No commission on medicines. No margin or profit sharing.',
                ),
                const Divider(height: 24),

                // Pharmacy independently block
                _pricingItem(text: 'Pharmacy independently:'),
                const SizedBox(height: 6),
                _subItem('Sets prices'),
                _subItem('Verifies prescriptions'),
                _subItem('Generates the invoice'),
                _subItem('Delivers orders to customers'),
                const Divider(height: 24),

                _pricingItem(
                  leading: Text.rich(TextSpan(children: [
                    const TextSpan(
                      text: '100%',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: ' of the invoice value is ',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    const TextSpan(
                      text: 'remitted to the pharmacy.',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic),
                    ),
                  ])),
                ),
                const Divider(height: 24),

                _pricingItem(
                  italic:
                      'Payment gateway / bank charges apply as per service provider terms.',
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                // ── Checkbox ───────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agreed,
                      onChanged: (v) => setState(() => _agreed = v ?? false),
                      activeColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _agreed = !_agreed),
                        child: const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text.rich(
                            TextSpan(
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black87),
                              children: [
                                TextSpan(
                                    text:
                                        'I understand and agree that the platform charges a technology usage '),
                                TextSpan(
                                  text: 'fee per successful order.',
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Proceed button ─────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _agreed
                        ? () {
                            Navigator.of(context).pop();
                            Navigator.pushNamed(
                                context, AppRoutes.registerPharmacist);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      disabledBackgroundColor: Colors.blue.shade200,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Proceed to Register',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Item with green check icon ─────────────────────────────────────────────
  Widget _pricingItem({
    String? text,
    String? boldText,
    String? italic,
    String? boldPrefix,
    String? rest,
    Widget? trailing,
    Widget? leading,
  }) {
    Widget label;

    if (leading != null) {
      label = leading;
    } else if (trailing != null) {
      label = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text ?? '',
              style: const TextStyle(fontSize: 14, color: Colors.black87)),
          trailing,
        ],
      );
    } else if (boldText != null) {
      label = Text(
        boldText,
        style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900),
      );
    } else if (italic != null) {
      label = Text(
        italic,
        style: const TextStyle(
            fontSize: 14, fontStyle: FontStyle.italic, color: Colors.black87),
      );
    } else if (boldPrefix != null) {
      label = Text.rich(TextSpan(children: [
        TextSpan(
          text: boldPrefix,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.blue.shade900),
        ),
        TextSpan(
          text: rest ?? '',
          style: TextStyle(fontSize: 14, color: Colors.blue.shade900),
        ),
      ]));
    } else {
      label = Text(
        text ?? '',
        style: TextStyle(fontSize: 14, color: Colors.blue.shade900),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 24),
        const SizedBox(width: 12),
        Expanded(child: label),
      ],
    );
  }

  // ── Sub-item with small green tick ────────────────────────────────────────
  Widget _subItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 36, bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
