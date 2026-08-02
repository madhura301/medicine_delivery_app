import { Order } from '../../../core/models/api.models';
import { AssignTo, OrderPaymentStatus, OrderStatus } from '../../../core/models/enums';
import { ChipTone } from '../../../shared/ui/status-chip';

/**
 * The five order sub-menus map one-to-one onto the `AssignTo` enum.
 *
 * Always bucket by `assignTo`. The id fields (`medicalStoreId`, `customerSupportId`, `managerId`,
 * `deliveryId`) persist after a hand-off, so an order can carry a delivery id while it sits in a
 * completely different bucket — inferring from "which id is set" puts one order in three places.
 */
export type OrderBucket = 'all' | AssignTo;

export interface BucketDefinition {
  /** Route segment under /orders. */
  slug: string;
  bucket: OrderBucket;
  title: string;
  subtitle: string;
  icon: string;
  emptyTitle: string;
  emptyMessage: string;
}

export const BUCKETS: readonly BucketDefinition[] = [
  {
    slug: 'all',
    bucket: 'all',
    title: 'All Orders',
    subtitle: 'Every order in the system, whoever currently owns it.',
    icon: 'list_alt',
    emptyTitle: 'No orders yet',
    emptyMessage: 'Orders placed in the mobile app appear here.',
  },
  {
    slug: 'awaiting-assignment',
    bucket: AssignTo.Customer,
    title: 'Awaiting Assignment',
    subtitle: 'Not with a chemist, support agent, manager or delivery partner — still with the customer.',
    icon: 'hourglass_empty',
    emptyTitle: 'Nothing awaiting assignment',
    emptyMessage: 'Every order has been routed to someone.',
  },
  {
    slug: 'with-chemist',
    bucket: AssignTo.Chemist,
    title: 'With Chemist',
    subtitle: 'Assigned to a medical store to accept, bill and dispatch.',
    icon: 'local_pharmacy',
    emptyTitle: 'No orders with a chemist',
    emptyMessage: 'Nothing is currently sitting with a medical store.',
  },
  {
    slug: 'with-support',
    bucket: AssignTo.CustomerSupport,
    title: 'With Customer Support',
    subtitle: 'Rejected by a chemist and routed to a support agent to place with another store.',
    icon: 'support_agent',
    emptyTitle: 'No orders with support',
    emptyMessage: 'No rejected orders are waiting on a support agent.',
  },
  {
    slug: 'with-manager',
    bucket: AssignTo.Manager,
    title: 'With Manager',
    subtitle: 'Escalated because no support agent covers the delivery pin code.',
    icon: 'escalator_warning',
    emptyTitle: 'No escalations',
    emptyMessage: 'Nothing has been escalated to a manager.',
  },
  {
    slug: 'with-delivery',
    bucket: AssignTo.Delivery,
    title: 'Out for Delivery',
    subtitle: 'Handed to a delivery partner to take to the customer.',
    icon: 'local_shipping',
    emptyTitle: 'Nothing out for delivery',
    emptyMessage: 'No orders are with a delivery partner right now.',
  },
];

export function bucketBySlug(slug: string): BucketDefinition {
  return BUCKETS.find((b) => b.slug === slug) ?? BUCKETS[0];
}

export function bucketLabel(assignTo: AssignTo): string {
  return BUCKETS.find((b) => b.bucket === assignTo)?.title ?? 'Unknown';
}

export function bucketTone(assignTo: AssignTo): ChipTone {
  switch (assignTo) {
    case AssignTo.Customer:
      return 'warning';
    case AssignTo.Chemist:
      return 'info';
    case AssignTo.CustomerSupport:
      return 'warning';
    case AssignTo.Manager:
      return 'danger';
    case AssignTo.Delivery:
      return 'positive';
    default:
      return 'neutral';
  }
}

/** Who currently holds the order, resolved to a display name. */
export function currentOwner(order: Order): string {
  switch (order.assignTo) {
    case AssignTo.Chemist:
      return order.medicalStoreName || 'Chemist';
    case AssignTo.CustomerSupport:
      return order.customerSupportName || 'Support agent';
    case AssignTo.Manager:
      return order.managerName || 'Manager';
    case AssignTo.Delivery:
      return order.deliveryBoyName || 'Delivery partner';
    case AssignTo.Customer:
      return 'Unassigned';
    default:
      return '—';
  }
}

export function statusTone(status: OrderStatus): ChipTone {
  switch (status) {
    case OrderStatus.Completed:
    case OrderStatus.Paid:
      return 'positive';
    case OrderStatus.Cancelled:
    case OrderStatus.RejectedByChemist:
      return 'danger';
    case OrderStatus.PendingPayment:
    case OrderStatus.AssignedToCustomerSupport:
    case OrderStatus.AssignedToManager:
      return 'warning';
    default:
      return 'info';
  }
}

export function paymentTone(status: OrderPaymentStatus): ChipTone {
  switch (status) {
    case OrderPaymentStatus.FullyPaid:
      return 'positive';
    case OrderPaymentStatus.PartiallyPaid:
      return 'warning';
    default:
      return 'neutral';
  }
}

export function formatAmount(value: number | null): string {
  return value === null || value === undefined ? '—' : `₹${value.toFixed(2)}`;
}
