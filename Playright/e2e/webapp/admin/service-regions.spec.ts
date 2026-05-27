import { test, expect } from '../../fixtures/web.fixture';

/**
 * /admin/regions (plan §6.3).
 * Verified against WebApp/src/pages/admin/ServiceRegionsPage.tsx:
 *  - Heading "Service Regions" + "Add Region" CTA
 *  - Search field placeholder "Search regions..."
 *  - 3 type chips: All Types, Customer Support, Delivery Boy
 *  - Create-region Dialog: title "Create Service Region", fields
 *    Region Name, City, Region Type select (Customer Support / Delivery Boy)
 *  - Manage-pincodes Dialog: title "Manage Pin Codes", add input + Add button
 *
 * F-FRONTEND-5 (logged in task.md): WebApp's regionsApi posts to
 * `/CustomerSupportRegions` but the actual API route is `/api/ServiceRegions`
 * (Phase 2 verified). So create/delete/add-pincode all 404 today. UI shell
 * (heading, chips, dialog open) works and is covered; the mutate round-trip
 * is `test.fixme` until the URL is corrected.
 *
 * F4 (Phase 2 backend nit, unrelated): duplicate pin code returns 500 not 400.
 */

test.describe('WebApp — Admin > Service Regions', () => {
  test('renders heading, CTA, search field, and 3 type chips', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('admin', '/admin/regions');
    await expect(page.getByRole('heading', { name: 'Service Regions' })).toBeVisible();
    await expect(page.getByRole('button', { name: /add region/i })).toBeVisible();
    await expect(page.getByPlaceholder('Search regions...')).toBeVisible();
    for (const chip of ['All Types', 'Customer Support', 'Delivery Boy']) {
      await expect(page.getByRole('button', { name: chip, exact: true })).toBeVisible();
    }
  });

  test('Add Region opens the create dialog with all expected fields', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('admin', '/admin/regions');
    await page.getByRole('button', { name: /add region/i }).click();
    const dialog = page.getByRole('dialog');
    await expect(dialog.getByRole('heading', { name: 'Create Service Region' })).toBeVisible();
    await expect(dialog.getByLabel('Region Name')).toBeVisible();
    await expect(dialog.getByLabel('City')).toBeVisible();
    // Region Type is rendered by MUI as a combobox (Select) — getByRole is reliable
    await expect(dialog.getByRole('combobox')).toBeVisible();
    await dialog.getByRole('button', { name: 'Cancel' }).click();
    await expect(dialog).not.toBeVisible();
  });

  test('type filter chip toggles to filled style', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('admin', '/admin/regions');
    const cs = page.getByRole('button', { name: 'Customer Support', exact: true });
    await cs.click();
    await expect(cs).toHaveClass(/MuiChip-filled/);
  });

  test.fixme('create -> manage pincode -> delete round-trip [F-FRONTEND-5]', async () => {});
});
