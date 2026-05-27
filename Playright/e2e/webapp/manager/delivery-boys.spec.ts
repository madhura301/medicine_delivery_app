import { test, expect } from '../../fixtures/web.fixture';

/**
 * /manager/delivery-boys (plan §6.5).
 * Verified against WebApp/src/pages/manager/DeliveryBoysPage.tsx:
 *  - Heading "Delivery Boys"
 *  - Either: a table with columns Name, Mobile, Driving License, Status
 *  - Or: empty state "No delivery boys found"
 */

test.describe('WebApp — Manager > Delivery Boys', () => {
  test('renders heading and either the table OR the empty state', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('manager', '/manager/delivery-boys');
    await expect(page.getByText('Delivery Boys', { exact: true }).first()).toBeVisible({ timeout: 15000 });

    const head = page.locator('table thead th').first();
    const empty = page.getByText('No delivery boys found');
    await expect(head.or(empty)).toBeVisible({ timeout: 15000 });

    if (await head.isVisible().catch(() => false)) {
      for (const col of ['Name', 'Mobile', 'Driving License', 'Status']) {
        await expect(page.locator('th', { hasText: col })).toBeVisible();
      }
    }
  });
});
