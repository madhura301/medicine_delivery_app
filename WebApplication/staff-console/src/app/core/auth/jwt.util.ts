import { UserRole } from '../models/enums';

/**
 * The login endpoint returns `role`, `userId` and `expiresAt` as null (the registered
 * AuthService only sets `success` and `token`), so everything the console needs about the
 * signed-in user is read from the token's claims instead.
 */
export interface JwtClaims {
  userId: string;
  email: string;
  /** Identity user name — the staff member's mobile number. */
  userName: string;
  firstName: string;
  lastName: string;
  role: UserRole | null;
  /** Expiry as epoch milliseconds. */
  expiresAt: number;
}

const CLAIM_NAME_ID = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier';
const CLAIM_EMAIL = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress';
const CLAIM_NAME = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name';
const CLAIM_ROLE = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role';

function decodePayload(token: string): Record<string, unknown> | null {
  const segments = token.split('.');
  if (segments.length < 2) {
    return null;
  }

  try {
    const base64 = segments[1].replace(/-/g, '+').replace(/_/g, '/');
    const padded = base64.padEnd(base64.length + ((4 - (base64.length % 4)) % 4), '=');
    const json = decodeURIComponent(
      atob(padded)
        .split('')
        .map((c) => '%' + c.charCodeAt(0).toString(16).padStart(2, '0'))
        .join(''),
    );
    return JSON.parse(json) as Record<string, unknown>;
  } catch {
    return null;
  }
}

function asString(value: unknown): string {
  if (Array.isArray(value)) {
    return typeof value[0] === 'string' ? value[0] : '';
  }
  return typeof value === 'string' ? value : '';
}

export function parseJwt(token: string): JwtClaims | null {
  const payload = decodePayload(token);
  if (!payload) {
    return null;
  }

  const exp = typeof payload['exp'] === 'number' ? payload['exp'] : 0;
  // The token carries both a short "role" claim and the long Microsoft one; prefer whichever is present.
  const role = asString(payload[CLAIM_ROLE]) || asString(payload['role']);

  return {
    userId: asString(payload[CLAIM_NAME_ID]),
    email: asString(payload[CLAIM_EMAIL]),
    userName: asString(payload[CLAIM_NAME]),
    firstName: asString(payload['firstName']),
    lastName: asString(payload['lastName']),
    role: (role as UserRole) || null,
    expiresAt: exp * 1000,
  };
}

export function isExpired(claims: JwtClaims, skewMs = 30_000): boolean {
  return claims.expiresAt > 0 && claims.expiresAt - skewMs <= Date.now();
}
