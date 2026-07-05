/// Legal business type of a chemist (medical store), collected as part of KYC.
/// Values mirror the backend's `MedicineDelivery.Domain.Enums.BusinessType` enum.
enum BusinessType {
  proprietorship(1, 'Proprietorship'),
  partnership(3, 'Partnership'),
  privateLimited(4, 'Private Limited'),
  publicLimited(5, 'Public Limited'),
  llp(6, 'LLP'),
  ngo(7, 'NGO'),
  trust(9, 'Trust'),
  society(10, 'Society'),
  individual(11, 'Individual');

  final int value;
  final String label;

  const BusinessType(this.value, this.label);

  static BusinessType fromValue(int? value) {
    return BusinessType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => BusinessType.privateLimited,
    );
  }
}
