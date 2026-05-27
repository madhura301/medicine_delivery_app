import { test, expect, login } from '../fixtures/api.fixture';
import { credentials, RoleName } from '../helpers/config';
import { decodeJwt, roleFromToken } from '../helpers/jwt';

/**
 * Covers AuthController: login, register, forgot-password,
 * verify-otp-reset-password, change-password.
 * Plan §7.1 (AuthController) + §7.4 negatives.
 *
 * Contract notes (verified against AuthController.cs):
 *  - successful login/register/change-password -> 200, body = AuthResult
 *  - failed   login/register/change-password -> 400, body = AuthResult { success:false, errors:[] }
 *  - forgot-password -> always 200 { message }; empty phone -> 400 { message }
 *  - verify-otp-reset-password mismatch -> 400 { message }
 *  - change-password without token -> 401
 */

// Roles whose seeded password is verified to match config in the current DB.
const VERIFIED_LOGIN_ROLES: RoleName[] = ['admin', 'manager', 'support', 'chemist'];

function uniqueUser() {
  const n = Date.now().toString().slice(-9);
  return {
    mobileNumber: `9${n}`,
    email: `e2e_${n}@example.com`,
    password: 'E2ePass@123',
    firstName: 'E2E',
    lastName: 'User',
  };
}

test.describe('Auth API', () => {
  test.describe('POST /api/auth/login', () => {
    // KNOWN ISSUE (see task.md "Findings" + decision D4): in the current
    // MedicineDeliveryNew DB the seeded `customer` (6666666666) password is NOT
    // Customer@123 — the user pre-existed and /api/setup/users/customer returns
    // 409 without resetting the password. Tracked, not hidden.
    test.fixme(
      'logs in seeded customer and returns a JWT with a role claim [KNOWN: password drift in shared DB]',
      async () => {},
    );

    for (const role of VERIFIED_LOGIN_ROLES) {
      test(`logs in seeded ${role} and returns a JWT with a role claim`, async ({ api }) => {
        const c = credentials[role];
        const res = await api.post('/api/auth/login', {
          data: { mobileNumber: c.mobileNumber, password: c.password, stayLoggedIn: false },
        });
        expect(res.status()).toBe(200);
        const body = await res.json();
        expect(body.success).toBe(true);
        expect(body.token, 'token should be present').toBeTruthy();
        const claims = decodeJwt(body.token);
        expect(Object.keys(claims).length).toBeGreaterThan(0);
        expect(roleFromToken(body.token), 'JWT should carry a role claim').toBeTruthy();
      });
    }

    test('rejects a wrong password with 400 and success=false', async ({ api }) => {
      const res = await api.post('/api/auth/login', {
        data: { mobileNumber: credentials.admin.mobileNumber, password: 'WrongPassword!1', stayLoggedIn: false },
      });
      expect(res.status()).toBe(400);
      const body = await res.json();
      expect(body.success).toBe(false);
      expect(Array.isArray(body.errors) && body.errors.length).toBeTruthy();
    });

    test('rejects an unknown mobile number with 400', async ({ api }) => {
      const res = await api.post('/api/auth/login', {
        data: { mobileNumber: '0000000001', password: 'whatever1!', stayLoggedIn: false },
      });
      expect(res.status()).toBe(400);
      expect((await res.json()).success).toBe(false);
    });

    test('rejects an empty body with 400', async ({ api }) => {
      const res = await api.post('/api/auth/login', { data: {} });
      expect(res.status()).toBe(400);
    });
  });

  test.describe('POST /api/auth/register', () => {
    test('registers a new user, then that user can log in', async ({ api }) => {
      const u = uniqueUser();
      const reg = await api.post('/api/auth/register', { data: u });
      expect(reg.status(), await reg.text()).toBe(200);
      expect((await reg.json()).success).toBe(true);

      const auth = await login(api, u.mobileNumber, u.password);
      expect(auth.success).toBe(true);
      expect(auth.token).toBeTruthy();
    });

    test('rejects duplicate registration with 400', async ({ api }) => {
      const u = uniqueUser();
      const first = await api.post('/api/auth/register', { data: u });
      expect(first.status()).toBe(200);
      const dup = await api.post('/api/auth/register', { data: u });
      expect(dup.status()).toBe(400);
      expect((await dup.json()).success).toBe(false);
    });
  });

  test.describe('POST /api/auth/forgot-password', () => {
    test('returns a generic 200 message for any phone (no enumeration)', async ({ api }) => {
      const res = await api.post('/api/auth/forgot-password', {
        data: { phoneNumber: credentials.customer.mobileNumber },
      });
      expect(res.status()).toBe(200);
      expect((await res.json()).message).toContain('OTP');
    });

    test('returns 400 when phone number is missing', async ({ api }) => {
      const res = await api.post('/api/auth/forgot-password', { data: { phoneNumber: '' } });
      expect(res.status()).toBe(400);
    });
  });

  test.describe('POST /api/auth/verify-otp-reset-password', () => {
    test('rejects mismatched new/confirm passwords with 400', async ({ api }) => {
      const res = await api.post('/api/auth/verify-otp-reset-password', {
        data: {
          phoneNumber: credentials.customer.mobileNumber,
          otpCode: '000000',
          newPassword: 'NewPass@123',
          confirmPassword: 'Different@123',
        },
      });
      expect(res.status()).toBe(400);
      expect((await res.json()).message).toMatch(/match/i);
    });

    test('rejects an invalid OTP with 400', async ({ api }) => {
      const res = await api.post('/api/auth/verify-otp-reset-password', {
        data: {
          phoneNumber: credentials.customer.mobileNumber,
          otpCode: '999999',
          newPassword: 'NewPass@123',
          confirmPassword: 'NewPass@123',
        },
      });
      expect(res.status()).toBe(400);
    });
  });

  test.describe('POST /api/auth/change-password [Authorize]', () => {
    test('returns 401 without a bearer token', async ({ api }) => {
      const res = await api.post('/api/auth/change-password', {
        data: { mobileNumber: credentials.admin.mobileNumber, currentPassword: 'x', newPassword: 'y' },
      });
      expect(res.status()).toBe(401);
    });

    test('rejects a wrong current password with 400 (auth as fresh user)', async ({ api }) => {
      const u = uniqueUser();
      expect((await api.post('/api/auth/register', { data: u })).status()).toBe(200);
      const auth = await login(api, u.mobileNumber, u.password);

      const res = await api.post('/api/auth/change-password', {
        headers: { Authorization: `Bearer ${auth.token}` },
        data: { mobileNumber: u.mobileNumber, currentPassword: 'TotallyWrong@1', newPassword: 'NextPass@123' },
      });
      expect(res.status()).toBe(400);
      expect((await res.json()).success).toBe(false);
    });

    test('changes password for a fresh user, then login uses the new password', async ({ api }) => {
      const u = uniqueUser();
      expect((await api.post('/api/auth/register', { data: u })).status()).toBe(200);
      const auth = await login(api, u.mobileNumber, u.password);
      const newPassword = 'Rotated@456';

      const res = await api.post('/api/auth/change-password', {
        headers: { Authorization: `Bearer ${auth.token}` },
        data: { mobileNumber: u.mobileNumber, currentPassword: u.password, newPassword },
      });
      expect(res.status(), await res.text()).toBe(200);
      expect((await res.json()).success).toBe(true);

      const relogin = await login(api, u.mobileNumber, newPassword);
      expect(relogin.success).toBe(true);
    });
  });
});
