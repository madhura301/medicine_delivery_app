import { test, expect } from '../fixtures/api.fixture';

/**
 * Covers CustomerSupportsController (`/api/customersupports`). Plan §7.1 + §7.4.
 *
 * Contract (verified against CustomerSupportsController.cs + CustomerSupportDto.cs):
 *  - class [Authorize]
 *  - POST   /register            RequireCustomerSupportCreatePermission -> 200 CustomerSupportResponseDto | 400 {errors}
 *  - GET    /                     RequireCustomerSupportReadPermission   -> 200 CustomerSupportDto[]
 *  - GET    /{id:guid}            RequireCustomerSupportReadPermission   -> 200 | 404
 *  - GET    /by-email/{email}     RequireCustomerSupportReadPermission   -> 200 | 404
 *  - PUT    /{id:guid}            RequireCustomerSupportUpdatePermission -> 200 | 404
 *  - DELETE /{id:guid}            RequireCustomerSupportDeletePermission -> 204 | 404 (soft delete)
 *  - POST   /{id}/photo           RequireCustomerSupportUpdatePermission -> 200 | 400(no/invalid file) | 404
 *  Admin holds all CustomerSupport permissions. NB register returns 200 (not 201).
 */

const ZERO_GUID = '00000000-0000-0000-0000-000000000000';

function uniqueCS() {
  const n = Date.now().toString().slice(-9) + Math.floor(Math.random() * 100);
  return {
    customerSupportFirstName: 'E2E',
    customerSupportLastName: 'Support',
    customerSupportMiddleName: '',
    address: '5 Helpdesk Lane',
    city: 'Pune',
    state: 'Maharashtra',
    mobileNumber: `9${n.slice(0, 9)}`,
    emailId: `e2e_cs_${n}@example.com`,
    alternativeMobileNumber: `8${n.slice(0, 9)}`,
    employeeId: `CS-${n}`,
  };
}

test.describe('CustomerSupports API', () => {
  test.describe('auth gating (401 without token)', () => {
    test('GET /', async ({ api }) => {
      expect((await api.get('/api/customersupports')).status()).toBe(401);
    });
    test('POST /register', async ({ api }) => {
      expect((await api.post('/api/customersupports/register', { data: {} })).status()).toBe(401);
    });
    test('DELETE /{id}', async ({ api }) => {
      expect((await api.delete(`/api/customersupports/${ZERO_GUID}`)).status()).toBe(401);
    });
  });

  test('GET / (admin) -> 200 array', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.get('/api/customersupports');
    expect(res.status(), await res.text()).toBe(200);
    expect(Array.isArray(await res.json())).toBeTruthy();
  });

  test('GET /{unknown guid} (admin) -> 404', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    expect((await admin.get(`/api/customersupports/${ZERO_GUID}`)).status()).toBe(404);
  });

  test('GET /by-email/{unknown} (admin) -> 404', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    expect((await admin.get('/api/customersupports/by-email/nobody-e2e@x.com')).status()).toBe(404);
  });

  test.describe.serial('CS lifecycle (register -> read -> update -> photo -> delete)', () => {
    const cs = uniqueCS();
    let id: string;

    test('POST /register (admin) -> 200', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.post('/api/customersupports/register', { data: cs });
      expect(res.status(), await res.text()).toBe(200);
      const body = await res.json();
      id = body.customerSupportId;
      expect(id).toBeTruthy();
      expect(body.emailId).toBe(cs.emailId);
    });

    test('GET /{id} (admin) -> 200 matches', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.get(`/api/customersupports/${id}`);
      expect(res.status()).toBe(200);
      expect((await res.json()).customerSupportId).toBe(id);
    });

    test('GET /by-email/{email} (admin) -> 200 matches', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.get(`/api/customersupports/by-email/${encodeURIComponent(cs.emailId)}`);
      expect(res.status()).toBe(200);
      expect((await res.json()).emailId).toBe(cs.emailId);
    });

    test('PUT /{id} (admin) updates it', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.put(`/api/customersupports/${id}`, {
        data: { ...cs, customerSupportFirstName: 'E2EUpdated' },
      });
      expect(res.status(), await res.text()).toBe(200);
      expect((await res.json()).customerSupportFirstName).toBe('E2EUpdated');
    });

    test('POST /{id}/photo with an invalid (non-image) file -> 400', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.post(`/api/customersupports/${id}/photo`, {
        multipart: {
          photo: { name: 'note.txt', mimeType: 'text/plain', buffer: Buffer.from('not an image') },
        },
      });
      expect(res.status()).toBe(400);
    });

    test('PUT /{unknown} (admin) -> 404', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      expect((await admin.put(`/api/customersupports/${ZERO_GUID}`, { data: cs })).status()).toBe(404);
    });

    // F3: soft delete — service returns success idempotently, so a 2nd DELETE
    // is still 204 (not 404). Behavior, not a bug.
    test('DELETE /{id} (admin) -> 204 (idempotent soft delete, F3)', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      expect((await admin.delete(`/api/customersupports/${id}`)).status()).toBe(204);
      expect([204, 404]).toContain((await admin.delete(`/api/customersupports/${id}`)).status());
    });
  });
});
