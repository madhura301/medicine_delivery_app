import { test, expect } from '../fixtures/api.fixture';

/**
 * Covers MedicalStoresController (`/api/medicalstores`). Plan §7.1 + §7.4.
 *
 * Contract (verified against MedicalStoresController.cs + MedicalStoreDto.cs):
 *  - class [Authorize]
 *  - POST   /api/medicalstores/register              [AllowAnonymous]  -> 200 result | 400 {errors}  (NOTE: 200, not 201)
 *  - GET    /api/medicalstores                       RequireChemistReadPermission   -> 200 MedicalStoreDto[]
 *  - GET    /api/medicalstores/{id:guid}             RequireChemistReadPermission   -> 200 | 404
 *  - GET    /api/medicalstores/by-email/{email}      RequireChemistReadPermission   -> 200 | 404
 *  - PUT    /api/medicalstores/{id:guid}             RequireChemistUpdatePermission -> 200 | 404 {error}
 *  - GET    /api/medicalstores/check-availability/{customerId:guid}  [Authorize]    -> 200 {isChemistAvailable} | 404 {error}
 *  - DELETE /api/medicalstores/{id:guid}             RequireChemistDeletePermission -> 204 | 404  (soft delete — see F3)
 *  Admin holds all Chemist permissions and is used for privileged paths.
 */

function uniqueStore() {
  const n = Date.now().toString().slice(-9) + Math.floor(Math.random() * 100);
  return {
    medicalName: `E2E Pharmacy ${n}`,
    ownerFirstName: 'Owner',
    ownerLastName: 'Tester',
    ownerMiddleName: '',
    password: 'E2eStore@123',
    addressLine1: '1 Test Street',
    addressLine2: 'Suite 2',
    city: 'Pune',
    state: 'Maharashtra',
    postalCode: '411001',
    latitude: 18.5204,
    longitude: 73.8567,
    mobileNumber: `9${n.slice(0, 9)}`,
    emailId: `e2e_store_${n}@example.com`,
    alternativeMobileNumber: `8${n.slice(0, 9)}`,
    registrationStatus: true,
    gstin: '27ABCDE1234F1Z5',
    pan: 'ABCDE1234F',
    fssaiNo: '12345678901234',
    dlNo: `DL-${n}`,
    pharmacistFirstName: 'Pharma',
    pharmacistLastName: 'Cist',
    pharmacistRegistrationNumber: `PH-${n}`,
    pharmacistMobileNumber: `7${n.slice(0, 9)}`,
  };
}

test.describe('MedicalStores API', () => {
  test.describe('auth gating (401 without token)', () => {
    test('GET /api/medicalstores', async ({ api }) => {
      expect((await api.get('/api/medicalstores')).status()).toBe(401);
    });
    test('GET /api/medicalstores/check-availability/{guid}', async ({ api }) => {
      expect(
        (await api.get('/api/medicalstores/check-availability/00000000-0000-0000-0000-000000000000')).status(),
      ).toBe(401);
    });
    test('PUT /api/medicalstores/{id}', async ({ api }) => {
      expect(
        (await api.put('/api/medicalstores/00000000-0000-0000-0000-000000000000', { data: {} })).status(),
      ).toBe(401);
    });
  });

  test('GET /api/medicalstores (admin) returns a list', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.get('/api/medicalstores');
    expect(res.status(), await res.text()).toBe(200);
    expect(Array.isArray(await res.json())).toBeTruthy();
  });

  test('GET /api/medicalstores/{unknown guid} (admin) -> 404', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    expect((await admin.get('/api/medicalstores/22222222-2222-2222-2222-222222222222')).status()).toBe(404);
  });

  test('GET /api/medicalstores/by-email/{unknown} (admin) -> 404', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    expect((await admin.get('/api/medicalstores/by-email/nobody-e2e@example.com')).status()).toBe(404);
  });

  test('check-availability for an unknown customer (admin) -> 404', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.get(
      '/api/medicalstores/check-availability/33333333-3333-3333-3333-333333333333',
    );
    expect(res.status()).toBe(404);
  });

  test.describe.serial('registration lifecycle (anon register -> read -> update -> delete)', () => {
    const s = uniqueStore();
    let storeId: string | undefined;

    test('POST /api/medicalstores/register (anon) -> 200', async ({ api }) => {
      const res = await api.post('/api/medicalstores/register', { data: s });
      expect(res.status(), await res.text()).toBe(200);
      const body = await res.json();
      const blob = JSON.stringify(body).toLowerCase();
      expect(blob).toContain(s.mobileNumber);
      storeId =
        body?.medicalStoreId ?? body?.medicalStore?.medicalStoreId ?? body?.data?.medicalStoreId;
    });

    test('the store is retrievable by email (admin)', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.get(`/api/medicalstores/by-email/${encodeURIComponent(s.emailId)}`);
      expect(res.status()).toBe(200);
      const store = await res.json();
      expect(store.emailId).toBe(s.emailId);
      storeId = storeId ?? store.medicalStoreId;
    });

    test('the store is retrievable by id (admin)', async ({ apiAs }) => {
      test.skip(!storeId, 'no storeId resolved');
      const admin = await apiAs('admin');
      const res = await admin.get(`/api/medicalstores/${storeId}`);
      expect(res.status()).toBe(200);
      expect((await res.json()).medicalStoreId).toBe(storeId);
    });

    test('PUT /api/medicalstores/{id} (admin) updates the store', async ({ apiAs }) => {
      test.skip(!storeId, 'no storeId resolved');
      const admin = await apiAs('admin');
      const res = await admin.put(`/api/medicalstores/${storeId}`, {
        data: { ...s, medicalName: `${s.medicalName} UPDATED` },
      });
      expect(res.status(), await res.text()).toBe(200);
      expect((await res.json()).medicalName).toContain('UPDATED');
    });

    test('PUT /api/medicalstores/{unknown} (admin) -> 404', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.put('/api/medicalstores/44444444-4444-4444-4444-444444444444', {
        data: s,
      });
      expect(res.status()).toBe(404);
    });

    test('DELETE /api/medicalstores/{id} (admin) -> 204 (soft delete, F3)', async ({ apiAs }) => {
      test.skip(!storeId, 'no storeId resolved');
      const admin = await apiAs('admin');
      expect((await admin.delete(`/api/medicalstores/${storeId}`)).status()).toBe(204);
      const after = await admin.get(`/api/medicalstores/${storeId}`);
      // Soft-delete: either still retrievable (isDeleted/!isActive) or 404.
      expect([200, 404]).toContain(after.status());
      if (after.status() === 200) {
        const body = await after.json();
        expect(body.isDeleted === true || body.isActive === false).toBeTruthy();
      }
    });
  });
});
