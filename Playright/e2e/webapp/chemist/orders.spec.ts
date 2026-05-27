import { test, expect } from '../../fixtures/web.fixture';

/**
 * /chemist/orders (plan §6.4).
 * Verified against WebApp/src/pages/chemist/ChemistOrdersPage.tsx:
 *  - Heading "My Orders"
 *  - 4 tabs: Pending, Accepted, Completed, Rejected
 *  - Each tab either shows a table (Order # / Customer / Date / Status / Actions)
 *    or the empty state "No <tab> orders"
 *  - Pending row Actions: Accept (success) and Reject -> dialog (reason
 *    required)
 *  - Accepted rows with status=3 expose an "Upload Bill" CTA -> dialog with
 *    amount + file input (image/* or .pdf)
 *
 * Mutating Accept/Reject/UploadBill is not exercised here (it would mutate
 * shared seed orders); Phase 2 already covers those endpoints. UI dialog
 * surface + tab navigation are covered.
 */

const TABS = ['Pending', 'Accepted', 'Completed', 'Rejected'];

test.describe('WebApp — Chemist Orders', () => {
  test('renders heading and 4 tabs', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('chemist', '/chemist/orders');
    await expect(page.getByRole('heading', { name: 'My Orders' })).toBeVisible();
    for (const tab of TABS) {
      await expect(page.getByRole('tab', { name: tab })).toBeVisible();
    }
  });

  test('each tab shows either a table or an empty state', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('chemist', '/chemist/orders');
    for (const tab of TABS) {
      await page.getByRole('tab', { name: tab }).click();
      const header = page.locator('table thead th').first();
      const empty = page.getByText(`No ${tab.toLowerCase()} orders`);
      await expect(header.or(empty)).toBeVisible({ timeout: 15000 });
    }
  });

  test('Reject dialog opens with required reason (when Pending row present)', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('chemist', '/chemist/orders');
    await page.getByRole('tab', { name: 'Pending' }).click();
    const rejectButtons = page.getByRole('button', { name: /^reject$/i });
    const count = await rejectButtons.count();
    test.skip(count === 0, 'No pending orders for this chemist — Reject dialog not exercised');

    await rejectButtons.first().click();
    const dialog = page.getByRole('dialog');
    await expect(dialog.getByRole('heading', { name: 'Reject Order' })).toBeVisible();
    await expect(dialog.getByLabel(/reason for rejection/i)).toBeVisible();
    const confirm = dialog.getByRole('button', { name: 'Reject', exact: true });
    await expect(confirm).toBeDisabled();
    await dialog.getByLabel(/reason for rejection/i).fill('test reason');
    await expect(confirm).toBeEnabled();
    await dialog.getByRole('button', { name: 'Cancel' }).click();
    await expect(dialog).not.toBeVisible();
  });

  test('Upload Bill dialog opens with amount + file input (when status=3 row present)', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('chemist', '/chemist/orders');
    await page.getByRole('tab', { name: 'Accepted' }).click();
    const uploadButtons = page.getByRole('button', { name: /upload bill/i });
    const count = await uploadButtons.count();
    test.skip(count === 0, 'No status-3 accepted orders — Upload Bill not exercised');

    await uploadButtons.first().click();
    const dialog = page.getByRole('dialog');
    await expect(dialog.getByRole('heading', { name: 'Upload Bill' })).toBeVisible();
    await expect(dialog.getByLabel(/total amount/i)).toBeVisible();
    await expect(dialog.getByRole('button', { name: /choose bill file/i })).toBeVisible();
    await dialog.getByRole('button', { name: 'Cancel' }).click();
    await expect(dialog).not.toBeVisible();
  });
});
