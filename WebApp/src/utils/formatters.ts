import { format, parseISO } from 'date-fns';

export function formatDate(dateStr?: string | null): string {
  if (!dateStr) return '—';
  try {
    return format(parseISO(dateStr), 'dd MMM yyyy');
  } catch {
    return dateStr;
  }
}

export function formatDateTime(dateStr?: string | null): string {
  if (!dateStr) return '—';
  try {
    return format(parseISO(dateStr), 'dd MMM yyyy, hh:mm a');
  } catch {
    return dateStr;
  }
}

export function formatCurrency(amount?: number | null): string {
  if (amount === undefined || amount === null) return '₹0.00';
  return `₹${amount.toFixed(2)}`;
}
