/**
 * Razorpay Standard Checkout for the web — the browser counterpart of the mobile app's
 * `razorpay_flutter` plugin. The script is loaded on first use rather than in index.html, so staff
 * never download it.
 */

const SCRIPT_URL = 'https://checkout.razorpay.com/v1/checkout.js';

export interface CheckoutSuccess {
  razorpay_payment_id: string;
  razorpay_order_id: string;
  razorpay_signature: string;
}

export interface CheckoutOptions {
  keyId: string;
  razorpayOrderId: string;
  /** In rupees — converted to paise here. */
  amount: number;
  description: string;
  prefill: { name?: string; contact?: string; email?: string };
}

/** Why checkout ended without a payment. */
export type CheckoutOutcome =
  | { kind: 'paid'; response: CheckoutSuccess }
  | { kind: 'dismissed' }
  | { kind: 'failed'; reason: string };

interface RazorpayInstance {
  open(): void;
  on(event: 'payment.failed', handler: (response: { error?: { description?: string } }) => void): void;
}

declare global {
  interface Window {
    Razorpay?: new (options: Record<string, unknown>) => RazorpayInstance;
  }
}

let loading: Promise<void> | null = null;

function loadScript(): Promise<void> {
  if (window.Razorpay) {
    return Promise.resolve();
  }
  loading ??= new Promise<void>((resolve, reject) => {
    const script = document.createElement('script');
    script.src = SCRIPT_URL;
    script.async = true;
    script.onload = () => resolve();
    script.onerror = () => {
      loading = null;
      reject(new Error('Could not load the payment window. Check your connection and try again.'));
    };
    document.head.appendChild(script);
  });
  return loading;
}

/** Opens checkout and resolves once the customer pays, closes the window, or the payment fails. */
export async function openCheckout(options: CheckoutOptions): Promise<CheckoutOutcome> {
  await loadScript();

  return new Promise<CheckoutOutcome>((resolve) => {
    let settled = false;
    const settle = (outcome: CheckoutOutcome) => {
      if (!settled) {
        settled = true;
        resolve(outcome);
      }
    };

    const instance = new window.Razorpay!({
      key: options.keyId,
      order_id: options.razorpayOrderId,
      amount: Math.round(options.amount * 100),
      currency: 'INR',
      name: 'Pharmaish',
      description: options.description,
      prefill: options.prefill,
      theme: { color: '#1f5fae' },
      handler: (response: CheckoutSuccess) => settle({ kind: 'paid', response }),
      modal: { ondismiss: () => settle({ kind: 'dismissed' }) },
    });

    instance.on('payment.failed', (response) =>
      settle({
        kind: 'failed',
        reason: response?.error?.description ?? 'The payment did not go through.',
      }),
    );

    instance.open();
  });
}
