import { test, expect } from '../../fixtures/web.fixture';

/**
 * /support/dashboard (plan §6.6).
 * Verified against WebApp/src/pages/support/SupportDashboard.tsx:
 *  - Welcome heading
 *  - 4 stat cards: Total Orders, Assigned to Support, Pending, Completed
 *  - Assigned-to-Support card + "Manage Order Assignments" quick action ->
 *    /support/assignments
 */

test.describe('WebApp — Support Dashboard', () => {
  test('renders welcome heading + 4 stat cards', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('support', '/support/dashboard');
    await expect(page.getByText(/welcome/i).first()).toBeVisible({ timeout: 15000 });
    for (const title of ['Total Orders', 'Assigned to Support', 'Pending', 'Completed']) {
      await expect(page.getByText(title, { exact: true })).toBeVisible();
    }
  });

  test('"Manage Order Assignments" navigates to /support/assignments', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('support', '/support/dashboard');
    await page.getByText('Manage Order Assignments', { exact: true }).click();
    await expect(page).toHaveURL(/\/support\/assignments/);
  });

  test('"Assigned to Support" stat card navigates to /support/assignments', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('support', '/support/dashboard');
    await expect(page.getByText('Assigned to Support', { exact: true })).toBeVisible({ timeout: 15000 });
    await page.getByText('Assigned to Support', { exact: true }).click();
    await expect(page).toHaveURL(/\/support\/assignments/);
  });
});
