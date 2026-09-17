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

/**
 * Where a signed-in user belongs when they have not asked for anywhere in particular.
 *
 * Chemists have no org-wide dashboard — their home is their own accept queue. Everything that
 * bounces a user (the guest guard, a failed role check, the empty path) routes through here, so a
 * chemist can never be sent to a screen their role then bounces them off again.
 */
function homeUrl(router: Router, role: UserRole | null) {
  switch (role) {
    case 'Customer':
      return router.createUrlTree(['/my']);
    case 'Chemist':
      return router.createUrlTree(['/orders/to-accept']);
    default:
      return router.createUrlTree(['/dashboard']);
  }
}

/**
 * Keeps customers out of the staff console. The console's menus would already be empty for them
 * and the API refuses its calls, but landing a customer on an empty admin shell is a poor
 * experience — send them to their own portal instead.
 */
export const staffAreaGuard: CanActivateFn = () => {
  const auth = inject(AuthStore);
  return auth.role() === 'Customer' ? inject(Router).createUrlTree(['/my']) : true;
};

/** Sends a signed-in user to the right landing screen for their role. */
export const homeGuard: CanActivateFn = () => {
  const auth = inject(AuthStore);
  return homeUrl(inject(Router), auth.role());
};

/** Keeps a signed-in user away from the login page. */
export const guestGuard: CanActivateFn = () => {
  const auth = inject(AuthStore);
  const router = inject(Router);
  return auth.isAuthenticated() ? homeUrl(router, auth.role()) : true;
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
    return role && allowed.includes(role) ? true : homeUrl(router, role);
  };
}
