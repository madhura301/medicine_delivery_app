export interface Payment {
  paymentId: string;
  orderId: string;
  paymentMode?: string;
  transactionId?: string;
  amount: number;
  paymentStatus: number; // 0 = Pending, 1 = Success, 2 = Failed
  paidOn?: string;
}
