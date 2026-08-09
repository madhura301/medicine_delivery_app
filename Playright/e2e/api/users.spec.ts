import { test, expect } from '../fixtures/api.fixture';

/**
 * Covers UsersController (`/api/users`). Plan §7.1 (Users) + §7.4 negatives.
 *
 * Contract (verified against UsersController.cs + UserRegistrationDto/CreateUserWithRoleDto):
 *  - class [Authorize]
 *  - GET  /api/users                  RequireReadUsersPermission        -> 200 UserDto[]
 *  - POST /api/users                  RequireCreateUsersPermission      -> 201
 *  - POST /api/users/create-with-role RequireAdminCreateUsersPermission -> 201 | 400(ModelState/InvalidOp)
 *  - POST /api/users/register         [AllowAnonymous]                  -> 201 | 400
 *  UserRegistrationDto: Email*, Password*(>=6), ConfirmPassword*(==Password), FirstName*, LastName*, PhoneNumber?
 *  CreateUserWithRoleDto: Email*, Password*(>=6), FirstName*, LastName*, RoleId*, PhoneNumber?, EmailConfirmed, IsActive
 *
 * F2 [FIXED 2026-07-20]: /api/users/register and /api/users/create-with-role used
 *  to throw System.InvalidCastException (ApplicationUserImpl -> ApplicationUserWrapper)
 *  in UserManagerService.CreateAsync AFTER inserting the user row, returning 500.
 *  Root cause: a hard cast to ApplicationUserWrapper to write back the generated Id.
 *  Fix: write the Id through the IApplicationUser interface setter instead. Both
 *  endpoints now return 201; the happy-path tests below are live again.
 */

const CUSTOMER_ROLE_ID = '44444444-4444-4444-4444-444444444444'; // PredefinedAuthorizationData.CustomerRoleId

function uniq() {
  const n = Date.now().toString().slice(-9) + Math.floor(Math.random() * 1000);
  return { email: `e2e_user_${n}@example.com`, phone: `9${n.slice(-9)}` };
}

test.describe('Users API', () => {
  test.describe('auth gating', () => {
    test('GET /api/users without token -> 401', async ({ api }) => {
      expect((await api.get('/api/users')).status()).toBe(401);
    });
    test('POST /api/users without token -> 401', async ({ api }) => {
      expect((await api.post('/api/users', { data: {} })).status()).toBe(401);
    });
    test('POST /api/users/create-with-role without token -> 401', async ({ api }) => {
      expect((await api.post('/api/users/create-with-role', { data: {} })).status()).toBe(401);
    });
  });

  test('GET /api/users (admin) returns a list of users', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.get('/api/users');
    expect(res.status(), await res.text()).toBe(200);
    const list = await res.json();
    expect(Array.isArray(list)).toBeTruthy();
    expect(list.length).toBeGreaterThan(0);
  });

  test.describe('POST /api/users/register (anonymous)', () => {
    test('valid payload -> 201 and the user is created', async ({ api }) => {
      const u = uniq();
      const res = await api.post('/api/users/register', {
        data: {
          email: u.email,
          password: 'E2ePass@123',
          confirmPassword: 'E2ePass@123',
          firstName: 'Reg',
          lastName: 'Tester',
          phoneNumber: u.phone,
        },
      });
      expect(res.status(), await res.text()).toBe(201);
      expect(JSON.stringify(await res.json()).toLowerCase()).toContain(u.email.toLowerCase());
    });

    test('mismatched confirmPassword -> 400', async ({ api }) => {
      const u = uniq();
      const res = await api.post('/api/users/register', {
        data: {
          email: u.email,
          password: 'E2ePass@123',
          confirmPassword: 'Different@123',
          firstName: 'Reg',
          lastName: 'Tester',
        },
      });
      expect(res.status()).toBe(400);
    });

    test('password shorter than 6 -> 400', async ({ api }) => {
      const u = uniq();
      const res = await api.post('/api/users/register', {
        data: { email: u.email, password: 'abc', confirmPassword: 'abc', firstName: 'A', lastName: 'B' },
      });
      expect(res.status()).toBe(400);
    });

    test('missing required fields -> 400', async ({ api }) => {
      const res = await api.post('/api/users/register', { data: { email: 'not-an-email' } });
      expect(res.status()).toBe(400);
    });

    test('duplicate email -> 400', async ({ api }) => {
      const u = uniq();
      const payload = {
        email: u.email,
        password: 'E2ePass@123',
        confirmPassword: 'E2ePass@123',
        firstName: 'Dup',
        lastName: 'User',
        phoneNumber: u.phone,
      };
      expect((await api.post('/api/users/register', { data: payload })).status()).toBe(201);
      const dup = await api.post('/api/users/register', { data: { ...payload, phoneNumber: `8${u.phone.slice(1)}` } });
      expect(dup.status()).toBe(400);
    });
  });

  test.describe('POST /api/users/create-with-role (admin)', () => {
    test('valid payload with a real RoleId -> 201', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const u = uniq();
      const res = await admin.post('/api/users/create-with-role', {
        data: {
          email: u.email,
          password: 'E2ePass@123',
          firstName: 'Role',
          lastName: 'User',
          roleId: CUSTOMER_ROLE_ID,
          phoneNumber: u.phone,
          emailConfirmed: true,
          isActive: true,
        },
      });
      expect(res.status(), await res.text()).toBe(201);
      expect(JSON.stringify(await res.json()).toLowerCase()).toContain(u.email.toLowerCase());
    });

    test('invalid ModelState (missing RoleId/email) -> 400', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.post('/api/users/create-with-role', {
        data: { password: 'E2ePass@123', firstName: 'No', lastName: 'Role' },
      });
      expect(res.status()).toBe(400);
    });
  });
});
