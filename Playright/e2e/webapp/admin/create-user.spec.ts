import { test, expect } from '../../fixtures/web.fixture';

/**
 * /admin/users/create (plan §6.3).
 * Verified against WebApp/src/pages/admin/CreateUserPage.tsx.
 *  - Step 1 (no role selected): 5 role cards (Customer, Customer Support,
 *    Chemist / Medical Store, Manager, Delivery Boy)
 *  - Step 2 (role picked): MUI form with Mobile Number, Email, First Name,
 *    Last Name, Password — plus role-specific extras:
 *      - Chemist: Medical Store Name, Drug License No, GSTIN
 *      - DeliveryBoy: Driving License Number
 *  - "Change" button returns to step 1
 *  - "Cancel" navigates to /admin/users
 *
 * Submit happy path is **test.fixme**:
 *  - F2 (Phase 2): UsersController create endpoints throw 500 on the cast.
 *  - F-FRONTEND-3 (logged here): WebApp's usersApi.create POSTs the
 *    CreateUserWithRoleDto-shaped body to `/Users`, but `POST /api/users`
 *    expects CreateUserDto. So the form submission cannot succeed today
 *    even if F2 were fixed. Flip to `test` once both are resolved.
 */

const ROLE_CARDS = [
  'Customer',
  'Customer Support',
  'Chemist / Medical Store',
  'Manager',
  'Delivery Boy',
];

test.describe('WebApp — Admin > Create User', () => {
  test('step 1: renders 5 role-picker cards', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('admin', '/admin/users/create');
    await expect(page.getByRole('heading', { name: 'Create New User' })).toBeVisible();
    for (const role of ROLE_CARDS) {
      await expect(page.getByText(role, { exact: true })).toBeVisible();
    }
  });

  test('Customer card transitions to the common form (no role-specific extras)', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('admin', '/admin/users/create');
    await page.getByText('Customer', { exact: true }).click();
    for (const label of ['Mobile Number', 'Email', 'First Name', 'Last Name']) {
      await expect(page.getByLabel(label)).toBeVisible();
    }
    // Password is type="password" -> no implicit role; locate by label hint
    await expect(page.locator('input[type="password"]')).toBeVisible();
    // No chemist/delivery-only fields
    await expect(page.getByLabel('Medical Store Name')).toHaveCount(0);
    await expect(page.getByLabel('Driving License Number')).toHaveCount(0);
  });

  test('Chemist / Medical Store transition shows the 3 extra fields', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('admin', '/admin/users/create');
    await page.getByText('Chemist / Medical Store', { exact: true }).click();
    for (const label of ['Medical Store Name', 'Drug License No', 'GSTIN']) {
      await expect(page.getByLabel(label)).toBeVisible();
    }
  });

  test('Delivery Boy transition shows the Driving License Number field', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('admin', '/admin/users/create');
    await page.getByText('Delivery Boy', { exact: true }).click();
    await expect(page.getByLabel('Driving License Number')).toBeVisible();
  });

  test('Change button returns to step 1', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('admin', '/admin/users/create');
    await page.getByText('Manager', { exact: true }).click();
    await expect(page.getByLabel('Mobile Number')).toBeVisible();
    await page.getByRole('button', { name: 'Change', exact: true }).click();
    // back to role picker
    await expect(page.getByText('Customer', { exact: true })).toBeVisible();
  });

  test('Cancel button navigates back to /admin/users', async ({ gotoAuthed }) => {
    const page = await gotoAuthed('admin', '/admin/users/create');
    await page.getByText('Manager', { exact: true }).click();
    await page.getByRole('button', { name: /^cancel$/i }).click();
    await expect(page).toHaveURL(/\/admin\/users(?!\/create)/);
  });

  // F2 + F-FRONTEND-3: submitting the form cannot succeed today.
  test.fixme('happy path: Customer create -> success alert -> redirect [F2, F-FRONTEND-3]', async () => {});
});
