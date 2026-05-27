import { test, expect } from '../fixtures/api.fixture';

/**
 * Covers RolePermissionsController (`/api/rolepermissions`). Plan §7.1 + §7.4.
 *
 * Contract (verified against RolePermissionsController.cs + RolePermissionDto.cs):
 *  - class [Authorize]; every action RequireManageRolePermission (admin has it)
 *  - GET  /{roleId}                  -> 200 | 400(InvalidOp)
 *  - POST /add     AddRolePermissionDto{RoleId*,PermissionId*(>=1),IsActive}    -> 200 | 400
 *  - POST /remove  RemoveRolePermissionDto{RoleId*,PermissionId*(>=1)}          -> 200 {success,message} | 400
 *  - GET  /roles-with-permissions[?includeInactiveRoles]                        -> 200
 *
 * NON-DESTRUCTIVE strategy: add then immediately remove permission 29
 * (ManageRolePermission) on the DeliveryBoyRoleId — a role no current spec uses
 * and which does not normally hold perm 29 — so the role-permission map ends
 * unchanged. Never mutate Admin's permissions (would break other specs).
 */

const ADMIN_ROLE_ID = '11111111-1111-1111-1111-111111111111';
const DELIVERYBOY_ROLE_ID = '66666666-6666-6666-6666-666666666666';
const MANAGE_ROLE_PERMISSION_ID = 29;

test.describe('RolePermissions API', () => {
  test.describe('auth gating (401 without token)', () => {
    test('GET /{roleId}', async ({ api }) => {
      expect((await api.get(`/api/rolepermissions/${ADMIN_ROLE_ID}`)).status()).toBe(401);
    });
    test('POST /add', async ({ api }) => {
      expect((await api.post('/api/rolepermissions/add', { data: {} })).status()).toBe(401);
    });
    test('POST /remove', async ({ api }) => {
      expect((await api.post('/api/rolepermissions/remove', { data: {} })).status()).toBe(401);
    });
    test('GET /roles-with-permissions', async ({ api }) => {
      expect((await api.get('/api/rolepermissions/roles-with-permissions')).status()).toBe(401);
    });
  });

  test('GET /{AdminRoleId} (admin) -> 200', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.get(`/api/rolepermissions/${ADMIN_ROLE_ID}`);
    expect(res.status(), await res.text()).toBe(200);
  });

  test('GET /roles-with-permissions (admin) -> 200', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.get('/api/rolepermissions/roles-with-permissions?includeInactiveRoles=true');
    expect(res.status(), await res.text()).toBe(200);
  });

  test.describe('validation negatives', () => {
    test('POST /add with missing fields -> 400', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      expect((await admin.post('/api/rolepermissions/add', { data: {} })).status()).toBe(400);
    });
    test('POST /add with PermissionId 0 (out of range) -> 400', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.post('/api/rolepermissions/add', {
        data: { roleId: DELIVERYBOY_ROLE_ID, permissionId: 0, isActive: true },
      });
      expect(res.status()).toBe(400);
    });
    test('POST /add with a nonexistent permission id -> 400', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.post('/api/rolepermissions/add', {
        data: { roleId: DELIVERYBOY_ROLE_ID, permissionId: 999999, isActive: true },
      });
      expect(res.status()).toBe(400);
    });
  });

  test.describe.serial('non-destructive add -> remove round-trip', () => {
    test('POST /add (admin) grants perm 29 to DeliveryBoy -> 200', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.post('/api/rolepermissions/add', {
        data: { roleId: DELIVERYBOY_ROLE_ID, permissionId: MANAGE_ROLE_PERMISSION_ID, isActive: true },
      });
      // 200 normally; 400 only if it already had it (then remove below restores baseline)
      expect([200, 400]).toContain(res.status());
    });

    test('POST /remove (admin) revokes perm 29 from DeliveryBoy -> 200', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.post('/api/rolepermissions/remove', {
        data: { roleId: DELIVERYBOY_ROLE_ID, permissionId: MANAGE_ROLE_PERMISSION_ID },
      });
      expect(res.status(), await res.text()).toBe(200);
      expect((await res.json()).success !== undefined).toBeTruthy();
    });
  });
});
