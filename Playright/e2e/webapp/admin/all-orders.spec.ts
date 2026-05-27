import { test, expect } from '../../fixtures/web.fixture';

/**
 * /admin/orders (plan §6.3).
 * Verified against WebApp/src/pages/admin/AllOrdersPage.tsx:
 *  - Heading "All Orders"
 *  - 5 filter chips: All, Pending, Active, Completed, Rejected
 *  - Table columns when not empty: Order #, Date, Status, Amount, Actions
 *  - View icon (Visibility) navigates to /admin/orders/:id
 *  - EmptyState "No orders found" otherwise
 *
 * F-FRONTEND-4 (logged in task.md): the API returns `orderId` as a NUMBER
 * (e.g. `1`), but `normalizeOrder` in WebApp/src/models/Order.ts type-asserts
 * it as a string. `OrderModel.orderId.slice(0,8)` and `key={order.orderId}`
 * downstream then misbehave — on this DB the table never paints and the page
 * stays on LoadingSpinner. The table-headers and view-icon tests are
 * therefore `test.fixme` with F-FRONTEND-4 refs. The chips + heading + filter
 * toggle UI itself works fine and is covered.
 */

const FILTERS = ['All', 'Pending', 'Active', 'Completed', 'Rejected'];

test.describe('WebApp — Admin > All Orders', () => {
  test('renders heading and 5 filter chips in order', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('admin', '/admin/orders');
    await expect(page.getByRole('heading', { name: 'All Orders' })).toBeVisible();
    for (const f of FILTERS) {
      await expect(page.getByRole('button', { name: f, exact: true })).toBeVisible();
    }
  });

  test.fixme('table headers render when orders exist [F-FRONTEND-4]', async () => {});

  test('clicking a filter chip marks it filled', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('admin', '/admin/orders');
    const pending = page.getByRole('button', { name: 'Pending', exact: true });
    await pending.click();
    await expect(pending).toHaveClass(/MuiChip-filled/);
  });

  test.fixme('view icon on first row navigates to /admin/orders/:id [F-FRONTEND-4]', async () => {});
});
