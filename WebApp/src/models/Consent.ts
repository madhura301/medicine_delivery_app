export interface Consent {
  consentId: string;
  title: string;
  description?: string;
  content?: string;
  isActive: boolean;
  createdOn?: string;
}

export interface ConsentLog {
  consentLogId: string;
  consentId: string;
  userId: string;
  userType?: string;
  respectiveId?: string;
  action: number; // 1 = Accept, 2 = Reject
  userAgent?: string;
  ipAddress?: string;
  deviceInfo?: string;
  createdOn?: string;
}
