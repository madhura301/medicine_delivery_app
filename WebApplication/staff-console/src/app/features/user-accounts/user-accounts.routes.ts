import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    loadComponent: () => import('./list/user-accounts-list').then((m) => m.UserAccountsList),
    title: 'User Accounts · Pharmaish',
  },
];
