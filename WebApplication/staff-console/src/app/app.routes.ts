import { Routes } from '@angular/router';
import { authGuard, guestGuard, homeGuard, roleGuard, staffAreaGuard } from './core/auth/auth.guards';

export const routes: Routes = [
  {
    path: 'login',
    canActivate: [guestGuard],
    loadComponent: () => import('./features/auth/login').then((m) => m.Login),
    title: 'Sign in · Pharmaish',
  },
  {
    // Public chemist sign-up — the web counterpart of the mobile self-registration screen, hitting
    // the same [AllowAnonymous] endpoint. Deliberately NOT behind guestGuard: a signed-in staff
    // member following the link should still see the page rather than be bounced to the dashboard.
    path: 'register-chemist',
    loadComponent: () =>
      import('./features/chemists/register/chemist-register-page').then((m) => m.ChemistRegisterPage),
    title: 'Register your pharmacy · Pharmaish',
  },
  {
    // Public customer sign-up. Signs the new customer straight in on success.
    path: 'register',
    canActivate: [guestGuard],
    loadComponent: () =>
      import('./features/customer-portal/register/customer-register-page').then(
        (m) => m.CustomerRegisterPage,
      ),
    title: 'Create your account · Pharmaish',
  },
  {
    // The customer portal — its own layout, entirely separate from the staff console below.
    path: 'my',
    canActivate: [authGuard, roleGuard('Customer')],
    loadChildren: () =>
      import('./features/customer-portal/customer-portal.routes').then((m) => m.routes),
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
    canActivate: [authGuard, staffAreaGuard],
    loadComponent: () => import('./layout/shell').then((m) => m.Shell),
    children: [
      // Role-aware, because a chemist has no org-wide dashboard to land on.
      { path: '', pathMatch: 'full', canActivate: [homeGuard], children: [] },
      {
        path: 'dashboard',
        canActivate: [roleGuard('Admin', 'Manager', 'CustomerSupport')],
        loadComponent: () => import('./features/dashboard/dashboard').then((m) => m.Dashboard),
        title: 'Dashboard · Pharmaish',
      },
      {
        path: 'change-password',
        loadComponent: () => import('./features/auth/change-password').then((m) => m.ChangePassword),
        title: 'Change password · Pharmaish',
      },
      {
        path: 'user-accounts',
        canActivate: [roleGuard('Admin', 'Manager')],
        loadChildren: () =>
          import('./features/user-accounts/user-accounts.routes').then((m) => m.routes),
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
        path: 'order-logs',
        canActivate: [roleGuard('Admin', 'Manager')],
        loadChildren: () => import('./features/order-logs/order-logs.routes').then((m) => m.routes),
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
