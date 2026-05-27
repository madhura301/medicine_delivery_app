import { test, expect } from '../../fixtures/web.fixture';

/**
 * /manager/dashboard (plan §6.5).
 * Verified against WebApp/src/pages/manager/ManagerDashboard.tsx:
 *  - Welcome heading + today's date subtitle
 *  - 4 stat cards: Total Orders, Pending Orders, In Delivery, Completed Today
 *  - Quick Action: "View All Orders" -> /manager/orders, "Delivery Boys" -> /manager/delivery-boys
 *
 * Same F-FRONTEND-4 caveat as the admin dashboard — counts come from
 * orderStore.orders.length and filtered counters, which render even if
 * downstream table rows have type issues.
 */

test.describe('WebApp — Manager Dashboard', () => {
  test('renders welcome heading and 4 stat cards', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('manager', '/manager/dashboard');
    await expect(page.getByText(/welcome back/i)).toBeVisible({ timeout: 15000 });
    for (const title of ['Total Orders', 'Pending Orders', 'In Delivery', 'Completed Today']) {
      await expect(page.getByText(title, { exact: true })).toBeVisible();
    }
  });

  test('Total Orders stat card navigates to /manager/orders', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('manager', '/manager/dashboard');
    await expect(page.getByText('Total Orders', { exact: true })).toBeVisible({ timeout: 15000 });
    await page.getByText('Total Orders', { exact: true }).click();
    await expect(page).toHaveURL(/\/manager\/orders/);
  });

  test('"View All Orders" quick action navigates correctly', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('manager', '/manager/dashboard');
    await page.getByText('View All Orders', { exact: true }).click();
    await expect(page).toHaveURL(/\/manager\/orders/);
  });

  test('"Delivery Boys" quick action navigates correctly', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('manager', '/manager/dashboard');
    await page.getByText('Delivery Boys', { exact: true }).first().click();
    await expect(page).toHaveURL(/\/manager\/delivery-boys/);
  });
});
