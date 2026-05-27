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
 * F-FRONTEND-2 (logged in task.md): WebApp's authApi.forgotPassword posts
 * `{ mobileNumber }`, but backend `SendOtpRequestDto` expects `{ PhoneNumber }`.
 * So PhoneNumber arrives null, AuthService.SendOtpAsync throws, and the
 * endpoint returns 500. Every UI submit therefore shows the
 * "Failed to send reset link" alert — that's what the spec asserts today.
 * Flip the assertion to the success path once the WebApp DTO is fixed.
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

  test('valid mobile shows failed-to-send alert today [F-FRONTEND-2]', async ({ page }) => {
    await page.goto('/forgot-password');
    await page.getByLabel('Mobile Number').fill(credentials.admin.mobileNumber);
    await page.getByRole('button', { name: /send reset otp/i }).click();
    // F-FRONTEND-2: DTO field-name mismatch -> backend 500 -> alert.
    await expect(page.getByText(/failed to send reset link/i)).toBeVisible();
    await expect(page).toHaveURL(/\/forgot-password/);
  });

  // Until F-FRONTEND-2 is fixed there is no observable difference between known
  // vs unknown mobile from the UI — every submit shows the same error alert.
  test.fixme('known mobile shows success alert (post-fix)', async () => {});

  test('"Back to Login" link returns to /login', async ({ page }) => {
    await page.goto('/forgot-password');
    await page.getByRole('link', { name: /back to login/i }).click();
    await expect(page).toHaveURL(/\/login/);
  });
});
