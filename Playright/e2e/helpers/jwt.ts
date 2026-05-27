/** Minimal JWT payload decoder (no verification — for test assertions only). */
export function decodeJwt(token: string): Record<string, unknown> {
  const parts = token.split('.');
  if (parts.length < 2) throw new Error('Not a JWT');
  const payload = parts[1].replace(/-/g, '+').replace(/_/g, '/');
  const json = Buffer.from(payload, 'base64').toString('utf8');
  return JSON.parse(json);
}

/** Reads the role claim regardless of which claim key the backend used. */
export function roleFromToken(token: string): string | undefined {
  const p = decodeJwt(token);
  const keys = [
    'role',
    'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',
  ];
  for (const k of keys) {
    const v = p[k];
    if (typeof v === 'string') return v;
    if (Array.isArray(v) && v.length) return String(v[0]);
  }
  return undefined;
}
