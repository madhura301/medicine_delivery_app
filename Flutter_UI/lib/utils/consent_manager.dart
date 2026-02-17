import 'package:flutter/material.dart';
import 'package:pharmaish/core/services/consent_service.dart';
import 'package:pharmaish/shared/widgets/consent_dialog.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';

/// Manages the display and logging of all pharmacist consent dialogs
class PharmacistConsentManager {
  /// 1. Retailer Registration Consent (DPDP Required)
  /// Shown during pharmacy sign-up
  static Future<bool> showRetailerRegistrationConsent(
    BuildContext context,
  ) async {
    bool accepted = false;

// Get consent ID from backend
    final consentId = await ConsentService.getConsentIdByType(
        ConsentType.retailerRegistrationConsent);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConsentDialog(
        title: 'Retailer Registration Consent',
        titleIcon: Icons.handshake,
        titleColor: const Color(0xFFD97706), // Orange
        message:
            'By registering, you consent to Pharmaish processing your personal and store information for verification, communication, and referrals. We do not share any data without your consent.',
        requireCheckbox: false,
        confirmButtonText: 'I Agree',
        cancelButtonText: 'Cancel',
        onConfirm: () async {
          accepted = true;
          // await ConsentService.logConsent(
          //   consentType: ConsentType.retailerRegistrationConsent,
          //   granted: true,
          //   metadata: {
          //     'context': 'pharmacy_registration',
          //     'mandatory': true,
          //     'compliance': 'DPDP',
          //   },
          // );
          if (consentId != null) {
            await ConsentService.acceptConsent(
              // ✅ Call accept API
              consentId: consentId,
              metadata: {
                'context': 'pharmacy_registration',
                'mandatory': true,
                'compliance': 'DPDP',
              },
            );
          }
        },
        onCancel: () async {
          // ✅ NEW: Handle cancel
          accepted = false;
          if (consentId != null) {
            await ConsentService.rejectConsent(
              // ✅ Call reject API
              consentId: consentId,
              reason: 'User declined consent',
              metadata: {
                'action': 'rejected',
                'reason': 'User clicked cancel',
                'context': 'pharmacy_registration',
              },
            );
          }
        },
      ),
    );

    return accepted;
  }

  /// 2. License Verification Confirmation (Drugs & Cosmetics Act Required)
  /// Shown during pharmacy onboarding
  static Future<bool> showLicenseVerificationConfirmation(
    BuildContext context,
  ) async {
    bool accepted = false;

// Get consent ID from backend
    final consentId = await ConsentService.getConsentIdByType(
        ConsentType.licenseVerificationConfirmation);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConsentDialog(
        title: 'License Verification Confirmation',
        titleIcon: Icons.verified_outlined,
        titleColor: const Color(0xFFD97706), // Orange
        message:
            'I confirm that my pharmacy holds valid licenses required to dispense medicines. I agree to upload/verify my Drug License, GST, and Pharmacist-in-charge details.',
        requireCheckbox: false,
        confirmButtonText: 'Confirm',
        cancelButtonText: 'Cancel',
        onConfirm: () async {
          accepted = true;
          // await ConsentService.logConsent(
          //   consentType: ConsentType.licenseVerificationConfirmation,
          //   granted: true,
          //   metadata: {
          //     'context': 'pharmacy_onboarding',
          //     'mandatory': true,
          //     'compliance': 'Drugs & Cosmetics Act',
          //   },
          // );

          if (consentId != null) {
            await ConsentService.acceptConsent(
              // ✅ Call accept API
              consentId: consentId,
              metadata: {
                'context': 'pharmacy_onboarding',
                'mandatory': true,
                'compliance': 'Drugs & Cosmetics Act',
              },
            );
          }
        },
        onCancel: () async {
          // ✅ NEW: Handle cancel
          accepted = false;
          if (consentId != null) {
            await ConsentService.rejectConsent(
                // ✅ Call reject API
                consentId: consentId,
                reason: 'User declined consent',
                metadata: {
                  'action': 'rejected',
                  'reason': 'User clicked cancel',
                  'context': 'pharmacy_onboarding',
                });
          }
        },
      ),
    );

    return accepted;
  }

  /// 3. Data Handling & Liability Disclaimer (Legal Protection Required)
  /// Shown when pharmacy opens a patient order
static Future<bool> showDataHandlingLiabilityDisclaimer(
    BuildContext context, {
    String? orderId,
    String? customerId,  // Changed from patientName to customerId
  }) async {
    bool accepted = false;

    // Get consent ID from backend
    final consentId = await ConsentService.getConsentIdByType(
        ConsentType.dataHandlingLiabilityDisclaimer);
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConsentDialog(
        title: 'Data Handling & Liability Disclaimer',
        titleIcon: Icons.balance,
        titleColor: const Color(0xFFD97706), // Orange
        message:
            'As a licensed pharmacy, you are solely responsible for dispensing '
            'medicines as per prescription, pricing, packing, expiry compliance, '
            'and legal obligations. Pharmaish is not involved in '
            'sale/stock/dispensing of medicines.',
        requireCheckbox: false,
        confirmButtonText: 'Understood',
        cancelButtonText: 'Cancel',
        onConfirm: () async {
          accepted = true;
          if (consentId != null) {
            await ConsentService.acceptConsent(
              consentId: consentId,
              metadata: {
                'context': 'order_view',
                'orderId': orderId,
                'customerId': customerId,
                'mandatory': true,
                'compliance': 'Legal Protection',
              },
            );
          }
        },
        onCancel: () async {
          accepted = false;
          if (consentId != null) {
            await ConsentService.rejectConsent(
              consentId: consentId,
              reason: 'User declined disclaimer',
              metadata: {
                'action': 'rejected',
                'reason': 'User clicked cancel',
                'context': 'order_view',
                'orderId': orderId,
                'customerId': customerId,
              },
            );
          }
        },
      ),
    );

    return accepted;
  }

  /// 4. Prescription Access Permission (DPDP-Sensitive Data Required)
  /// Shown when viewing patient prescription
  static Future<bool> showPrescriptionAccessPermission(
    BuildContext context, {
    String? orderId,
    String? customerId,  // Changed from patientName to customerId
  }) async {
    bool accepted = false;

    // Get consent ID from backend
    final consentId = await ConsentService.getConsentIdByType(
        ConsentType.prescriptionAccessPermission);
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConsentDialog(
        title: 'Prescription Access Permission',
        titleIcon: Icons.description_outlined,
        titleColor: const Color(0xFFD97706), // Orange
        message:
            'By tapping "View Prescription", you acknowledge that the prescription '
            'contains sensitive personal health information and you will access it '
            'only for lawful dispensing purposes.',
        requireCheckbox: false,
        confirmButtonText: 'View Prescription',
        cancelButtonText: 'Cancel',
        onConfirm: () async {
          accepted = true;
          if (consentId != null) {
            await ConsentService.acceptConsent(
              consentId: consentId,
              metadata: {
                'context': 'prescription_view',
                'orderId': orderId,
                'customerId': customerId,
                'mandatory': true,
                'compliance': 'DPDP-Sensitive Data',
              },
            );
          }
        },
        onCancel: () async {
          accepted = false;
          if (consentId != null) {
            await ConsentService.rejectConsent(
              consentId: consentId,
              reason: 'User declined consent',
              metadata: {
                'action': 'rejected',
                'reason': 'User clicked cancel',
                'context': 'prescription_view',
                'orderId': orderId,
                'customerId': customerId,
              },
            );
          }
        },
      ),
    );

    return accepted;
  }
  
  /// Check if pharmacist has already accepted the order disclaimer
  /// This prevents showing the dialog multiple times for the same order
  static Future<bool> hasAcceptedOrderDisclaimer(String orderId) async {
    // Check local storage for this specific order
    // You can implement this using SharedPreferences or similar
    // For now, we'll return false to always show (you can optimize this)
    return false;
  }

  /// Check if pharmacist has already accepted prescription access for this order
  static Future<bool> hasAcceptedPrescriptionAccess(String orderId) async {
    // Check local storage for this specific order
    // For now, we'll return false to always show (you can optimize this)
    return false;
  }

  /// Show all onboarding consents in sequence
  /// Returns true only if all mandatory consents are accepted
  static Future<bool> showOnboardingConsentsSequence(
    BuildContext context,
  ) async {
    // 1. Registration Consent
    final registrationAccepted = await showRetailerRegistrationConsent(context);
    if (!registrationAccepted) return false;

    // 2. License Verification
    final licenseAccepted = await showLicenseVerificationConfirmation(context);
    if (!licenseAccepted) return false;

    return true;
  }

  /// Check if prescription access consent has been given for this session
  static Future<bool> needsPrescriptionAccessConsent() async {
    // Check if consent was given in the current session
    // You could implement session-based consent tracking here
    return true; // Always show for maximum compliance
  }
}

/// Customer-specific consent dialogs
class CustomerConsentManager {
  /// General Data Consent (DPDP Required)
  /// Shown immediately after first login/registration
  static Future<bool> showGeneralDataConsent(BuildContext context) async {
    bool accepted = false;

    // Get consent ID from backend
    final consentId =
        await ConsentService.getConsentIdByType(ConsentType.generalDataConsent);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConsentDialog(
        title: 'General Data Consent',
        titleIcon: Icons.lock_outline,
        titleColor: const Color(0xFF2E7D32), // Green
        message:
            'To continue, please allow us to process your personal data for secure account creation and order fulfillment. We do not share any data without your consent.',
        requireCheckbox: false,
        confirmButtonText: 'Allow',
        cancelButtonText: 'Cancel',
        onConfirm: () async {
          accepted = true;
          // await ConsentService.logConsent(
          //   consentType: ConsentType.generalDataConsent,
          //   granted: true,
          //   metadata: {
          //     'context': 'customer_registration',
          //     'mandatory': true,
          //     'compliance': 'DPDP',
          //   },
          // );
          if (consentId != null) {
            await ConsentService.acceptConsent(
              // ✅ Call accept API
              consentId: consentId,
              metadata: {
                'context': 'customer_registration',
                'mandatory': true,
                'compliance': 'DPDP',
              },
            );
          }
        },
        onCancel: () async {
          // ✅ NEW: Handle cancel
          accepted = false;
          if (consentId != null) {
            await ConsentService.rejectConsent(
                // ✅ Call reject API
                consentId: consentId,
                reason: 'User declined consent',
                metadata: {
                  'action': 'rejected',
                  'reason': 'User clicked cancel',
                  'context': 'customer_registration'
                });
          }
        },
      ),
    );

    return accepted;
  }

  /// Prescription Sharing Consent
  /// Shown when user uploads prescription
  static Future<bool> showPrescriptionSharingConsent(
    BuildContext context,
  ) async {
    bool accepted = false;

// Get consent ID from backend
    final consentId = await ConsentService.getConsentIdByType(
        ConsentType.prescriptionSharingConsent);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConsentDialog(
        title: 'Prescription Sharing Consent',
        titleIcon: Icons.local_pharmacy,
        titleColor: const Color(0xFFD97706), // Orange
        message:
            'We need your permission to securely share your prescription with a licensed pharmacy to fulfil your order.',
        requireCheckbox: false,
        confirmButtonText: 'Allow',
        cancelButtonText: 'Cancel',
        onConfirm: () async {
          accepted = true;
          // await ConsentService.logConsent(
          //   consentType: ConsentType.prescriptionSharingConsent,
          //   granted: true,
          //   metadata: {
          //     'context': 'prescription_upload',
          //     'mandatory': true,
          //     'compliance': 'DPDP',
          //   },
          // );
          if (consentId != null) {
            await ConsentService.acceptConsent(
              // ✅ Call accept API
              consentId: consentId,
              metadata: {
                'context': 'prescription_upload',
                'mandatory': true,
                'compliance': 'DPDP',
              },
            );
          }
        },
        onCancel: () async {
          // ✅ NEW: Handle cancel
          accepted = false;
          if (consentId != null) {
            await ConsentService.rejectConsent(
                // ✅ Call reject API
                consentId: consentId,
                reason: 'User declined consent',
                metadata: {
                  'action': 'rejected',
                  'reason': 'User clicked cancel',
                  'context': 'prescription_upload'
                });
          }
        },
      ),
    );

    return accepted;
  }

  /// Terms & Conditions Acceptance
  /// Shown on first app launch
  static Future<bool> showTermsAndConditions(BuildContext context) async {
    bool accepted = false;

// Get consent ID from backend
    final consentId =
    await ConsentService.getConsentIdByType(ConsentType.termsAndConditions);
    AppLogger.info("ConsentID: " + consentId.toString());
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConsentDialog(
        title: 'Accept Terms & Conditions',
        titleIcon: Icons.check_circle_outline,
        titleColor: const Color(0xFFD97706), // Orange
        message:
            'To continue, please accept our Terms & Conditions and Privacy Policy to use the Pharmaish platform.',
        checkboxText:
            'I have read and agree to the Terms & Conditions and Privacy Policy',
        requireCheckbox: true,
        confirmButtonText: 'I Accept',
        cancelButtonText: 'Cancel',
        links: {
          'Terms & Conditions':
              '${AppConstants.documentsProdBaseUrl}/Terms_and_Conditions.pdf',
          'Privacy Policy':
              '${AppConstants.documentsProdBaseUrl}/Privacy_Policy.pdf',
        },
        onConfirm: () async {
          accepted = true;
          // await ConsentService.logConsent(
          //   consentType: ConsentType.termsAndConditions,
          //   granted: true,
          //   metadata: {
          //     'context': 'app_launch',
          //     'mandatory': true,
          //     'compliance': 'Legal',
          //   },
          // );
          if (consentId != null) {
            await ConsentService.acceptConsent(
              // ✅ Call accept API
              consentId: consentId,
              metadata: {
                'context': 'app_launch',
                'mandatory': true,
                'compliance': 'DPDP',
              },
            );
          }
        },
        onCancel: () async {
          // ✅ NEW: Handle cancel
          accepted = false;
          if (consentId != null) {
            await ConsentService.rejectConsent(
                // ✅ Call reject API
                consentId: consentId,
                reason: 'User declined consent',
                metadata: {
                  'action': 'rejected',
                  'reason': 'User clicked cancel',
                  'context': 'app_launch'
                });
          }
        },
      ),
    );

    return accepted;
  }

  /// Patient Counselling Disclaimer
  /// Shown in footer or when accessing pharmacy support features
  static Future<void> showPatientCounsellingDisclaimer(
    BuildContext context,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => InfoDialog(
        title: 'Patient Counselling Disclaimer',
        titleIcon: Icons.info_outline,
        titleColor: const Color(0xFFD97706), // Orange
        message:
            'Pharmacist counselling is for educational purposes only and is NOT a substitute for medical advice. Users must consult their doctor for any diagnosis or treatment changes.',
        buttonText: 'Understood',
        onConfirm: () {
          // No logging needed for information-only disclaimers
        },
      ),
    );
  }

  /// Account/Data Deletion Confirmation
  /// Shown when user requests account deletion
  static Future<bool> showAccountDeletionConfirmation(
    BuildContext context,
  ) async {
    bool confirmed = false;

// Get consent ID from backend
    final consentId =
        await ConsentService.getConsentIdByType(ConsentType.generalDataConsent);
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ConsentDialog(
        title: 'Delete Account & Data?',
        titleIcon: Icons.warning_amber,
        titleColor: Colors.red.shade600,
        message:
            'Deleting your account will permanently erase all your stored data. Do you want to continue?',
        requireCheckbox: false,
        confirmButtonText: 'Yes, Delete',
        cancelButtonText: 'Cancel',
        onConfirm: () async {
          confirmed = true;
          // Log the deletion request
          // await ConsentService.logConsent(
          //   consentType: ConsentType.generalDataConsent,
          //   granted: false,
          //   metadata: {
          //     'action': 'account_deletion_requested',
          //     'compliance': 'DPDP Right to be Forgotten',
          //   },
          // );

          if (consentId != null) {
            await ConsentService.acceptConsent(
              // ✅ Call accept API
              consentId: consentId,
              metadata: {
                'action': 'account_deletion_requested',
                'compliance': 'DPDP Right to be Forgotten'
              },
            );
          }
        },
        onCancel: () async {
          // ✅ NEW: Handle cancel
          confirmed = false;
          if (consentId != null) {
            await ConsentService.rejectConsent(
                // ✅ Call reject API
                consentId: consentId,
                reason: 'User declined consent',
                metadata: {
                  'action': 'rejected',
                  'reason': 'User clicked cancel',
                  'context': 'account_deletion_requested'
                });
          }
        },
        barrierDismissible: true,
      ),
    );

    return confirmed;
  }
}
