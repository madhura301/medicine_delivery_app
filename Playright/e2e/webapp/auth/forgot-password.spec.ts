import { test, expect } from '../../fixtures/web.fixture';
import { credentials } from '../../helpers/config';

/**
 * /forgot-password (plan §6.2).
 * Verified against WebApp/src/pages/auth/ForgotPasswordPage.tsx:
 *  - Single MUI field "Mobile Number" (required)
 *  - Submit button "Send Reset OTP"
 *  - Success -> green Alert: "OTP sent! Check your mobile."
 *  - Error -> red Alert: "Failed to send reset link. Please try again."
 *  - Back link -> /login
 *
 * F-FRONTEND-2 (was logged in task.md): WebApp's authApi.forgotPassword used to
 * post `{ mobileNumber }` while the backend expects `{ phoneNumber }`, so every
 * submit 500'd. FIXED — authApi.ts now posts `{ phoneNumber: mobileNumber }` and
 * the endpoint returns 200 ("If this number is registered, an OTP has been sent.").
 * The UI shows the success Alert "OTP sent! Check your mobile." which this spec
 * now asserts. (OTP goes to the Console SMS log in dev — never a real SMS.)
 */

test.describe('WebApp — Forgot Password', () => {
  test('renders form fields', async ({ page }) => {
    await page.goto('/forgot-password');
    await expect(page.getByRole('heading', { name: /forgot password/i })).toBeVisible();
    await expect(page.getByLabel('Mobile Number')).toBeVisible();
    await expect(page.getByRole('button', { name: /send reset otp/i })).toBeVisible();
    await expect(page.getByRole('link', { name: /back to login/i })).toBeVisible();
  });

  test('empty submit blocked by required field (stays on /forgot-password)', async ({ page }) => {
    await page.goto('/forgot-password');
    await page.getByRole('button', { name: /send reset otp/i }).click();
    await expect(page).toHaveURL(/\/forgot-password/);
  });

  test('valid mobile shows success alert (OTP sent)', async ({ page }) => {
    await page.goto('/forgot-password');
    await page.getByLabel('Mobile Number').fill(credentials.admin.mobileNumber);
    await page.getByRole('button', { name: /send reset otp/i }).click();
    // F-FRONTEND-2 fixed: endpoint returns 200 and the success Alert is shown.
    await expect(page.getByText(/otp sent! check your mobile/i)).toBeVisible();
  });

  // Backend deliberately returns the same generic response for known & unknown
  // numbers (no account enumeration), so the UI shows the success alert for any
  // well-formed mobile — asserted above.

  test('"Back to Login" link returns to /login', async ({ page }) => {
    await page.goto('/forgot-password');
    await page.getByRole('link', { name: /back to login/i }).click();
    await expect(page).toHaveURL(/\/login/);
  });
});
