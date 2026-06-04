import 'package:flutter/material.dart';
import 'package:pharmaish/core/services/consent_service.dart';
import 'package:pharmaish/shared/widgets/consent_dialog.dart';
import 'package:pharmaish/utils/constants.dart';

/// Show a consent dialog and log the accept/reject decision to the backend.
///
/// Returns `true` when the user accepts. The dialog auto-pops on accept; on
/// cancel the helper pops the dialog itself before calling [rejectConsent].
///
/// Reject metadata is derived from [metadata] by overlaying
/// `{action: 'rejected', reason: 'User clicked cancel'}` so audit logs always
/// include the consent context.
Future<bool> _showConsent(
  BuildContext context, {
  required ConsentType consentType,
  required String title,
  required IconData titleIcon,
  required Color titleColor,
  required String message,
  required Map<String, dynamic> metadata,
  String confirmButtonText = 'I Agree',
  String cancelButtonText = 'Cancel',
  bool requireCheckbox = false,
  String? checkboxText,
  Map<String, String>? links,
  String rejectionReason = 'User declined consent',
  bool barrierDismissible = false,
}) async {
  bool accepted = false;
  final consentId = await ConsentService.getConsentIdByType(consentType);
  if (!context.mounted) return false;

  await showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) => ConsentDialog(
      title: title,
      titleIcon: titleIcon,
      titleColor: titleColor,
      message: message,
      requireCheckbox: requireCheckbox,
      checkboxText: checkboxText,
      links: links,
      confirmButtonText: confirmButtonText,
      cancelButtonText: cancelButtonText,
      onConfirm: () async {
        accepted = true;
        if (consentId != null) {
          await ConsentService.acceptConsent(
            consentId: consentId,
            metadata: metadata,
          );
        }
      },
      onCancel: () async {
        accepted = false;
        Navigator.of(ctx).pop();
        if (consentId != null) {
          await ConsentService.rejectConsent(
            consentId: consentId,
            reason: rejectionReason,
            metadata: {
              ...metadata,
              'action': 'rejected',
              'reason': 'User clicked cancel',
            },
          );
        }
      },
    ),
  );

  return accepted;
}

/// Pharmacist-facing consent dialogs.
class PharmacistConsentManager {
  /// Retailer Registration Consent (DPDP). Shown during pharmacy sign-up.
  static Future<bool> showRetailerRegistrationConsent(BuildContext context) =>
      _showConsent(
        context,
        consentType: ConsentType.retailerRegistrationConsent,
        title: 'Retailer Registration Consent',
        titleIcon: Icons.handshake,
        titleColor: const Color(0xFFD97706),
        message:
            'By registering, you consent to Pharmaish processing your personal and store information for verification, communication, and referrals. We do not share any data without your consent.',
        confirmButtonText: 'I Agree',
        metadata: const {
          'context': 'pharmacy_registration',
          'mandatory': true,
          'compliance': 'DPDP',
        },
      );

  /// License Verification Confirmation (Drugs & Cosmetics Act).
  /// Shown during pharmacy onboarding.
  static Future<bool> showLicenseVerificationConfirmation(
          BuildContext context) =>
      _showConsent(
        context,
        consentType: ConsentType.licenseVerificationConfirmation,
        title: 'License Verification Confirmation',
        titleIcon: Icons.verified_outlined,
        titleColor: const Color(0xFFD97706),
        message:
            'I confirm that my pharmacy holds valid licenses required to dispense medicines. I agree to upload/verify my Drug License, GST, and Pharmacist-in-charge details.',
        confirmButtonText: 'Confirm',
        metadata: const {
          'context': 'pharmacy_onboarding',
          'mandatory': true,
          'compliance': 'Drugs & Cosmetics Act',
        },
      );

  /// Data Handling & Liability Disclaimer (Legal Protection).
  /// Shown when pharmacy opens a patient order.
  static Future<bool> showDataHandlingLiabilityDisclaimer(
    BuildContext context, {
    String? orderId,
    String? customerId,
  }) =>
      _showConsent(
        context,
        consentType: ConsentType.dataHandlingLiabilityDisclaimer,
        title: 'Data Handling & Liability Disclaimer',
        titleIcon: Icons.balance,
        titleColor: const Color(0xFFD97706),
        message:
            'As a licensed pharmacy, you are solely responsible for dispensing '
            'medicines as per prescription, pricing, packing, expiry compliance, '
            'and legal obligations. Pharmaish is not involved in '
            'sale/stock/dispensing of medicines.',
        confirmButtonText: 'Understood',
        rejectionReason: 'User declined disclaimer',
        metadata: {
          'context': 'order_view',
          'orderId': orderId,
          'customerId': customerId,
          'mandatory': true,
          'compliance': 'Legal Protection',
        },
      );

  /// Prescription Access Permission (DPDP-Sensitive Data).
  /// Shown when viewing patient prescription.
  static Future<bool> showPrescriptionAccessPermission(
    BuildContext context, {
    String? orderId,
    String? customerId,
  }) =>
      _showConsent(
        context,
        consentType: ConsentType.prescriptionAccessPermission,
        title: 'Prescription Access Permission',
        titleIcon: Icons.description_outlined,
        titleColor: const Color(0xFFD97706),
        message:
            'By tapping "View Prescription", you acknowledge that the prescription '
            'contains sensitive personal health information and you will access it '
            'only for lawful dispensing purposes.',
        confirmButtonText: 'View Prescription',
        metadata: {
          'context': 'prescription_view',
          'orderId': orderId,
          'customerId': customerId,
          'mandatory': true,
          'compliance': 'DPDP-Sensitive Data',
        },
      );

  /// Check if pharmacist has already accepted the order disclaimer.
  /// TODO: persist per-order acceptance to avoid re-prompting.
  static Future<bool> hasAcceptedOrderDisclaimer(String orderId) async => false;

  /// Check if pharmacist has already accepted prescription access for this order.
  /// TODO: persist per-order acceptance to avoid re-prompting.
  static Future<bool> hasAcceptedPrescriptionAccess(String orderId) async =>
      false;

  /// Show all onboarding consents in sequence.
  /// Returns true only if all mandatory consents are accepted.
  static Future<bool> showOnboardingConsentsSequence(
      BuildContext context) async {
    final registrationAccepted = await showRetailerRegistrationConsent(context);
    if (!registrationAccepted) return false;
    if (!context.mounted) return false;

    final licenseAccepted =
        await showLicenseVerificationConfirmation(context);
    if (!licenseAccepted) return false;

    return true;
  }

  /// Whether prescription access consent must be re-prompted in this session.
  static Future<bool> needsPrescriptionAccessConsent() async => true;
}

/// Customer-facing consent dialogs.
class CustomerConsentManager {
  /// General Data Consent (DPDP). Shown after first login/registration.
  static Future<bool> showGeneralDataConsent(BuildContext context) =>
      _showConsent(
        context,
        consentType: ConsentType.generalDataConsent,
        title: 'General Data Consent',
        titleIcon: Icons.lock_outline,
        titleColor: const Color(0xFF2E7D32),
        message:
            'To continue, please allow us to process your personal data for secure account creation and order fulfillment. We do not share any data without your consent.',
        confirmButtonText: 'Allow',
        metadata: const {
          'context': 'customer_registration',
          'mandatory': true,
          'compliance': 'DPDP',
        },
      );

  /// Prescription Sharing Consent. Shown when uploading a prescription.
  static Future<bool> showPrescriptionSharingConsent(BuildContext context) =>
      _showConsent(
        context,
        consentType: ConsentType.prescriptionSharingConsent,
        title: 'Prescription Sharing Consent',
        titleIcon: Icons.local_pharmacy,
        titleColor: const Color(0xFFD97706),
        message:
            'We need your permission to securely share your prescription with a licensed pharmacy to fulfil your order.',
        confirmButtonText: 'Allow',
        metadata: const {
          'context': 'prescription_upload',
          'mandatory': true,
          'compliance': 'DPDP',
        },
      );

  /// Terms & Conditions Acceptance. Shown on first app launch.
  static Future<bool> showTermsAndConditions(BuildContext context) =>
      _showConsent(
        context,
        consentType: ConsentType.termsAndConditions,
        title: 'Accept Terms & Conditions',
        titleIcon: Icons.check_circle_outline,
        titleColor: const Color(0xFFD97706),
        message:
            'To continue, please accept our Terms & Conditions and Privacy Policy to use the Pharmaish platform.',
        checkboxText:
            'I have read and agree to the Terms & Conditions and Privacy Policy',
        requireCheckbox: true,
        confirmButtonText: 'I Accept',
        links: {
          'Terms & Conditions': AppConstants.termsAndConditionsUrl,
          'Privacy Policy': AppConstants.privacyPolicyUrl,
        },
        metadata: const {
          'context': 'app_launch',
          'mandatory': true,
          'compliance': 'DPDP',
        },
      );

  /// Patient Counselling Disclaimer. Information-only — no consent logging.
  static Future<void> showPatientCounsellingDisclaimer(
      BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => InfoDialog(
        title: 'Patient Counselling Disclaimer',
        titleIcon: Icons.info_outline,
        titleColor: const Color(0xFFD97706),
        message:
            'Pharmacist counselling is for educational purposes only and is NOT a substitute for medical advice. Users must consult their doctor for any diagnosis or treatment changes.',
        buttonText: 'Understood',
        onConfirm: () {},
      ),
    );
  }

  /// Account/Data Deletion Confirmation (DPDP Right to be Forgotten).
  /// NOTE: uses `generalDataConsent` type — preserved from original code, may
  /// be a backend-side bug worth confirming with the team.
  static Future<bool> showAccountDeletionConfirmation(BuildContext context) =>
      _showConsent(
        context,
        consentType: ConsentType.generalDataConsent,
        title: 'Delete Account & Data?',
        titleIcon: Icons.warning_amber,
        titleColor: Colors.red.shade600,
        message:
            'Deleting your account will permanently erase all your stored data. Do you want to continue?',
        confirmButtonText: 'Yes, Delete',
        barrierDismissible: true,
        metadata: const {
          'action': 'account_deletion_requested',
          'compliance': 'DPDP Right to be Forgotten',
        },
      );
}
