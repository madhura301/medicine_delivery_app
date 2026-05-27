import { test, expect } from '../../fixtures/web.fixture';

/**
 * /support/assignments (plan §6.6).
 * Verified against WebApp/src/pages/support/OrderAssignmentPage.tsx:
 *  - Heading "Order Assignments"
 *  - 5 filter chips: All, Pending, Active, Completed, Rejected
 *  - Table columns when not empty: Order #, Date, Status, Actions
 *  - Status 0 or 8 rows get an "Assign to Chemist" CTA -> dialog with a
 *    Select labelled "Select Chemist"
 *
 * F-FRONTEND-4 blocks the table render; we therefore cover only the heading +
 * chip toggling here.
 */

const FILTERS = ['All', 'Pending', 'Active', 'Completed', 'Rejected'];

test.describe('WebApp — Support > Order Assignments', () => {
  test('renders heading and 5 filter chips', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('support', '/support/assignments');
    await expect(page.getByText('Order Assignments', { exact: true }).first()).toBeVisible({ timeout: 15000 });
    for (const f of FILTERS) {
      await expect(page.getByRole('button', { name: f, exact: true })).toBeVisible();
    }
  });

  test('clicking a filter chip marks it filled', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('support', '/support/assignments');
    const pending = page.getByRole('button', { name: 'Pending', exact: true });
    await pending.click();
    await expect(pending).toHaveClass(/MuiChip-filled/);
  });
});
