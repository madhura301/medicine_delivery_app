import { test, expect } from '../../fixtures/web.fixture';

/**
 * /admin/dashboard (plan §6.3).
 * Verified against WebApp/src/pages/admin/AdminDashboard.tsx + StatCard.tsx +
 * Sidebar.tsx:
 *  - 4 stat cards: Total Users, Total Orders, Active Chemists, Pending Orders
 *    (numeric values, rendered as h4)
 *  - Stat cards with onClick (Total Users, Total Orders, Pending Orders) navigate
 *    to /admin/users or /admin/orders. Active Chemists has no onClick.
 *  - Welcome heading with firstName
 *  - 4 Quick Action buttons: Manage Users, View Orders, Service Regions, Consent Logs
 *    -> /admin/users, /admin/orders, /admin/regions, /admin/consent-logs
 */

test.describe('WebApp — Admin Dashboard', () => {
  test('renders welcome heading + 4 stat cards with numeric values', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('admin', '/admin/dashboard');
    await expect(page.getByRole('heading', { name: /welcome back/i })).toBeVisible();

    for (const title of ['Total Users', 'Total Orders', 'Active Chemists', 'Pending Orders']) {
      const label = page.getByText(title, { exact: true });
      await expect(label).toBeVisible();
      // value is in the same MUI Card; assert it's a non-empty number string
      const card = label.locator('xpath=ancestor::*[contains(@class,"MuiCard-root")][1]');
      const value = await card.getByRole('heading', { level: 4 }).innerText();
      expect(value.trim()).toMatch(/^\d+$/);
    }
  });

  test('Total Users stat card navigates to /admin/users', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('admin', '/admin/dashboard');
    await page.getByText('Total Users', { exact: true }).click();
    await expect(page).toHaveURL(/\/admin\/users/);
  });

  test('Total Orders stat card navigates to /admin/orders', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('admin', '/admin/dashboard');
    await page.getByText('Total Orders', { exact: true }).click();
    await expect(page).toHaveURL(/\/admin\/orders/);
  });

  for (const { label, url } of [
    { label: 'Manage Users', url: /\/admin\/users/ },
    { label: 'View Orders', url: /\/admin\/orders/ },
    { label: 'Service Regions', url: /\/admin\/regions/ },
    { label: 'Consent Logs', url: /\/admin\/consent-logs/ },
  ]) {
    test(`Quick Action "${label}" navigates to its route`, async ({ gotoAuthed }) => {
      const page = await gotoAuthed('admin', '/admin/dashboard');
      await page.getByText(label, { exact: true }).click();
      await expect(page).toHaveURL(url);
    });
  }
});
