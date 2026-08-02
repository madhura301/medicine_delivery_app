/**
 * Mirrors the enums in MedicineDelivery.Domain/Enums. The API serialises enums as
 * numbers, so these must stay numeric and in sync with the backend.
 */

export enum OrderStatus {
  PendingPayment = 0,
  AssignedToChemist = 1,
  RejectedByChemist = 2,
  AcceptedByChemist = 3,
  BillUploaded = 4,
  Paid = 5,
  OutForDelivery = 6,
  Completed = 7,
  AssignedToCustomerSupport = 8,
  AssignedToManager = 9,
  Cancelled = 10,
}

export const ORDER_STATUS_LABELS: Record<OrderStatus, string> = {
  [OrderStatus.PendingPayment]: 'Pending payment',
  [OrderStatus.AssignedToChemist]: 'Assigned to chemist',
  [OrderStatus.RejectedByChemist]: 'Rejected by chemist',
  [OrderStatus.AcceptedByChemist]: 'Accepted by chemist',
  [OrderStatus.BillUploaded]: 'Bill uploaded',
  [OrderStatus.Paid]: 'Paid',
  [OrderStatus.OutForDelivery]: 'Out for delivery',
  [OrderStatus.Completed]: 'Completed',
  [OrderStatus.AssignedToCustomerSupport]: 'With customer support',
  [OrderStatus.AssignedToManager]: 'With manager',
  [OrderStatus.Cancelled]: 'Cancelled',
};

export enum OrderPaymentStatus {
  NotPaid = 0,
  PartiallyPaid = 1,
  FullyPaid = 2,
}

export const PAYMENT_STATUS_LABELS: Record<OrderPaymentStatus, string> = {
  [OrderPaymentStatus.NotPaid]: 'Not paid',
  [OrderPaymentStatus.PartiallyPaid]: 'Partially paid',
  [OrderPaymentStatus.FullyPaid]: 'Fully paid',
};

/**
 * Who currently owns the order. The console's order sub-menus map one-to-one onto these values.
 * Legacy rows with a NULL AssignTo arrive as 0 (Customer), which is the correct bucket for them.
 */
export enum AssignTo {
  Customer = 0,
  Chemist = 1,
  CustomerSupport = 2,
  Delivery = 3,
  Manager = 4,
}

export const ASSIGN_TO_LABELS: Record<AssignTo, string> = {
  [AssignTo.Customer]: 'Awaiting assignment',
  [AssignTo.Chemist]: 'With chemist',
  [AssignTo.CustomerSupport]: 'With customer support',
  [AssignTo.Delivery]: 'Out for delivery',
  [AssignTo.Manager]: 'With manager',
};

export enum AssignedByType {
  System = 0,
  CustomerSupport = 1,
}

export enum OrderInputType {
  Image = 0,
  Voice = 1,
  Text = 2,
}

export const ORDER_INPUT_TYPE_LABELS: Record<OrderInputType, string> = {
  [OrderInputType.Image]: 'Prescription image',
  [OrderInputType.Voice]: 'Voice note',
  [OrderInputType.Text]: 'Typed list',
};

export enum OrderType {
  NotSet = 0,
  OTC = 1,
  PrescriptionDrugs = 2,
}

/** Region kind. The two region menus differ only by this value. */
export enum RegionType {
  CustomerSupport = 0,
  DeliveryBoy = 1,
}

export enum ChemistPayoutStatus {
  NotStarted = 0,
  Pending = 1,
  NeedsClarification = 2,
  Active = 3,
  Rejected = 4,
  Suspended = 5,
}

export const CHEMIST_PAYOUT_STATUS_LABELS: Record<ChemistPayoutStatus, string> = {
  [ChemistPayoutStatus.NotStarted]: 'Not started',
  [ChemistPayoutStatus.Pending]: 'Pending review',
  [ChemistPayoutStatus.NeedsClarification]: 'Needs clarification',
  [ChemistPayoutStatus.Active]: 'Active',
  [ChemistPayoutStatus.Rejected]: 'Rejected',
  [ChemistPayoutStatus.Suspended]: 'Suspended',
};

export enum ChemistActivationStatus {
  Created = 1,
  Paid = 2,
  Failed = 3,
  Expired = 4,
}

export const CHEMIST_ACTIVATION_STATUS_LABELS: Record<ChemistActivationStatus, string> = {
  [ChemistActivationStatus.Created]: 'Awaiting payment',
  [ChemistActivationStatus.Paid]: 'Paid',
  [ChemistActivationStatus.Failed]: 'Failed',
  [ChemistActivationStatus.Expired]: 'Expired',
};

/**
 * Label lookups. TypeScript treats the maps above as total over their enum, but the values come
 * from an API that could add a member before the client is updated — these tolerate that.
 */
export function orderStatusLabel(status: OrderStatus): string {
  return ORDER_STATUS_LABELS[status] ?? 'Unknown';
}

export function paymentStatusLabel(status: OrderPaymentStatus): string {
  return PAYMENT_STATUS_LABELS[status] ?? 'Unknown';
}

export function orderInputTypeLabel(type: OrderInputType): string {
  return ORDER_INPUT_TYPE_LABELS[type] ?? 'Unknown';
}

export function assignToLabel(assignTo: AssignTo): string {
  return ASSIGN_TO_LABELS[assignTo] ?? 'Unknown';
}

export function chemistPayoutStatusLabel(status: ChemistPayoutStatus): string {
  return CHEMIST_PAYOUT_STATUS_LABELS[status] ?? 'Unknown';
}

export function chemistActivationStatusLabel(status: ChemistActivationStatus): string {
  return CHEMIST_ACTIVATION_STATUS_LABELS[status] ?? 'Unknown';
}

/** Identity role names as they appear in the JWT role claim. */
export type UserRole =
  | 'Admin'
  | 'Manager'
  | 'CustomerSupport'
  | 'Customer'
  | 'Chemist'
  | 'DeliveryBoy';

/** The only roles allowed into this console. */
export const STAFF_ROLES: readonly UserRole[] = ['Admin', 'Manager', 'CustomerSupport'] as const;

export const ROLE_LABELS: Record<UserRole, string> = {
  Admin: 'Administrator',
  Manager: 'Manager',
  CustomerSupport: 'Customer support',
  Customer: 'Customer',
  Chemist: 'Chemist',
  DeliveryBoy: 'Delivery partner',
};
