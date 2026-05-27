import { test, expect } from '../fixtures/api.fixture';

/**
 * Covers CustomerAddressesController (`/api/customeraddresses`). Plan §7.1 + §7.4.
 *
 * Contract (verified against CustomerAddressesController.cs + CustomerAddressDto.cs):
 *  - class [Authorize]
 *  - GET    /{id:guid}                                  RequireCustomerReadPermission   -> 200 | 404 {error}
 *  - GET    /customer/{customerId:guid}                 RequireCustomerReadPermission   -> 200 CustomerAddressDto[]
 *  - GET    /customer/{customerId:guid}/default         RequireCustomerReadPermission   -> 200 | 404 {error}
 *  - POST   /                                           RequireCustomerCreatePermission -> 201 CustomerAddressDto
 *  - PUT    /{id:guid}                                  RequireCustomerUpdatePermission -> 200 | 404 {error}
 *  - DELETE /{id:guid}                                  RequireCustomerDeletePermission -> 204 | 404 {error}
 *  - PUT    /customer/{customerId}/set-default/{addrId} RequireCustomerUpdatePermission -> 200 {message} | 404 {error}
 *  Admin holds all Customer permissions. A real customer is registered first
 *  (anon /api/customers/register) to obtain a valid customerId.
 */

const ZERO_GUID = '00000000-0000-0000-0000-000000000000';

function uniqueCustomer() {
  const n = Date.now().toString().slice(-9) + Math.floor(Math.random() * 100);
  return {
    customerFirstName: 'Addr',
    customerLastName: 'Owner',
    mobileNumber: `9${n.slice(0, 9)}`,
    password: 'E2eAddr@123',
    emailId: `e2e_addr_${n}@example.com`,
    dateOfBirth: '1992-02-02T00:00:00Z',
  };
}

test.describe('CustomerAddresses API', () => {
  test.describe('auth gating (401 without token)', () => {
    test('GET /{id}', async ({ api }) => {
      expect((await api.get(`/api/customeraddresses/${ZERO_GUID}`)).status()).toBe(401);
    });
    test('GET /customer/{id}', async ({ api }) => {
      expect((await api.get(`/api/customeraddresses/customer/${ZERO_GUID}`)).status()).toBe(401);
    });
    test('POST /', async ({ api }) => {
      expect((await api.post('/api/customeraddresses', { data: {} })).status()).toBe(401);
    });
    test('DELETE /{id}', async ({ api }) => {
      expect((await api.delete(`/api/customeraddresses/${ZERO_GUID}`)).status()).toBe(401);
    });
  });

  test('GET /{unknown} (admin) -> 404', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    expect((await admin.get(`/api/customeraddresses/${ZERO_GUID}`)).status()).toBe(404);
  });

  test('GET /customer/{unknown}/default (admin) -> 404', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    expect(
      (await admin.get(`/api/customeraddresses/customer/${ZERO_GUID}/default`)).status(),
    ).toBe(404);
  });

  test('PUT set-default with unknown ids (admin) -> 404', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.put(
      `/api/customeraddresses/customer/${ZERO_GUID}/set-default/${ZERO_GUID}`,
    );
    expect(res.status()).toBe(404);
  });

  test.describe.serial('address lifecycle for a fresh customer', () => {
    const c = uniqueCustomer();
    let customerId: string;
    let addressId: string;

    test('setup: register a customer', async ({ api }) => {
      const res = await api.post('/api/customers/register', { data: c });
      expect(res.status(), await res.text()).toBe(201);
      const body = await res.json();
      customerId = body?.customer?.customerId ?? body?.customerId;
      expect(customerId).toBeTruthy();
    });

    test('GET /customer/{customerId} (admin) -> 200 array', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.get(`/api/customeraddresses/customer/${customerId}`);
      expect(res.status()).toBe(200);
      expect(Array.isArray(await res.json())).toBeTruthy();
    });

    test('POST / (admin) creates an address -> 201', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.post('/api/customeraddresses', {
        data: {
          customerId,
          addressLine1: '10 Pharma Road',
          addressLine2: 'Near Clinic',
          city: 'Pune',
          state: 'Maharashtra',
          postalCode: '411002',
          latitude: 18.52,
          longitude: 73.85,
          isDefault: true,
        },
      });
      expect(res.status(), await res.text()).toBe(201);
      const body = await res.json();
      addressId = body.id;
      expect(addressId).toBeTruthy();
      expect(body.customerId).toBe(customerId);
      expect(res.headers()['location']).toBeTruthy();
    });

    test('GET /{addressId} (admin) -> 200 matches', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.get(`/api/customeraddresses/${addressId}`);
      expect(res.status()).toBe(200);
      expect((await res.json()).id).toBe(addressId);
    });

    test('the address shows up in the customer list', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const list = (await (
        await admin.get(`/api/customeraddresses/customer/${customerId}`)
      ).json()) as Array<{ id: string }>;
      expect(list.some((a) => a.id === addressId)).toBeTruthy();
    });

    test('GET /customer/{customerId}/default (admin) -> 200', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.get(`/api/customeraddresses/customer/${customerId}/default`);
      expect(res.status()).toBe(200);
    });

    test('PUT /{addressId} (admin) updates the address', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.put(`/api/customeraddresses/${addressId}`, {
        data: { city: 'Mumbai', postalCode: '400001' },
      });
      expect(res.status(), await res.text()).toBe(200);
      expect((await res.json()).city).toBe('Mumbai');
    });

    test('PUT set-default/{addressId} (admin) -> 200 {message}', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.put(
        `/api/customeraddresses/customer/${customerId}/set-default/${addressId}`,
      );
      expect(res.status(), await res.text()).toBe(200);
      expect((await res.json()).message).toBeTruthy();
    });

    test('PUT /{unknown} (admin) -> 404', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.put(`/api/customeraddresses/${ZERO_GUID}`, { data: { city: 'X' } });
      expect(res.status()).toBe(404);
    });

    test('DELETE /{addressId} (admin) -> 204 (cleanup)', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      expect((await admin.delete(`/api/customeraddresses/${addressId}`)).status()).toBe(204);
      // delete semantics: hard (404) or soft (200) — both acceptable, just not 5xx
      const after = await admin.get(`/api/customeraddresses/${addressId}`);
      expect([200, 404]).toContain(after.status());
    });

    test('DELETE /{addressId} again (admin) -> 404', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      expect((await admin.delete(`/api/customeraddresses/${addressId}`)).status()).toBe(404);
    });
  });
});
