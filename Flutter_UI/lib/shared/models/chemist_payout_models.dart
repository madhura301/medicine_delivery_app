/// Models for the chemist payout-onboarding + activation-fee APIs
/// (`/api/chemist-payout/...`). Field names match the backend's camelCase JSON.

import 'package:pharmaish/shared/models/business_type.dart';

/// Razorpay Route linked-account / payout onboarding status for a chemist.
class ChemistPayoutStatusModel {
  final String medicalStoreId;
  final String? razorpayLinkedAccountId;
  final String? businessName;
  final BusinessType? razorpayBusinessType;
  final String? ownerPanMasked;
  final String onboardingStatus; // e.g. NotStarted / Pending / Active ...
  final String? onboardingError;
  final String? bankAccountNumberMasked;
  final String? bankIfscCode;
  final String? bankAccountHolderName;
  final DateTime? activatedOn;

  const ChemistPayoutStatusModel({
    required this.medicalStoreId,
    required this.onboardingStatus,
    this.razorpayLinkedAccountId,
    this.businessName,
    this.razorpayBusinessType,
    this.ownerPanMasked,
    this.onboardingError,
    this.bankAccountNumberMasked,
    this.bankIfscCode,
    this.bankAccountHolderName,
    this.activatedOn,
  });

  bool get isActive => onboardingStatus.toLowerCase() == 'active';
  bool get hasLinkedAccount =>
      (razorpayLinkedAccountId ?? '').isNotEmpty;

  factory ChemistPayoutStatusModel.fromJson(Map<String, dynamic> json) {
    return ChemistPayoutStatusModel(
      medicalStoreId: json['medicalStoreId']?.toString() ?? '',
      razorpayLinkedAccountId: json['razorpayLinkedAccountId']?.toString(),
      businessName: json['businessName']?.toString(),
      razorpayBusinessType: json['razorpayBusinessType'] == null
          ? null
          : BusinessType.fromValue(json['razorpayBusinessType'] as int?),
      ownerPanMasked: json['ownerPanMasked']?.toString(),
      onboardingStatus:
          json['onboardingStatusName']?.toString() ?? json['onboardingStatus']?.toString() ?? 'NotStarted',
      onboardingError: json['onboardingError']?.toString(),
      bankAccountNumberMasked: json['bankAccountNumberMasked']?.toString(),
      bankIfscCode: json['bankIfscCode']?.toString(),
      bankAccountHolderName: json['bankAccountHolderName']?.toString(),
      activatedOn: _parseDate(json['activatedOn']),
    );
  }
}

/// Chemist one-time activation/onboarding-fee payment status.
class ChemistActivationModel {
  final String medicalStoreId;
  final double amount;
  final double gst;
  final double total;
  final String status; // Created / Paid / Failed / Expired
  final String? paymentLinkUrl;
  final String? paymentLinkId;
  final bool isActivated;
  final DateTime? paidOn;

  const ChemistActivationModel({
    required this.medicalStoreId,
    required this.amount,
    required this.gst,
    required this.total,
    required this.status,
    required this.isActivated,
    this.paymentLinkUrl,
    this.paymentLinkId,
    this.paidOn,
  });

  bool get isPaid => status.toLowerCase() == 'paid';

  factory ChemistActivationModel.fromJson(Map<String, dynamic> json) {
    return ChemistActivationModel(
      medicalStoreId: json['medicalStoreId']?.toString() ?? '',
      amount: _toDouble(json['amount']),
      gst: _toDouble(json['gst']),
      total: _toDouble(json['total']),
      status: json['statusName']?.toString() ?? json['status']?.toString() ?? 'Created',
      paymentLinkUrl: json['paymentLinkUrl']?.toString(),
      paymentLinkId: json['paymentLinkId']?.toString(),
      isActivated: json['isActivated'] == true,
      paidOn: _parseDate(json['paidOn']),
    );
  }
}

double _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0;

DateTime? _parseDate(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}
