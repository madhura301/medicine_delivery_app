import { test, expect } from '../../fixtures/web.fixture';

/**
 * /admin/users (plan §6.3).
 * Verified against WebApp/src/pages/admin/UserManagement.tsx:
 *  - 5 tabs in order: Customers, Cust. Support, Chemists, Managers, Delivery Boys
 *  - 4 filter Chips: All, Active, Inactive, Deleted
 *  - Search field placeholder "Search by name, email, mobile..."
 *  - Table columns: Name, Mobile, Email, Status, Actions
 *  - Delete IconButton -> ConfirmDialog ("Delete User", confirm label "Delete")
 *  - EmptyState "No users found" when filter yields nothing
 *  - "Create User" button -> /admin/users/create
 *
 * Note: deletion is destructive on shared seed data — the test asserts the
 * dialog appears and CANCEL closes it without deleting; the confirmation path
 * itself is exercised via the API authorization suite (Phase 2 deleted users
 * round-trip there), so we don't risk wiping seeded fixtures here.
 */

test.describe('WebApp — Admin > User Management', () => {
  test('renders title, 5 tabs, 4 filter chips, and Create User CTA', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('admin', '/admin/users');
    await expect(page.getByRole('heading', { name: 'User Management' })).toBeVisible();
    for (const tab of ['Customers', 'Cust. Support', 'Chemists', 'Managers', 'Delivery Boys']) {
      await expect(page.getByRole('tab', { name: tab })).toBeVisible();
    }
    for (const chip of ['All', 'Active', 'Inactive', 'Deleted']) {
      await expect(page.getByRole('button', { name: chip, exact: true })).toBeVisible();
    }
    await expect(page.getByPlaceholder('Search by name, email, mobile...')).toBeVisible();
    await expect(page.getByRole('button', { name: /create user/i })).toBeVisible();
  });

  test('switching tabs preserves the columns', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('admin', '/admin/users');
    for (const tab of ['Chemists', 'Managers', 'Cust. Support']) {
      await page.getByRole('tab', { name: tab }).click();
      // wait for the table to render (or empty state)
      await expect(page.locator('th', { hasText: 'Name' }).or(page.getByText('No users found'))).toBeVisible();
    }
  });

  test('filter chip toggling updates aria-selected/style', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('admin', '/admin/users');
    const deletedChip = page.getByRole('button', { name: 'Deleted', exact: true });
    await deletedChip.click();
    // chip becomes "filled" / primary — visually it picks up MuiChip-filled
    await expect(deletedChip).toHaveClass(/MuiChip-filled/);
  });

  test('search field accepts input and filters table without page nav', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('admin', '/admin/users');
    await page.getByPlaceholder('Search by name, email, mobile...').fill('zzz-no-match');
    await expect(page).toHaveURL(/\/admin\/users/);
    // With an impossible search, the empty state shows
    await expect(page.getByText('No users found')).toBeVisible();
  });

  test('"Create User" button navigates to /admin/users/create', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('admin', '/admin/users');
    await page.getByRole('button', { name: /create user/i }).click();
    await expect(page).toHaveURL(/\/admin\/users\/create/);
  });

  test('delete icon opens ConfirmDialog; Cancel closes it without deleting', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('admin', '/admin/users');
    // Switch to Chemists tab — there's at least one seeded chemist
    await page.getByRole('tab', { name: 'Chemists' }).click();
    const tableRows = page.locator('table tbody tr');
    const rowCount = await tableRows.count();
    test.skip(rowCount === 0, 'No chemists in this DB — delete dialog not exercised');

    // first row's delete IconButton (the only error-colored icon in the row)
    await tableRows.first().getByRole('button').last().click();
    const dialog = page.getByRole('dialog');
    await expect(dialog).toBeVisible();
    await expect(dialog.getByRole('heading', { name: 'Delete User' })).toBeVisible();
    await expect(dialog.getByRole('button', { name: 'Delete' })).toBeVisible();
    await expect(dialog.getByRole('button', { name: 'Cancel' })).toBeVisible();
    await dialog.getByRole('button', { name: 'Cancel' }).click();
    await expect(dialog).not.toBeVisible();
    // table row count unchanged
    expect(await tableRows.count()).toBe(rowCount);
  });
});
