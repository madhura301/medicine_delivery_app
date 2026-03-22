import { jwtDecode } from 'jwt-decode';
import type { UserRole } from '../models/OrderEnums';

interface JwtPayload {
  [key: string]: unknown;
}

const CLAIM = {
  role: [
    'role',
    'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',
  ],
  userId: [
    'UserId',
    'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier',
    'id',
    'sub',
  ],
  email: [
    'email',
    'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress',
  ],
  firstName: ['firstName'],
  lastName: ['lastName'],
  mobileNumber: [
    'mobileNumber',
    'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name',
  ],
};

function extractClaim(payload: JwtPayload, keys: string[]): string {
  for (const key of keys) {
    const val = payload[key];
    if (val !== undefined && val !== null) return String(val);
  }
  return '';
}

export function extractUserRole(roleStr: string): UserRole {
  const lower = roleStr.toLowerCase();
  if (lower.includes('admin')) return 'Admin';
  if (lower.includes('chemist')) return 'Chemist';
  if (lower.includes('customersupport')) return 'CustomerSupport';
  if (lower.includes('manager')) return 'Manager';
  if (lower.includes('deliveryboy') || lower.includes('delivery')) return 'DeliveryBoy';
  if (lower.includes('customer')) return 'Customer';
  return 'Customer';
}

export interface DecodedUser {
  userId: string;
  role: UserRole;
  email: string;
  firstName: string;
  lastName: string;
  mobileNumber: string;
}

export function decodeToken(token: string): DecodedUser {
  const payload = jwtDecode<JwtPayload>(token);
  const roleStr = extractClaim(payload, CLAIM.role);
  return {
    userId: extractClaim(payload, CLAIM.userId),
    role: extractUserRole(roleStr),
    email: extractClaim(payload, CLAIM.email),
    firstName: extractClaim(payload, CLAIM.firstName),
    lastName: extractClaim(payload, CLAIM.lastName),
    mobileNumber: extractClaim(payload, CLAIM.mobileNumber),
  };
}
