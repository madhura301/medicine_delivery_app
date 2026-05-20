// Customer profile DTOs used by the customer profile screen.
//
// NOTE: A second pair of `CustomerDto` / `CustomerAddressDto` lives in
// `role_specific_dtos.dart` with a different shape:
//   - That `CustomerDto` has all-nullable fields plus a `customerNumber`,
//     `addresses` list, and `fullName`/`initials` getters; no denormalised
//     address fields on the customer itself.
//   - This `CustomerDto` requires several fields and carries denormalised
//     `address`/`city`/`state`/`postalCode` directly on the customer.
//
// Likewise `CustomerAddressDto` exists in three places (here, role_specific
// version with `customerAddressId` + `country`/`addressType`, and a near-copy
// in `address_selector_widget.dart`). Unifying these requires confirming the
// canonical backend schema first.

class CustomerDto {
  final String customerId;
  final String customerFirstName;
  final String customerLastName;
  final String? customerMiddleName;
  final String mobileNumber;
  final String? alternativeMobileNumber;
  final String? emailId;
  final String? address;
  final String? city;
  final String? state;
  final String? postalCode;
  final DateTime dateOfBirth;
  final String? gender;
  final String? customerPhoto;
  final bool isActive;
  final DateTime createdOn;
  final DateTime? updatedOn;
  final String? userId;

  CustomerDto({
    required this.customerId,
    required this.customerFirstName,
    required this.customerLastName,
    this.customerMiddleName,
    required this.mobileNumber,
    this.alternativeMobileNumber,
    this.emailId,
    this.address,
    this.city,
    this.state,
    this.postalCode,
    required this.dateOfBirth,
    this.gender,
    this.customerPhoto,
    required this.isActive,
    required this.createdOn,
    this.updatedOn,
    this.userId,
  });

  factory CustomerDto.fromJson(Map<String, dynamic> json) {
    return CustomerDto(
      customerId: json['customerId'] ?? '',
      customerFirstName: json['customerFirstName'] ?? '',
      customerLastName: json['customerLastName'] ?? '',
      customerMiddleName: json['customerMiddleName'],
      mobileNumber: json['mobileNumber'] ?? '',
      alternativeMobileNumber: json['alternativeMobileNumber'],
      emailId: json['emailId'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: json['gender'],
      customerPhoto: json['customerPhoto'],
      isActive: json['isActive'] ?? false,
      createdOn: DateTime.parse(json['createdOn']),
      updatedOn:
          json['updatedOn'] != null ? DateTime.parse(json['updatedOn']) : null,
      userId: json['userId'],
    );
  }
}

class CustomerAddressDto {
  final String? addressId;
  final String customerId;
  final String? address;
  final String? addressLine1;
  final String? addressLine2;
  final String? addressLine3;
  final String? city;
  final String? state;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final bool isActive;
  final DateTime createdOn;
  final DateTime? updatedOn;

  CustomerAddressDto({
    this.addressId,
    required this.customerId,
    this.address,
    this.addressLine1,
    this.addressLine2,
    this.addressLine3,
    this.city,
    this.state,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.isActive = true,
    required this.createdOn,
    this.updatedOn,
  });

  factory CustomerAddressDto.fromJson(Map<String, dynamic> json) {
    return CustomerAddressDto(
      addressId: json['id'],
      customerId: json['customerId'] ?? '',
      address: json['address'],
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      addressLine3: json['addressLine3'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      isDefault: json['isDefault'] ?? false,
      isActive: json['isActive'] ?? true,
      createdOn: DateTime.parse(json['createdOn']),
      updatedOn:
          json['updatedOn'] != null ? DateTime.parse(json['updatedOn']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (addressId != null) 'id': addressId,
      'customerId': customerId,
      'address': address,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'addressLine3': addressLine3,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
      'isActive': isActive,
      'createdOn': createdOn.toIso8601String(),
      if (updatedOn != null) 'updatedOn': updatedOn!.toIso8601String(),
    };
  }

  String get fullAddress {
    final parts = [
      if (addressLine1?.isNotEmpty == true) addressLine1,
      if (addressLine2?.isNotEmpty == true) addressLine2,
      if (addressLine3?.isNotEmpty == true) addressLine3,
      if (city?.isNotEmpty == true) city,
      if (state?.isNotEmpty == true) state,
      if (postalCode?.isNotEmpty == true) postalCode,
    ];
    return parts.join(', ');
  }
}
