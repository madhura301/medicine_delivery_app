import { test, expect } from '../../fixtures/web.fixture';

/**
 * Session handling (plan §6.2).
 * Verified against axiosInstance.ts:
 *  - Response interceptor on 401 -> storage.clearAll() + window.location='/login'
 * And AuthStore.loadFromStorage() / RoleGuard.tsx:
 *  - A token with an unrecognized/missing role -> AuthStore.role stays null ->
 *    !isAuthenticated -> RoleGuard sends user to /login
 *  - A completely malformed token -> decodeToken throws -> storage cleared
 *    in the catch -> /login
 *
 * No real protected-route XHR is guaranteed to fire on every page, so this
 * spec drives the visible auth-state branches directly rather than depending
 * on a specific API call.
 */

test.describe('WebApp — Session', () => {
  test('malformed token in localStorage is cleared and user is sent to /login', async ({ context, page }) => {
    await context.addInitScript(() => {
      window.localStorage.setItem('auth_token', 'this-is-not-a-jwt');
    });
    await page.goto('/admin/dashboard');
    await expect(page).toHaveURL(/\/login/);
    const token = await page.evaluate(() => window.localStorage.getItem('auth_token'));
    expect(token).toBeNull();
  });

  test('no token at all -> protected route redirects to /login', async ({ page }) => {
    await page.goto('/admin/dashboard');
    await expect(page).toHaveURL(/\/login/);
  });

  test('expired JWT decodes but RoleGuard treats role-less token as unauth', async ({ context, page }) => {
    // A structurally valid but expired/empty-payload token. AuthStore.loadFromStorage
    // calls decodeToken; if the role claim is missing, AuthStore.role stays null,
    // !isAuthenticated is true, and RoleGuard sends to /login.
    const fakeJwt = [
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
      Buffer.from(JSON.stringify({ exp: 1 })).toString('base64url'),
      'sig',
    ].join('.');
    await context.addInitScript((t) => {
      window.localStorage.setItem('auth_token', t as string);
    }, fakeJwt);
    await page.goto('/admin/dashboard');
    await expect(page).toHaveURL(/\/login/);
  });
});
