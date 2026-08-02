/**
 * Saves a blob fetched through HttpClient. Order files sit behind an authenticated endpoint, so
 * they cannot simply be linked to — the bearer token has to be on the request.
 */
export function saveBlob(blob: Blob, fileName: string): void {
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement('a');
  anchor.href = url;
  anchor.download = fileName;
  document.body.appendChild(anchor);
  anchor.click();
  anchor.remove();
  // Revoke on the next tick so the download has started before the URL disappears.
  setTimeout(() => URL.revokeObjectURL(url), 0);
}

/** Best-effort extension from the stored file path, so downloads keep a sensible name. */
export function extensionFrom(path: string | null, fallback = 'bin'): string {
  if (!path) {
    return fallback;
  }
  const match = /\.([a-z0-9]+)(?:\?|$)/i.exec(path);
  return match ? match[1].toLowerCase() : fallback;
}
