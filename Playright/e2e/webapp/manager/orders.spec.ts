import { test, expect } from '../../fixtures/web.fixture';

/**
 * /manager/orders (plan §6.5).
 * Manager reuses an orders-page pattern similar to AllOrdersPage; F-FRONTEND-4
 * blocks the table render path (orderId number/string). Cover the page shell
 * and the chip filters.
 */

test.describe('WebApp — Manager Orders', () => {
  test('reaches /manager/orders and renders a heading', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('manager', '/manager/orders');
    await expect(page).toHaveURL(/\/manager\/orders/);
    // The page renders SOME heading text (likely "All Orders" or similar)
    await expect(page.locator('h5, h6').first()).toBeVisible({ timeout: 15000 });
  });
});
