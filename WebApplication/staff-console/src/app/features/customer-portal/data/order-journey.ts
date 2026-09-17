import { HttpErrorResponse } from '@angular/common/http';
import { Order } from '../../../core/models/api.models';
import { OrderPaymentStatus, OrderStatus } from '../../../core/models/enums';

/**
 * The customer's view of an order.
 *
 * Internally an order moves through eleven statuses, several of which the customer should never
 * have to think about — being rejected by one chemist and handed to support is, to them, simply
 * "we're still finding a chemist". This folds the status machine into the six stages a customer
 * actually recognises.
 */
export const JOURNEY_STAGES = [
  { key: 'placed', label: 'Order placed', icon: 'receipt_long' },
  { key: 'accepted', label: 'Chemist accepted', icon: 'local_pharmacy' },
  { key: 'bill', label: 'Bill ready', icon: 'request_quote' },
  { key: 'paid', label: 'Paid', icon: 'payments' },
  { key: 'dispatched', label: 'Out for delivery', icon: 'local_shipping' },
  { key: 'delivered', label: 'Delivered', icon: 'task_alt' },
] as const;

export type JourneyTone = 'progress' | 'action' | 'done' | 'stopped';

export interface JourneyState {
  /** Index into JOURNEY_STAGES of the stage the order has reached. */
  stage: number;
  /** One short sentence, written to the customer. */
  headline: string;
  detail: string;
  tone: JourneyTone;
  cancelled: boolean;
}

export function journeyOf(order: Order): JourneyState {
  switch (order.orderStatus) {
    case OrderStatus.PendingPayment:
    case OrderStatus.AssignedToChemist:
      return {
        stage: 0,
        headline: 'Waiting for a chemist to accept',
        detail: 'Your prescription has been sent to a chemist near you.',
        tone: 'progress',
        cancelled: false,
      };
    case OrderStatus.RejectedByChemist:
    case OrderStatus.AssignedToCustomerSupport:
    case OrderStatus.AssignedToManager:
      return {
        stage: 0,
        headline: 'Finding you another chemist',
        detail:
          'The first chemist could not fulfil this order. Our team is placing it with another store — you do not need to do anything.',
        tone: 'progress',
        cancelled: false,
      };
    case OrderStatus.AcceptedByChemist:
      return {
        stage: 1,
        headline: 'The chemist is preparing your bill',
        detail: 'You will be able to pay as soon as the bill is uploaded.',
        tone: 'progress',
        cancelled: false,
      };
    case OrderStatus.BillUploaded:
      return {
        stage: 2,
        headline: isFullyPaid(order) ? 'Payment received' : 'Your bill is ready — pay to confirm',
        detail: isFullyPaid(order)
          ? 'The chemist will hand your order to a delivery partner shortly.'
          : 'Once you pay, the chemist sends your medicines out for delivery.',
        tone: isFullyPaid(order) ? 'progress' : 'action',
        cancelled: false,
      };
    case OrderStatus.Paid:
      return {
        stage: 3,
        headline: 'Paid — getting ready to dispatch',
        detail: 'A delivery partner will collect your order from the chemist.',
        tone: 'progress',
        cancelled: false,
      };
    case OrderStatus.OutForDelivery:
      return {
        stage: 4,
        headline: 'On its way to you',
        detail: 'Share your delivery code with the delivery partner when they arrive.',
        tone: 'action',
        cancelled: false,
      };
    case OrderStatus.Completed:
      return {
        stage: 5,
        headline: 'Delivered',
        detail: 'Your order has been delivered. Thank you for using Pharmaish.',
        tone: 'done',
        cancelled: false,
      };
    case OrderStatus.Cancelled:
    default:
      return {
        stage: 0,
        headline: 'Cancelled',
        detail: order.cancellationReason
          ? `Reason: ${order.cancellationReason}`
          : 'This order was cancelled.',
        tone: 'stopped',
        cancelled: true,
      };
  }
}

export function isFullyPaid(order: Order): boolean {
  return order.orderPaymentStatus === OrderPaymentStatus.FullyPaid;
}

/** The bill is up and has not been paid yet. */
export function isPayable(order: Order): boolean {
  return (
    order.orderStatus === OrderStatus.BillUploaded &&
    !isFullyPaid(order) &&
    (order.totalAmount ?? 0) > 0
  );
}

export function isActive(order: Order): boolean {
  return order.orderStatus !== OrderStatus.Completed && order.orderStatus !== OrderStatus.Cancelled;
}

/* ── Money ─────────────────────────────────────────────────────────────── */

/**
 * Payment breakdown, mirrored exactly from the mobile app's payment summary so a customer is
 * charged the same whichever app they pay from:
 *   gateway charges = 2% of the bill; GST = 18% of those charges; total = bill + both.
 */
export const GATEWAY_CHARGE_RATE = 0.02;
export const GST_ON_CHARGES_RATE = 0.18;

export interface PaymentBreakdown {
  bill: number;
  gatewayCharges: number;
  gst: number;
  /** gatewayCharges + gst — sent to the API as the convenience fee, as mobile does. */
  convenienceFee: number;
  total: number;
}

export function paymentBreakdown(billAmount: number): PaymentBreakdown {
  const bill = round2(billAmount);
  const gatewayCharges = round2(bill * GATEWAY_CHARGE_RATE);
  const gst = round2(gatewayCharges * GST_ON_CHARGES_RATE);
  const convenienceFee = round2(gatewayCharges + gst);
  return { bill, gatewayCharges, gst, convenienceFee, total: round2(bill + convenienceFee) };
}

function round2(value: number): number {
  return Math.round(value * 100) / 100;
}

const INR = new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR' });

export function rupees(value: number | null | undefined): string {
  return value === null || value === undefined ? '—' : INR.format(value);
}

/* ── Errors ────────────────────────────────────────────────────────────── */

/**
 * Turns a refused order into something a customer can act on. The most common refusal is that
 * nobody serves their area yet, and the raw message ("No chemist, customer support available
 * for pincode 411041") is written for staff.
 */
export function describePlaceOrderError(error: HttpErrorResponse): { title: string; message: string } {
  const body = error.error as { error?: string; missingRoles?: string[]; postalCode?: string } | null;

  if (error.status === 400 && body?.missingRoles?.length) {
    const pin = body.postalCode ? ` ${body.postalCode}` : '';
    return {
      title: `We don't deliver to${pin} yet`,
      message:
        'Pharmaish is not available at this address right now. Try a different delivery address, or check back soon — we are adding new areas.',
    };
  }

  if (error.status === 0) {
    return {
      title: 'You appear to be offline',
      message: 'Check your internet connection and try again. Your order has not been placed.',
    };
  }

  const text = body?.error ?? (typeof error.error === 'string' ? error.error : null);
  return {
    title: 'Your order could not be placed',
    message: text ?? 'Something went wrong on our side. Please try again in a moment.',
  };
}
