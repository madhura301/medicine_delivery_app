import { isExpired, parseJwt } from './jwt.util';

/** Builds an unsigned token with the given payload — parseJwt only reads the claims. */
function tokenWith(payload: Record<string, unknown>): string {
  const encode = (value: object) =>
    btoa(JSON.stringify(value)).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
  return `${encode({ alg: 'HS256' })}.${encode(payload)}.signature`;
}

const NAME_ID = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier';
const EMAIL = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress';
const NAME = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name';
const ROLE = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role';

describe('parseJwt', () => {
  it('reads the claims the login response leaves null', () => {
    const claims = parseJwt(
      tokenWith({
        [NAME_ID]: '59584b9b-5c92-4314-8627-86235831f6c6',
        [EMAIL]: 'admin@medicine.com',
        [NAME]: '9999999999',
        [ROLE]: 'Admin',
        firstName: 'System',
        lastName: 'Administrator',
        exp: 1785683418,
      }),
    );

    expect(claims).not.toBeNull();
    expect(claims!.userId).toBe('59584b9b-5c92-4314-8627-86235831f6c6');
    expect(claims!.email).toBe('admin@medicine.com');
    expect(claims!.userName).toBe('9999999999');
    expect(claims!.role).toBe('Admin');
    expect(claims!.expiresAt).toBe(1785683418 * 1000);
  });

  it('falls back to the short role claim', () => {
    expect(parseJwt(tokenWith({ role: 'Manager', exp: 1 }))!.role).toBe('Manager');
  });

  it('takes the first role when the claim is an array', () => {
    expect(parseJwt(tokenWith({ [ROLE]: ['CustomerSupport', 'Admin'], exp: 1 }))!.role).toBe(
      'CustomerSupport',
    );
  });

  it('returns null for a token it cannot read', () => {
    expect(parseJwt('not-a-token')).toBeNull();
    expect(parseJwt('header.@@@not-base64@@@.sig')).toBeNull();
  });

  it('reports a missing role rather than guessing', () => {
    expect(parseJwt(tokenWith({ exp: 1 }))!.role).toBeNull();
  });
});

describe('isExpired', () => {
  const claims = (expiresAt: number) => ({
    userId: '',
    email: '',
    userName: '',
    firstName: '',
    lastName: '',
    role: null,
    expiresAt,
  });

  it('is false for a token with time left', () => {
    expect(isExpired(claims(Date.now() + 60_000))).toBe(false);
  });

  it('is true once the expiry has passed', () => {
    expect(isExpired(claims(Date.now() - 1))).toBe(true);
  });

  it('treats a token inside the clock-skew window as expired', () => {
    expect(isExpired(claims(Date.now() + 5_000))).toBe(true);
  });
});
