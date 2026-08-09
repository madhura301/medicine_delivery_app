import { HttpErrorResponse, HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { catchError, throwError } from 'rxjs';
import { AuthStore } from '../auth/auth.store';
import { ToastService } from '../ui/toast.service';

/** Attaches the bearer token to every same-API request. */
export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const token = inject(AuthStore).token();
  if (!token) {
    return next(req);
  }

  return next(req.clone({ setHeaders: { Authorization: `Bearer ${token}` } }));
};

/** Turns an API error into a readable sentence. */
export function describeHttpError(error: HttpErrorResponse): string {
  if (error.status === 0) {
    return 'Cannot reach the API. Check that the backend is running.';
  }

  const body = error.error as
    | { error?: string; message?: string; errors?: Record<string, string[]> | string[] }
    | string
    | null;

  if (typeof body === 'string' && body.trim()) {
    return body;
  }

  if (body && typeof body === 'object') {
    if (typeof body.error === 'string') {
      return body.error;
    }
    if (typeof body.message === 'string') {
      return body.message;
    }
    // ASP.NET ModelState: { field: ["message", ...] }
    if (body.errors && !Array.isArray(body.errors)) {
      const first = Object.values(body.errors).flat()[0];
      if (typeof first === 'string') {
        return first;
      }
    }
    if (Array.isArray(body.errors) && typeof body.errors[0] === 'string') {
      return body.errors[0];
    }
  }

  switch (error.status) {
    case 400:
      return 'The server rejected that request.';
    case 403:
      return 'You do not have permission to do this.';
    case 404:
      return 'Not found.';
    default:
      return 'Something went wrong. Please try again.';
  }
};

/**
 * Signs the user out on 401 and surfaces 403/5xx as a toast. Errors are re-thrown so callers can
 * still show inline state (a failed list keeps its own error panel).
 */
export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  const auth = inject(AuthStore);
  const toast = inject(ToastService);

  return next(req).pipe(
    catchError((error: HttpErrorResponse) => {
      if (error.status === 401) {
        auth.logout();
        toast.error('Your session has expired. Please sign in again.');
      } else if (error.status === 403) {
        toast.error('You do not have permission to do this.');
      } else if (error.status >= 500) {
        toast.error(describeHttpError(error));
      }

      return throwError(() => error);
    }),
  );
};
