import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    loadComponent: () => import('./list/customers-list').then((m) => m.CustomersList),
    title: 'Customers · Pharmaish',
  },
  {
    path: ':id',
    loadComponent: () => import('./detail/customer-detail').then((m) => m.CustomerDetail),
    title: 'Customer · Pharmaish',
  },
];
