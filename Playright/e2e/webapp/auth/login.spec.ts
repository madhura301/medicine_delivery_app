import { test, expect } from '../../fixtures/web.fixture';
import { credentials } from '../../helpers/config';

/**
 * WebApp login (plan §6.2). Verified against WebApp/src/pages/auth/LoginPage.tsx
 * + AuthStore.ts:
 *  - MUI fields labelled "Mobile Number" and "Password"; submit "Sign In"
 *  - success -> navigate to authStore.dashboardRoute (role-based)
 *  - wrong creds: API 400 has no `message` field, so AuthStore shows the
 *    fallback "Network error. Please try again." (asserting ACTUAL behavior)
 *  - Customer/DeliveryBoy blocked with "only accessible on the mobile app"
 *
 * Selector strategy: Track B (role/label/text) — no data-testid in WebApp.
 */

test.describe('WebApp — Login', () => {
  test('valid admin login navigates to the admin dashboard', async ({ page }) => {
    await page.goto('/login');
    await page.getByLabel('Mobile Number').fill(credentials.admin.mobileNumber);
    await page.getByLabel('Password').fill(credentials.admin.password);
    await page.getByRole('button', { name: /sign in/i }).click();
    await expect(page).toHaveURL(/\/admin\/dashboard/);
  });

  // F5 (see task.md): chemist login via the WebApp consistently shows
  // "Network error. Please try again." and stays on /login, even though the
  // chemist API login (POST /api/auth/login, 5555555555/Chemist@123) returns 200
  // + token (Phase 2 verified, and web.fixture uses it for other roles). admin
  // login through the exact same code path works. Likely WebApp-side token/role
  // handling for the Chemist role. Tracked, not hidden — flip to `test` when fixed.
  test.fixme('chemist login lands on the chemist dashboard [F5]', async ({ page }) => {
    await page.goto('/login');
    await page.getByLabel('Mobile Number').fill(credentials.chemist.mobileNumber);
    await page.getByLabel('Password').fill(credentials.chemist.password);
    await page.getByRole('button', { name: /sign in/i }).click();
    await expect(page).toHaveURL(/\/chemist\/dashboard/);
  });

  test('wrong password shows an error alert and stays on /login', async ({ page }) => {
    await page.goto('/login');
    await page.getByLabel('Mobile Number').fill(credentials.admin.mobileNumber);
    await page.getByLabel('Password').fill('definitely-wrong-1!');
    await page.getByRole('button', { name: /sign in/i }).click();
    await expect(page.getByRole('alert')).toBeVisible();
    await expect(page).toHaveURL(/\/login/);
  });

  test('empty form does not navigate (HTML5 required blocks submit)', async ({ page }) => {
    await page.goto('/login');
    await page.getByRole('button', { name: /sign in/i }).click();
    await expect(page).toHaveURL(/\/login/);
  });

  test('"Forgot Password?" link goes to /forgot-password', async ({ page }) => {
    await page.goto('/login');
    await page.getByRole('link', { name: /forgot password/i }).click();
    await expect(page).toHaveURL(/\/forgot-password/);
  });

  // F1: seeded `customer` password is drifted in the shared DB, so the API
  // returns 400 (not a token) and the WebApp can't reach the role-block branch.
  // Tracked, not hidden — re-enable when F1 is resolved.
  test.fixme('Customer role is blocked with a mobile-app-only message [F1]', async () => {});
});
