import { test, expect } from '../../fixtures/web.fixture';

/**
 * /chemist/dashboard (plan §6.4).
 * Verified against WebApp/src/pages/chemist/ChemistDashboard.tsx:
 *  - Welcome heading
 *  - 4 stat cards: Pending, Accepted, Completed, Rejected
 *  - Recent Pending Orders section header (preview of up to 5)
 *
 * F5 (Phase 2 task.md): Chemist UI login is broken — every spec here
 * therefore uses `gotoAuthed` (API-issued JWT seeded into localStorage)
 * rather than the login form. This keeps coverage despite F5.
 *
 * F-FRONTEND-4 (orderId number/string) affects chemist orders too, but
 * dashboard counts come from chemistStore.orderCounts which sums per-status
 * arrays — these still render even if individual order rows have type quirks.
 */

test.describe('WebApp — Chemist Dashboard', () => {
  test('renders welcome heading + 4 stat cards', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('chemist', '/chemist/dashboard');
    await expect(page.getByRole('heading', { name: /welcome/i })).toBeVisible({ timeout: 15000 });
    for (const title of ['Pending', 'Accepted', 'Completed', 'Rejected']) {
      await expect(page.getByText(title, { exact: true })).toBeVisible();
    }
    await expect(page.getByRole('heading', { name: /recent pending orders/i })).toBeVisible();
  });

  test('Pending stat card navigates to /chemist/orders', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('chemist', '/chemist/dashboard');
    // Wait for cards to render
    await expect(page.getByText('Pending', { exact: true })).toBeVisible({ timeout: 15000 });
    await page.getByText('Pending', { exact: true }).click();
    await expect(page).toHaveURL(/\/chemist\/orders/);
  });
});
