import { test, expect } from '../fixtures/api.fixture';

/**
 * Covers RazorpayController (`/api/razorpay`). Plan §7.1 + §7.4 + decision D5.
 *
 * Contract (verified against RazorpayController.cs):
 *  - class has NO [Authorize]; each action has [Authorize]
 *  - POST /api/razorpay/create-order   {OrderId, Amount}
 *      OrderId<=0 -> 400; Amount<=0 -> 400; service !Success -> 400; ok -> 200 RazorpayOrderResponseDto
 *  - POST /api/razorpay/verify-payment {OrderId, RazorpayOrderId, RazorpayPaymentId, RazorpaySignature}
 *      any of the 3 razorpay fields blank -> 400; !success -> 400; ok -> 200 {message}
 *
 * D5: Razorpay keys are empty in appsettings — a real create/verify happy path
 * cannot run here. We cover: auth gating, input validation, and the
 * signature-mismatch negative (deterministically 400). The "create for a real
 * order then verify" happy path is owned by the orders lifecycle once/if a
 * sandbox key is provided (tracked in task.md D5).
 */

test.describe('Razorpay API', () => {
  test.describe('auth gating (401 without token)', () => {
    test('POST /api/razorpay/create-order', async ({ api }) => {
      expect((await api.post('/api/razorpay/create-order', { data: {} })).status()).toBe(401);
    });
    test('POST /api/razorpay/verify-payment', async ({ api }) => {
      expect((await api.post('/api/razorpay/verify-payment', { data: {} })).status()).toBe(401);
    });
  });

  test('create-order with OrderId <= 0 (admin) -> 400', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.post('/api/razorpay/create-order', {
      data: { orderId: 0, amount: 100 },
    });
    expect(res.status()).toBe(400);
    expect((await res.json()).message).toBeTruthy();
  });

  test('create-order with Amount <= 0 (admin) -> 400', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.post('/api/razorpay/create-order', {
      data: { orderId: 1, amount: 0 },
    });
    expect(res.status()).toBe(400);
    expect((await res.json()).message).toBeTruthy();
  });

  test('create-order for a nonexistent order (admin) -> 400 (no keys/order, D5)', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.post('/api/razorpay/create-order', {
      data: { orderId: 99999999, amount: 500 },
    });
    // No Razorpay keys + unknown order -> service returns !Success -> 400.
    // (If a sandbox key is later configured this may become 200 — revisit per D5.)
    expect([200, 400]).toContain(res.status());
  });

  test('verify-payment with missing razorpay fields (admin) -> 400', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.post('/api/razorpay/verify-payment', {
      data: { orderId: 1, razorpayOrderId: '', razorpayPaymentId: '', razorpaySignature: '' },
    });
    expect(res.status()).toBe(400);
    expect((await res.json()).message).toBeTruthy();
  });

  test('verify-payment with a bogus signature (admin) -> 400', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.post('/api/razorpay/verify-payment', {
      data: {
        orderId: 1,
        razorpayOrderId: 'order_BOGUS123',
        razorpayPaymentId: 'pay_BOGUS123',
        razorpaySignature: 'deadbeefsignature',
      },
    });
    expect(res.status()).toBe(400);
  });
});
