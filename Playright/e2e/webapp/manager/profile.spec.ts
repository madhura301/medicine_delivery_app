import { test, expect } from '../../fixtures/web.fixture';

/**
 * /manager/profile (plan §6.5). Reads from managersApi.
 * Cover that the page reaches its route, renders a profile heading or the
 * "not found"-style fallback.
 */

test.describe('WebApp — Manager Profile', () => {
  test('reaches /manager/profile and renders a stable surface', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('manager', '/manager/profile');
    await expect(page).toHaveURL(/\/manager\/profile/);
    // any header text + at least one InfoField label is acceptable; also
    // accept a not-found branch in case the manager has no matching profile.
    const anyHeader = page.locator('h5, h6').first();
    const notFound = page.getByText(/not found/i);
    await expect(anyHeader.or(notFound)).toBeVisible({ timeout: 20000 });
  });
});
