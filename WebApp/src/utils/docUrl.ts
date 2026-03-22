import { DOC_BASE_URL, API_BASE_URL } from '../config/environment';

/** Resolve a backend file path to a full URL */
export function resolveDocUrl(path?: string | null): string {
  if (!path) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  // Strip leading slash
  const clean = path.replace(/^\/+/, '');
  // Try documents base first, fallback to api base
  const base = DOC_BASE_URL || API_BASE_URL.replace('/api', '/documents');
  return `${base}/${clean}`;
}
