/// 0 = within radius (distanceInKm populated), 1 = postal code fallback.
enum ChemistMatchType { distance, postalCode }

class ChemistModel {
  final String medicalStoreId;
  final String medicalName;
  final String city;
  final String state;
  final bool isActive;
  final String addressLine1;
  final String addressLine2;
  final String postalCode;
  final String mobileNumber;
  final ChemistMatchType matchType;
  final double? distanceInKm;

  ChemistModel({
    required this.medicalStoreId,
    required this.medicalName,
    required this.city,
    required this.state,
    required this.isActive,
    this.addressLine1 = '',
    this.addressLine2 = '',
    this.postalCode = '',
    this.mobileNumber = '',
    this.matchType = ChemistMatchType.distance,
    this.distanceInKm,
  });

  factory ChemistModel.fromJson(Map<String, dynamic> json) {
    final rawMatch = json['matchType'];
    ChemistMatchType match = ChemistMatchType.distance;
    if (rawMatch is int) {
      match = rawMatch == 1
          ? ChemistMatchType.postalCode
          : ChemistMatchType.distance;
    } else if (rawMatch is String) {
      match = rawMatch.toLowerCase().contains('postal')
          ? ChemistMatchType.postalCode
          : ChemistMatchType.distance;
    }

    final rawDistance = json['distanceInKm'];
    double? distance;
    if (rawDistance is num) distance = rawDistance.toDouble();

    return ChemistModel(
      medicalStoreId: json['medicalStoreId'] ?? '',
      medicalName: json['medicalName'] ?? 'Unknown',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      isActive: json['isActive'] ?? true,
      addressLine1: json['addressLine1'] ?? '',
      addressLine2: json['addressLine2'] ?? '',
      postalCode: json['postalCode'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      matchType: match,
      distanceInKm: distance,
    );
  }

  String get distanceLabel {
    if (distanceInKm != null) return '${distanceInKm!.toStringAsFixed(2)} km';
    if (matchType == ChemistMatchType.postalCode) return 'Same postal code';
    return '—';
  }
}
