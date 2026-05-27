import { test, expect } from '../fixtures/api.fixture';

/**
 * Covers SetupController (`/api/setup`). Plan §7.1 (Setup).
 *
 * All endpoints are [AllowAnonymous] and idempotent. They are already exercised
 * by globalSetup (helpers/seed.ts) on every run; this spec asserts their
 * contract explicitly and that they are reachable WITHOUT a token.
 *  - POST /api/setup/roles/predefined            -> 200
 *  - POST /api/setup/permissions/predefined      -> 200
 *  - POST /api/setup/role-permissions/predefined -> 200
 *  - POST /api/setup/users/{role}                -> 200 (created) | 409 (already exists)
 *  - POST /api/setup/customers/fix-missing-customer-numbers -> 200
 */

test.describe('Setup API (anonymous, idempotent)', () => {
  test('predefined roles/permissions/role-permissions -> 200 (no auth needed)', async ({ api }) => {
    for (const path of [
      '/api/setup/roles/predefined',
      '/api/setup/permissions/predefined',
      '/api/setup/role-permissions/predefined',
    ]) {
      const res = await api.post(path);
      expect(res.status(), `${path} -> ${res.status()}`).toBe(200);
    }
  });

  test('seed users are idempotent -> 200 or 409', async ({ api }) => {
    for (const path of [
      '/api/setup/users/admin/firstuser',
      '/api/setup/users/admin',
      '/api/setup/users/manager',
      '/api/setup/users/customer-support',
      '/api/setup/users/customer',
      '/api/setup/users/chemist',
    ]) {
      const res = await api.post(path);
      expect([200, 409], `${path} -> ${res.status()}`).toContain(res.status());
    }
  });

  test('fix-missing-customer-numbers maintenance endpoint -> 200', async ({ api }) => {
    const res = await api.post('/api/setup/customers/fix-missing-customer-numbers');
    expect(res.status(), await res.text()).toBe(200);
  });
});
