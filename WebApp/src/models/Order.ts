import { OrderType, OrderInputType } from './OrderEnums';

export interface OrderAssignmentHistory {
  assignmentId: string;
  orderId: string;
  customerId?: string;
  medicalStoreId?: string;
  assignedByType: number;
  assignTo: number;
  status: number;
  rejectNote?: string;
  assignedOn?: string;
  updatedOn?: string;
  deliveryPersonName?: string;
  chemistName?: string;
}

export interface OrderModel {
  orderId: string;
  customerId: string;
  medicalStoreId?: string;
  customerSupportId?: string;
  deliveryId?: string;
  orderType: OrderType;
  orderInputType: OrderInputType;
  prescriptionFileUrl?: string;
  orderInputFileLocation?: string;
  prescriptionText?: string;
  orderInputText?: string;
  voiceNoteUrl?: string;
  status: number;
  orderStatus?: number;
  totalAmount?: number;
  billFileUrl?: string;
  completionOtp?: string;
  completedOn?: string;
  rejectionReason?: string;
  customerRejectionReason?: string;
  customerRejectionPhotoUrl?: string;
  orderNumber?: string;
  orderPaymentStatus?: number;
  assignmentHistory: OrderAssignmentHistory[];
  shippingAddressLine1?: string;
  shippingAddressLine2?: string;
  shippingArea?: string;
  shippingCity?: string;
  shippingPincode?: string;
  shippingLatitude?: number;
  shippingLongitude?: number;
  isActive: boolean;
  createdOn: string;
  updatedOn?: string;
}

/** Normalize backend response keys (PascalCase → camelCase) */
export function normalizeOrder(raw: Record<string, unknown>): OrderModel {
  const get = (keys: string[]): unknown => {
    for (const k of keys) {
      if (raw[k] !== undefined) return raw[k];
    }
    return undefined;
  };

  return {
    orderId: (get(['orderId', 'OrderId', 'id', 'Id']) as string) ?? '',
    customerId: (get(['customerId', 'CustomerId']) as string) ?? '',
    medicalStoreId: get(['medicalStoreId', 'MedicalStoreId']) as string | undefined,
    customerSupportId: get(['customerSupportId', 'CustomerSupportId']) as string | undefined,
    deliveryId: get(['deliveryId', 'DeliveryId']) as string | undefined,
    orderType: (get(['orderType', 'OrderType']) as OrderType) ?? OrderType.NotSet,
    orderInputType: (get(['orderInputType', 'OrderInputType']) as OrderInputType) ?? OrderInputType.Image,
    prescriptionFileUrl: (get(['prescriptionFileUrl', 'PrescriptionFileUrl', 'orderInputFileLocation', 'OrderInputFileLocation']) as string | undefined),
    orderInputFileLocation: get(['orderInputFileLocation', 'OrderInputFileLocation']) as string | undefined,
    prescriptionText: (get(['prescriptionText', 'PrescriptionText', 'orderInputText', 'OrderInputText']) as string | undefined),
    orderInputText: get(['orderInputText', 'OrderInputText']) as string | undefined,
    voiceNoteUrl: get(['voiceNoteUrl', 'VoiceNoteUrl']) as string | undefined,
    status: (get(['status', 'Status', 'orderStatus', 'OrderStatus']) as number) ?? 0,
    orderStatus: get(['orderStatus', 'OrderStatus', 'status', 'Status']) as number | undefined,
    totalAmount: get(['totalAmount', 'TotalAmount']) as number | undefined,
    billFileUrl: get(['billFileUrl', 'BillFileUrl']) as string | undefined,
    completionOtp: get(['completionOtp', 'CompletionOtp']) as string | undefined,
    completedOn: get(['completedOn', 'CompletedOn']) as string | undefined,
    rejectionReason: get(['rejectionReason', 'RejectionReason']) as string | undefined,
    customerRejectionReason: get(['customerRejectionReason', 'CustomerRejectionReason']) as string | undefined,
    customerRejectionPhotoUrl: get(['customerRejectionPhotoUrl', 'CustomerRejectionPhotoUrl']) as string | undefined,
    orderNumber: get(['orderNumber', 'OrderNumber']) as string | undefined,
    orderPaymentStatus: get(['orderPaymentStatus', 'OrderPaymentStatus']) as number | undefined,
    assignmentHistory: normalizeAssignmentHistory(get(['assignmentHistory', 'AssignmentHistory', 'orderAssignmentHistories', 'OrderAssignmentHistories'])),
    shippingAddressLine1: get(['shippingAddressLine1', 'ShippingAddressLine1']) as string | undefined,
    shippingAddressLine2: get(['shippingAddressLine2', 'ShippingAddressLine2']) as string | undefined,
    shippingArea: get(['shippingArea', 'ShippingArea']) as string | undefined,
    shippingCity: get(['shippingCity', 'ShippingCity']) as string | undefined,
    shippingPincode: get(['shippingPincode', 'ShippingPincode']) as string | undefined,
    shippingLatitude: get(['shippingLatitude', 'ShippingLatitude']) as number | undefined,
    shippingLongitude: get(['shippingLongitude', 'ShippingLongitude']) as number | undefined,
    isActive: (get(['isActive', 'IsActive']) as boolean) ?? true,
    createdOn: (get(['createdOn', 'CreatedOn']) as string) ?? '',
    updatedOn: get(['updatedOn', 'UpdatedOn']) as string | undefined,
  };
}

function normalizeAssignmentHistory(raw: unknown): OrderAssignmentHistory[] {
  if (!Array.isArray(raw)) return [];
  return raw.map((item: Record<string, unknown>) => ({
    assignmentId: (item.assignmentId ?? item.AssignmentId ?? '') as string,
    orderId: (item.orderId ?? item.OrderId ?? '') as string,
    customerId: (item.customerId ?? item.CustomerId) as string | undefined,
    medicalStoreId: (item.medicalStoreId ?? item.MedicalStoreId) as string | undefined,
    assignedByType: (item.assignedByType ?? item.AssignedByType ?? 0) as number,
    assignTo: (item.assignTo ?? item.AssignTo ?? 0) as number,
    status: (item.status ?? item.Status ?? 0) as number,
    rejectNote: (item.rejectNote ?? item.RejectNote) as string | undefined,
    assignedOn: (item.assignedOn ?? item.AssignedOn) as string | undefined,
    updatedOn: (item.updatedOn ?? item.UpdatedOn) as string | undefined,
    deliveryPersonName: (item.deliveryPersonName ?? item.DeliveryPersonName) as string | undefined,
    chemistName: (item.chemistName ?? item.ChemistName) as string | undefined,
  }));
}
