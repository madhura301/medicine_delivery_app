import { test as base, APIRequestContext, request as pwRequest, expect } from '@playwright/test';
import { config, credentials, RoleName } from '../helpers/config';

export interface AuthResponse {
  success: boolean;
  token?: string;
  refreshToken?: string;
  expiresAt?: string;
  role?: string;
  userId?: string;
  entityId?: string;
  errors?: string[];
}

/** POST /api/auth/login. Throws on non-2xx so callers fail loudly. */
export async function login(
  apiContext: APIRequestContext,
  mobileNumber: string,
  password: string,
  stayLoggedIn = false,
): Promise<AuthResponse> {
  const res = await apiContext.post('/api/auth/login', {
    data: { mobileNumber, password, stayLoggedIn },
  });
  expect(res.ok(), `login failed for ${mobileNumber}: ${res.status()} ${await res.text()}`).toBeTruthy();
  return (await res.json()) as AuthResponse;
}

type ApiFixtures = {
  /** Unauthenticated API context (baseURL = API). */
  api: APIRequestContext;
  /** Returns a JWT for the given seeded role. */
  loginAs: (role: RoleName) => Promise<string>;
  /** Returns an API context with Authorization: Bearer <token> for the role. */
  apiAs: (role: RoleName) => Promise<APIRequestContext>;
};

export const test = base.extend<ApiFixtures>({
  api: async ({ playwright }, use) => {
    const ctx = await playwright.request.newContext({ baseURL: config.apiBaseUrl });
    await use(ctx);
    await ctx.dispose();
  },

  loginAs: async ({ api }, use) => {
    const cache = new Map<RoleName, string>();
    await use(async (role: RoleName) => {
      if (cache.has(role)) return cache.get(role)!;
      const c = credentials[role];
      const auth = await login(api, c.mobileNumber, c.password);
      expect(auth.token, `no token in login response for ${role}`).toBeTruthy();
      cache.set(role, auth.token!);
      return auth.token!;
    });
  },

  apiAs: async ({ loginAs }, use) => {
    const created: APIRequestContext[] = [];
    await use(async (role: RoleName) => {
      const token = await loginAs(role);
      const ctx = await pwRequest.newContext({
        baseURL: config.apiBaseUrl,
        extraHTTPHeaders: { Authorization: `Bearer ${token}` },
      });
      created.push(ctx);
      return ctx;
    });
    for (const c of created) await c.dispose();
  },
});

export { expect };
