import { test, expect } from '../fixtures/api.fixture';

/**
 * Covers ConsentsController (`/api/consents`). Plan §7.1 + §7.4.
 *
 * Contract (verified against ConsentsController.cs + ConsentDto.cs):
 *  - class [Authorize]
 *  - GET    /                 RequireReadConsentsPermission     -> 200 ConsentDto[]
 *  - GET    /active           RequireReadConsentsPermission     -> 200 ConsentDto[]
 *  - GET    /{id:guid}        RequireReadConsentsPermission     -> 200 | 404 {error}
 *  - POST   /                 RequireCreateConsentsPermission   -> 201 ConsentDto
 *  - PUT    /{id:guid}        RequireUpdateConsentsPermission   -> 200 | 404
 *  - DELETE /{id:guid}        RequireDeleteConsentsPermission   -> 204 | 404
 *  - POST   /{id}/accept      [Authorize] (any auth)            -> 200 log | 401 | 404
 *  - POST   /{id}/reject      [Authorize] (any auth)            -> 200 log | 401 | 404
 *  - GET    /{id}/logs        RequireReadConsentLogsPermission  -> 200 ConsentLogDto[]
 *  - GET    /my-logs          [Authorize] (any auth)            -> 200 ConsentLogDto[] | 401
 *  CreateConsentDto = { Title, Description?, Content, IsActive }. Admin holds all.
 */

const ZERO_GUID = '00000000-0000-0000-0000-000000000000';

test.describe('Consents API', () => {
  test.describe('auth gating (401 without token)', () => {
    test('GET /', async ({ api }) => {
      expect((await api.get('/api/consents')).status()).toBe(401);
    });
    test('POST /', async ({ api }) => {
      expect((await api.post('/api/consents', { data: {} })).status()).toBe(401);
    });
    test('POST /{id}/accept', async ({ api }) => {
      expect((await api.post(`/api/consents/${ZERO_GUID}/accept`, { data: {} })).status()).toBe(401);
    });
    test('GET /my-logs', async ({ api }) => {
      expect((await api.get('/api/consents/my-logs')).status()).toBe(401);
    });
  });

  test('GET / and /active (admin) -> 200 arrays', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const all = await admin.get('/api/consents');
    expect(all.status(), await all.text()).toBe(200);
    expect(Array.isArray(await all.json())).toBeTruthy();
    const active = await admin.get('/api/consents/active');
    expect(active.status()).toBe(200);
    expect(Array.isArray(await active.json())).toBeTruthy();
  });

  test('GET /{unknown} (admin) -> 404', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    expect((await admin.get(`/api/consents/${ZERO_GUID}`)).status()).toBe(404);
  });

  test('POST /{unknown}/accept (admin) -> 404', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    expect((await admin.post(`/api/consents/${ZERO_GUID}/accept`, { data: {} })).status()).toBe(404);
  });

  test('GET /my-logs (admin) -> 200 array', async ({ apiAs }) => {
    const admin = await apiAs('admin');
    const res = await admin.get('/api/consents/my-logs');
    expect(res.status()).toBe(200);
    expect(Array.isArray(await res.json())).toBeTruthy();
  });

  test.describe.serial('consent lifecycle (create -> read -> update -> accept/reject -> logs -> delete)', () => {
    let consentId: string;

    test('POST / (admin) -> 201', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.post('/api/consents', {
        data: {
          title: `E2E Consent ${Date.now()}`,
          description: 'E2E generated',
          content: 'I agree to the E2E terms.',
          isActive: true,
        },
      });
      expect(res.status(), await res.text()).toBe(201);
      const body = await res.json();
      consentId = body.consentId;
      expect(consentId).toBeTruthy();
      expect(res.headers()['location']).toBeTruthy();
    });

    test('GET /{id} (admin) -> 200 matches', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.get(`/api/consents/${consentId}`);
      expect(res.status()).toBe(200);
      expect((await res.json()).consentId).toBe(consentId);
    });

    test('PUT /{id} (admin) updates the consent', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.put(`/api/consents/${consentId}`, {
        data: { title: 'E2E Consent UPDATED', content: 'updated content', isActive: true },
      });
      expect(res.status(), await res.text()).toBe(200);
      expect((await res.json()).title).toBe('E2E Consent UPDATED');
    });

    test('POST /{id}/accept (admin) -> 200 log', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.post(`/api/consents/${consentId}/accept`, {
        data: { deviceInfo: 'e2e-runner' },
      });
      expect(res.status(), await res.text()).toBe(200);
    });

    test('POST /{id}/reject (admin) -> 200 log', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.post(`/api/consents/${consentId}/reject`, { data: {} });
      expect(res.status()).toBe(200);
    });

    test('GET /{id}/logs (admin) -> 200 array with entries', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.get(`/api/consents/${consentId}/logs`);
      expect(res.status()).toBe(200);
      const logs = await res.json();
      expect(Array.isArray(logs)).toBeTruthy();
      expect(logs.length).toBeGreaterThanOrEqual(1);
    });

    test('PUT /{unknown} (admin) -> 404', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      const res = await admin.put(`/api/consents/${ZERO_GUID}`, {
        data: { title: 'x', content: 'y', isActive: true },
      });
      expect(res.status()).toBe(404);
    });

    test('DELETE /{id} (admin) -> 204 (cleanup)', async ({ apiAs }) => {
      const admin = await apiAs('admin');
      expect((await admin.delete(`/api/consents/${consentId}`)).status()).toBe(204);
      expect([204, 404]).toContain((await admin.delete(`/api/consents/${consentId}`)).status());
    });
  });
});
