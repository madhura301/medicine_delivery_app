import { HttpErrorResponse } from '@angular/common/http';
import { Injectable, computed, inject, signal } from '@angular/core';
import { firstValueFrom } from 'rxjs';
import { AuthStore } from '../../../core/auth/auth.store';
import { describeHttpError } from '../../../core/http/interceptors';
import { Customer, CustomerAddress, Order } from '../../../core/models/api.models';
import { CustomersApiService } from '../../customers/data/customers-api.service';
import { isActive } from './order-journey';
import { PortalApiService } from './portal-api.service';

/**
 * The signed-in customer's profile, addresses and orders, loaded once and shared by every portal
 * screen so moving between Home, Orders and Addresses is instant.
 */
@Injectable({ providedIn: 'root' })
export class PortalStore {
  private readonly api = inject(PortalApiService);
  private readonly customersApi = inject(CustomersApiService);
  private readonly auth = inject(AuthStore);

  private readonly _profile = signal<Customer | null>(null);
  private readonly _orders = signal<Order[]>([]);
  private readonly _addresses = signal<CustomerAddress[]>([]);
  private readonly _loading = signal(false);
  private readonly _error = signal<string | null>(null);
  private loadedFor: string | null = null;

  readonly profile = this._profile.asReadonly();
  readonly addresses = this._addresses.asReadonly();
  readonly loading = this._loading.asReadonly();
  readonly error = this._error.asReadonly();

  /** Newest first. */
  readonly orders = computed(() =>
    [...this._orders()].sort((a, b) => b.createdOn.localeCompare(a.createdOn)),
  );
  readonly activeOrders = computed(() => this.orders().filter(isActive));

  readonly firstName = computed(() => this._profile()?.customerFirstName?.trim() || 'there');

  readonly defaultAddress = computed(
    () => this._addresses().find((a) => a.isDefault) ?? this._addresses()[0] ?? null,
  );

  /** Resolved at sign-in; falls back to the profile if the session was restored without it. */
  readonly customerId = computed(() => this.auth.entityId() ?? this._profile()?.customerId ?? null);

  async load(force = false): Promise<void> {
    const userKey = this.auth.token();
    if (!force && userKey && this.loadedFor === userKey) {
      return;
    }

    this._loading.set(true);
    this._error.set(null);

    try {
      const profile = await firstValueFrom(this.api.myProfile());
      this._profile.set(profile);

      const [orders, addresses] = await Promise.all([
        firstValueFrom(this.api.myOrders(profile.customerId)).catch(() => [] as Order[]),
        firstValueFrom(this.customersApi.addresses(profile.customerId)).catch(
          () => profile.addresses ?? [],
        ),
      ]);
      this._orders.set(orders ?? []);
      this._addresses.set((addresses ?? []).filter((a) => a.isActive));
      this.loadedFor = userKey;
    } catch (err) {
      this._error.set(describeHttpError(err as HttpErrorResponse));
    } finally {
      this._loading.set(false);
    }
  }

  async refreshOrders(): Promise<void> {
    const id = this.customerId();
    if (!id) {
      return;
    }
    this._orders.set((await firstValueFrom(this.api.myOrders(id))) ?? []);
  }

  async refreshAddresses(): Promise<void> {
    const id = this.customerId();
    if (!id) {
      return;
    }
    const addresses = (await firstValueFrom(this.customersApi.addresses(id))) ?? [];
    this._addresses.set(addresses.filter((a) => a.isActive));
  }

  setProfile(profile: Customer): void {
    this._profile.set(profile);
  }

  /** Keeps the list in step after an action on a single order, without refetching everything. */
  upsertOrder(order: Order): void {
    this._orders.update((list) => {
      const index = list.findIndex((o) => o.orderId === order.orderId);
      return index === -1 ? [order, ...list] : list.map((o, i) => (i === index ? order : o));
    });
  }

  reset(): void {
    this._profile.set(null);
    this._orders.set([]);
    this._addresses.set([]);
    this.loadedFor = null;
  }
}
