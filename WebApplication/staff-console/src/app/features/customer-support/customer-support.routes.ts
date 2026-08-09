import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    loadComponent: () => import('./list/customer-support-list').then((m) => m.CustomerSupportList),
    title: 'Customer Support · Pharmaish',
  },
  {
    path: ':id',
    loadComponent: () =>
      import('./detail/customer-support-detail').then((m) => m.CustomerSupportDetail),
    title: 'Support agent · Pharmaish',
  },
];
