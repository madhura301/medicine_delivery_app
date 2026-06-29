// Shown when a user taps "Register as Pharmacy/Pharmacist"

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:pharmaish/core/app_routes.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class TransparentPricingDialog extends StatefulWidget {
  const TransparentPricingDialog({super.key});

  @override
  State<TransparentPricingDialog> createState() =>
      TransparentPricingDialogState();
}

class TransparentPricingDialogState extends State<TransparentPricingDialog> {
  bool _agreed = false;

  static const Color _indigo = Color(0xFF5B4FE0);
  static const Color _indigoDark = Color(0xFF312E81);
  static const Color _green = Color(0xFF16A34A);
  static const Color _orange = Color(0xFFEA8A1E);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildTopCards(),
                const SizedBox(height: 12),
                _buildGreenBanner(),
                const SizedBox(height: 12),
                _buildIndependentlySection(),
                const SizedBox(height: 12),
                _buildOnboardingPolicySection(),
                const SizedBox(height: 12),
                _buildNotesSection(),
                const SizedBox(height: 12),
                _buildGatewayBanner(),
                const SizedBox(height: 16),
                _buildAgreeCheckbox(),
                const SizedBox(height: 10),
                _buildTermsLine(),
                const SizedBox(height: 14),
                _buildProceedButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back, size: 24),
        ),
        Expanded(
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Transparent Pricing',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _indigoDark,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.verified, color: _indigo, size: 22),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Clear. Fair. Pharmacy-first.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
      ],
    );
  }

  // ── Top fee cards ─────────────────────────────────────────────────────────
  Widget _buildTopCards() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _feeCard(
              icon: Icons.rocket_launch,
              iconColor: _indigo,
              iconBg: const Color(0xFFEDEBFB),
              title: 'One-time Platform Onboarding Fee',
              value: const Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: '₹14,999/-',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _indigo,
                    ),
                  ),
                ]),
              ),
              extra: '+ GST 18%',
              subtitle:
                  'One-time setup charge to activate your pharmacy on the '
                  'Pharmaish platform.',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _feeCard(
              icon: Icons.desktop_windows,
              iconColor: _green,
              iconBg: const Color(0xFFE6F6EC),
              title: 'Platform Technology Fee Schedule '
                  '(Per Successfully Completed Order)',
              value: InkWell(
                onTap: () => _openUrl(AppConstants.paymentPolicyUrl),
                child: const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Payment Policy',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _green,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.only(left: 4),
                          child:
                              Icon(Icons.open_in_new, size: 14, color: _green),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              subtitle:
                  'The Platform Technology Fee is charged slab-wise on each '
                  'successfully completed order, and the minimum order value is Rs.200/-',
            ),
          ),
        ],
      ),
    );
  }

  Widget _feeCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required Widget value,
    String? extra,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: iconBg,
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                value,
                if (extra != null) ...[
                  const SizedBox(height: 2),
                  Text(extra,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                ],
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                        fontSize: 10.5,
                        color: Colors.grey.shade600,
                        height: 1.3),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Green banner ──────────────────────────────────────────────────────────
  Widget _buildGreenBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FAF3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCDEBD6)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _bannerCol(
                icon: Icons.check_circle,
                iconColor: _green,
                bold: 'No commission on medicines. No margin or profit '
                    'sharing.',
                sub: 'You keep 100% of your medicine sales.',
              ),
            ),
            const VerticalDivider(width: 20, thickness: 1),
            Expanded(
              child: _bannerCol(
                icon: Icons.verified_user,
                iconColor: _indigo,
                bold: '100% of the invoice value is remitted to the pharmacy.',
                sub: 'We only charge a platform fee.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bannerCol({
    required IconData icon,
    required Color iconColor,
    required String bold,
    required String sub,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bold,
                  style: const TextStyle(
                      fontSize: 11.5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(sub,
                  style:
                      TextStyle(fontSize: 10.5, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Pharmacy independently ────────────────────────────────────────────────
  Widget _buildIndependentlySection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pharmacy independently:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _independentItem(Icons.sell_outlined, 'Sets prices',
                    'You decide the best prices for your customers.'),
                _independentItem(Icons.fact_check_outlined,
                    'Verifies prescriptions',
                    'You verify and approve prescriptions as per regulatory norms.'),
                _independentItem(Icons.description_outlined, 'Generates invoice',
                    'You generate invoices in your pharmacy name.'),
                _independentItem(Icons.local_shipping_outlined, 'Delivers orders',
                    'You deliver orders to customers.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _independentItem(IconData icon, String title, String desc) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFEDEBFB),
                    child: Icon(icon, color: _indigo, size: 20),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle,
                          color: _green, size: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 9.5, color: Colors.grey.shade600, height: 1.25),
            ),
          ],
        ),
      ),
    );
  }

  // ── Notes ─────────────────────────────────────────────────────────────────
  Widget _buildNotesSection() {
    const notes = [
      'Applicable fee is charged on each successfully completed order.',
      'Fee is automatically deducted through the settlement mechanism.',
      "Applicable slab is determined based on the pharmacy's order volume.",
      'Pharmaish reserves the right to revise, modify, introduce, withdraw, '
          'or restructure the fee schedule from time to time.',
      '18% Taxes (GST) and applicable gateway charges are additional where '
          'applicable.',
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F0FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9D6F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.description_outlined, size: 16, color: _indigo),
              SizedBox(width: 6),
              Text(
                'Notes',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _indigoDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final note in notes)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, size: 15, color: _indigo),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey.shade800,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Gateway / bank charges ────────────────────────────────────────────────
  Widget _buildGatewayBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF3E7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF6E0BF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _orange.withValues(alpha: 0.15),
            child: const Icon(Icons.credit_card, color: _orange, size: 20),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gateway / Bank Charges',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text(
                  'Payment gateway / bank charges apply as per service '
                  'provider terms.',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('As applicable',
                  style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: _orange)),
              SizedBox(width: 4),
              Icon(Icons.info_outline, size: 14, color: _orange),
            ],
          ),
        ],
      ),
    );
  }

  // ── Onboarding policy link (replaces the slab-wise fee table) ─────────────
  Widget _buildOnboardingPolicySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F0FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9D6F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'To view the detailed slab-wise rates, please refer to our '
            'Retailer Onboarding Policy.',
            style: TextStyle(
                fontSize: 11.5, color: Colors.grey.shade700, height: 1.35),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => _openUrl(AppConstants.retailerOnboardingPolicyUrl),
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.open_in_new, size: 16, color: _indigo),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'View Retailer Onboarding Policy',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: _indigo,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Agreement checkbox ────────────────────────────────────────────────────
  Widget _buildAgreeCheckbox() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: _agreed,
            onChanged: (v) => setState(() => _agreed = v ?? false),
            activeColor: _indigo,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _agreed = !_agreed),
              child: const Text(
                'I understand and agree that the onboarding fee, GST, and '
                'gateway charges (as applicable) will be charged as per the '
                'above terms.',
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsLine() {
    const linkStyle = TextStyle(
      fontSize: 12,
      color: _indigo,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
    );
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          children: [
            const TextSpan(text: 'By proceeding, you agree to our '),
            TextSpan(
              text: 'Terms & Conditions',
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () => _openUrl(AppConstants.termsAndConditionsUrl),
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () => _openUrl(AppConstants.privacyPolicyUrl),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }

  // ── Proceed button ────────────────────────────────────────────────────────
  Widget _buildProceedButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _agreed
            ? () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, AppRoutes.registerPharmacist);
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _indigo,
          disabledBackgroundColor: _indigo.withValues(alpha: 0.4),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Proceed to Register',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_circle_right_outlined, size: 22),
          ],
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open link')),
        );
      }
    }
  }
}
