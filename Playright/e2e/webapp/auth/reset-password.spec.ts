import { test, expect } from '../../fixtures/web.fixture';
import { credentials } from '../../helpers/config';

/**
 * /reset-password (plan §6.2).
 * Verified against WebApp/src/pages/auth/ResetPasswordPage.tsx:
 *  - Four MUI fields (Mobile Number, OTP, New Password, Confirm Password) — all required
 *  - Submit button "Reset Password"
 *  - newPassword !== confirmPassword -> client-side red Alert "Passwords do not match"
 *  - On API error -> red Alert "Reset failed. Check your OTP and try again."
 *  - Success -> navigate('/login')
 *
 * F-FRONTEND-1 (logged in task.md): WebApp's authApi.resetPassword POSTs to
 * `/Auth/reset-password` with `{ mobileNumber, otp, newPassword }`, but the
 * actual backend endpoint is `/Auth/verify-otp-reset-password` and the DTO is
 * `{ PhoneNumber, OtpCode, NewPassword, ConfirmPassword }`. So *every* reset
 * submission fails today — the spec asserts that observed behavior + the
 * client-side validation that does work.
 *
 * D2 deferred: OTP retrieval (Console SMS). The happy path that actually
 * resets a password remains test.fixme until D2 is resolved.
 *
 * Selector note: New Password / Confirm Password are <input type="password">,
 * which has no implicit role, so getByLabel is the most reliable locator
 * here. Use the bare string (it's already unique on this page) — the
 * `{ exact: true }` form interacts oddly with MUI's TextField label wiring.
 */

test.describe('WebApp — Reset Password', () => {
  test('renders all four fields and submit button', async ({ page }) => {
    await page.goto('/reset-password');
    await expect(page.getByRole('heading', { name: /reset password/i })).toBeVisible();
    await expect(page.getByLabel('Mobile Number')).toBeVisible();
    await expect(page.getByLabel('OTP')).toBeVisible();
    await expect(page.getByLabel('New Password')).toBeVisible();
    await expect(page.getByLabel('Confirm Password')).toBeVisible();
    await expect(page.getByRole('button', { name: /reset password/i })).toBeVisible();
  });

  test('mismatched passwords show client-side error and do not navigate', async ({ page }) => {
    await page.goto('/reset-password');
    await page.getByLabel('Mobile Number').fill(credentials.admin.mobileNumber);
    await page.getByLabel('OTP').fill('000000');
    await page.getByLabel('New Password').fill('Abcd@1234');
    await page.getByLabel('Confirm Password').fill('Different@1234');
    await page.getByRole('button', { name: /reset password/i }).click();
    await expect(page.getByText(/passwords do not match/i)).toBeVisible();
    await expect(page).toHaveURL(/\/reset-password/);
  });

  test('bad OTP shows the reset-failed alert [F-FRONTEND-1]', async ({ page }) => {
    await page.goto('/reset-password');
    await page.getByLabel('Mobile Number').fill(credentials.admin.mobileNumber);
    await page.getByLabel('OTP').fill('999999');
    await page.getByLabel('New Password').fill('NewerPwd@1');
    await page.getByLabel('Confirm Password').fill('NewerPwd@1');
    await page.getByRole('button', { name: /reset password/i }).click();
    // F-FRONTEND-1: until the URL/DTO mismatch is fixed every submission 404s
    // and we see the same fallback alert.
    await expect(page.getByText(/reset failed/i)).toBeVisible();
    await expect(page).toHaveURL(/\/reset-password/);
  });

  test('"Back to Login" link returns to /login', async ({ page }) => {
    await page.goto('/reset-password');
    await page.getByRole('link', { name: /back to login/i }).click();
    await expect(page).toHaveURL(/\/login/);
  });

  // D2 + F-FRONTEND-1: happy path (real OTP -> success -> /login) needs both
  // an OTP-retrieval helper and the authApi.resetPassword URL/DTO fixed.
  test.fixme('valid OTP resets password and redirects to /login [D2, F-FRONTEND-1]', async () => {});
});
