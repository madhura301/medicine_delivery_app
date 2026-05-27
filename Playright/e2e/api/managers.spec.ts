import { test, expect } from '../fixtures/api.fixture';

/**
 * Covers ManagersController (`/api/managers`). Plan §7.1 + §7.4.
 *
 * Contract (verified against ManagersController.cs + ManagerDto.cs):
 *  - class [Authorize]
 *  - POST   /register            RequireManagerSupportCreatePermission -> 200 ManagerResponseDto | 400 {errors}
 *  - GET    /                     RequireManagerSupportReadPermission   -> 200 ManagerDto[]
 *  - GET    /{id:guid}            RequireManagerSupportReadPermission   -> 200 | 404
 *  - GET    /by-email/{email}     RequireManagerSupportReadPermission   -> 200 | 404
 *  - PUT    /{id:guid}            RequireManagerSupportUpdatePermission -> 200 | 404
 *  - DELETE /{id:guid}            RequireManagerSupportDeletePermission -> 204 | 404 (soft delete)
 *  - POST   /{id}/photo           RequireManagerSupportUpdatePermission -> 200 | 400 | 404
 *  Admin holds all ManagerSupport permissions. NB register returns 200 (not 201).
 */

const ZERO_GUID = '00000000-0000-0000-0000-000000000000';

function uniqueManager() {
  const n = Date.now().toString().slice(-9) + Math.floor(Math.random() * 100);
  return {
    managerFirstName: 'E2E',
    managerLastName: 'Manager',
    managerMiddleName: '',
    address: '7 Ops Avenue',
    city: 'Pune',
    state: 'Maharashtra',
    mobileNumber: `9${n.slice(0, 9)}`,
    emailId: `e2e_mgr_${n}@example.com`,
    alternativeMobileNumber: `8${n.slice(0, 9)}`,
    employeeId: `MGR-${n}`,
  };
}

test.describe('Managers API', () => {
  test.describe('auth gating (401 without token)', () => {
    test('GET /', async ({ api }) => {
      expect((await api.get('/api/managers')).status()).toBe(401);
    });
    test('POST /register', async ({ api }) => {
      expect((await api.post('/api/managers/register', { data: {} })).status()).toBe(401);
    });
    test('DELETE /{id}', async ({ api }) => {
      expect((await api.delete(`/api/managers/${ZERO_GUID}`)).status()).toBe(401);
    });
  });

  test('GET / (admin) -> 200 array', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.get('/api/managers');
    expect(res.status(), await res.text()).toBe(200);
    expect(Array.isArray(await res.json())).toBeTruthy();
  });

  test('GET /{unknown guid} (admin) -> 404', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    expect((await admin.get(`/api/managers/${ZERO_GUID}`)).status()).toBe(404);
  });

  test('GET /by-email/{unknown} (admin) -> 404', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    expect((await admin.get('/api/managers/by-email/nobody-e2e@x.com')).status()).toBe(404);
  });

  test.describe.serial('Manager lifecycle (register -> read -> update -> photo -> delete)', () => {
    const m = uniqueManager();
    let id: string;

    test('POST /register (admin) -> 200', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.post('/api/managers/register', { data: m });
      expect(res.status(), await res.text()).toBe(200);
      const body = await res.json();
      id = body.managerId;
      expect(id).toBeTruthy();
      expect(body.emailId).toBe(m.emailId);
    });

    test('GET /{id} (admin) -> 200 matches', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.get(`/api/managers/${id}`);
      expect(res.status()).toBe(200);
      expect((await res.json()).managerId).toBe(id);
    });

    test('GET /by-email/{email} (admin) -> 200 matches', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.get(`/api/managers/by-email/${encodeURIComponent(m.emailId)}`);
      expect(res.status()).toBe(200);
      expect((await res.json()).emailId).toBe(m.emailId);
    });

    test('PUT /{id} (admin) updates it', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.put(`/api/managers/${id}`, {
        data: { ...m, managerFirstName: 'E2EUpdated' },
      });
      expect(res.status(), await res.text()).toBe(200);
      expect((await res.json()).managerFirstName).toBe('E2EUpdated');
    });

    test('POST /{id}/photo with an invalid (non-image) file -> 400', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.post(`/api/managers/${id}/photo`, {
        multipart: {
          photo: { name: 'note.txt', mimeType: 'text/plain', buffer: Buffer.from('not an image') },
        },
      });
      expect(res.status()).toBe(400);
    });

    test('PUT /{unknown} (admin) -> 404', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      expect((await admin.put(`/api/managers/${ZERO_GUID}`, { data: m })).status()).toBe(404);
    });

    // F3: soft delete — service returns success idempotently, so a 2nd DELETE
    // is still 204 (not 404). Behavior, not a bug.
    test('DELETE /{id} (admin) -> 204 (idempotent soft delete, F3)', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      expect((await admin.delete(`/api/managers/${id}`)).status()).toBe(204);
      expect([204, 404]).toContain((await admin.delete(`/api/managers/${id}`)).status());
    });
  });
});
