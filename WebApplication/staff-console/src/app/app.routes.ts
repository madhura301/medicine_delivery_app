import { Routes } from '@angular/router';
import { authGuard, guestGuard, roleGuard } from './core/auth/auth.guards';

export const routes: Routes = [
  {
    path: 'login',
    canActivate: [guestGuard],
    loadComponent: () => import('./features/auth/login').then((m) => m.Login),
    title: 'Sign in · Pharmaish',
  },
  {
    path: 'forgot-password',
    canActivate: [guestGuard],
    loadComponent: () => import('./features/auth/forgot-password').then((m) => m.ForgotPassword),
    title: 'Forgot password · Pharmaish',
  },
  {
    path: 'reset-password',
    canActivate: [guestGuard],
    loadComponent: () => import('./features/auth/reset-password').then((m) => m.ResetPassword),
    title: 'Reset password · Pharmaish',
  },
  {
    path: '',
    canActivate: [authGuard],
    loadComponent: () => import('./layout/shell').then((m) => m.Shell),
    children: [
      { path: '', pathMatch: 'full', redirectTo: 'dashboard' },
      {
        path: 'dashboard',
        loadComponent: () => import('./features/dashboard/dashboard').then((m) => m.Dashboard),
        title: 'Dashboard · Pharmaish',
      },
      {
        path: 'change-password',
        loadComponent: () => import('./features/auth/change-password').then((m) => m.ChangePassword),
        title: 'Change password · Pharmaish',
      },
      {
        path: 'managers',
        canActivate: [roleGuard('Admin', 'Manager')],
        loadChildren: () => import('./features/managers/managers.routes').then((m) => m.routes),
      },
      {
        path: 'customer-support',
        loadChildren: () =>
          import('./features/customer-support/customer-support.routes').then((m) => m.routes),
      },
      {
        path: 'delivery-boys',
        canActivate: [roleGuard('Admin', 'Manager')],
        loadChildren: () =>
          import('./features/delivery-boys/delivery-boys.routes').then((m) => m.routes),
      },
      {
        path: 'chemists',
        loadChildren: () => import('./features/chemists/chemists.routes').then((m) => m.routes),
      },
      {
        path: 'customers',
        loadChildren: () => import('./features/customers/customers.routes').then((m) => m.routes),
      },
      {
        path: 'regions',
        loadChildren: () => import('./features/regions/regions.routes').then((m) => m.routes),
      },
      {
        path: 'orders',
        loadChildren: () => import('./features/orders/orders.routes').then((m) => m.routes),
      },
    ],
  },
  { path: '**', redirectTo: '' },
];
