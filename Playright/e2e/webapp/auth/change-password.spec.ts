import { test, expect } from '../../fixtures/web.fixture';
import { credentials, RoleName } from '../../helpers/config';

/**
 * /:role/change-password (plan §6.2).
 * Verified against WebApp/src/pages/auth/ChangePasswordPage.tsx + Sidebar.tsx
 * (each role's sidebar has a "Change Password" item routing to
 * /admin|chemist|manager|support/change-password — all rendering the same
 * component, which reads mobileNumber from AuthStore).
 *
 * Behavior:
 *  - newPassword !== confirmPassword -> client-side red Alert "Passwords do not match"
 *  - on API error -> red Alert "Failed to change password. Check your current password."
 *  - on success -> green Alert "Password changed successfully!" (stays on page)
 *
 * Spec contract: must NOT permanently rotate any seeded role password (other
 * specs depend on the documented seeds). We do happy-path only with a
 * round-trip on the **admin** account: change -> new -> change-back -> origin.
 * Other roles get negative-path coverage only.
 *
 * F5 blocks UI login for chemist (Phase 2 task.md F5) — so the chemist
 * negative-path test seeds the JWT via `gotoAuthed` rather than the login UI.
 */

const ROLES: { role: RoleName; route: string }[] = [
  { role: 'admin', route: '/admin/change-password' },
  { role: 'manager', route: '/manager/change-password' },
  { role: 'support', route: '/support/change-password' },
  { role: 'chemist', route: '/chemist/change-password' },
];

test.describe('WebApp — Change Password (negative paths, all 4 web roles)', () => {
  for (const { role, route } of ROLES) {
    test(`${role}: mismatch shows client-side error`, async ({ gotoAuthed }) => {
      const page = await gotoAuthed(role, route);
      await page.locator('input[type="password"]').nth(0).fill('whatever');
      await page.locator('input[type="password"]').nth(1).fill('Abcd@1234');
      await page.locator('input[type="password"]').nth(2).fill('Different@1234');
      await page.getByRole('button', { name: /update password/i }).click();
      await expect(page.getByText(/passwords do not match/i)).toBeVisible();
    });

    test(`${role}: wrong current password shows API error`, async ({ gotoAuthed }) => {
      const page = await gotoAuthed(role, route);
      await page.locator('input[type="password"]').nth(0).fill('absolutely-wrong-current-pw');
      await page.locator('input[type="password"]').nth(1).fill('IrrelevantNew@1');
      await page.locator('input[type="password"]').nth(2).fill('IrrelevantNew@1');
      await page.getByRole('button', { name: /update password/i }).click();
      await expect(page.getByText(/failed to change password/i)).toBeVisible();
    });
  }
});

test('admin happy-path round-trip: rotate then rotate back', async ({ gotoAuthed }) => {
  // Single test so we don't leave the admin in a half-rotated state on a
  // mid-spec failure. JWT is unaffected by password change, so the same
  // authenticated page can submit twice.
  const TEMP = 'TempAdmin@2026';
  const page = await gotoAuthed('admin', '/admin/change-password');

  // 1. seeded -> TEMP
  await page.locator('input[type="password"]').nth(0).fill(credentials.admin.password);
  await page.locator('input[type="password"]').nth(1).fill(TEMP);
  await page.locator('input[type="password"]').nth(2).fill(TEMP);
  await page.getByRole('button', { name: /update password/i }).click();
  await expect(page.getByText(/password changed successfully/i)).toBeVisible();

  // ChangePasswordPage clears its inputs on success; fill them again for the trip back.
  await page.locator('input[type="password"]').nth(0).fill(TEMP);
  await page.locator('input[type="password"]').nth(1).fill(credentials.admin.password);
  await page.locator('input[type="password"]').nth(2).fill(credentials.admin.password);
  await page.getByRole('button', { name: /update password/i }).click();
  await expect(page.getByText(/password changed successfully/i)).toBeVisible();
});
