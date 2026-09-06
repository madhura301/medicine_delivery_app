import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    loadComponent: () => import('./list/order-logs-list').then((m) => m.OrderLogsList),
    title: 'Order Log · Pharmaish',
  },
  {
    path: ':id',
    loadComponent: () => import('./detail/order-log-detail').then((m) => m.OrderLogDetail),
    title: 'Order Log · Pharmaish',
  },
];
