import { test, expect } from '../fixtures/api.fixture';

/**
 * Covers SetupController (`/api/setup`). Plan §7.1 (Setup).
 *
 * SECURITY (changed 2026-07-29, finding C-01): these endpoints create roles, permissions
 * and privileged users — including an Admin account with a hardcoded password. They used to
 * be [AllowAnonymous], which allowed anonymous administrative takeover. They now require
 * either an authenticated Admin or the shared `X-Setup-Token` (config `Setup:AccessToken`),
 * and fail CLOSED when no token is configured outside Development.
 *
 * These tests therefore assert BOTH halves of the control:
 *   1. anonymous callers are rejected (401);
 *   2. callers presenting the token still succeed (so seeding/automation keeps working).
 *
 * Set SETUP_ACCESS_TOKEN in e2e/.env to match the API's Setup:AccessToken.
 */

const SETUP_TOKEN = process.env.SETUP_ACCESS_TOKEN ?? '';
const tokenHeaders = { 'X-Setup-Token': SETUP_TOKEN };

const SEED_PATHS = [
  '/api/setup/roles/predefined',
  '/api/setup/permissions/predefined',
  '/api/setup/role-permissions/predefined',
];

const USER_PATHS = [
  '/api/setup/users/admin/firstuser',
  '/api/setup/users/admin',
  '/api/setup/users/manager',
  '/api/setup/users/customer-support',
  '/api/setup/users/customer',
  '/api/setup/users/chemist',
];

test.describe('Setup API — access control (C-01)', () => {
  test('anonymous callers are REJECTED on every setup endpoint', async ({ api }) => {
    for (const path of [...SEED_PATHS, ...USER_PATHS, '/api/setup/customers/fix-missing-customer-numbers']) {
      const res = await api.post(path);
      expect([401, 403], `${path} must not be anonymous -> got ${res.status()}`).toContain(res.status());
    }
  });

  test('an invalid setup token is REJECTED', async ({ api }) => {
    const res = await api.post('/api/setup/roles/predefined', {
      headers: { 'X-Setup-Token': 'definitely-not-the-token' },
    });
    expect([401, 403]).toContain(res.status());
  });

  test('anonymous callers cannot create an Admin user (privilege escalation blocked)', async ({ api }) => {
    for (const path of ['/api/setup/users/admin', '/api/setup/users/admin/firstuser']) {
      const res = await api.post(path);
      expect([401, 403], `${path} -> ${res.status()}`).toContain(res.status());
    }
  });
});

test.describe('Setup API — authorised access still works (idempotent)', () => {
  test.skip(!SETUP_TOKEN, 'SETUP_ACCESS_TOKEN not configured');

  test('predefined roles/permissions/role-permissions -> 200 with token', async ({ api }) => {
    for (const path of SEED_PATHS) {
      const res = await api.post(path, { headers: tokenHeaders });
      expect(res.status(), `${path} -> ${res.status()}`).toBe(200);
    }
  });

  test('seed users are idempotent -> 200 or 409 with token', async ({ api }) => {
    for (const path of USER_PATHS) {
      const res = await api.post(path, { headers: tokenHeaders });
      expect([200, 409], `${path} -> ${res.status()}`).toContain(res.status());
    }
  });

  test('fix-missing-customer-numbers maintenance endpoint -> 200 with token', async ({ api }) => {
    const res = await api.post('/api/setup/customers/fix-missing-customer-numbers', { headers: tokenHeaders });
    expect(res.status(), await res.text()).toBe(200);
  });
});
