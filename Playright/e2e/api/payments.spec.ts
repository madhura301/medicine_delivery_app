import { test, expect } from '../fixtures/api.fixture';

/**
 * Covers PaymentsController (`/api/payments`). Plan §7.1 + §7.4.
 *
 * Contract (verified against PaymentsController.cs + RecordPaymentDto.cs):
 *  - class [Authorize]
 *  - POST /api/payments                       RequireOrderUpdatePermission -> 201 | 400(ModelState) | 404(KeyNotFound) | 400(Argument)
 *  - GET  /api/payments/order/{orderId:int}        RequireOrderReadPermission -> 200 PaymentDto[]
 *  - GET  /api/payments/order/{orderId:int}/total  RequireOrderReadPermission -> 200 { orderId, totalPaidAmount }
 *  RecordPaymentDto = { OrderId, PaymentMode, TransactionId, Amount, PaymentStatus(enum), ProviderReference? }
 *  The happy-path "record payment for a real order" is covered by the orders
 *  lifecycle spec (needs a created order). Here: gating + reads + unknown-order negatives.
 */

test.describe('Payments API', () => {
  test.describe('auth gating (401 without token)', () => {
    test('POST /api/payments', async ({ api }) => {
      expect((await api.post('/api/payments', { data: {} })).status()).toBe(401);
    });
    test('GET /api/payments/order/{id}', async ({ api }) => {
      expect((await api.get('/api/payments/order/1')).status()).toBe(401);
    });
    test('GET /api/payments/order/{id}/total', async ({ api }) => {
      expect((await api.get('/api/payments/order/1/total')).status()).toBe(401);
    });
  });

  test('GET /api/payments/order/{unknown} (admin) -> 200 empty list', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.get('/api/payments/order/99999999');
    expect(res.status(), await res.text()).toBe(200);
    expect(Array.isArray(await res.json())).toBeTruthy();
  });

  test('GET /api/payments/order/{unknown}/total (admin) -> 200 with totalPaidAmount', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.get('/api/payments/order/99999999/total');
    expect(res.status()).toBe(200);
    const body = await res.json();
    expect(body.orderId).toBe(99999999);
    expect(body).toHaveProperty('totalPaidAmount');
  });

  test('POST /api/payments for an unknown order (admin) -> 404', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.post('/api/payments', {
      data: {
        orderId: 99999999,
        paymentMode: 'UPI',
        transactionId: `E2E-${Date.now()}`,
        amount: 100.5,
        paymentStatus: 1, // Completed
      },
    });
    expect(res.status(), await res.text()).toBe(404);
  });
});
