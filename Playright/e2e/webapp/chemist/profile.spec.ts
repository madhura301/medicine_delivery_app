import { test, expect } from '../../fixtures/web.fixture';

/**
 * /chemist/profile (plan §6.4).
 * Verified against WebApp/src/pages/chemist/ChemistProfilePage.tsx:
 *  - Heading "Pharmacy Profile"
 *  - Fetches medicalStoresApi.getAll() and finds the row matching authStore.userId
 *  - If found: shows medical store name + InfoField rows (Owner, Mobile,
 *    Email, City, DL No, GSTIN, FSSAI, PAN) + Active/Inactive chip
 *  - If not found: "Profile not found." text
 *
 * The seeded chemist's userId may or may not match a medical store row in the
 * shared DB (depends on prior seed runs). Accept either branch.
 */

test.describe('WebApp — Chemist Profile', () => {
  test('reaches a stable state — heading, "Profile not found", or loading -> resolved', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('chemist', '/chemist/profile');
    // Accept any post-load surface: heading text (via locator, not role —
    // MUI Typography variant mapping varies and can drop the heading role),
    // the "Profile not found" branch, or the page reaching /chemist/profile.
    await expect(page).toHaveURL(/\/chemist\/profile/);
    const heading = page.getByText('Pharmacy Profile', { exact: true });
    const notFound = page.getByText('Profile not found.');
    const owner = page.getByText('Owner', { exact: true });
    await expect(heading.or(notFound).or(owner)).toBeVisible({ timeout: 20000 });
  });
});
