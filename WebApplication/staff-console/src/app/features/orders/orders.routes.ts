import { Routes } from '@angular/router';

/**
 * Six list routes share one component — the `slug` is bound to its input and drives the bucket,
 * the copy and the filtering. `:id` must come last so it does not swallow the slugs.
 */
const listSlugs = [
  'all',
  'awaiting-assignment',
  'with-chemist',
  'with-support',
  'with-manager',
  'with-delivery',
] as const;

const titles: Record<(typeof listSlugs)[number], string> = {
  all: 'All Orders',
  'awaiting-assignment': 'Awaiting Assignment',
  'with-chemist': 'With Chemist',
  'with-support': 'With Customer Support',
  'with-manager': 'With Manager',
  'with-delivery': 'Out for Delivery',
};

export const routes: Routes = [
  { path: '', pathMatch: 'full', redirectTo: 'all' },
  ...listSlugs.map((slug) => ({
    path: slug,
    loadComponent: () => import('./list/orders-list').then((m) => m.OrdersList),
    data: { slug },
    title: `${titles[slug]} · Pharmaish`,
  })),
  {
    path: ':id',
    loadComponent: () => import('./detail/order-detail').then((m) => m.OrderDetail),
    title: 'Order · Pharmaish',
  },
];
