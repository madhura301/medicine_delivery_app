import { test, expect } from '../../fixtures/web.fixture';
import { credentials } from '../../helpers/config';

/**
 * Logout (plan §6.2).
 * Verified against WebApp/src/layouts/Sidebar.tsx (Logout button calls
 * authStore.logout() then navigate('/login')) + AuthStore.logout() +
 * storage.clearAll().
 *  - Logout button is the last item in the sidebar with text "Logout"
 *  - Clicking it clears `auth_token`, `refresh_token`, and every `user_*` key
 *  - Browser navigates to /login
 *  - Re-navigating to a protected route after logout redirects to /login
 *
 * Note on fixtures: `gotoAuthed` uses `addInitScript` to inject the token,
 * which re-runs on every navigation. So the post-logout "now visit a
 * protected route" test must do a real UI login on a fresh context — that's
 * exercised in the second test below.
 */

test.describe('WebApp — Logout', () => {
  test('admin logout clears localStorage and redirects to /login', async ({ gotoAuthed, page }) => {
    await gotoAuthed('admin', '/admin/dashboard');
    await expect(page).toHaveURL(/\/admin\/dashboard/);

    await page.getByRole('button', { name: /^logout$/i }).click();
    await expect(page).toHaveURL(/\/login/);

    const tokenAfter = await page.evaluate(() => window.localStorage.getItem('auth_token'));
    expect(tokenAfter).toBeNull();
    const refreshAfter = await page.evaluate(() => window.localStorage.getItem('refresh_token'));
    expect(refreshAfter).toBeNull();
    const userKeysAfter = await page.evaluate(() => {
      const keys: string[] = [];
      for (let i = 0; i < window.localStorage.length; i++) {
        const k = window.localStorage.key(i);
        if (k?.startsWith('user_')) keys.push(k);
      }
      return keys;
    });
    expect(userKeysAfter).toEqual([]);
  });

  test('after logout, visiting a protected route redirects to /login', async ({ browser }) => {
    const ctx = await browser.newContext({ baseURL: 'http://localhost:5173' });
    const p = await ctx.newPage();
    await p.goto('/login');
    await p.getByLabel('Mobile Number').fill(credentials.admin.mobileNumber);
    await p.getByLabel('Password').fill(credentials.admin.password);
    await p.getByRole('button', { name: /sign in/i }).click();
    await expect(p).toHaveURL(/\/admin\/dashboard/);

    await p.getByRole('button', { name: /^logout$/i }).click();
    await expect(p).toHaveURL(/\/login/);

    await p.goto('/admin/dashboard');
    await expect(p).toHaveURL(/\/login/);
    await ctx.close();
  });
});
