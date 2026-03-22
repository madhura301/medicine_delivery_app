export enum OrderType {
  NotSet = 0,
  OTC = 1,
  PrescriptionDrugs = 2,
}

export const OrderTypeLabel: Record<OrderType, string> = {
  [OrderType.NotSet]: 'Not Set',
  [OrderType.OTC]: 'Over-the-Counter (OTC)',
  [OrderType.PrescriptionDrugs]: 'Prescription Required',
};

export enum OrderInputType {
  Image = 0,
  Voice = 1,
  Text = 2,
}

export const OrderInputTypeLabel: Record<OrderInputType, string> = {
  [OrderInputType.Image]: 'Image',
  [OrderInputType.Voice]: 'Voice',
  [OrderInputType.Text]: 'Text',
};

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
}

export const OrderStatusLabel: Record<number, string> = {
  0: 'Pending Payment',
  1: 'Assigned to Chemist',
  2: 'Rejected by Chemist',
  3: 'Accepted by Chemist',
  4: 'Bill Uploaded',
  5: 'Paid',
  6: 'Out for Delivery',
  7: 'Completed',
  8: 'Assigned to Customer Support',
};

export enum OrderPaymentStatus {
  NotPaid = 0,
  PartiallyPaid = 1,
  FullyPaid = 2,
}

export enum AssignmentStatus {
  Assigned = 0,
  Accepted = 1,
  Rejected = 2,
}

export enum AssignTo {
  Customer = 0,
  Chemist = 1,
  CustomerSupport = 2,
  Delivery = 3,
}

export enum AssignedByType {
  System = 0,
  CustomerSupport = 1,
}

export enum RegionType {
  CustomerSupport = 0,
  DeliveryBoy = 1,
}

export type UserRole = 'Admin' | 'Chemist' | 'CustomerSupport' | 'Manager' | 'DeliveryBoy' | 'Customer';
