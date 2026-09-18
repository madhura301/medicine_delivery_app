import { DatePipe } from '@angular/common';
import { HttpErrorResponse } from '@angular/common/http';
import {
  ChangeDetectionStrategy,
  Component,
  OnDestroy,
  computed,
  effect,
  inject,
  input,
  signal,
} from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { RouterLink } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { describeHttpError } from '../../../core/http/interceptors';
import { Order, Payment } from '../../../core/models/api.models';
import { OrderInputType, OrderStatus } from '../../../core/models/enums';
import { ToastService } from '../../../core/ui/toast.service';
import { LocationMap } from '../../../shared/ui/location-map';
import { extensionFrom, saveBlob } from '../../../shared/util/download';
import { formatAddress } from '../../customers/data/customers-api.service';
import { OrdersApiService } from '../../orders/data/orders-api.service';
import { isActive, isPayable, journeyOf, paymentBreakdown, rupees } from '../data/order-journey';
import { PortalApiService } from '../data/portal-api.service';
import { PortalStore } from '../data/portal.store';
import { openCheckout } from '../data/razorpay-checkout';
import { OrderTracker } from '../ui/order-tracker';

/** How often an open, in-progress order re-checks its status. */
const POLL_MS = 30_000;

@Component({
  selector: 'app-portal-order-detail',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    DatePipe, RouterLink, MatButtonModule, MatIconModule, MatProgressBarModule,
    MatProgressSpinnerModule, OrderTracker, LocationMap,
  ],
  template: `
    <a routerLink="/my/orders" class="back"><mat-icon>arrow_back</mat-icon>My orders</a>

    @if (loading() && !order()) {
      <mat-progress-bar mode="indeterminate" />
    } @else if (error() && !order()) {
      <div class="card notice">
        <mat-icon>error_outline</mat-icon>
        <div><strong>We couldn't open this order.</strong><p>{{ error() }}</p></div>
        <button matButton class="pt-round" (click)="load()">Try again</button>
      </div>
    } @else if (order(); as o) {

      <header class="head">
        <div>
          <p class="num">Order {{ o.orderNumber }}</p>
          <h1>{{ journey().headline }}</h1>
          <p class="detail">{{ journey().detail }}</p>
        </div>
        <span class="placed">Placed {{ o.createdOn | date: 'd MMM yyyy, h:mm a' }}</span>
      </header>

      <section class="card tracker" aria-label="Order progress">
        <app-order-tracker [order]="o" />
      </section>

      <!-- The one thing this order needs from the customer, if anything. -->
      @if (payable()) {
        <section class="card bill" aria-labelledby="bill-title">
          <div class="bill-top">
            <div>
              <h2 id="bill-title">Your bill is ready</h2>
              <p>From {{ o.medicalStoreName || 'your chemist' }}. Review it, then pay to send your order out.</p>
            </div>
            @if (o.orderBillFileLocation) {
              <button matButton="outlined" class="pt-round" (click)="downloadBill()" [disabled]="downloading()">
                <mat-icon>description</mat-icon>View bill
              </button>
            }
          </div>

          <dl class="sum">
            <dt>Medicines</dt><dd>{{ rupees(breakdown().bill) }}</dd>
            <dt>Payment charges <small>2%</small></dt><dd>{{ rupees(breakdown().gatewayCharges) }}</dd>
            <dt>GST on charges <small>18%</small></dt><dd>{{ rupees(breakdown().gst) }}</dd>
            <dt class="total">Total to pay</dt><dd class="total">{{ rupees(breakdown().total) }}</dd>
          </dl>

          @if (payError()) {
            <p class="pay-error" role="alert"><mat-icon>error_outline</mat-icon>{{ payError() }}</p>
          }

          <button matButton="filled" class="pt-cta pay" (click)="pay()" [disabled]="paying()">
            @if (paying()) { <span class="inner"><mat-spinner diameter="18" />{{ payStep() }}</span> } @else { <span class="inner"><mat-icon>lock</mat-icon>Pay {{ rupees(breakdown().total) }} securely</span> }
          </button>
          <p class="fine">Payments are processed by Razorpay. UPI, cards, net banking and wallets accepted.</p>
        </section>
      }

      @if (o.otp && showCode()) {
        <section class="card code" aria-labelledby="code-title">
          <div>
            <h2 id="code-title">Your delivery code</h2>
            <p>Share this code with the delivery partner only when your medicines are in your hands. Don't share it over the phone.</p>
          </div>
          <div class="digits" aria-label="Delivery code {{ o.otp }}">
            @for (d of o.otp.split(''); track $index) { <span>{{ d }}</span> }
          </div>
        </section>
      }

      <div class="grid">
        <section class="card" aria-labelledby="what-title">
          <h2 id="what-title">What you ordered</h2>
          <dl class="facts">
            <dt>Order type</dt><dd>{{ o.orderType === 2 ? 'Prescription medicines' : 'Over the counter' }}</dd>
            @if (o.medicalStoreName) { <dt>Chemist</dt><dd>{{ o.medicalStoreName }}</dd> }
          </dl>

          @switch (o.orderInputType) {
            @case (inputText) {
              <p class="typed">{{ o.orderInputText }}</p>
            }
            @case (inputImage) {
              @if (inputUrl()) {
                <a [href]="inputUrl()" target="_blank" rel="noopener" class="rx"><img [src]="inputUrl()" alt="Your prescription" /></a>
              } @else {
                <button matButton="outlined" class="pt-round" (click)="loadInput()" [disabled]="loadingInput()">
                  <mat-icon>image</mat-icon>Show my prescription
                </button>
              }
            }
            @case (inputVoice) {
              @if (inputUrl()) {
                <audio [src]="inputUrl()" controls></audio>
              } @else {
                <button matButton="outlined" class="pt-round" (click)="loadInput()" [disabled]="loadingInput()">
                  <mat-icon>play_arrow</mat-icon>Play my voice note
                </button>
              }
            }
          }
        </section>

        <section class="card" aria-labelledby="addr-title">
          <h2 id="addr-title">Delivery address</h2>
          @if (o.deliveryAddress; as a) {
            <p class="addr">{{ formatAddress(a) }}</p>
            @if (a.latitude !== null && a.longitude !== null) {
              <app-location-map class="map" [latitude]="a.latitude" [longitude]="a.longitude" label="Delivery location" [collapsible]="true" />
            }
          } @else {
            <p class="muted">Address details are not available for this order.</p>
          }
        </section>

        @if (o.totalAmount || payments().length) {
          <section class="card" aria-labelledby="pay-title">
            <h2 id="pay-title">Payment</h2>
            <dl class="facts">
              @if (o.totalAmount) { <dt>Bill amount</dt><dd>{{ rupees(o.totalAmount) }}</dd> }
              <dt>Status</dt><dd>{{ paymentLabel() }}</dd>
            </dl>
            @for (p of payments(); track p.id) {
              <div class="payment">
                <mat-icon>check_circle</mat-icon>
                <span>{{ rupees(p.amount) }}@if (p.paymentMethod) { · {{ p.paymentMethod }} }</span>
                <span class="muted">{{ p.paymentDate | date: 'd MMM, h:mm a' }}</span>
              </div>
            }
            @if (o.orderBillFileLocation && !payable()) {
              <button matButton class="pt-round" (click)="downloadBill()" [disabled]="downloading()"><mat-icon>download</mat-icon>Download bill</button>
            }
          </section>
        }
      </div>

      <p class="help">Something wrong with this order? <a routerLink="/my/help">Contact support</a> and quote <strong>{{ o.orderNumber }}</strong>.</p>
    }
  `,
  styles: `
    :host { display: flex; flex-direction: column; gap: 18px; }
    .back { display: inline-flex; align-items: center; gap: 4px; color: var(--pt-muted); text-decoration: none; font-weight: 600; font-size: 0.9rem; width: fit-content; }
    .back mat-icon { font-size: 18px; width: 18px; height: 18px; }
    .muted { color: var(--pt-muted); }

    .card { background: var(--pt-card); border: 1px solid var(--pt-line); border-radius: var(--pt-radius); padding: 22px; }
    .card h2 { margin: 0 0 12px; font-size: 1.08rem; font-weight: 700; }
    .notice { display: flex; gap: 12px; align-items: center; }
    .notice div { flex: 1; } .notice p { margin: 2px 0 0; color: var(--pt-muted); }

    .head { display: flex; justify-content: space-between; align-items: flex-end; gap: 16px; flex-wrap: wrap; }
    .num { margin: 0; font-weight: 700; color: var(--pt-orange-deep); font-size: 0.88rem; letter-spacing: 0.02em; font-variant-numeric: tabular-nums; }
    h1 { margin: 4px 0 6px; font-size: clamp(1.6rem, 3vw, 2.1rem); font-weight: 800; letter-spacing: -0.025em; line-height: 1.15; color: var(--pt-navy-deep); text-wrap: balance; }
    .detail { margin: 0; color: var(--pt-muted); max-width: 60ch; }
    .placed { color: var(--pt-faint); font-size: 0.88rem; }

    .tracker { padding: 26px 22px; }

    .bill { border: 2px solid var(--pt-orange); display: flex; flex-direction: column; gap: 16px; }
    .bill-top { display: flex; justify-content: space-between; gap: 16px; align-items: flex-start; flex-wrap: wrap; }
    .bill-top h2 { margin: 0 0 4px; font-size: 1.25rem; }
    .bill-top p { margin: 0; color: var(--pt-muted); }
    .sum { margin: 0; display: grid; grid-template-columns: 1fr auto; gap: 10px 20px; max-width: 460px; }
    .sum dt { color: var(--pt-muted); } .sum dt small { color: var(--pt-faint); margin-left: 4px; }
    .sum dd { margin: 0; text-align: right; font-variant-numeric: tabular-nums; font-weight: 600; }
    .sum .total { border-top: 1.5px solid var(--pt-line); padding-top: 12px; font-size: 1.15rem; font-weight: 800; color: var(--pt-ink); }
    .pay { height: 52px; font-size: 1.05rem; max-width: 460px; }
    .inner { display: inline-flex; align-items: center; gap: 8px; }
    .pay-error { display: flex; gap: 6px; align-items: center; margin: 0; color: var(--pt-stop); }
    .fine { margin: 0; color: var(--pt-faint); font-size: 0.82rem; }

    .code { display: flex; justify-content: space-between; align-items: center; gap: 20px; flex-wrap: wrap; background: linear-gradient(135deg, var(--pt-navy), var(--pt-navy-deep)); color: #fff; border: 0; }
    .code h2 { color: #fff; margin-bottom: 4px; }
    .code p { margin: 0; color: rgba(255,255,255,0.78); max-width: 46ch; }
    .digits { display: flex; gap: 10px; }
    .digits span { width: 56px; height: 68px; border-radius: 14px; background: #fff; color: var(--pt-navy-deep); display: grid; place-items: center; font: 800 2rem Figtree, sans-serif; }

    .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 16px; align-items: start; }
    .facts { margin: 0 0 14px; display: grid; grid-template-columns: auto 1fr; gap: 8px 16px; }
    .facts dt { color: var(--pt-muted); font-size: 0.9rem; }
    .facts dd { margin: 0; text-align: right; font-weight: 600; }
    .typed { margin: 0; white-space: pre-wrap; background: var(--pt-ground); padding: 14px 16px; border-radius: 12px; line-height: 1.6; }
    .rx img { width: 100%; max-height: 320px; object-fit: contain; border-radius: 12px; background: var(--pt-ground); border: 1px solid var(--pt-line); }
    audio { width: 100%; }
    .addr { margin: 0 0 12px; line-height: 1.55; }
    .map { display: block; --map-height: 220px; }
    .payment { display: flex; align-items: center; gap: 8px; padding: 10px 0; border-top: 1px solid var(--pt-line); font-size: 0.92rem; }
    .payment mat-icon { color: var(--pt-good); font-size: 20px; width: 20px; height: 20px; }
    .payment .muted { margin-left: auto; font-size: 0.85rem; }

    .help { margin: 4px 0 0; color: var(--pt-muted); text-align: center; }
    .help a { color: var(--pt-navy); font-weight: 700; }

    @media (max-width: 560px) { .digits span { width: 48px; height: 58px; font-size: 1.7rem; } }
  `,
})
export class PortalOrderDetail implements OnDestroy {
  private readonly api = inject(PortalApiService);
  private readonly ordersApi = inject(OrdersApiService);
  private readonly store = inject(PortalStore);
  private readonly toast = inject(ToastService);

  /** Bound from the `:id` route parameter. */
  readonly id = input.required<string>();

  protected readonly rupees = rupees;
  protected readonly formatAddress = formatAddress;
  protected readonly inputText = OrderInputType.Text;
  protected readonly inputImage = OrderInputType.Image;
  protected readonly inputVoice = OrderInputType.Voice;

  protected readonly order = signal<Order | null>(null);
  protected readonly payments = signal<Payment[]>([]);
  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);
  protected readonly paying = signal(false);
  protected readonly payStep = signal('');
  protected readonly payError = signal<string | null>(null);
  protected readonly downloading = signal(false);
  protected readonly loadingInput = signal(false);
  protected readonly inputUrl = signal<string | null>(null);

  private poll: ReturnType<typeof setInterval> | null = null;

  protected readonly journey = computed(() => journeyOf(this.order()!));
  protected readonly payable = computed(() => !!this.order() && isPayable(this.order()!));
  protected readonly breakdown = computed(() => paymentBreakdown(this.order()?.totalAmount ?? 0));
  protected readonly showCode = computed(() => {
    const status = this.order()?.orderStatus;
    return status === OrderStatus.Paid || status === OrderStatus.OutForDelivery || status === OrderStatus.BillUploaded;
  });
  protected readonly paymentLabel = computed(() => {
    const o = this.order();
    if (!o) return '';
    return ['Not paid', 'Partly paid', 'Paid in full'][o.orderPaymentStatus] ?? '—';
  });

  constructor() {
    effect(() => {
      this.id();
      this.resetInput();
      void this.load();
    });
  }

  protected async load(): Promise<void> {
    const orderId = Number(this.id());
    this.loading.set(true);
    this.error.set(null);
    try {
      const order = await firstValueFrom(this.api.order(orderId));
      this.order.set(order);
      this.store.upsertOrder(order);
      this.payments.set((await firstValueFrom(this.api.payments(orderId)).catch(() => [])) ?? []);
      this.schedulePoll(order);
    } catch (err) {
      this.error.set(describeHttpError(err as HttpErrorResponse));
    } finally {
      this.loading.set(false);
    }
  }

  /** Keeps an in-progress order fresh while it's on screen, so "on its way" appears without a reload. */
  private schedulePoll(order: Order): void {
    this.stopPoll();
    if (isActive(order) && !this.paying()) {
      this.poll = setInterval(() => void this.quietRefresh(), POLL_MS);
    }
  }

  private async quietRefresh(): Promise<void> {
    if (this.paying() || document.hidden) {
      return;
    }
    const order = await firstValueFrom(this.api.order(Number(this.id()))).catch(() => null);
    if (order) {
      this.order.set(order);
      this.store.upsertOrder(order);
      if (!isActive(order)) {
        this.stopPoll();
      }
    }
  }

  protected async pay(): Promise<void> {
    const order = this.order();
    if (!order || !this.payable()) {
      return;
    }
    const b = this.breakdown();
    const profile = this.store.profile();

    this.payError.set(null);
    this.paying.set(true);
    this.stopPoll();

    try {
      this.payStep.set('Preparing payment…');
      const gateway = await firstValueFrom(
        this.api.createPaymentOrder({ orderId: order.orderId, amount: b.total, billAmount: b.bill, convenienceFee: b.convenienceFee }),
      );

      this.payStep.set('Complete payment in the window…');
      const outcome = await openCheckout({
        keyId: gateway.keyId,
        razorpayOrderId: gateway.razorpayOrderId,
        amount: b.total,
        description: `Order ${order.orderNumber}`,
        prefill: {
          name: profile ? `${profile.customerFirstName} ${profile.customerLastName}`.trim() : undefined,
          contact: profile?.mobileNumber,
          email: profile?.emailId ?? undefined,
        },
      });

      if (outcome.kind === 'dismissed') {
        return;
      }
      if (outcome.kind === 'failed') {
        this.payError.set(`${outcome.reason} You have not been charged. Please try again.`);
        return;
      }

      this.payStep.set('Confirming payment…');
      await firstValueFrom(
        this.api.verifyPayment({
          orderId: order.orderId,
          razorpayOrderId: outcome.response.razorpay_order_id,
          razorpayPaymentId: outcome.response.razorpay_payment_id,
          razorpaySignature: outcome.response.razorpay_signature,
        }),
      );
      this.toast.success('Payment received. Your delivery code is below.');
    } catch (err) {
      const e = err as HttpErrorResponse | Error;
      this.payError.set(
        e instanceof HttpErrorResponse
          ? `${describeHttpError(e)} If money left your account, it will be matched to your order automatically — please don't pay twice.`
          : e.message,
      );
    } finally {
      this.paying.set(false);
      this.payStep.set('');
      await this.load();
    }
  }

  protected async downloadBill(): Promise<void> {
    const order = this.order();
    if (!order) return;
    this.downloading.set(true);
    try {
      const blob = await firstValueFrom(this.ordersApi.downloadBill(order.orderId));
      saveBlob(blob, `Pharmaish-bill-${order.orderNumber}.${extensionFrom(order.orderBillFileLocation, 'pdf')}`);
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    } finally {
      this.downloading.set(false);
    }
  }

  protected async loadInput(): Promise<void> {
    const order = this.order();
    if (!order) return;
    this.loadingInput.set(true);
    try {
      const blob = await firstValueFrom(this.ordersApi.downloadInputFile(order.orderId));
      this.resetInput();
      this.inputUrl.set(URL.createObjectURL(blob));
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    } finally {
      this.loadingInput.set(false);
    }
  }

  private resetInput(): void {
    const url = this.inputUrl();
    if (url) URL.revokeObjectURL(url);
    this.inputUrl.set(null);
  }

  private stopPoll(): void {
    if (this.poll) {
      clearInterval(this.poll);
      this.poll = null;
    }
  }

  ngOnDestroy(): void {
    this.stopPoll();
    this.resetInput();
  }
}
