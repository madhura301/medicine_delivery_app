import { test, expect } from '../fixtures/api.fixture';

/**
 * Covers ServiceRegionsController (route `/api/ServiceRegions`, file
 * CustomerSupportRegionsController.cs). Plan §7.1 + §7.4.
 *
 * Contract (verified against the controller + CustomerSupportRegionDto.cs):
 *  - class [Authorize]; mutations RequireOrderUpdatePermission, reads RequireOrderReadPermission
 *  - POST   /api/ServiceRegions                       -> 201 ServiceRegionDto | 400
 *  - GET    /api/ServiceRegions[?regionType=0|1]      -> 200 ServiceRegionDto[]
 *  - GET    /api/ServiceRegions/{id:int}              -> 200 | 404
 *  - PUT    /api/ServiceRegions/{id:int}              -> 200 | 404(KeyNotFound)
 *  - DELETE /api/ServiceRegions/{id:int}              -> 204 | 404
 *  - POST   /api/ServiceRegions/assign                -> 200 | 404 | 400
 *  - POST   /api/ServiceRegions/assign-delivery       -> 200 | 404 | 400
 *  - POST   /api/ServiceRegions/add-pincode           -> 200 | 404 | 400
 *  - POST   /api/ServiceRegions/remove-pincode        -> 200 | 404 | 400
 *  - GET    /api/ServiceRegions/{regionId:int}/pincodes -> 200 string[]
 *  - GET    /api/ServiceRegions/by-pincode/{pinCode}  -> 200 | 404
 *  RegionType: 0=CustomerSupport, 1=DeliveryBoy. Admin holds Order R/U perms.
 */

const ZERO_GUID = '00000000-0000-0000-0000-000000000000';

test.describe('ServiceRegions API', () => {
  test.describe('auth gating (401 without token)', () => {
    test('GET /api/ServiceRegions', async ({ api }) => {
      expect((await api.get('/api/ServiceRegions')).status()).toBe(401);
    });
    test('POST /api/ServiceRegions', async ({ api }) => {
      expect((await api.post('/api/ServiceRegions', { data: {} })).status()).toBe(401);
    });
    test('DELETE /api/ServiceRegions/{id}', async ({ api }) => {
      expect((await api.delete('/api/ServiceRegions/1')).status()).toBe(401);
    });
  });

  test('GET /api/ServiceRegions and ?regionType=0 (admin) -> 200 arrays', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const all = await admin.get('/api/ServiceRegions');
    expect(all.status(), await all.text()).toBe(200);
    expect(Array.isArray(await all.json())).toBeTruthy();
    const byType = await admin.get('/api/ServiceRegions?regionType=0');
    expect(byType.status()).toBe(200);
    expect(Array.isArray(await byType.json())).toBeTruthy();
  });

  test('GET /api/ServiceRegions/{unknown} (admin) -> 404', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    expect((await admin.get('/api/ServiceRegions/99999999')).status()).toBe(404);
  });

  test('GET /api/ServiceRegions/by-pincode/{unknown} (admin) -> 404', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    expect((await admin.get('/api/ServiceRegions/by-pincode/000000')).status()).toBe(404);
  });

  test.describe.serial('region lifecycle (create -> read -> pincodes -> assign -> delete)', () => {
    // Pin codes are unique per region-type (server enforces it). Use a run-unique
    // 6-digit pin and create the region with NO pincodes to avoid collisions.
    const pin = Date.now().toString().slice(-6);
    let regionId: number;

    test('POST /api/ServiceRegions (admin) -> 201', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.post('/api/ServiceRegions', {
        data: {
          name: `E2E Region ${Date.now()}`,
          city: 'Pune',
          regionName: 'E2E Zone',
          regionType: 0,
          pinCodes: [],
        },
      });
      expect(res.status(), await res.text()).toBe(201);
      const body = await res.json();
      regionId = body.id;
      expect(regionId).toBeTruthy();
      expect(res.headers()['location']).toBeTruthy();
    });

    test('GET /api/ServiceRegions/{id} (admin) -> 200 matches', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.get(`/api/ServiceRegions/${regionId}`);
      expect(res.status()).toBe(200);
      expect((await res.json()).id).toBe(regionId);
    });

    test('PUT /api/ServiceRegions/{id} (admin) updates it', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.put(`/api/ServiceRegions/${regionId}`, {
        data: { name: 'E2E Region UPDATED' },
      });
      expect(res.status(), await res.text()).toBe(200);
      expect((await res.json()).name).toBe('E2E Region UPDATED');
    });

    test('add-pincode -> appears in /pincodes -> resolvable by-pincode', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const add = await admin.post('/api/ServiceRegions/add-pincode', {
        data: { serviceRegionId: regionId, pinCode: pin },
      });
      expect(add.status(), await add.text()).toBe(200);

      const list = await admin.get(`/api/ServiceRegions/${regionId}/pincodes`);
      expect(list.status()).toBe(200);
      expect((await list.json()) as string[]).toContain(pin);

      const byPin = await admin.get(`/api/ServiceRegions/by-pincode/${pin}`);
      expect(byPin.status()).toBe(200);
      expect((await byPin.json()).id).toBe(regionId);
    });

    test('remove-pincode -> 200, removing again -> 404', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const rm = await admin.post('/api/ServiceRegions/remove-pincode', {
        data: { serviceRegionId: regionId, pinCode: pin },
      });
      expect(rm.status(), await rm.text()).toBe(200);
      const rm2 = await admin.post('/api/ServiceRegions/remove-pincode', {
        data: { serviceRegionId: regionId, pinCode: pin },
      });
      expect(rm2.status()).toBe(404);
    });

    test('assign to unknown customer support -> 404', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.post('/api/ServiceRegions/assign', {
        data: { serviceRegionId: regionId, customerSupportId: ZERO_GUID },
      });
      expect(res.status()).toBe(404);
    });

    test('assign-delivery to unknown delivery -> 404', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.post('/api/ServiceRegions/assign-delivery', {
        data: { serviceRegionId: regionId, deliveryId: 99999999 },
      });
      expect(res.status()).toBe(404);
    });

    test('PUT unknown region -> 404', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.put('/api/ServiceRegions/99999999', { data: { name: 'x' } });
      expect(res.status()).toBe(404);
    });

    test('DELETE /api/ServiceRegions/{id} (admin) -> 204 (cleanup)', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      expect((await admin.delete(`/api/ServiceRegions/${regionId}`)).status()).toBe(204);
      expect([204, 404]).toContain((await admin.delete(`/api/ServiceRegions/${regionId}`)).status());
    });
  });
});
