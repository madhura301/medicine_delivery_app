import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    loadComponent: () => import('./list/delivery-boys-list').then((m) => m.DeliveryBoysList),
    title: 'Delivery Boys · Pharmaish',
  },
];
