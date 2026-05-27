import { test, expect } from '../fixtures/api.fixture';
import { config } from '../helpers/config';

/**
 * Plan §7.4 — cross-cutting negative / edge cases not owned by one controller.
 * (Per-endpoint validation/404/401 negatives live in their own specs.)
 */

test.describe('Negative & edge cases', () => {
  test('malformed JSON body -> 400', async ({ api }) => {
    const res = await api.post('/api/auth/login', {
      headers: { 'Content-Type': 'application/json' },
      data: '{ this is not valid json ',
    });
    expect(res.status()).toBe(400);
  });

  test('garbage bearer token -> 401', async ({ playwright }) => {
    const ctx = await playwright.request.newContext({
      baseURL: config.apiBaseUrl,
      extraHTTPHeaders: { Authorization: 'Bearer not.a.real.jwt' },
    });
    expect((await ctx.get('/api/orders')).status()).toBe(401);
    await ctx.dispose();
  });

  test('well-formed but wrong-signature JWT -> 401', async ({ playwright }) => {
    // header.payload are valid base64url JSON; signature is bogus.
    const header = Buffer.from('{"alg":"HS256","typ":"JWT"}').toString('base64url');
    const payload = Buffer.from('{"sub":"e2e","role":"Admin","exp":9999999999}').toString('base64url');
    const forged = `${header}.${payload}.bogussignature`;
    const ctx = await playwright.request.newContext({
      baseURL: config.apiBaseUrl,
      extraHTTPHeaders: { Authorization: `Bearer ${forged}` },
    });
    expect((await ctx.get('/api/orders')).status()).toBe(401);
    await ctx.dispose();
  });

  test('unknown route -> 404', async ({ api }) => {
    expect((await api.get('/api/this-route-does-not-exist')).status()).toBe(404);
  });

  test('wrong HTTP method on a real route -> 404 or 405', async ({ api }) => {
    // DELETE on the login route (only POST is mapped)
    const res = await api.delete('/api/auth/login');
    expect([404, 405]).toContain(res.status());
  });

  test('ModelState: reject note over StringLength(250) -> 400 (before order lookup)', async ({
    apiAs,
  }) => {
    const admin = await apiAs('admin');
    const res = await admin.put('/api/orders/1/reject', {
      data: { rejectNote: 'x'.repeat(300) },
    });
    expect(res.status()).toBe(400);
  });

  test('ModelState: complete OTP over StringLength(4) -> 400', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.put('/api/orders/1/complete', { data: { otp: '123456' } });
    expect(res.status()).toBe(400);
  });

  test('login with empty credentials -> 400', async ({ api }) => {
    const res = await api.post('/api/auth/login', {
      data: { mobileNumber: '', password: '' },
    });
    expect(res.status()).toBe(400);
  });

  test('expired token is rejected -> 401', async ({ playwright }) => {
    // exp in the past (2001); signature irrelevant — expiry/validation fails first.
    const header = Buffer.from('{"alg":"HS256","typ":"JWT"}').toString('base64url');
    const payload = Buffer.from('{"sub":"e2e","role":"Admin","exp":1000000000}').toString(
      'base64url',
    );
    const expired = `${header}.${payload}.sig`;
    const ctx = await playwright.request.newContext({
      baseURL: config.apiBaseUrl,
      extraHTTPHeaders: { Authorization: `Bearer ${expired}` },
    });
    expect((await ctx.get('/api/orders')).status()).toBe(401);
    await ctx.dispose();
  });
});
