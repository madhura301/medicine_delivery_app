import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { UserRole } from '../models/enums';
import { AuthStore } from './auth.store';

export const authGuard: CanActivateFn = (_route, state) => {
  const auth = inject(AuthStore);
  const router = inject(Router);

  if (auth.isAuthenticated()) {
    return true;
  }

  auth.logout(false);
  return router.createUrlTree(['/login'], { queryParams: { returnUrl: state.url } });
};

/** Keeps a signed-in user away from the login page. */
export const guestGuard: CanActivateFn = () => {
  const auth = inject(AuthStore);
  const router = inject(Router);
  return auth.isAuthenticated() ? router.createUrlTree(['/dashboard']) : true;
};

/**
 * Route-level role check. The client-side map is a convenience, not a security boundary — the
 * API enforces permissions per request, so screens must still handle a 403.
 */
export function roleGuard(...allowed: UserRole[]): CanActivateFn {
  return () => {
    const auth = inject(AuthStore);
    const router = inject(Router);

    if (!auth.isAuthenticated()) {
      return router.createUrlTree(['/login']);
    }

    const role = auth.role();
    return role && allowed.includes(role) ? true : router.createUrlTree(['/dashboard']);
  };
}
