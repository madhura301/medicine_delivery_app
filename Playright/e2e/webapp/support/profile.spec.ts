import { test, expect } from '../../fixtures/web.fixture';

/**
 * /support/profile (plan §6.6). Reads from customerSupportsApi.
 * Assert page renders a header or not-found fallback.
 */

test.describe('WebApp — Support Profile', () => {
  test('reaches /support/profile and renders a stable surface', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('support', '/support/profile');
    await expect(page).toHaveURL(/\/support\/profile/);
    const header = page.locator('h5, h6').first();
    const notFound = page.getByText(/not found/i);
    await expect(header.or(notFound)).toBeVisible({ timeout: 20000 });
  });
});
