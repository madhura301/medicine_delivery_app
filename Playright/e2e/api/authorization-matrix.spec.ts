import { test, expect } from '../fixtures/api.fixture';
import { RoleName } from '../helpers/config';

/**
 * Plan §7.3 — authorization model enforcement.
 *
 * Working logins: admin, manager, support, chemist (customer login broken — F1;
 * no deliveryboy seeded). This spec asserts the crisp, high-confidence boundaries
 * (a wrong result here is a real authz surprise, not test noise):
 *
 *  1. authn vs authz are distinct: no token -> 401; valid token lacking the
 *     permission -> 403 (NOT 401) on the same endpoint.
 *  2. Each working role's token is accepted system-wide on a role-appropriate
 *     endpoint (authorized => not 401/403).
 *  3. Admin-only governance (RequireManageRolePermission) is denied to
 *     non-admin-tier roles (chemist, support) and allowed for admin.
 *
 * The exhaustive per-permission grid is intentionally NOT enumerated here (the
 * role→permission map is large and analysis-derived); these boundaries are the
 * load-bearing guarantees. See task.md for the deferred full-grid note.
 */

const ADMIN_ROLE_ID = '11111111-1111-1111-1111-111111111111';
const GOVERNANCE_ENDPOINT = `/api/rolepermissions/${ADMIN_ROLE_ID}`;

test.describe('Authorization matrix', () => {
  test('authn vs authz: no token -> 401, under-privileged token -> 403 (same endpoint)', async ({
    api,
    apiAs,
  }) => {
    expect((await api.get(GOVERNANCE_ENDPOINT)).status(), 'no token').toBe(401);
    const chemist = await apiAs('chemist');
    expect(
      (await chemist.get(GOVERNANCE_ENDPOINT)).status(),
      'chemist lacks ManageRolePermission -> must be 403, not 401',
    ).toBe(403);
  });

  test('admin IS allowed on the governance endpoint -> 200', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    expect((await admin.get(GOVERNANCE_ENDPOINT)).status()).toBe(200);
  });

  test('non-admin-tier roles are forbidden from governance (chemist & support -> 403)', async ({
    apiAs,
  }) => {
    for (const role of ['chemist', 'support'] as RoleName[]) {
      const ctx = await apiAs(role);
      expect((await ctx.get(GOVERNANCE_ENDPOINT)).status(), `${role} -> governance`).toBe(403);
    }
  });

  // Each working role can reach at least one endpoint it is entitled to
  // (proves the token is accepted across the system; authorized => not 401/403).
  const roleEntitledEndpoint: Record<Exclude<RoleName, 'customer'>, string> = {
    admin: '/api/orders', // RequireListAllOrdersPermission
    manager: '/api/managers', // RequireManagerSupportReadPermission
    support: '/api/customersupports', // RequireCustomerSupportReadPermission
    chemist: '/api/medicalstores', // RequireChemistReadPermission
  };

  for (const [role, endpoint] of Object.entries(roleEntitledEndpoint)) {
    test(`${role} is authorized on ${endpoint} (not 401/403)`, async ({ apiAs }) => {
      const ctx = await apiAs(role as RoleName);
      const status = (await ctx.get(endpoint)).status();
      expect([401, 403], `${role} ${endpoint} -> ${status}`).not.toContain(status);
      expect(status).toBeLessThan(500);
    });
  }
});
