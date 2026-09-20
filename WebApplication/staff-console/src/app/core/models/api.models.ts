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
 * Body for POST /api/MedicalStores/register.
 *
 * Registering creates BOTH the store record and its login account, with the mobile number as the
 * username — the same endpoint the mobile self-registration screen posts to. Field names match the
 * API's MedicalStoreRegistrationDto exactly; anything not declared there is silently dropped by
 * model binding, so do not add fields speculatively.
 */
export interface MedicalStoreRegistration {
  medicalName: string;
  ownerFirstName: string;
  ownerMiddleName: string;
  ownerLastName: string;
  /** Plain text over HTTPS, as the API's DTO requires. Never logged or stored client-side. */
  password: string;
  addressLine1: string;
  addressLine2: string;
  city: string;
  state: string;
  postalCode: string;
  /**
   * Worth capturing at registration: order routing prefers a geo search, and a store with no
   * coordinates is invisible to it even when the customer is next door.
   */
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
}

/**
 * Response from the register endpoint. Note it returns HTTP 200 with `success: false` for some
 * failures and HTTP 400 with only `errors` for others, so callers must check both.
 */
export interface MedicalStoreRegistrationResult {
  success: boolean;
  medicalStore: (MedicalStore & { password?: string }) | null;
  errors: string[];
}

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

/**
 * GET /api/chemist-payout/{storeId}/activation.
 *
 * Mirrors the API's ChemistActivationDto. The `razorpay*` block is a LIVE reading of the payment
 * link taken on each request and never stored: the `payment_link.paid` webhook is the only thing
 * that marks an activation paid, so a missed webhook leaves `status` behind what Razorpay holds —
 * and an un-activated chemist receives no orders.
 */
export interface ChemistActivation {
  medicalStoreId: string;
  amount: number;
  gst: number;
  gatewayCharges?: number | null;
  total: number;
  status: ChemistActivationStatus;
  statusName?: string | null;
  paymentLinkUrl?: string | null;
  paymentLinkId?: string | null;
  /** True once MedicalStores.ActivatedOn is stamped — this also starts the platform-fee free period. */
  isActivated: boolean;
  createdOn: string;
  paidOn?: string | null;

  /** True when Razorpay answered this request. */
  razorpayReachable: boolean;
  /** Razorpay's own wording: created / partially_paid / paid / expired / cancelled. */
  razorpayRawStatus?: string | null;
  /** Razorpay's state mapped onto ours; null when unreadable or unrecognised. */
  razorpayStatus?: ChemistActivationStatus | null;
  razorpayStatusName?: string | null;
  razorpayAmountPaid?: number | null;
  razorpayPaymentId?: string | null;
  razorpayError?: string | null;
  razorpayCheckedAt?: string | null;
  /** null when undeterminable: no payment link, or the gateway was unreachable. */
  inSync?: boolean | null;
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

/**
 * The delivery destination, carried inline on every order by the API.
 *
 * Deliberately narrower than {@link CustomerAddress}: no owning customer id, no address-book
 * bookkeeping. That is what lets a chemist or delivery partner read the destination without
 * holding AllCustomerRead — fetching the customer's address book would 403 for them.
 */
export interface OrderDeliveryAddress {
  id: string;
  address: string | null;
  addressLine1: string | null;
  addressLine2: string | null;
  addressLine3: string | null;
  city: string | null;
  state: string | null;
  postalCode: string | null;
  latitude: number | null;
  longitude: number | null;
}

export interface Order {
  orderId: number;
  orderNumber: string | null;
  customerId: string;
  customerName: string | null;
  customerAddressId: string;
  /** Resolved from `customerAddressId` server-side. Null only when that address record is missing. */
  deliveryAddress: OrderDeliveryAddress | null;
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
  /**
   * The delivery OTP. The API reveals it only to the customer who owns the order, and only once
   * they have paid — for everyone else it is always null.
   */
  otp?: string | null;
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

/**
 * GET /api/MedicalStores/nearby — every chemist within the order-routing radius of a point.
 * `receivesOrders` applies the same three checks the router does, so a store that is close but not
 * eligible is shown as such rather than implying it would get the order.
 */
export interface ChemistsNearLocation {
  radiusKm: number;
  receivingOrdersCount: number;
  chemists: ChemistNearLocation[];
}

export interface ChemistNearLocation {
  medicalStoreId: string;
  medicalName: string;
  address: string;
  postalCode: string;
  latitude: number;
  longitude: number;
  distanceKm: number;
  isActive: boolean;
  payoutActive: boolean;
  activationPaid: boolean;
  receivesOrders: boolean;
  notReceivingReasons: string[];
}

/* ── Customer self-service ────────────────────────────────────────────────── */

/** Body for the anonymous POST /api/Customers/register. The mobile number becomes the username. */
export interface CustomerRegistration {
  customerFirstName: string;
  customerMiddleName: string | null;
  customerLastName: string;
  mobileNumber: string;
  password: string;
  alternativeMobileNumber: string | null;
  emailId: string | null;
  /** ISO date; the API stores it as a date of birth. */
  dateOfBirth: string;
  gender: string | null;
}

/** Returned by POST /api/Razorpay/create-order — everything checkout needs to open. */
export interface RazorpayOrderResponse {
  razorpayOrderId: string;
  /** In rupees. */
  amount: number;
  currency: string;
  /** Public key id; safe to hand to the browser. */
  keyId: string;
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
