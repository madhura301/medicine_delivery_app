export enum ChemistMatchType {
  Distance = 0,
  PostalCode = 1,
}

export interface NearbyChemistDto {
  medicalStoreId: string;
  medicalName: string;
  addressLine1: string;
  addressLine2: string;
  city: string;
  state: string;
  postalCode: string;
  latitude?: number;
  longitude?: number;
  mobileNumber: string;
  matchType: ChemistMatchType;
  distanceInKm?: number;
}

export interface NearbyChemistResponseDto {
  orderNumber: string;
  totalChemists: number;
  chemists: NearbyChemistDto[];
}
