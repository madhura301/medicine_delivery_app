import { test, expect } from '../../fixtures/web.fixture';

/**
 * /admin/orders/:id (plan §6.3).
 * Verified against WebApp/src/pages/admin/OrderDetailsPage.tsx:
 *  - Back button (returns via navigate(-1))
 *  - Status banner: "Order #...", date, StatusBadge
 *  - Mandatory panels: Order Information, Customer Details, Assignment History
 *  - Conditional panels: Chemist Details, Delivery Address, Prescription
 *    (with Download), Bill (with Download) — only render if data present
 *  - Unknown id -> Alert severity="error" "Order not found"
 *
 * F-FRONTEND-4 blocks the list-driven entry path (table never paints), so we
 * navigate directly with a probed real orderId. The id type itself is
 * number-from-API but the URL accepts any string; OrderDetailsPage calls
 * fetchOrderById(id) which posts whatever's in the URL.
 *
 * The bogus-id path is the most reliable assertion here today.
 */

test.describe('WebApp — Admin > Order Details', () => {
  test('unknown order id shows the "Order not found" alert', async ({ gotoAuthed }) => {
    const bogusId = '00000000-0000-0000-0000-000000000000';
    const page = await gotoAuthed('admin', `/admin/orders/${bogusId}`);
    await expect(page.getByText(/order not found/i)).toBeVisible({ timeout: 15000 });
  });

  // Real-id render path also blocked by F-FRONTEND-4: the response shape /
  // normalizeOrder call ultimately stalls the UI (loading spinner never
  // resolves) even when fetched directly. Flip when F-FRONTEND-4 is fixed.
  test.fixme('navigation to a real order id renders Order Information panel [F-FRONTEND-4]', async () => {});
});
