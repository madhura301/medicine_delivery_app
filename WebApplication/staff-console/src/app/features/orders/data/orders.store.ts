import { HttpErrorResponse } from '@angular/common/http';
import { Injectable, computed, inject, signal } from '@angular/core';
import { firstValueFrom } from 'rxjs';
import { AuthStore } from '../../../core/auth/auth.store';
import { describeHttpError } from '../../../core/http/interceptors';
import { Order } from '../../../core/models/api.models';
import { OrdersApiService } from './orders-api.service';

/**
 * Loads the order list once and shares it across the six bucket screens and the dashboard.
 *
 * Which endpoint to use depends on the role: Admin and Manager hold ListAllOrders and can read
 * everything, while CustomerSupport does not — they are served their own queue instead.
 */
@Injectable({ providedIn: 'root' })
export class OrdersStore {
  private readonly api = inject(OrdersApiService);
  private readonly auth = inject(AuthStore);

  private readonly _orders = signal<Order[]>([]);
  private readonly _loading = signal(false);
  private readonly _error = signal<string | null>(null);
  private readonly _forbidden = signal(false);
  private readonly _loadedAt = signal<number | null>(null);

  readonly orders = this._orders.asReadonly();
  readonly loading = this._loading.asReadonly();
  readonly error = this._error.asReadonly();
  readonly forbidden = this._forbidden.asReadonly();

  /** True when this user only ever sees their own queue, so "All Orders" is not available. */
  readonly scopedToOwnQueue = computed(() => this.auth.role() === 'CustomerSupport');

  async load(force = false): Promise<void> {
    const age = this._loadedAt();
    if (!force && age !== null && Date.now() - age < 30_000) {
      return;
    }

    this._loading.set(true);
    this._error.set(null);
    this._forbidden.set(false);

    try {
      this._orders.set(await this.fetch());
      this._loadedAt.set(Date.now());
    } catch (err) {
      const error = err as HttpErrorResponse;
      this._forbidden.set(error.status === 403);
      this._error.set(describeHttpError(error));
      this._orders.set([]);
    } finally {
      this._loading.set(false);
    }
  }

  private async fetch(): Promise<Order[]> {
    const role = this.auth.role();
    const entityId = this.auth.entityId();

    if (role === 'CustomerSupport') {
      if (!entityId) {
        throw new HttpErrorResponse({
          status: 409,
          error: {
            error:
              'Your support-agent record could not be found, so your queue cannot be loaded. Ask an administrator to check your account.',
          },
        });
      }
      return (await firstValueFrom(this.api.byCustomerSupport(entityId))) ?? [];
    }

    return (await firstValueFrom(this.api.listAll())) ?? [];
  }

  /** Call after any action that changes an order so every screen sees the new state. */
  invalidate(): void {
    this._loadedAt.set(null);
  }
}
