import { Routes } from '@angular/router';

/** Everything under `/my`. The shell supplies the customer layout and loads the account once. */
export const routes: Routes = [
  {
    path: '',
    loadComponent: () => import('./shell/customer-shell').then((m) => m.CustomerShell),
    children: [
      {
        path: '',
        pathMatch: 'full',
        loadComponent: () => import('./home/portal-home').then((m) => m.PortalHome),
        title: 'Home · Pharmaish',
      },
      {
        path: 'new-order',
        loadComponent: () => import('./new-order/portal-new-order').then((m) => m.PortalNewOrder),
        title: 'New order · Pharmaish',
      },
      {
        path: 'orders',
        loadComponent: () => import('./orders/portal-orders').then((m) => m.PortalOrders),
        title: 'My orders · Pharmaish',
      },
      {
        path: 'orders/:id',
        loadComponent: () => import('./orders/portal-order-detail').then((m) => m.PortalOrderDetail),
        title: 'Order · Pharmaish',
      },
      {
        path: 'addresses',
        loadComponent: () => import('./addresses/portal-addresses').then((m) => m.PortalAddresses),
        title: 'Addresses · Pharmaish',
      },
      {
        path: 'profile',
        loadComponent: () => import('./profile/portal-profile').then((m) => m.PortalProfile),
        title: 'Profile · Pharmaish',
      },
      {
        path: 'change-password',
        loadComponent: () => import('../auth/change-password').then((m) => m.ChangePassword),
        title: 'Change password · Pharmaish',
      },
      {
        path: 'help',
        loadComponent: () => import('./help/portal-help').then((m) => m.PortalHelp),
        title: 'Help · Pharmaish',
      },
    ],
  },
];
