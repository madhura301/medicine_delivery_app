import {
  AssignedByType,
  AssignTo,
  ChemistActivationStatus,
  ChemistPayoutStatus,
  OrderInputType,
  OrderLogReason,
  OrderPaymentStatus,
  OrderStatus,
  OrderType,
  RegionType,
} from './enums';

/* ── Auth ─────────────────────────────────────────────────────────────────── */

export interface LoginRequest {
  mobileNumber: string;
  password: string;
  stayLoggedIn: boolean;
}

/**
 * NOTE: the API returns `role`, `userId`, `entityId` and `expiresAt` as null — the registered
 * AuthService only fills in `success` and `token`. Everything else is read from the JWT.
 */
export interface LoginResponse {
  success: boolean;
  token: string | null;
  refreshToken: string | null;
  expiresAt: string | null;
  role: string | null;
  userId: string | null;
  entityId: string | null;
  errors: string[];
}

/* ── Staff (Manager / CustomerSupport share a shape) ──────────────────────── */

export interface Manager {
  managerId: string;
  managerFirstName: string;
  managerMiddleName: string;
  managerLastName: string;
  address: string;
  city: string;
  state: string;
  mobileNumber: string;
  emailId: string;
  alternativeMobileNumber: string;
  employeeId: string;
  managerPhoto: string;
  isActive: boolean;
  isDeleted: boolean;
  createdOn: string;
  updatedOn: string | null;
  userId: string | null;
  /** Only returned by the register endpoint — the temporary password to hand to the new staff member. */
  password?: string | null;
}

export interface ManagerRegistration {
  managerFirstName: string;
  managerMiddleName: string;
  managerLastName: string;
  address: string;
  city: string;
  state: string;
  mobileNumber: string;
  emailId: string;
  alternativeMobileNumber: string;
  employeeId: string;
}

export interface ManagerUpdate extends ManagerRegistration {
  isActive: boolean;
}

export interface CustomerSupport {
  customerSupportId: string;
  customerSupportFirstName: string;
  customerSupportMiddleName: string;
  customerSupportLastName: string;
  address: string;
  city: string;
  state: string;
  mobileNumber: string;
  emailId: string;
  alternativeMobileNumber: string;
  employeeId: string;
  customerSupportPhoto: string;
  isActive: boolean;
  isDeleted: boolean;
  createdOn: string;
  updatedOn: string | null;
  userId: string | null;
  serviceRegionId: number | null;
  /** Only returned by the register endpoint — the temporary password for the new agent. */
  password?: string | null;
}

export interface CustomerSupportRegistration {
  customerSupportFirstName: string;
  customerSupportMiddleName: string;
  customerSupportLastName: string;
  address: string;
  city: string;
  state: string;
  mobileNumber: string;
  emailId: string;
  alternativeMobileNumber: string;
  employeeId: string;
  serviceRegionId?: number | null;
}

export interface CustomerSupportUpdate extends CustomerSupportRegistration {
  isActive: boolean;
}

/* ── Delivery partners ────────────────────────────────────────────────────── */

export interface DeliveryBoy {
  id: number;
  firstName: string | null;
  middleName: string | null;
  lastName: string | null;
  drivingLicenceNumber: string | null;
  mobileNumber: string | null;
  isActive: boolean;
  isDeleted: boolean;
  medicalStoreId: string | null;
  serviceRegionId: number | null;
  userId: string | null;
  addedOn: string;
  modifiedOn: string | null;
}

export interface CreateDeliveryBoy {
  firstName: string;
  middleName: string | null;
  lastName: string;
  drivingLicenceNumber: string;
  mobileNumber: string;
  medicalStoreId: string | null;
  serviceRegionId: number | null;
}

export interface UpdateDeliveryBoy extends CreateDeliveryBoy {
  isActive: boolean;
}

/* ── Chemists / medical stores ────────────────────────────────────────────── */

export interface MedicalStore {
  medicalStoreId: string;
  medicalName: string;
  ownerFirstName: string;
  ownerMiddleName: string;
  ownerLastName: string;
  addressLine1: string;
  addressLine2: string;
  city: string;
  state: string;
  postalCode: string;
  latitude: number | null;
  longitude: number | null;
  mobileNumber: string;
  emailId: string;
  alternativeMobileNumber: string;
  registrationStatus: boolean;
  gstin: string | null;
  pan: string;
  fssaiNo: string;
  dlNo: string;
  pharmacistFirstName: string;
  pharmacistLastName: string;
  pharmacistRegistrationNumber: string;
  pharmacistMobileNumber: string;
  isActive: boolean;
  isDeleted: boolean;
  createdOn: string;
  updatedOn: string | null;
  userId: string | null;
}

export type MedicalStoreUpdate = Omit<
  MedicalStore,
  'medicalStoreId' | 'isDeleted' | 'createdOn' | 'updatedOn' | 'userId'
>;

/**
 * GET /api/chemist-payout/{storeId}.
 *
 * Field names mirror the API's ChemistPayoutStatusDto exactly. The `razorpay*` block is a LIVE
 * reading taken from the payment gateway on each request and is never stored: webhooks can be
 * missed, so the persisted `onboardingStatus` may lag what the gateway actually holds.
 */
export interface ChemistPayoutAccount {
  medicalStoreId: string;
  razorpayLinkedAccountId?: string | null;
  businessName?: string | null;
  onboardingStatus: ChemistPayoutStatus;
  onboardingStatusName?: string | null;
  onboardingError?: string | null;
  bankAccountNumberMasked?: string | null;
  bankIfscCode?: string | null;
  bankAccountHolderName?: string | null;
  activatedOn?: string | null;
  createdOn?: string | null;
  updatedOn?: string | null;

  /** True when Razorpay answered this request. */
  razorpayReachable: boolean;
  /** Razorpay's own status string, e.g. "created" / "activated". */
  razorpayRawStatus?: string | null;
  /** Razorpay's status mapped onto our states; null when unreachable. */
  razorpayStatus?: ChemistPayoutStatus | null;
  razorpayStatusName?: string | null;
  /** Why the live lookup failed, when it did. */
  razorpayError?: string | null;
  razorpayCheckedAt?: string | null;
  /** null when undeterminable: no linked account, or the gateway was unreachable. */
  inSync?: boolean | null;
}

export interface ChemistActivation {
  medicalStoreId: string;
  status: ChemistActivationStatus;
  amount?: number | null;
  paymentLinkUrl?: string | null;
  paidOn?: string | null;
}

/* ── Customers ────────────────────────────────────────────────────────────── */

export interface CustomerAddress {
  id: string;
  customerId: string;
  /** Free-text line the mobile app captures; the structured lines below may be blank instead. */
  address: string | null;
  addressLine1: string | null;
  addressLine2: string | null;
  addressLine3: string | null;
  city: string | null;
  state: string | null;
  postalCode: string | null;
  latitude: number | null;
  longitude: number | null;
  isDefault: boolean;
  isActive: boolean;
  createdOn: string;
  updatedOn: string | null;
}

export interface CreateCustomerAddress {
  customerId: string;
  address: string | null;
  addressLine1: string | null;
  addressLine2: string | null;
  addressLine3: string | null;
  city: string | null;
  state: string | null;
  postalCode: string | null;
  /** Set from the map picker; null when no geo location has been captured. */
  latitude: number | null;
  longitude: number | null;
  isDefault: boolean;
}

export type UpdateCustomerAddress = Omit<CreateCustomerAddress, 'customerId'>;

export interface Customer {
  customerId: string;
  customerNumber: string;
  customerFirstName: string;
  customerMiddleName: string | null;
  customerLastName: string;
  mobileNumber: string;
  alternativeMobileNumber: string | null;
  emailId: string | null;
  dateOfBirth: string;
  gender: string | null;
  customerPhoto: string | null;
  isActive: boolean;
  createdOn: string;
  updatedOn: string | null;
  userId: string | null;
  addresses: CustomerAddress[] | null;
}

/* ── Service regions ──────────────────────────────────────────────────────── */

export interface ServiceRegion {
  id: number;
  name: string;
  city: string;
  regionName: string;
  regionType: RegionType;
  pinCodes: string[];
}

export interface CreateServiceRegion {
  name: string;
  city: string;
  regionName: string;
  regionType: RegionType;
  pinCodes: string[];
}

export interface AssignCustomerSupportRegion {
  serviceRegionId: number | null;
  customerSupportId: string;
}

export interface AssignCustomerSupportRegionBulk {
  serviceRegionId: number;
  customerSupportIds: string[];
}

export interface AssignDeliveryRegion {
  serviceRegionId: number | null;
  deliveryId: number;
}

export interface AssignDeliveryRegionBulk {
  serviceRegionId: number;
  deliveryIds: number[];
}

/* ── Orders ───────────────────────────────────────────────────────────────── */

export interface OrderAssignmentHistoryEntry {
  id: number;
  orderId: number;
  assignTo: string;
  assigneeName: string;
  assignmentStatus: string;
  assignedByType: AssignedByType;
  assignedOn: string;
}

export interface Payment {
  id: number;
  orderId: number;
  amount: number;
  paymentMethod?: string | null;
  paymentDate?: string | null;
}

export interface Order {
  orderId: number;
  orderNumber: string | null;
  customerId: string;
  customerName: string | null;
  customerAddressId: string;
  medicalStoreId: string | null;
  customerSupportId: string | null;
  managerId: string | null;
  deliveryId: number | null;
  /** Authoritative bucket discriminator — never infer the bucket from the ids above. */
  assignTo: AssignTo;
  assignedByType: AssignedByType;
  medicalStoreName: string | null;
  customerSupportName: string | null;
  managerName: string | null;
  deliveryBoyName: string | null;
  orderType: OrderType;
  orderInputType: OrderInputType;
  orderInputFileLocation: string | null;
  orderInputText: string | null;
  orderBillFileLocation: string | null;
  orderStatus: OrderStatus;
  orderPaymentStatus: OrderPaymentStatus;
  cancellationReason: string | null;
  totalAmount: number | null;
  createdOn: string;
  updatedOn: string | null;
  assignmentHistory: OrderAssignmentHistoryEntry[] | null;
  payments: Payment[] | null;
}

export interface MedicalStoreBasic {
  medicalStoreId: string;
  medicalName: string;
}

/* ── Order log ────────────────────────────────────────────────────────────── */

/**
 * One refused order attempt. The API records these whenever a customer's order is turned away —
 * most often because the delivery area has no chemist, no customer support agent, or no delivery
 * partner. The three `*Unavailable` flags say which, and `details` carries the full free-text
 * diagnostic that used to exist only in the server log file.
 */
export interface OrderLogListItem {
  orderLogId: number;
  customerId: string | null;
  customerName: string | null;
  customerMobileNumber: string | null;
  deliveryAddress: string | null;
  postalCode: string | null;
  latitude: number | null;
  longitude: number | null;
  reason: OrderLogReason;
  reasonName: string;
  reasonSummary: string;
  chemistUnavailable: boolean;
  customerSupportUnavailable: boolean;
  deliveryBoyUnavailable: boolean;
  createdOn: string;
}

export interface OrderLog extends OrderLogListItem {
  customerAddressId: string | null;
  /** Only populated by the single-log endpoint. */
  details: string | null;
}

export interface PagedResult<T> {
  items: T[];
  totalCount: number;
  page: number;
  pageSize: number;
}
