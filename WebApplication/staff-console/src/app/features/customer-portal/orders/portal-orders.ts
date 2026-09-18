import { DatePipe } from '@angular/common';
import { ChangeDetectionStrategy, Component, computed, inject, OnInit, signal } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { RouterLink } from '@angular/router';
import { Order } from '../../../core/models/api.models';
import { OrderStatus } from '../../../core/models/enums';
import { isActive, isPayable, journeyOf, paymentBreakdown, rupees } from '../data/order-journey';
import { PortalStore } from '../data/portal.store';
import { OrderTracker } from '../ui/order-tracker';

type Filter = 'active' | 'delivered' | 'all';

@Component({
  selector: 'app-portal-orders',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [DatePipe, RouterLink, MatButtonModule, MatIconModule, OrderTracker],
  template: `
    <header class="head">
      <div>
        <h1>My orders</h1>
        <p>Track every order from prescription to your door.</p>
      </div>
      <button matButton class="pt-round refresh" (click)="refresh()" [disabled]="refreshing()">
        <mat-icon [class.spin]="refreshing()">refresh</mat-icon>Refresh
      </button>
    </header>

    <div class="filters" role="tablist" aria-label="Filter orders">
      @for (f of filters(); track f.key) {
        <button role="tab" [attr.aria-selected]="filter() === f.key" [class.on]="filter() === f.key" (click)="filter.set(f.key)">
          {{ f.label }} <span>{{ f.count }}</span>
        </button>
      }
    </div>

    @if (visible().length) {
      <ul class="list">
        @for (order of visible(); track order.orderId) {
          <li>
            <a class="row" [routerLink]="['/my/orders', order.orderId]" [class.attn]="isPayable(order)">
              <span class="icon" [class]="'icon ' + tone(order)">
                <mat-icon>{{ icon(order) }}</mat-icon>
              </span>
              <span class="main">
                <span class="top">
                  <strong>{{ order.orderNumber }}</strong>
                  <span class="date">{{ order.createdOn | date: 'd MMM yyyy' }}</span>
                </span>
                <span class="status">{{ headline(order) }}</span>
                <app-order-tracker [order]="order" variant="compact" />
              </span>
              <span class="end">
                @if (isPayable(order)) {
                  <span class="pay">Pay {{ payTotal(order) }}</span>
                } @else if (order.totalAmount) {
                  <span class="amount">{{ rupees(order.totalAmount) }}</span>
                }
                <mat-icon class="chev">chevron_right</mat-icon>
              </span>
            </a>
          </li>
        }
      </ul>
    } @else if (!store.loading()) {
      <div class="empty">
        <span class="empty-icon"><mat-icon>{{ filter() === 'delivered' ? 'inventory_2' : 'receipt_long' }}</mat-icon></span>
        <h2>{{ emptyTitle() }}</h2>
        <p>{{ emptyText() }}</p>
        <a matButton="filled" class="pt-cta" routerLink="/my/new-order">Start a new order</a>
      </div>
    }
  `,
  styles: `
    :host { display: flex; flex-direction: column; gap: 20px; }
    .head { display: flex; justify-content: space-between; align-items: flex-end; gap: 16px; }
    h1 { margin: 0; font-size: clamp(1.7rem, 3vw, 2.2rem); font-weight: 800; letter-spacing: -0.025em; color: var(--pt-navy-deep); }
    .head p { margin: 4px 0 0; color: var(--pt-muted); }
    .spin { animation: spin 0.9s linear infinite; }
    @keyframes spin { to { transform: rotate(360deg); } }

    .filters { display: flex; gap: 8px; flex-wrap: wrap; }
    .filters button {
      font: inherit; font-weight: 600; cursor: pointer; padding: 9px 16px; border-radius: 999px;
      border: 1.5px solid var(--pt-line); background: var(--pt-card); color: var(--pt-muted);
      display: inline-flex; gap: 8px; align-items: center;
    }
    .filters button span { font-size: 0.78rem; background: var(--pt-ground); padding: 1px 8px; border-radius: 999px; }
    .filters button.on { border-color: var(--pt-navy); background: var(--pt-navy); color: #fff; }
    .filters button.on span { background: rgba(255,255,255,0.18); }
    .filters button:focus-visible { outline: 3px solid color-mix(in srgb, var(--pt-navy) 40%, transparent); outline-offset: 2px; }

    .list { list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; gap: 12px; }
    .row {
      display: flex; align-items: center; gap: 16px; padding: 18px 18px 18px 16px;
      background: var(--pt-card); border: 1px solid var(--pt-line); border-radius: var(--pt-radius);
      text-decoration: none; color: var(--pt-ink); transition: border-color 140ms ease, box-shadow 140ms ease;
    }
    .row:hover { border-color: color-mix(in srgb, var(--pt-navy) 30%, transparent); box-shadow: var(--pt-shadow); }
    .row:focus-visible { outline: 3px solid color-mix(in srgb, var(--pt-navy) 40%, transparent); outline-offset: 2px; }
    .row.attn { border-color: color-mix(in srgb, var(--pt-orange) 50%, transparent); background: linear-gradient(90deg, var(--pt-orange-soft), var(--pt-card) 42%); }

    .icon { width: 46px; height: 46px; border-radius: 14px; display: grid; place-items: center; flex: none; }
    .icon.progress { background: var(--pt-navy-soft); color: var(--pt-navy); }
    .icon.action { background: var(--pt-orange); color: #fff; }
    .icon.done { background: var(--pt-good-soft); color: var(--pt-good); }
    .icon.stopped { background: var(--pt-stop-soft); color: var(--pt-stop); }

    .main { flex: 1; min-width: 0; display: flex; flex-direction: column; gap: 6px; }
    .top { display: flex; gap: 12px; align-items: baseline; }
    .top strong { font-weight: 700; font-variant-numeric: tabular-nums; }
    .date { color: var(--pt-faint); font-size: 0.85rem; }
    .status { color: var(--pt-muted); font-size: 0.93rem; }
    app-order-tracker { max-width: 360px; }

    .end { display: flex; align-items: center; gap: 8px; flex: none; }
    .amount { font-weight: 700; font-variant-numeric: tabular-nums; }
    .pay { background: var(--pt-orange); color: #fff; font-weight: 700; padding: 7px 14px; border-radius: 999px; font-size: 0.9rem; white-space: nowrap; }
    .chev { color: var(--pt-faint); }

    .empty { display: flex; flex-direction: column; align-items: center; text-align: center; gap: 8px; padding: 56px 20px; background: var(--pt-card); border: 1px solid var(--pt-line); border-radius: var(--pt-radius); }
    .empty-icon { width: 64px; height: 64px; border-radius: 50%; background: var(--pt-navy-soft); color: var(--pt-navy); display: grid; place-items: center; margin-bottom: 6px; }
    .empty h2 { margin: 0; font-size: 1.2rem; font-weight: 700; }
    .empty p { margin: 0 0 10px; color: var(--pt-muted); max-width: 44ch; }

    @media (max-width: 600px) { .refresh { display: none; } .row { align-items: flex-start; } .amount, .pay { font-size: 0.82rem; } }
    @media (prefers-reduced-motion: reduce) { .spin { animation: none; } }
  `,
})
export class PortalOrders implements OnInit {
  protected readonly store = inject(PortalStore);
  protected readonly isPayable = isPayable;
  protected readonly rupees = rupees;

  protected readonly filter = signal<Filter>('active');
  protected readonly refreshing = signal(false);

  private readonly delivered = computed(() =>
    this.store.orders().filter((o) => o.orderStatus === OrderStatus.Completed),
  );

  protected readonly filters = computed(() => [
    { key: 'active' as const, label: 'In progress', count: this.store.activeOrders().length },
    { key: 'delivered' as const, label: 'Delivered', count: this.delivered().length },
    { key: 'all' as const, label: 'All', count: this.store.orders().length },
  ]);

  protected readonly visible = computed(() => {
    switch (this.filter()) {
      case 'active': return this.store.orders().filter(isActive);
      case 'delivered': return this.delivered();
      default: return this.store.orders();
    }
  });

  protected readonly emptyTitle = computed(() =>
    this.filter() === 'active' ? 'Nothing in progress' : this.filter() === 'delivered' ? 'No deliveries yet' : 'No orders yet',
  );
  protected readonly emptyText = computed(() =>
    this.filter() === 'active'
      ? 'When you place an order, you can follow it here from chemist to doorstep.'
      : 'Orders you receive will be listed here for your records.',
  );

  ngOnInit(): void {
    // Landing on the list with nothing in progress but a history to show? Open on All instead.
    queueMicrotask(() => {
      if (!this.store.activeOrders().length && this.store.orders().length) {
        this.filter.set('all');
      }
    });
  }

  protected async refresh(): Promise<void> {
    this.refreshing.set(true);
    try {
      await this.store.refreshOrders();
    } finally {
      this.refreshing.set(false);
    }
  }

  protected headline(order: Order): string {
    return journeyOf(order).headline;
  }

  protected tone(order: Order): string {
    return journeyOf(order).tone;
  }

  protected icon(order: Order): string {
    const j = journeyOf(order);
    if (j.cancelled) return 'block';
    if (j.tone === 'done') return 'task_alt';
    if (isPayable(order)) return 'payments';
    return ['hourglass_top', 'local_pharmacy', 'request_quote', 'inventory', 'local_shipping', 'task_alt'][j.stage];
  }

  protected payTotal(order: Order): string {
    return rupees(paymentBreakdown(order.totalAmount ?? 0).total);
  }
}
