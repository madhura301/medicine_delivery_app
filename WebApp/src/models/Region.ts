export interface ServiceRegion {
  serviceRegionId: string;
  name: string;
  city: string;
  regionName?: string;
  regionType: number; // 0 = CustomerSupport, 1 = DeliveryBoy
  isActive: boolean;
  createdOn?: string;
  updatedOn?: string;
  regionPinCodes?: ServiceRegionPinCode[];
}

export interface ServiceRegionPinCode {
  serviceRegionPinCodeId?: string;
  pinCode: string;
  serviceRegionId: string;
}

export interface CreateRegionDto {
  name: string;
  city: string;
  regionName?: string;
  regionType: number;
}
