import { DOC_BASE_URL, API_BASE_URL } from '../config/environment';
import api from '../api/axiosInstance';

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

/** Build the API path for downloading an order's input file (prescription image).
 *  Returns a relative path suitable for use with the axios instance. */
export function getOrderInputFileApiPath(orderId: string): string {
  return `Orders/${orderId}/download-input-file`;
}

/** Extract just the file name from a prescription file URL/path. */
export function extractFileName(fileUrl?: string | null): string {
  if (!fileUrl) return '';
  const normalized = fileUrl.replace(/\\/g, '/');
  return normalized.split('/').pop() ?? '';
}

/** Build the API path for downloading an order's bill file.
 *  Returns a relative path suitable for use with the axios instance. */
export function getOrderBillApiPath(orderId: string): string {
  return `Orders/${orderId}/download-bill`;
}

/** Download a file via the authenticated API and trigger a browser save. */
async function downloadAuthFile(apiPath: string, fileUrl: string | null | undefined, fallbackName: string): Promise<void> {
  const fileName = extractFileName(fileUrl) || fallbackName;

  const response = await api.get(apiPath, { responseType: 'blob' });
  const blobUrl = URL.createObjectURL(response.data);

  const link = document.createElement('a');
  link.href = blobUrl;
  link.download = fileName;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  URL.revokeObjectURL(blobUrl);
}

/** Download a prescription image via the authenticated API and trigger a browser save. */
export async function downloadPrescriptionImage(orderId: string, prescriptionFileUrl?: string | null): Promise<void> {
  return downloadAuthFile(getOrderInputFileApiPath(orderId), prescriptionFileUrl, `prescription_${orderId}.png`);
}

/** Download a bill file via the authenticated API and trigger a browser save. */
export async function downloadBillFile(orderId: string, billFileUrl?: string | null): Promise<void> {
  return downloadAuthFile(getOrderBillApiPath(orderId), billFileUrl, `bill_${orderId}.png`);
}
