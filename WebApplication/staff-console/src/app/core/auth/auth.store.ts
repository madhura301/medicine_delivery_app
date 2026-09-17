import { Injectable, computed, inject, signal } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, firstValueFrom, of } from 'rxjs';
import { CONSOLE_ROLES, UserRole } from '../models/enums';
import { AuthApiService } from './auth-api.service';
import { JwtClaims, isExpired, parseJwt } from './jwt.util';

const TOKEN_KEY = 'pharmaish.staff.token';
const ENTITY_KEY = 'pharmaish.staff.entityId';

export interface LoginOutcome {
  ok: boolean;
  /** Present when the sign-in failed or the account is not allowed into this console. */
  error?: string;
}

/**
 * Single source of truth for the signed-in user. The token lives in localStorage when the user
 * ticked "keep me signed in", otherwise in sessionStorage so it dies with the tab.
 */
@Injectable({ providedIn: 'root' })
export class AuthStore {
  private readonly api = inject(AuthApiService);
  private readonly router = inject(Router);

  private readonly _token = signal<string | null>(null);
  private readonly _claims = signal<JwtClaims | null>(null);
  /** ManagerId or CustomerSupportId — needed by the "my queue" screens, absent from the JWT. */
  private readonly _entityId = signal<string | null>(null);

  readonly token = this._token.asReadonly();
  readonly claims = this._claims.asReadonly();
  readonly entityId = this._entityId.asReadonly();

  readonly role = computed<UserRole | null>(() => this._claims()?.role ?? null);
  readonly isAuthenticated = computed(() => {
    const claims = this._claims();
    return !!claims && !isExpired(claims);
  });
  readonly displayName = computed(() => {
    const claims = this._claims();
    if (!claims) {
      return '';
    }
    const full = `${claims.firstName} ${claims.lastName}`.trim();
    return full || claims.userName;
  });
  readonly initials = computed(() => {
    const claims = this._claims();
    if (!claims) {
      return '';
    }
    const first = claims.firstName.charAt(0);
    const last = claims.lastName.charAt(0);
    return (first + last).toUpperCase() || claims.userName.slice(0, 2).toUpperCase();
  });

  constructor() {
    this.restore();
  }

  /** Rehydrates a session left behind by a previous page load. */
  private restore(): void {
    const token = localStorage.getItem(TOKEN_KEY) ?? sessionStorage.getItem(TOKEN_KEY);
    if (!token) {
      return;
    }

    const claims = parseJwt(token);
    if (!claims || isExpired(claims) || !this.canUseConsole(claims.role)) {
      this.clearStorage();
      return;
    }

    this._token.set(token);
    this._claims.set(claims);
    this._entityId.set(localStorage.getItem(ENTITY_KEY) ?? sessionStorage.getItem(ENTITY_KEY));
  }

  private canUseConsole(role: UserRole | null): boolean {
    return !!role && CONSOLE_ROLES.includes(role);
  }

  async login(mobileNumber: string, password: string, stayLoggedIn: boolean): Promise<LoginOutcome> {
    const response = await firstValueFrom(
      this.api.login({ mobileNumber, password, stayLoggedIn }).pipe(catchError(() => of(null))),
    );

    if (!response?.success || !response.token) {
      const message = response?.errors?.[0] ?? 'Invalid mobile number or password.';
      return { ok: false, error: message };
    }

    const claims = parseJwt(response.token);
    if (!claims) {
      return { ok: false, error: 'Sign-in failed: the server returned a token we could not read.' };
    }

    if (!this.canUseConsole(claims.role)) {
      return {
        ok: false,
        error: 'Delivery partners use the Pharmaish mobile app to sign in.',
      };
    }

    const store = stayLoggedIn ? localStorage : sessionStorage;
    store.setItem(TOKEN_KEY, response.token);
    this._token.set(response.token);
    this._claims.set(claims);

    await this.resolveEntityId(claims, store);
    return { ok: true };
  }

  /**
   * Managers and support agents are identified in the order APIs by their entity id, which the
   * token does not carry. Look it up once at sign-in and cache it alongside the token.
   * A failure here is not fatal — only the "my queue" screens need it.
   */
  private async resolveEntityId(claims: JwtClaims, store: Storage): Promise<void> {
    let id: string | null | undefined;

    // Customers resolve from their token, not by email: plenty of them register without one.
    if (claims.role === 'Customer') {
      id = (await firstValueFrom(this.api.myCustomerProfile().pipe(catchError(() => of(null)))))
        ?.customerId;
      if (id) {
        this._entityId.set(id);
        store.setItem(ENTITY_KEY, id);
      }
      return;
    }

    const needsLookup =
      claims.role === 'Manager' || claims.role === 'CustomerSupport' || claims.role === 'Chemist';

    if (!claims.email || !needsLookup) {
      return;
    }

    if (claims.role === 'Manager') {
      id = (
        await firstValueFrom(this.api.managerByEmail(claims.email).pipe(catchError(() => of(null))))
      )?.managerId;
    } else if (claims.role === 'CustomerSupport') {
      id = (
        await firstValueFrom(
          this.api.customerSupportByEmail(claims.email).pipe(catchError(() => of(null))),
        )
      )?.customerSupportId;
    } else {
      // A chemist's every screen is scoped by store, so without this they see nothing at all —
      // the orders store turns a missing id into an explanatory message rather than an empty list.
      id = (
        await firstValueFrom(
          this.api.medicalStoreByEmail(claims.email).pipe(catchError(() => of(null))),
        )
      )?.medicalStoreId;
    }

    if (id) {
      this._entityId.set(id);
      store.setItem(ENTITY_KEY, id);
    }
  }

  logout(redirect = true): void {
    this.clearStorage();
    this._token.set(null);
    this._claims.set(null);
    this._entityId.set(null);
    if (redirect) {
      void this.router.navigate(['/login']);
    }
  }

  private clearStorage(): void {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(ENTITY_KEY);
    sessionStorage.removeItem(TOKEN_KEY);
    sessionStorage.removeItem(ENTITY_KEY);
  }
}
