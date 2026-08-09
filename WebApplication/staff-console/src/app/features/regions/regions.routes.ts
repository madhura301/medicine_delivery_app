import { Routes } from '@angular/router';
import { RegionType } from '../../core/models/enums';

/**
 * Both menus render the same component; `data.regionType` is bound to its `regionType` input by
 * withComponentInputBinding().
 */
export const routes: Routes = [
  { path: '', pathMatch: 'full', redirectTo: 'support' },
  {
    path: 'support',
    loadComponent: () => import('./list/regions-list').then((m) => m.RegionsList),
    data: { regionType: RegionType.CustomerSupport },
    title: 'Support Regions · Pharmaish',
  },
  {
    path: 'delivery',
    loadComponent: () => import('./list/regions-list').then((m) => m.RegionsList),
    data: { regionType: RegionType.DeliveryBoy },
    title: 'Delivery Regions · Pharmaish',
  },
];
