import { test, expect } from '../fixtures/api.fixture';

/**
 * Covers OrdersController (`/api/orders`, 25 endpoints). Plan §7.1 + §7.2 + §7.4.
 *
 * Contract (verified against OrdersController.cs + Order DTOs + enums):
 *  - class [Authorize]; reads RequireOrderReadPermission, list RequireListAllOrdersPermission,
 *    create RequireOrderCreatePermission, mutations RequireOrderUpdatePermission
 *  - OrderType: NotSet=0, OTC=1, PrescriptionDrugs=2 ; OrderInputType: Image=0, Voice=1, Text=2
 *  - POST /api/orders is multipart/form-data [FromForm] CreateOrderDto
 *    {CustomerId*, CustomerAddressId*, OrderType*, OrderInputType*, OrderInputText?, OrderInputFile?}
 *  - GET /api/orders/delivery/my-orders reads int "UserId" claim -> 401 for admin (no int UserId)
 *
 * We use TEXT orders (OrderInputType=2 + OrderInputText) to avoid the Azure blob
 * path. The deep accept->bill->deliver->complete chain is state-machine + geo
 * dependent and `complete` needs the generated 4-char OTP which we cannot read
 * yet (decision D2) — those steps are flexible/`fixme` and tracked, NOT faked.
 */

const ZERO_GUID = '00000000-0000-0000-0000-000000000000';

function uniqueCustomer() {
  const n = Date.now().toString().slice(-9) + Math.floor(Math.random() * 100);
  return {
    customerFirstName: 'Ord',
    customerLastName: 'Buyer',
    mobileNumber: `9${n.slice(0, 9)}`,
    password: 'E2eOrd@123',
    emailId: `e2e_ord_${n}@example.com`,
    dateOfBirth: '1991-03-03T00:00:00Z',
  };
}

test.describe('Orders API', () => {
  test.describe('auth gating (401 without token)', () => {
    test('GET /api/orders', async ({ api }) => {
      expect((await api.get('/api/orders')).status()).toBe(401);
    });
    test('GET /api/orders/1', async ({ api }) => {
      expect((await api.get('/api/orders/1')).status()).toBe(401);
    });
    test('POST /api/orders (multipart)', async ({ api }) => {
      const res = await api.post('/api/orders', { multipart: { OrderType: '1' } });
      expect(res.status()).toBe(401);
    });
    test('PUT /api/orders/assign', async ({ api }) => {
      expect((await api.put('/api/orders/assign', { data: {} })).status()).toBe(401);
    });
    test('POST /api/orders/assign-to-delivery', async ({ api }) => {
      expect((await api.post('/api/orders/assign-to-delivery', { data: {} })).status()).toBe(401);
    });
  });

  test('GET /api/orders (admin, ListAllOrders) -> 200 array', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.get('/api/orders');
    expect(res.status(), await res.text()).toBe(200);
    expect(Array.isArray(await res.json())).toBeTruthy();
  });

  test('GET /api/orders/{unknown} (admin) -> 404', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    expect((await admin.get('/api/orders/99999999')).status()).toBe(404);
  });

  // Unknown store/CS guid -> service throws ArgumentException -> 400 (it does
  // NOT return an empty 200 list). Assert authorized + well-formed (200 or 400),
  // never 401/403/500.
  test('GET /api/orders/medicalstore/{guid}[/active|/accepted|/rejected] (admin) -> 200|400', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    for (const suffix of ['', '/active', '/accepted', '/rejected']) {
      const res = await admin.get(`/api/orders/medicalstore/${ZERO_GUID}${suffix}`);
      expect([200, 400], `medicalstore${suffix} -> ${res.status()}`).toContain(res.status());
    }
  });

  test('GET /api/orders/customersupport/{guid}[/assignedtocustomersupport] (admin) -> 200|400', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    for (const suffix of ['', '/assignedtocustomersupport']) {
      const res = await admin.get(`/api/orders/customersupport/${ZERO_GUID}${suffix}`);
      expect([200, 400]).toContain(res.status());
    }
  });

  test('GET /api/orders/delivery/my-orders as admin -> 401 (no int UserId claim)', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    expect((await admin.get('/api/orders/delivery/my-orders')).status()).toBe(401);
  });

  test('order-not-found negatives (admin)', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    expect((await admin.get('/api/orders/99999999/download-input-file')).status()).toBe(404);
    expect((await admin.get('/api/orders/99999999/download-bill')).status()).toBe(404);
    expect((await admin.get('/api/orders/99999999/medical-stores-by-city')).status()).toBe(404);
    expect((await admin.get('/api/orders/99999999/medical-stores-by-pincode')).status()).toBe(404);
    expect((await admin.get('/api/orders/99999999/eligible-delivery-boys')).status()).toBe(404);
    expect((await admin.get('/api/orders/nearby-chemists/NOPE-0000')).status()).toBe(404);
    expect((await admin.put('/api/orders/99999999/accept')).status()).toBe(404);
  });

  test('mutation negatives for unknown order (admin)', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    expect(
      (await admin.put('/api/orders/99999999/reject', { data: { rejectNote: 'n/a' } })).status(),
    ).toBe(404);
    expect(
      (await admin.put('/api/orders/99999999/complete', { data: { otp: '1234' } })).status(),
    ).toBe(404);
    // assign/assign-to-delivery validate args first -> ArgumentException(400)
    // may precede KeyNotFound(404); both are valid "rejected" outcomes.
    expect(
      [400, 404],
    ).toContain(
      (await admin.put('/api/orders/assign', { data: { orderId: 99999999, medicalStoreId: ZERO_GUID } })).status(),
    );
    expect(
      [400, 404],
    ).toContain(
      (await admin.post('/api/orders/assign-to-delivery', { data: { orderId: 99999999, deliveryId: 99999999 } })).status(),
    );
  });

  test('reject with invalid body (missing RejectNote) -> 400', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.put('/api/orders/1/reject', { data: {} });
    expect(res.status()).toBe(400);
  });

  test.describe.serial('create order -> read -> list -> payment -> razorpay', () => {
    const c = uniqueCustomer();
    let customerId: string;
    let addressId: string;
    let orderId: number;
    let orderNumber: string | undefined;

    test('setup: register customer + address', async ({ api, apiAs }) => {
      const reg = await api.post('/api/customers/register', { data: c });
      expect(reg.status(), await reg.text()).toBe(201);
      customerId = (await reg.json())?.customer?.customerId;
      expect(customerId).toBeTruthy();

      const admin = await apiAs('admin');
      const addr = await admin.post('/api/customeraddresses', {
        data: {
          customerId,
          addressLine1: '9 Order Street',
          city: 'Pune',
          state: 'Maharashtra',
          postalCode: '411001',
          latitude: 18.52,
          longitude: 73.85,
          isDefault: true,
        },
      });
      expect(addr.status(), await addr.text()).toBe(201);
      addressId = (await addr.json()).id;
      expect(addressId).toBeTruthy();
    });

    test('POST /api/orders (multipart, text order) -> 201', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.post('/api/orders', {
        multipart: {
          CustomerId: customerId,
          CustomerAddressId: addressId,
          OrderType: '1', // OTC
          OrderInputType: '2', // Text
          OrderInputText: 'E2E: 1x Paracetamol 500mg',
        },
      });
      expect(res.status(), await res.text()).toBe(201);
      const body = await res.json();
      orderId = body.orderId;
      orderNumber = body.orderNumber ?? undefined;
      expect(orderId).toBeGreaterThan(0);
      expect(body.customerId).toBe(customerId);
      expect(res.headers()['location']).toBeTruthy();
    });

    test('GET /api/orders/{orderId} (admin) -> 200 matches', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.get(`/api/orders/${orderId}`);
      expect(res.status()).toBe(200);
      const o = await res.json();
      expect(o.orderId).toBe(orderId);
      expect(o.orderInputText).toContain('Paracetamol');
    });

    test('the order appears in GET /api/orders and customer orders', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const all = (await (await admin.get('/api/orders')).json()) as Array<{ orderId: number }>;
      expect(all.some((o) => o.orderId === orderId)).toBeTruthy();
      const byCust = await admin.get(`/api/orders/customer/${customerId}`);
      expect(byCust.status()).toBe(200);
      expect(((await byCust.json()) as Array<{ orderId: number }>).some((o) => o.orderId === orderId)).toBeTruthy();
    });

    test('download-input-file for a text order -> 404 (no file, expected)', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      expect((await admin.get(`/api/orders/${orderId}/download-input-file`)).status()).toBe(404);
    });

    test('POST /api/payments for the real order -> 201 (PaymentsController happy path)', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.post('/api/payments', {
        data: {
          orderId,
          paymentMode: 'UPI',
          transactionId: `E2E-${Date.now()}`,
          amount: 250.0,
          paymentStatus: 1,
        },
      });
      expect(res.status(), await res.text()).toBe(201);

      const list = await admin.get(`/api/payments/order/${orderId}`);
      expect(list.status()).toBe(200);
      expect(((await list.json()) as unknown[]).length).toBeGreaterThanOrEqual(1);

      const total = await admin.get(`/api/payments/order/${orderId}/total`);
      expect(total.status()).toBe(200);
      expect(Number((await total.json()).totalPaidAmount)).toBeGreaterThanOrEqual(250);
    });

    test('razorpay create-order for the real order (D5: 200 or 400)', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.post('/api/razorpay/create-order', {
        data: { orderId, amount: 250 },
      });
      expect([200, 400]).toContain(res.status());
    });

    // F-D2: completing delivery needs the server-generated 4-char OTP which we
    // cannot read until decision D2 (OTP retrieval) is implemented. Tracked, not faked.
    test.fixme('PUT /api/orders/{id}/complete with real OTP [needs D2 OTP retrieval]', async () => {});
  });
});
