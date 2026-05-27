import { test, expect } from '../fixtures/api.fixture';

/**
 * Covers CustomersController (`/api/customers`). Plan §7.1 (Customers) + §7.4.
 *
 * Contract (verified against CustomersController.cs + CustomerDto.cs):
 *  - class [Authorize]
 *  - GET    /api/customers                      RequireAllCustomerReadPermission -> 200 CustomerDto[]
 *  - GET    /api/customers/{id:guid}            RequireCustomerReadPermission    -> 200 | 404 {error}
 *  - GET    /api/customers/by-mobile/{mobile}   RequireCustomerReadPermission    -> 200 | 404 {error}
 *  - GET    /api/customers/my-profile           RequireCustomerReadPermission    -> 200 | 404 | 401
 *  - POST   /api/customers/register             [AllowAnonymous]                 -> 201 result | 400 {errors}
 *  - POST   /api/customers                      RequireCustomerCreatePermission  -> 201 | 400 {errors}
 *  - PUT    /api/customers/{id:guid}            RequireCustomerUpdatePermission  -> 200 | 404
 *  - DELETE /api/customers/{id:guid}            RequireCustomerDeletePermission  -> 204 | 404
 *  CustomerRegistrationDto: CustomerFirstName, CustomerLastName, MobileNumber,
 *    Password, DateOfBirth, EmailId?, Gender?, Addresses?
 *  Admin holds AllCustomer* + Customer* permissions, so it is used for the
 *  privileged paths. NB: registering a fresh customer here is also the documented
 *  workaround for Finding F1 (seeded customer password drift).
 */

function uniqueCustomer() {
  const n = Date.now().toString().slice(-9) + Math.floor(Math.random() * 100);
  const mobile = `9${n.slice(0, 9)}`;
  return {
    customerFirstName: 'E2E',
    customerLastName: 'Customer',
    mobileNumber: mobile,
    password: 'E2eCust@123',
    emailId: `e2e_cust_${n}@example.com`,
    dateOfBirth: '1990-01-01T00:00:00Z',
    gender: 'Other',
  };
}

test.describe('Customers API', () => {
  test.describe('auth gating (401 without token)', () => {
    test('GET /api/customers', async ({ api }) => {
      expect((await api.get('/api/customers')).status()).toBe(401);
    });
    test('GET /api/customers/{id}', async ({ api }) => {
      expect((await api.get('/api/customers/00000000-0000-0000-0000-000000000000')).status()).toBe(401);
    });
    test('POST /api/customers', async ({ api }) => {
      expect((await api.post('/api/customers', { data: {} })).status()).toBe(401);
    });
    test('DELETE /api/customers/{id}', async ({ api }) => {
      expect((await api.delete('/api/customers/00000000-0000-0000-0000-000000000000')).status()).toBe(401);
    });
  });

  test('GET /api/customers (admin) returns a customer list', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.get('/api/customers');
    expect(res.status(), await res.text()).toBe(200);
    expect(Array.isArray(await res.json())).toBeTruthy();
  });

  test('GET /api/customers/{unknown guid} (admin) -> 404', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.get('/api/customers/11111111-1111-1111-1111-111111111111');
    expect(res.status()).toBe(404);
  });

  test('GET /api/customers/by-mobile/{unknown} (admin) -> 404', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    expect((await admin.get('/api/customers/by-mobile/0000000001')).status()).toBe(404);
  });

  test('GET /api/customers/my-profile (admin) is reachable & authorized (200 or 404)', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.get('/api/customers/my-profile');
    // admin is not a Customer entity -> typically 404; must NOT be 401/403/500.
    expect([200, 404]).toContain(res.status());
  });

  test.describe.serial('anonymous registration lifecycle', () => {
    const c = uniqueCustomer();
    let customerId: string | undefined;

    test('POST /api/customers/register (anon) creates a customer -> 201', async ({ api }) => {
      const res = await api.post('/api/customers/register', { data: c });
      expect(res.status(), await res.text()).toBe(201);
      const body = await res.json();
      const blob = JSON.stringify(body).toLowerCase();
      expect(blob).toContain(c.mobileNumber);
      // result shape: { success, customer:{ customerId,... }, errors }
      customerId = body?.customer?.customerId ?? body?.customerId;
      expect(customerId, 'registration response should expose the new customerId').toBeTruthy();
    });

    test('the new customer is retrievable by mobile (admin)', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.get(`/api/customers/by-mobile/${c.mobileNumber}`);
      expect(res.status()).toBe(200);
      const cust = await res.json();
      expect(cust.mobileNumber).toBe(c.mobileNumber);
    });

    test('the new customer is retrievable by id (admin)', async ({ apiAs }) => {
      test.skip(!customerId, 'no customerId from registration step');
      const admin = await apiAs('admin');
      const res = await admin.get(`/api/customers/${customerId}`);
      expect(res.status()).toBe(200);
      expect((await res.json()).customerId).toBe(customerId);
    });

    test('PUT /api/customers/{id} (admin) updates the customer', async ({ apiAs }) => {
      test.skip(!customerId, 'no customerId from registration step');
      const admin = await apiAs('admin');
      const res = await admin.put(`/api/customers/${customerId}`, {
        data: {
          customerFirstName: 'E2EUpdated',
          customerLastName: c.customerLastName,
          mobileNumber: c.mobileNumber,
          dateOfBirth: c.dateOfBirth,
          isActive: true,
        },
      });
      expect(res.status(), await res.text()).toBe(200);
      expect((await res.json()).customerFirstName).toBe('E2EUpdated');
    });

    test('duplicate registration with the same mobile -> 400', async ({ api }) => {
      const res = await api.post('/api/customers/register', { data: c });
      expect(res.status()).toBe(400);
    });

    // Finding F3: DELETE is a SOFT delete — returns 204 but the record remains
    // retrievable with isActive=false (it is NOT a hard delete / 404 afterwards).
    test('DELETE /api/customers/{id} (admin) -> 204 and soft-deletes (isActive=false)', async ({ apiAs }) => {
      test.skip(!customerId, 'no customerId from registration step');
      const admin = await apiAs('admin');
      expect((await admin.delete(`/api/customers/${customerId}`)).status()).toBe(204);
      const after = await admin.get(`/api/customers/${customerId}`);
      expect(after.status(), 'soft-delete: record still retrievable').toBe(200);
      expect((await after.json()).isActive, 'soft-deleted record should be inactive').toBe(false);
    });
  });
});
