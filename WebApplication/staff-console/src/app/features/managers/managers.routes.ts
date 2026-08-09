import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    loadComponent: () => import('./list/managers-list').then((m) => m.ManagersList),
    title: 'Managers · Pharmaish',
  },
  {
    path: ':id',
    loadComponent: () => import('./detail/manager-detail').then((m) => m.ManagerDetail),
    title: 'Manager · Pharmaish',
  },
];
