// ROLE-SPECIFIC DTO MODELS
// These match your backend DTOs exactly

import 'dart:convert';

// ============================================================================
// CUSTOMER DTOs
// ============================================================================

class CustomerDto {
  final String? customerId;
  final String? customerFirstName;
  final String? customerLastName;
  final String? customerMiddleName;
  final String? mobileNumber;
  final String? alternativeMobileNumber;
  final String? emailId;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? customerPhoto;
  final bool? isActive;
  final DateTime? createdOn;
  final DateTime? updatedOn;
  final String? userId;
  final List<CustomerAddressDto>? addresses;

  CustomerDto({
    this.customerId,
    this.customerFirstName,
    this.customerLastName,
    this.customerMiddleName,
    this.mobileNumber,
    this.alternativeMobileNumber,
    this.emailId,
    this.dateOfBirth,
    this.gender,
    this.customerPhoto,
    this.isActive,
    this.createdOn,
    this.updatedOn,
    this.userId,
    this.addresses,
  });

  factory CustomerDto.fromJson(Map<String, dynamic> json) {
    return CustomerDto(
      customerId: json['customerId']?.toString(),
      customerFirstName: json['customerFirstName'],
      customerLastName: json['customerLastName'],
      customerMiddleName: json['customerMiddleName'],
      mobileNumber: json['mobileNumber'],
      alternativeMobileNumber: json['alternativeMobileNumber'],
      emailId: json['emailId'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      gender: json['gender'],
      customerPhoto: json['customerPhoto'],
      isActive: json['isActive'] ?? true,
      createdOn: json['createdOn'] != null
          ? DateTime.parse(json['createdOn'])
          : null,
      updatedOn: json['updatedOn'] != null
          ? DateTime.parse(json['updatedOn'])
          : null,
      userId: json['userId'],
      addresses: json['addresses'] != null
          ? (json['addresses'] as List)
              .map((a) => CustomerAddressDto.fromJson(a))
              .toList()
          : null,
    );
  }

  String get fullName {
    return '${customerFirstName ?? ''} ${customerLastName ?? ''}'.trim();
  }

  String get initials {
    final first = customerFirstName?.trim() ?? '';
    final last = customerLastName?.trim() ?? '';
    return '${first.isNotEmpty ? first[0] : ''}${last.isNotEmpty ? last[0] : ''}'
        .toUpperCase();
  }
}

class CustomerAddressDto {
  final String? customerAddressId;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String? addressType;
  final bool? isDefault;

  CustomerAddressDto({
    this.customerAddressId,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.addressType,
    this.isDefault,
  });

  factory CustomerAddressDto.fromJson(Map<String, dynamic> json) {
    return CustomerAddressDto(
      customerAddressId: json['customerAddressId']?.toString(),
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      country: json['country'],
      addressType: json['addressType'],
      isDefault: json['isDefault'] ?? false,
    );
  }
}

// ============================================================================
// MANAGER DTOs
// ============================================================================

class ManagerDto {
  final String? managerId;
  final String? managerFirstName;
  final String? managerLastName;
  final String? managerMiddleName;
  final String? address;
  final String? city;
  final String? state;
  final String? mobileNumber;
  final String? emailId;
  final String? alternativeMobileNumber;
  final String? employeeId;
  final String? managerPhoto;
  final bool? isActive;
  final bool? isDeleted;
  final DateTime? createdOn;
  final String? createdBy;
  final DateTime? updatedOn;
  final String? updatedBy;
  final String? userId;

  ManagerDto({
    this.managerId,
    this.managerFirstName,
    this.managerLastName,
    this.managerMiddleName,
    this.address,
    this.city,
    this.state,
    this.mobileNumber,
    this.emailId,
    this.alternativeMobileNumber,
    this.employeeId,
    this.managerPhoto,
    this.isActive,
    this.isDeleted,
    this.createdOn,
    this.createdBy,
    this.updatedOn,
    this.updatedBy,
    this.userId,
  });

  factory ManagerDto.fromJson(Map<String, dynamic> json) {
    return ManagerDto(
      managerId: json['managerId']?.toString(),
      managerFirstName: json['managerFirstName'],
      managerLastName: json['managerLastName'],
      managerMiddleName: json['managerMiddleName'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      mobileNumber: json['mobileNumber'],
      emailId: json['emailId'],
      alternativeMobileNumber: json['alternativeMobileNumber'],
      employeeId: json['employeeId'],
      managerPhoto: json['managerPhoto'],
      isActive: json['isActive'] ?? true,
      isDeleted: json['isDeleted'] ?? false,
      createdOn: json['createdOn'] != null
          ? DateTime.parse(json['createdOn'])
          : null,
      createdBy: json['createdBy']?.toString(),
      updatedOn: json['updatedOn'] != null
          ? DateTime.parse(json['updatedOn'])
          : null,
      updatedBy: json['updatedBy']?.toString(),
      userId: json['userId'],
    );
  }

  String get fullName {
    return '${managerFirstName ?? ''} ${managerLastName ?? ''}'.trim();
  }

  String get initials {
    final first = managerFirstName?.trim() ?? '';
    final last = managerLastName?.trim() ?? '';
    return '${first.isNotEmpty ? first[0] : ''}${last.isNotEmpty ? last[0] : ''}'
        .toUpperCase();
  }
}

// ============================================================================
// MEDICAL STORE / CHEMIST DTOs
// ============================================================================

class MedicalStoreDto {
  final String? medicalStoreId;
  final String? medicalName;
  final String? ownerFirstName;
  final String? ownerLastName;
  final String? ownerMiddleName;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final String? mobileNumber;
  final String? emailId;
  final String? alternativeMobileNumber;
  final bool? registrationStatus;
  final String? gstin;
  final String? pan;
  final String? fssaiNo;
  final String? dlNo;
  final String? pharmacistFirstName;
  final String? pharmacistLastName;
  final String? pharmacistRegistrationNumber;
  final String? pharmacistMobileNumber;
  final bool? isActive;
  final bool? isDeleted;
  final DateTime? createdOn;
  final String? createdBy;
  final DateTime? updatedOn;
  final String? updatedBy;
  final String? userId;

  MedicalStoreDto({
    this.medicalStoreId,
    this.medicalName,
    this.ownerFirstName,
    this.ownerLastName,
    this.ownerMiddleName,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.mobileNumber,
    this.emailId,
    this.alternativeMobileNumber,
    this.registrationStatus,
    this.gstin,
    this.pan,
    this.fssaiNo,
    this.dlNo,
    this.pharmacistFirstName,
    this.pharmacistLastName,
    this.pharmacistRegistrationNumber,
    this.pharmacistMobileNumber,
    this.isActive,
    this.isDeleted,
    this.createdOn,
    this.createdBy,
    this.updatedOn,
    this.updatedBy,
    this.userId,
  });

  factory MedicalStoreDto.fromJson(Map<String, dynamic> json) {
    return MedicalStoreDto(
      medicalStoreId: json['medicalStoreId']?.toString(),
      medicalName: json['medicalName'],
      ownerFirstName: json['ownerFirstName'],
      ownerLastName: json['ownerLastName'],
      ownerMiddleName: json['ownerMiddleName'],
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      mobileNumber: json['mobileNumber'],
      emailId: json['emailId'],
      alternativeMobileNumber: json['alternativeMobileNumber'],
      registrationStatus: json['registrationStatus'] ?? false,
      gstin: json['gstin'],
      pan: json['pan'],
      fssaiNo: json['fssaiNo'],
      dlNo: json['dlNo'],
      pharmacistFirstName: json['pharmacistFirstName'],
      pharmacistLastName: json['pharmacistLastName'],
      pharmacistRegistrationNumber: json['pharmacistRegistrationNumber'],
      pharmacistMobileNumber: json['pharmacistMobileNumber'],
      isActive: json['isActive'] ?? true,
      isDeleted: json['isDeleted'] ?? false,
      createdOn: json['createdOn'] != null
          ? DateTime.parse(json['createdOn'])
          : null,
      createdBy: json['createdBy']?.toString(),
      updatedOn: json['updatedOn'] != null
          ? DateTime.parse(json['updatedOn'])
          : null,
      updatedBy: json['updatedBy']?.toString(),
      userId: json['userId'],
    );
  }

  String get fullName {
    return '${ownerFirstName ?? ''} ${ownerLastName ?? ''}'.trim();
  }

  String get initials {
    final first = ownerFirstName?.trim() ?? '';
    final last = ownerLastName?.trim() ?? '';
    return '${first.isNotEmpty ? first[0] : ''}${last.isNotEmpty ? last[0] : ''}'
        .toUpperCase();
  }
}

// ============================================================================
// CUSTOMER SUPPORT DTOs
// ============================================================================

class CustomerSupportDto {
  final String? customerSupportId;
  final String? customerSupportFirstName;
  final String? customerSupportLastName;
  final String? customerSupportMiddleName;
  final String? mobileNumber;
  final String? emailId;
  final String? alternativeMobileNumber;
  final bool? isActive;
  final bool? isDeleted;
  final DateTime? createdOn;
  final String? createdBy;
  final DateTime? updatedOn;
  final String? updatedBy;
  final String? userId;

  CustomerSupportDto({
    this.customerSupportId,
    this.customerSupportFirstName,
    this.customerSupportLastName,
    this.customerSupportMiddleName,
    this.mobileNumber,
    this.emailId,
    this.alternativeMobileNumber,
    this.isActive,
    this.isDeleted,
    this.createdOn,
    this.createdBy,
    this.updatedOn,
    this.updatedBy,
    this.userId,
  });

  factory CustomerSupportDto.fromJson(Map<String, dynamic> json) {
    return CustomerSupportDto(
      customerSupportId: json['customerSupportId']?.toString(),
      customerSupportFirstName: json['customerSupportFirstName'],
      customerSupportLastName: json['customerSupportLastName'],
      customerSupportMiddleName: json['customerSupportMiddleName'],
      mobileNumber: json['mobileNumber'],
      emailId: json['emailId'],
      alternativeMobileNumber: json['alternativeMobileNumber'],
      isActive: json['isActive'] ?? true,
      isDeleted: json['isDeleted'] ?? false,
      createdOn: json['createdOn'] != null
          ? DateTime.parse(json['createdOn'])
          : null,
      createdBy: json['createdBy']?.toString(),
      updatedOn: json['updatedOn'] != null
          ? DateTime.parse(json['updatedOn'])
          : null,
      updatedBy: json['updatedBy']?.toString(),
      userId: json['userId'],
    );
  }

  String get fullName {
    return '${customerSupportFirstName ?? ''} ${customerSupportLastName ?? ''}'
        .trim();
  }

  String get initials {
    final first = customerSupportFirstName?.trim() ?? '';
    final last = customerSupportLastName?.trim() ?? '';
    return '${first.isNotEmpty ? first[0] : ''}${last.isNotEmpty ? last[0] : ''}'
        .toUpperCase();
  }
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

// Parse user from generic JSON based on role
dynamic parseUserByRole(Map<String, dynamic> json, String role) {
  final roleKey = role.toLowerCase();

  switch (roleKey) {
    case 'customer':
      return CustomerDto.fromJson(json);
    case 'manager':
      return ManagerDto.fromJson(json);
    case 'chemist':
    case 'medicalstore':
      return MedicalStoreDto.fromJson(json);
    case 'customersupport':
      return CustomerSupportDto.fromJson(json);
    default:
      return null;
  }
}

// Get display name from any user type
String getUserDisplayName(dynamic user) {
  if (user is CustomerDto) {
    return user.fullName;
  } else if (user is ManagerDto) {
    return user.fullName;
  } else if (user is MedicalStoreDto) {
    return user.fullName;
  } else if (user is CustomerSupportDto) {
    return user.fullName;
  }
  return 'Unknown User';
}

// Get email from any user type
String? getUserEmail(dynamic user) {
  if (user is CustomerDto) {
    return user.emailId;
  } else if (user is ManagerDto) {
    return user.emailId;
  } else if (user is MedicalStoreDto) {
    return user.emailId;
  } else if (user is CustomerSupportDto) {
    return user.emailId;
  }
  return null;
}

// Get mobile from any user type
String? getUserMobile(dynamic user) {
  if (user is CustomerDto) {
    return user.mobileNumber;
  } else if (user is ManagerDto) {
    return user.mobileNumber;
  } else if (user is MedicalStoreDto) {
    return user.mobileNumber;
  } else if (user is CustomerSupportDto) {
    return user.mobileNumber;
  }
  return null;
}

// Get isActive from any user type
bool getUserIsActive(dynamic user) {
  if (user is CustomerDto) {
    return user.isActive ?? true;
  } else if (user is ManagerDto) {
    return user.isActive ?? true;
  } else if (user is MedicalStoreDto) {
    return user.isActive ?? true;
  } else if (user is CustomerSupportDto) {
    return user.isActive ?? true;
  }
  return true;
}

// Get initials from any user type
String getUserInitials(dynamic user) {
  if (user is CustomerDto) {
    return user.initials;
  } else if (user is ManagerDto) {
    return user.initials;
  } else if (user is MedicalStoreDto) {
    return user.initials;
  } else if (user is CustomerSupportDto) {
    return user.initials;
  }
  return 'U';
}