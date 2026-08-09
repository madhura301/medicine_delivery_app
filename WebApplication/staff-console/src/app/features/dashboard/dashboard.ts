import { ChangeDetectionStrategy, Component, computed, inject, signal } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { Router, RouterLink } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { AuthStore } from '../../core/auth/auth.store';
import { CapabilityService } from '../../core/config/capabilities';
import { AssignTo, OrderStatus, RegionType } from '../../core/models/enums';
import { PageHeader } from '../../shared/ui/page-header';
import { ChemistsApiService } from '../chemists/data/chemists-api.service';
import { CustomerSupportApiService } from '../customer-support/data/customer-support-api.service';
import { CustomersApiService } from '../customers/data/customers-api.service';
import { DeliveryBoysApiService } from '../delivery-boys/data/delivery-boys-api.service';
import { ManagersApiService } from '../managers/data/managers-api.service';
import { BUCKETS, bucketTone } from '../orders/data/order-buckets';
import { OrdersStore } from '../orders/data/orders.store';
import { RegionsApiService } from '../regions/data/regions-api.service';

interface CountTile {
  label: string;
  value: number;
  icon: string;
  route: string;
}

@Component({
  selector: 'app-dashboard',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    RouterLink,
    MatCardModule,
    MatIconModule,
    MatButtonModule,
    MatProgressSpinnerModule,
    PageHeader,
  ],
  template: `
    <app-page-header
      [title]="greeting()"
      subtitle="Where things stand right now across the platform."
    />

    <section class="block">
      <h2>Orders</h2>
      @if (store.loading()) {
        <div class="spinner"><mat-spinner diameter="28" /></div>
      } @else if (store.error()) {
        <mat-card appearance="outlined">
          <mat-card-content>
            <p class="muted">{{ store.error() }}</p>
            <button matButton (click)="reload()">Try again</button>
          </mat-card-content>
        </mat-card>
      } @else {
        <div class="grid">
          @for (tile of orderTiles(); track tile.route) {
            <a [routerLink]="tile.route" class="tile">
              <mat-card appearance="outlined">
                <mat-card-content>
                  <div class="tile-head">
                    <mat-icon [class]="'tone-' + tile.tone">{{ tile.icon }}</mat-icon>
                    <span class="value">{{ tile.value }}</span>
                  </div>
                  <span class="label">{{ tile.label }}</span>
                </mat-card-content>
              </mat-card>
            </a>
          }
        </div>
      }
    </section>

    @if (queueLabel()) {
      <section class="block">
        <h2>My queue</h2>
        <mat-card appearance="outlined" class="queue">
          <mat-card-content>
            <div class="queue-body">
              <div>
                <span class="value">{{ myQueueCount() }}</span>
                <p class="muted">{{ queueLabel() }}</p>
              </div>
              <a matButton="filled" [routerLink]="queueRoute()">Open queue</a>
            </div>
          </mat-card-content>
        </mat-card>
      </section>
    }

    <section class="block">
      <h2>People</h2>
      @if (peopleLoading()) {
        <div class="spinner"><mat-spinner diameter="28" /></div>
      } @else {
        <div class="grid">
          @for (tile of peopleTiles(); track tile.route) {
            <a [routerLink]="tile.route" class="tile">
              <mat-card appearance="outlined">
                <mat-card-content>
                  <div class="tile-head">
                    <mat-icon>{{ tile.icon }}</mat-icon>
                    <span class="value">{{ tile.value }}</span>
                  </div>
                  <span class="label">{{ tile.label }}</span>
                </mat-card-content>
              </mat-card>
            </a>
          }
        </div>
      }
    </section>

    <section class="block">
      <h2>Coverage</h2>
      @if (peopleLoading()) {
        <div class="spinner"><mat-spinner diameter="28" /></div>
      } @else {
        <div class="grid">
          <a routerLink="/regions/support" class="tile">
            <mat-card appearance="outlined">
              <mat-card-content>
                <div class="tile-head">
                  <mat-icon>headset_mic</mat-icon>
                  <span class="value">{{ supportRegions() }}</span>
                </div>
                <span class="label">Support regions · {{ supportPins() }} pin codes</span>
              </mat-card-content>
            </mat-card>
          </a>
          <a routerLink="/regions/delivery" class="tile">
            <mat-card appearance="outlined">
              <mat-card-content>
                <div class="tile-head">
                  <mat-icon>moped</mat-icon>
                  <span class="value">{{ deliveryRegions() }}</span>
                </div>
                <span class="label">Delivery regions · {{ deliveryPins() }} pin codes</span>
              </mat-card-content>
            </mat-card>
          </a>
        </div>
      }
    </section>
  `,
  styles: `
    :host { display: block; }

    .block { margin-bottom: 28px; }
    h2 { margin: 0 0 12px; font: var(--mat-sys-title-medium); }

    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(190px, 1fr));
      gap: 16px;
    }

    .tile { text-decoration: none; color: inherit; }
    mat-card { height: 100%; transition: background 120ms ease; }
    mat-card:hover { background: var(--mat-sys-surface-container); }

    .tile-head {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 8px;
    }
    .value { font: var(--mat-sys-headline-medium); }
    .label { display: block; margin-top: 4px; color: var(--mat-sys-on-surface-variant); font: var(--mat-sys-body-small); }
    .muted { color: var(--mat-sys-on-surface-variant); font: var(--mat-sys-body-medium); }

    mat-icon { color: var(--mat-sys-on-surface-variant); }
    .tone-warning { color: #b45309; }
    .tone-danger { color: var(--mat-sys-error); }
    .tone-positive { color: #17663a; }
    .tone-info { color: var(--mat-sys-primary); }

    .queue-body {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 16px;
      flex-wrap: wrap;
    }
    .queue .muted { margin: 0; }
    .spinner { display: flex; justify-content: center; padding: 24px; }
  `,
})
export class Dashboard {
  protected readonly auth = inject(AuthStore);
  protected readonly store = inject(OrdersStore);
  private readonly router = inject(Router);
  private readonly capabilities = inject(CapabilityService);

  private readonly managersApi = inject(ManagersApiService);
  private readonly supportApi = inject(CustomerSupportApiService);
  private readonly deliveryApi = inject(DeliveryBoysApiService);
  private readonly chemistsApi = inject(ChemistsApiService);
  private readonly customersApi = inject(CustomersApiService);
  private readonly regionsApi = inject(RegionsApiService);

  protected readonly peopleLoading = signal(true);
  private readonly counts = signal<Record<string, number>>({});
  protected readonly supportRegions = signal(0);
  protected readonly deliveryRegions = signal(0);
  protected readonly supportPins = signal(0);
  protected readonly deliveryPins = signal(0);

  protected readonly greeting = computed(() => `Welcome, ${this.auth.displayName()}`);

  protected readonly orderTiles = computed(() => {
    const orders = this.store.orders();
    return BUCKETS.filter((b) => b.bucket !== 'all').map((b) => ({
      label: b.title,
      value: orders.filter((o) => o.assignTo === b.bucket).length,
      icon: b.icon,
      route: `/orders/${b.slug}`,
      tone: bucketTone(b.bucket as AssignTo),
    }));
  });

  /** Manager and support agents get a shortcut to what is actually waiting on them. */
  protected readonly queueLabel = computed(() => {
    const role = this.auth.role();
    if (role === 'CustomerSupport') {
      return 'orders waiting for you to place with another chemist';
    }
    if (role === 'Manager') {
      return 'orders escalated to a manager';
    }
    return '';
  });

  protected readonly queueRoute = computed(() =>
    this.auth.role() === 'Manager' ? '/orders/with-manager' : '/orders/with-support',
  );

  protected readonly myQueueCount = computed(() => {
    const role = this.auth.role();
    const orders = this.store.orders();
    const entityId = this.auth.entityId();

    if (role === 'CustomerSupport') {
      return orders.filter((o) => o.orderStatus === OrderStatus.AssignedToCustomerSupport).length;
    }
    if (role === 'Manager') {
      return orders.filter(
        (o) =>
          o.assignTo === AssignTo.Manager && (!entityId || !o.managerId || o.managerId === entityId),
      ).length;
    }
    return 0;
  });

  protected readonly peopleTiles = computed<CountTile[]>(() => {
    const counts = this.counts();
    const tiles: CountTile[] = [];

    if (counts['managers'] !== undefined) {
      tiles.push({ label: 'Managers', value: counts['managers'], icon: 'manage_accounts', route: '/managers' });
    }
    if (counts['support'] !== undefined) {
      tiles.push({
        label: 'Support agents',
        value: counts['support'],
        icon: 'support_agent',
        route: '/customer-support',
      });
    }
    if (counts['delivery'] !== undefined) {
      tiles.push({
        label: 'Delivery partners',
        value: counts['delivery'],
        icon: 'two_wheeler',
        route: '/delivery-boys',
      });
    }
    if (counts['chemists'] !== undefined) {
      tiles.push({ label: 'Chemists', value: counts['chemists'], icon: 'local_pharmacy', route: '/chemists' });
    }
    if (counts['customers'] !== undefined) {
      tiles.push({ label: 'Customers', value: counts['customers'], icon: 'people', route: '/customers' });
    }

    return tiles;
  });

  constructor() {
    void this.store.load();
    void this.loadPeople();
  }

  protected reload(): void {
    void this.store.load(true);
  }

  /**
   * Each count is optional: a role that cannot read a roster simply does not get that tile,
   * rather than the whole dashboard failing on one 403.
   */
  private async loadPeople(): Promise<void> {
    this.peopleLoading.set(true);
    const counts: Record<string, number> = {};

    const [managers, support, delivery, chemists, customers, regions] = await Promise.all([
      this.capabilities.can('manageManagers') || this.auth.role() === 'Manager'
        ? firstValueFrom(this.managersApi.list()).catch(() => null)
        : Promise.resolve(null),
      firstValueFrom(this.supportApi.list()).catch(() => null),
      this.capabilities.can('manageDeliveryBoys')
        ? firstValueFrom(this.deliveryApi.list()).catch(() => null)
        : Promise.resolve(null),
      firstValueFrom(this.chemistsApi.list()).catch(() => null),
      firstValueFrom(this.customersApi.list()).catch(() => null),
      firstValueFrom(this.regionsApi.list()).catch(() => null),
    ]);

    if (managers) {
      counts['managers'] = managers.filter((m) => !m.isDeleted && m.isActive).length;
    }
    if (support) {
      counts['support'] = support.filter((s) => !s.isDeleted && s.isActive).length;
    }
    if (delivery) {
      counts['delivery'] = delivery.filter((d) => !d.isDeleted && d.isActive).length;
    }
    if (chemists) {
      counts['chemists'] = chemists.filter((c) => !c.isDeleted && c.isActive).length;
    }
    if (customers) {
      counts['customers'] = customers.filter((c) => c.isActive).length;
    }

    if (regions) {
      const support = regions.filter((r) => r.regionType === RegionType.CustomerSupport);
      const deliveryRegions = regions.filter((r) => r.regionType === RegionType.DeliveryBoy);
      this.supportRegions.set(support.length);
      this.deliveryRegions.set(deliveryRegions.length);
      this.supportPins.set(support.reduce((sum, r) => sum + (r.pinCodes?.length ?? 0), 0));
      this.deliveryPins.set(deliveryRegions.reduce((sum, r) => sum + (r.pinCodes?.length ?? 0), 0));
    }

    this.counts.set(counts);
    this.peopleLoading.set(false);
  }
}
