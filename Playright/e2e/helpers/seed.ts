import { config } from './config';

/**
 * Seeds roles, permissions, role-permission mappings and the 6 test users via the
 * Backend's [AllowAnonymous] /api/setup/* endpoints. Idempotent-tolerant: a non-2xx
 * usually means "already seeded" — we log and continue rather than fail the run.
 */
const SETUP_STEPS: string[] = [
  '/api/setup/roles/predefined',
  '/api/setup/permissions/predefined',
  '/api/setup/role-permissions/predefined',
  '/api/setup/users/admin/firstuser',
  '/api/setup/users/admin',
  '/api/setup/users/manager',
  '/api/setup/users/customer-support',
  '/api/setup/users/customer',
  '/api/setup/users/chemist',
];

export async function waitForApi(timeoutMs = 120_000): Promise<void> {
  const deadline = Date.now() + timeoutMs;
  const url = `${config.apiBaseUrl}/swagger/index.html`;
  let lastErr: unknown;
  while (Date.now() < deadline) {
    try {
      const res = await fetch(url);
      if (res.ok || res.status === 301 || res.status === 302) return;
    } catch (e) {
      lastErr = e;
    }
    await new Promise((r) => setTimeout(r, 2000));
  }
  throw new Error(`API not reachable at ${config.apiBaseUrl} within ${timeoutMs}ms: ${lastErr}`);
}

export async function seed(): Promise<void> {
  for (const step of SETUP_STEPS) {
    const url = `${config.apiBaseUrl}${step}`;
    try {
      const res = await fetch(url, { method: 'POST' });
      const ok = res.status >= 200 && res.status < 300;
      // eslint-disable-next-line no-console
      console.log(`[seed] POST ${step} -> ${res.status}${ok ? '' : ' (continuing; likely already seeded)'}`);
    } catch (e) {
      // eslint-disable-next-line no-console
      console.warn(`[seed] POST ${step} failed: ${e} (continuing)`);
    }
  }
}
