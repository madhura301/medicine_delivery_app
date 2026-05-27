import { test as base, expect, Page } from '@playwright/test';
import { config, credentials, RoleName } from '../helpers/config';

/**
 * WebApp fixtures (Phase 3). The WebApp keeps auth in localStorage
 * (`auth_token`); AuthStore.loadFromStorage() decodes it on construction. So we
 * authenticate fast & reliably by fetching a JWT from the API and seeding
 * localStorage via an init script BEFORE the SPA loads — no brittle UI login
 * for every test (login UI itself is covered explicitly in webapp/auth/login.spec.ts).
 */

async function apiToken(
  request: import('@playwright/test').APIRequestContext,
  role: RoleName,
): Promise<string> {
  const c = credentials[role];
  const res = await request.post(`${config.apiBaseUrl}/api/auth/login`, {
    data: { mobileNumber: c.mobileNumber, password: c.password, stayLoggedIn: false },
  });
  expect(res.ok(), `API login failed for ${role}: ${res.status()}`).toBeTruthy();
  const body = await res.json();
  expect(body.token, `no token for ${role}`).toBeTruthy();
  return body.token as string;
}

type WebFixtures = {
  /** Returns a JWT for a web role via the API (admin/manager/support/chemist). */
  webToken: (role: RoleName) => Promise<string>;
  /** Seeds the token into localStorage, then navigates to `path` already authed. */
  gotoAuthed: (role: RoleName, path: string) => Promise<Page>;
};

export const test = base.extend<WebFixtures>({
  webToken: async ({ request }, use) => {
    const cache = new Map<RoleName, string>();
    await use(async (role) => {
      if (!cache.has(role)) cache.set(role, await apiToken(request, role));
      return cache.get(role)!;
    });
  },

  gotoAuthed: async ({ context, page, webToken }, use) => {
    await use(async (role, path) => {
      const token = await webToken(role);
      await context.addInitScript((t) => {
        window.localStorage.setItem('auth_token', t as string);
      }, token);
      await page.goto(path);
      return page;
    });
  },
});

export { expect };
