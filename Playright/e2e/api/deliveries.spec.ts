import { test, expect } from '../fixtures/api.fixture';

/**
 * Covers DeliveriesController (`/api/deliveries`). Plan §7.1 + §7.4.
 *
 * Contract (verified against DeliveriesController.cs + DeliveryDto.cs):
 *  - class [Authorize]
 *  - POST   /api/deliveries                               RequireOrderUpdatePermission -> 201 | 400(ModelState) | 404(KeyNotFound) | 400(InvalidOp)
 *  - GET    /api/deliveries                               RequireOrderReadPermission   -> 200 DeliveryDto[]
 *  - GET    /api/deliveries/{id:int}                      RequireOrderReadPermission   -> 200 | 404 {error}
 *  - GET    /api/deliveries/medicalstore/{guid}           RequireOrderReadPermission   -> 200 DeliveryDto[]
 *  - GET    /api/deliveries/medicalstore/{guid}/active    RequireOrderReadPermission   -> 200 DeliveryDto[]
 *  - PUT    /api/deliveries/{id:int}                      RequireOrderUpdatePermission -> 200 | 404 {error}
 *  - DELETE /api/deliveries/{id:int}                      RequireOrderUpdatePermission -> 204 | 404 {error}
 *  CreateDeliveryDto = { FirstName?, MiddleName?, LastName?, DrivingLicenceNumber?,
 *    MobileNumber?, Password?, MedicalStoreId?, ServiceRegionId? } — a "Delivery" is
 *    a delivery-boy record (no OrderId here). Admin holds OrderRead/Update perms.
 */

const ZERO_GUID = '00000000-0000-0000-0000-000000000000';

function uniqueBoy() {
  const n = Date.now().toString().slice(-9) + Math.floor(Math.random() * 100);
  return {
    firstName: 'E2E',
    lastName: 'Rider',
    drivingLicenceNumber: `DL-${n}`,
    mobileNumber: `9${n.slice(0, 9)}`,
    password: 'E2eRide@123',
  };
}

test.describe('Deliveries API', () => {
  test.describe('auth gating (401 without token)', () => {
    test('GET /api/deliveries', async ({ api }) => {
      expect((await api.get('/api/deliveries')).status()).toBe(401);
    });
    test('GET /api/deliveries/{id}', async ({ api }) => {
      expect((await api.get('/api/deliveries/1')).status()).toBe(401);
    });
    test('POST /api/deliveries', async ({ api }) => {
      expect((await api.post('/api/deliveries', { data: {} })).status()).toBe(401);
    });
    test('DELETE /api/deliveries/{id}', async ({ api }) => {
      expect((await api.delete('/api/deliveries/1')).status()).toBe(401);
    });
  });

  test('GET /api/deliveries (admin) -> 200 array', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.get('/api/deliveries');
    expect(res.status(), await res.text()).toBe(200);
    expect(Array.isArray(await res.json())).toBeTruthy();
  });

  test('GET /api/deliveries/{unknown} (admin) -> 404', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    expect((await admin.get('/api/deliveries/99999999')).status()).toBe(404);
  });

  test('GET /api/deliveries/medicalstore/{guid} (admin) -> 200 array', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.get(`/api/deliveries/medicalstore/${ZERO_GUID}`);
    expect(res.status()).toBe(200);
    expect(Array.isArray(await res.json())).toBeTruthy();
  });

  test('GET /api/deliveries/medicalstore/{guid}/active (admin) -> 200 array', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.get(`/api/deliveries/medicalstore/${ZERO_GUID}/active`);
    expect(res.status()).toBe(200);
    expect(Array.isArray(await res.json())).toBeTruthy();
  });

  test('PUT /api/deliveries/{unknown} (admin) -> 404', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.put('/api/deliveries/99999999', { data: { firstName: 'X' } });
    expect(res.status()).toBe(404);
  });

  test('DELETE /api/deliveries/{unknown} (admin) -> 404', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    expect((await admin.delete('/api/deliveries/99999999')).status()).toBe(404);
  });

  test.describe.serial('delivery-boy create -> read -> update -> delete (admin)', () => {
    const b = uniqueBoy();
    let id: number | undefined;

    test('POST /api/deliveries -> 201', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.post('/api/deliveries', { data: b });
      expect(res.status(), await res.text()).toBe(201);
      const body = await res.json();
      id = body.id;
      expect(id).toBeTruthy();
      expect(res.headers()['location']).toBeTruthy();
    });

    test('GET /api/deliveries/{id} -> 200 matches', async ({ apiAs }) => {
      test.skip(!id, 'no delivery id');
      const admin = await apiAs('admin');
      const res = await admin.get(`/api/deliveries/${id}`);
      expect(res.status()).toBe(200);
      expect((await res.json()).id).toBe(id);
    });

    test('PUT /api/deliveries/{id} updates it', async ({ apiAs }) => {
      test.skip(!id, 'no delivery id');
      const admin = await apiAs('admin');
      const res = await admin.put(`/api/deliveries/${id}`, {
        data: { firstName: 'E2EUpdated', isActive: true },
      });
      expect(res.status(), await res.text()).toBe(200);
      expect((await res.json()).firstName).toBe('E2EUpdated');
    });

    test('DELETE /api/deliveries/{id} -> 204 (soft delete)', async ({ apiAs }) => {
      test.skip(!id, 'no delivery id');
      const admin = await apiAs('admin');
      expect((await admin.delete(`/api/deliveries/${id}`)).status()).toBe(204);
    });
  });
});
