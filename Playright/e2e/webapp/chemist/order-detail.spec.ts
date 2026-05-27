import { test, expect } from '../../fixtures/web.fixture';

/**
 * /chemist/orders/:id (plan §6.4).
 * Verified against WebApp/src/pages/chemist/ChemistOrderDetailPage.tsx (read
 * inline since no separate notes file — same shape as admin OrderDetailsPage
 * with chemist-specific actions).
 *
 * F-FRONTEND-4 (orderId type quirks) blocks the by-id detail render today —
 * same root cause as the admin order details. Cover the unknown-id branch
 * and the back-nav surface only.
 */

test.describe('WebApp — Chemist Order Detail', () => {
  test('unknown order id renders an error or empty state without crashing', async ({ gotoAuthed }) => {
    const bogus = '00000000-0000-0000-0000-000000000000';
    const page = await gotoAuthed('chemist', `/chemist/orders/${bogus}`);
    // At minimum the page should reach a "not found"-style state. Accept either
    // the dedicated alert or the back button being visible.
    const notFound = page.getByText(/not found/i);
    const backBtn = page.getByRole('button', { name: /^back$/i });
    await expect(notFound.or(backBtn)).toBeVisible({ timeout: 15000 });
  });
});
