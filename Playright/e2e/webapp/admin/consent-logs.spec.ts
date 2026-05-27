import { test, expect } from '../../fixtures/web.fixture';

/**
 * /admin/consent-logs (plan §6.3).
 * Verified against WebApp/src/pages/admin/ConsentLogsPage.tsx:
 *  - Heading "Consent Logs"
 *  - Either: a table with columns User ID, User Type, Action, IP Address,
 *    Device, Date — OR an empty state "No consent logs found"
 *  - Action column shows a Chip labeled "Accepted" (green) or "Rejected" (red)
 *
 * On a fresh DB with no consents, the empty state shows. With seeded consent
 * activity, the table renders. The spec accepts either.
 */

test.describe('WebApp — Admin > Consent Logs', () => {
  test('renders heading and either the table OR the empty state', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('admin', '/admin/consent-logs');
    await expect(page.getByRole('heading', { name: 'Consent Logs' })).toBeVisible();

    const tableHead = page.locator('table thead th').first();
    const empty = page.getByText('No consent logs found');
    await expect(tableHead.or(empty)).toBeVisible({ timeout: 15000 });

    const tableVisible = await tableHead.isVisible().catch(() => false);
    if (tableVisible) {
      for (const col of ['User ID', 'User Type', 'Action', 'IP Address', 'Device', 'Date']) {
        await expect(page.locator('th', { hasText: col })).toBeVisible();
      }
    }
  });
});
