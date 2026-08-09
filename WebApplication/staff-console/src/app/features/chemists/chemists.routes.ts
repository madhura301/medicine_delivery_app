import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    loadComponent: () => import('./list/chemists-list').then((m) => m.ChemistsList),
    title: 'Chemists · Pharmaish',
  },
  {
    path: ':id',
    loadComponent: () => import('./detail/chemist-detail').then((m) => m.ChemistDetail),
    title: 'Chemist · Pharmaish',
  },
];
