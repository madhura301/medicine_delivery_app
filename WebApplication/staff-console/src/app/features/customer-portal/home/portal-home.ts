import { DatePipe } from '@angular/common';
import { ChangeDetectionStrategy, Component, computed, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { RouterLink } from '@angular/router';
import { OrderStatus } from '../../../core/models/enums';
import { formatAddress } from '../../customers/data/customers-api.service';
import { isPayable, journeyOf, paymentBreakdown, rupees } from '../data/order-journey';
import { PortalStore } from '../data/portal.store';
import { OrderTracker } from '../ui/order-tracker';
import { Order } from '../../../core/models/api.models';

/** Something only the customer can move forward: a bill to pay, or a code to share at the door. */
interface AttentionItem {
  order: Order;
  kind: 'pay' | 'code';
  title: string;
  subtitle: string;
  amount: string;
}

@Component({
  selector: 'app-portal-home',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [DatePipe, RouterLink, MatButtonModule, MatIconModule, MatProgressBarModule, OrderTracker],
  template: `
    @if (store.loading() && !store.profile()) {
      <mat-progress-bar mode="indeterminate" class="loading" />
    }

    <section class="hello">
      <p class="eyebrow">{{ greeting() }}</p>
      <h1>Hi {{ store.firstName() }}, what do you need today?</h1>
    </section>

    @if (store.error()) {
      <div class="notice stop" role="alert">
        <mat-icon>error_outline</mat-icon>
        <div><strong>We couldn't load your account.</strong> {{ store.error() }}</div>
        <button matButton class="pt-round" (click)="store.load(true)">Try again</button>
      </div>
    }

    <!-- Things only the customer can move forward come first. -->
    @for (item of attention(); track item.order.orderId) {
      <a class="attention" [class.code]="item.kind === 'code'" [routerLink]="['/my/orders', item.order.orderId]">
        <span class="att-icon">
          <mat-icon>{{ item.kind === 'pay' ? 'payments' : 'local_shipping' }}</mat-icon>
        </span>
        <span class="att-body">
          <strong>{{ item.title }}</strong>
          <span>Order {{ item.order.orderNumber }} · {{ item.subtitle }}</span>
        </span>
        @if (item.kind === 'code') {
          <span class="otp" aria-label="Delivery code">{{ item.order.otp }}</span>
        } @else {
          <span matButton="filled" class="pt-cta pay">Pay {{ item.amount }}</span>
        }
      </a>
    }

    <section class="start" aria-labelledby="start-title">
      <h2 id="start-title" class="sr">Start an order</h2>
      <a class="tile primary" routerLink="/my/new-order" [queryParams]="{ input: 'photo' }">
        <span class="tile-icon"><mat-icon>photo_camera</mat-icon></span>
        <span class="tile-text">
          <strong>Upload a prescription</strong>
          <span>Snap or upload a photo — we'll find a chemist near you.</span>
        </span>
        <mat-icon class="go">arrow_forward</mat-icon>
      </a>
      <a class="tile" routerLink="/my/new-order" [queryParams]="{ input: 'text' }">
        <span class="tile-icon"><mat-icon>edit_note</mat-icon></span>
        <span class="tile-text">
          <strong>Type your medicines</strong>
          <span>Know what you need? Just list it.</span>
        </span>
        <mat-icon class="go">arrow_forward</mat-icon>
      </a>
      <a class="tile" routerLink="/my/new-order" [queryParams]="{ input: 'voice' }">
        <span class="tile-icon"><mat-icon>mic</mat-icon></span>
        <span class="tile-text">
          <strong>Record a voice note</strong>
          <span>Say it instead of typing it.</span>
        </span>
        <mat-icon class="go">arrow_forward</mat-icon>
      </a>
    </section>

    <div class="two">
      <section class="panel" aria-labelledby="active-title">
        <header class="panel-head">
          <h2 id="active-title">Active orders</h2>
          @if (store.orders().length) {
            <a routerLink="/my/orders" class="link">View all</a>
          }
        </header>

        @if (active().length) {
          <ul class="orders">
            @for (order of active(); track order.orderId) {
              <li>
                <a [routerLink]="['/my/orders', order.orderId]" class="order">
                  <span class="o-top">
                    <strong>{{ order.orderNumber }}</strong>
                    <span class="o-date">{{ order.createdOn | date: 'd MMM, h:mm a' }}</span>
                  </span>
                  <span class="o-status">{{ headline(order) }}</span>
                  <app-order-tracker [order]="order" variant="compact" />
                </a>
              </li>
            }
          </ul>
        } @else if (store.orders().length) {
          <div class="empty">
            <mat-icon>check_circle</mat-icon>
            <p>No orders in progress. Everything you've ordered has been delivered.</p>
          </div>
        } @else if (!store.loading()) {
          <ol class="how">
            <li><span>1</span><div><strong>Send your prescription</strong><p>A photo, a typed list or a voice note.</p></div></li>
            <li><span>2</span><div><strong>A nearby chemist bills it</strong><p>You see the exact amount before paying.</p></div></li>
            <li><span>3</span><div><strong>Pay and it's on its way</strong><p>Share your delivery code at the door.</p></div></li>
          </ol>
        }
      </section>

      <section class="panel" aria-labelledby="addr-title">
        <header class="panel-head">
          <h2 id="addr-title">Delivering to</h2>
          <a routerLink="/my/addresses" class="link">Manage</a>
        </header>
        @if (store.defaultAddress(); as addr) {
          <div class="addr">
            <mat-icon>location_on</mat-icon>
            <div>
              <strong>{{ addr.isDefault ? 'Default address' : 'Saved address' }}</strong>
              <p>{{ formatAddress(addr) }}</p>
            </div>
          </div>
        } @else if (!store.loading()) {
          <div class="empty">
            <mat-icon>add_location_alt</mat-icon>
            <p>Add a delivery address so we can match you with a chemist nearby.</p>
            <a matButton="outlined" class="pt-round" routerLink="/my/addresses">Add address</a>
          </div>
        }
      </section>
    </div>
  `,
  styles: `
    :host { display: flex; flex-direction: column; gap: 28px; }
    .loading { position: fixed; top: 68px; left: 0; right: 0; z-index: 25; }
    .sr { position: absolute; width: 1px; height: 1px; overflow: hidden; clip: rect(0 0 0 0); }

    .hello { display: flex; flex-direction: column; gap: 6px; }
    .eyebrow { margin: 0; color: var(--pt-orange-deep); font-weight: 700; font-size: 0.85rem; letter-spacing: 0.04em; text-transform: uppercase; }
    h1 { margin: 0; font-size: clamp(1.7rem, 3.4vw, 2.4rem); font-weight: 800; letter-spacing: -0.025em; line-height: 1.12; text-wrap: balance; color: var(--pt-navy-deep); }

    .notice { display: flex; gap: 12px; align-items: center; padding: 14px 16px; border-radius: 14px; }
    .notice.stop { background: var(--pt-stop-soft); color: var(--pt-stop); }
    .notice div { flex: 1; }

    .attention {
      display: flex; align-items: center; gap: 16px; padding: 16px 18px 16px 16px;
      border-radius: var(--pt-radius); text-decoration: none; color: var(--pt-ink);
      background: var(--pt-orange-soft); border: 1px solid color-mix(in srgb, var(--pt-orange) 35%, transparent);
    }
    .attention.code { background: var(--pt-navy-soft); border-color: color-mix(in srgb, var(--pt-navy) 25%, transparent); }
    .att-icon { width: 46px; height: 46px; border-radius: 14px; display: grid; place-items: center; background: var(--pt-orange); color: #fff; flex: none; }
    .attention.code .att-icon { background: var(--pt-navy); }
    .att-body { display: flex; flex-direction: column; flex: 1; min-width: 0; }
    .att-body strong { font-weight: 700; font-size: 1.02rem; }
    .att-body span { color: var(--pt-muted); font-size: 0.9rem; }
    .otp { font: 800 1.6rem/1 Figtree, sans-serif; letter-spacing: 0.22em; color: var(--pt-navy-deep); background: #fff; padding: 10px 14px; border-radius: 12px; }
    .pay { pointer-events: none; }

    .start { display: grid; grid-template-columns: 1.35fr 1fr 1fr; gap: 16px; }
    .tile {
      display: flex; flex-direction: column; gap: 16px; padding: 22px; min-height: 176px;
      background: var(--pt-card); border: 1px solid var(--pt-line); border-radius: var(--pt-radius);
      text-decoration: none; color: var(--pt-ink); box-shadow: var(--pt-shadow); position: relative;
      transition: transform 160ms ease, box-shadow 160ms ease, border-color 160ms ease;
    }
    .tile:hover { transform: translateY(-2px); border-color: color-mix(in srgb, var(--pt-navy) 30%, transparent); }
    .tile:focus-visible { outline: 3px solid color-mix(in srgb, var(--pt-navy) 45%, transparent); outline-offset: 2px; }
    .tile.primary { background: linear-gradient(145deg, var(--pt-navy) 0%, var(--pt-navy-deep) 100%); color: #fff; border-color: transparent; }
    .tile-icon { width: 48px; height: 48px; border-radius: 14px; display: grid; place-items: center; background: var(--pt-navy-soft); color: var(--pt-navy); }
    .tile.primary .tile-icon { background: var(--pt-orange); color: #fff; }
    .tile-text { display: flex; flex-direction: column; gap: 4px; }
    .tile-text strong { font-size: 1.12rem; font-weight: 700; letter-spacing: -0.01em; }
    .tile-text span { font-size: 0.9rem; color: var(--pt-muted); line-height: 1.45; }
    .tile.primary .tile-text span { color: rgba(255, 255, 255, 0.78); }
    .go { position: absolute; top: 22px; right: 20px; color: var(--pt-faint); }
    .tile.primary .go { color: rgba(255, 255, 255, 0.7); }

    .two { display: grid; grid-template-columns: 1.5fr 1fr; gap: 20px; align-items: start; }
    .panel { background: var(--pt-card); border: 1px solid var(--pt-line); border-radius: var(--pt-radius); padding: 20px 22px; }
    .panel-head { display: flex; align-items: baseline; justify-content: space-between; margin-bottom: 14px; }
    .panel-head h2 { margin: 0; font-size: 1.1rem; font-weight: 700; }
    .link { color: var(--pt-navy); font-weight: 600; text-decoration: none; font-size: 0.92rem; }
    .link:hover { text-decoration: underline; }

    .orders { list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; gap: 10px; }
    .order { display: flex; flex-direction: column; gap: 8px; padding: 14px 16px; border-radius: 14px; background: var(--pt-ground); text-decoration: none; color: var(--pt-ink); }
    .order:hover { background: var(--pt-navy-soft); }
    .o-top { display: flex; justify-content: space-between; gap: 12px; }
    .o-top strong { font-weight: 700; font-variant-numeric: tabular-nums; }
    .o-date { color: var(--pt-faint); font-size: 0.85rem; }
    .o-status { font-size: 0.92rem; color: var(--pt-muted); }

    .addr { display: flex; gap: 12px; }
    .addr mat-icon { color: var(--pt-orange); flex: none; }
    .addr strong { font-weight: 700; }
    .addr p { margin: 2px 0 0; color: var(--pt-muted); line-height: 1.5; }

    .empty { display: flex; flex-direction: column; align-items: flex-start; gap: 10px; color: var(--pt-muted); }
    .empty mat-icon { color: var(--pt-good); }
    .empty p { margin: 0; line-height: 1.5; }

    .how { list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; gap: 14px; }
    .how li { display: flex; gap: 14px; }
    .how li > span { width: 30px; height: 30px; border-radius: 50%; background: var(--pt-navy-soft); color: var(--pt-navy); font-weight: 800; display: grid; place-items: center; flex: none; }
    .how strong { font-weight: 700; }
    .how p { margin: 2px 0 0; color: var(--pt-muted); font-size: 0.9rem; }

    @media (max-width: 900px) { .start { grid-template-columns: 1fr; } .tile { min-height: 0; flex-direction: row; align-items: center; } .go { position: static; margin-left: auto; } .two { grid-template-columns: 1fr; } }
    @media (prefers-reduced-motion: reduce) { .tile { transition: none; } .tile:hover { transform: none; } }
  `,
})
export class PortalHome {
  protected readonly store = inject(PortalStore);
  protected readonly formatAddress = formatAddress;

  protected readonly active = computed(() => this.store.activeOrders().slice(0, 4));

  protected readonly greeting = computed(() => {
    const hour = new Date().getHours();
    return hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
  });

  protected readonly attention = computed<AttentionItem[]>(() =>
    this.store.orders().flatMap((order): AttentionItem[] => {
      if (isPayable(order)) {
        const amount = rupees(paymentBreakdown(order.totalAmount ?? 0).total);
        return [{ order, kind: 'pay', title: 'Your bill is ready', subtitle: 'Pay to confirm your order', amount }];
      }
      if (order.orderStatus === OrderStatus.OutForDelivery && order.otp) {
        return [{ order, kind: 'code', title: 'Your order is on its way', subtitle: 'Share this code at delivery', amount: '' }];
      }
      return [];
    }),
  );

  protected headline(order: Parameters<typeof journeyOf>[0]): string {
    return journeyOf(order).headline;
  }
}
