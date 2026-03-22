export interface CustomerDto {
  customerId: string;
  customerFirstName: string;
  customerLastName: string;
  customerMiddleName?: string;
  customerNumber?: string;
  mobileNumber: string;
  alternativeMobileNumber?: string;
  emailId?: string;
  dateOfBirth?: string;
  gender?: string;
  customerPhoto?: string;
  isActive: boolean;
  isDeleted?: boolean;
  createdOn?: string;
  updatedOn?: string;
  userId?: string;
  addresses?: CustomerAddressDto[];
}

export interface CustomerAddressDto {
  customerAddressId: string;
  addressLine1: string;
  addressLine2?: string;
  city: string;
  state: string;
  postalCode: string;
  country?: string;
  addressType?: string;
  isDefault: boolean;
  latitude?: number;
  longitude?: number;
}

export interface MedicalStoreDto {
  medicalStoreId: string;
  medicalName: string;
  ownerFirstName: string;
  ownerLastName: string;
  ownerMiddleName?: string;
  addressLine1?: string;
  addressLine2?: string;
  city?: string;
  state?: string;
  postalCode?: string;
  latitude?: number;
  longitude?: number;
  mobileNumber: string;
  emailId?: string;
  alternativeMobileNumber?: string;
  registrationStatus?: boolean;
  gstin?: string;
  pan?: string;
  fssaiNo?: string;
  dlNo?: string;
  pharmacistFirstName?: string;
  pharmacistLastName?: string;
  pharmacistRegistrationNumber?: string;
  pharmacistMobileNumber?: string;
  isActive: boolean;
  isDeleted?: boolean;
  createdOn?: string;
  createdBy?: string;
  updatedOn?: string;
  updatedBy?: string;
  userId?: string;
}

export interface ManagerDto {
  managerId: string;
  managerFirstName: string;
  managerLastName: string;
  managerMiddleName?: string;
  address?: string;
  city?: string;
  state?: string;
  mobileNumber: string;
  emailId?: string;
  alternativeMobileNumber?: string;
  employeeId?: string;
  managerPhoto?: string;
  isActive: boolean;
  isDeleted?: boolean;
  createdOn?: string;
  createdBy?: string;
  updatedOn?: string;
  updatedBy?: string;
  userId?: string;
}

export interface CustomerSupportDto {
  customerSupportId: string;
  customerSupportFirstName: string;
  customerSupportLastName: string;
  customerSupportMiddleName?: string;
  address?: string;
  city?: string;
  state?: string;
  mobileNumber: string;
  emailId?: string;
  alternativeMobileNumber?: string;
  employeeId?: string;
  customerSupportPhoto?: string;
  serviceRegionId?: string;
  isActive: boolean;
  isDeleted?: boolean;
  createdOn?: string;
  createdBy?: string;
  updatedOn?: string;
  updatedBy?: string;
  userId?: string;
}

export interface DeliveryDto {
  deliveryId: string;
  deliveryFirstName: string;
  deliveryLastName: string;
  deliveryMiddleName?: string;
  drivingLicenseNumber?: string;
  mobileNumber: string;
  medicalStoreId?: string;
  serviceRegionId?: string;
  isActive: boolean;
  isDeleted?: boolean;
  createdOn?: string;
  updatedOn?: string;
  userId?: string;
}

export interface CreateUserWithRoleDto {
  mobileNumber: string;
  firstName: string;
  lastName: string;
  email: string;
  password: string;
  role: string;
  // Role-specific fields sent as additional properties
  [key: string]: unknown;
}
