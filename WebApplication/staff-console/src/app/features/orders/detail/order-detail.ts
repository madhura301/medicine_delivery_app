import { DatePipe } from '@angular/common';
import { HttpErrorResponse } from '@angular/common/http';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  effect,
  inject,
  input,
  signal,
} from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatDialog } from '@angular/material/dialog';
import { MatDividerModule } from '@angular/material/divider';
import { MatIconModule } from '@angular/material/icon';
import { Router } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { CapabilityService } from '../../../core/config/capabilities';
import { describeHttpError } from '../../../core/http/interceptors';
import { Customer, CustomerAddress, Order } from '../../../core/models/api.models';
import {
  AssignTo,
  OrderInputType,
  assignToLabel,
  orderInputTypeLabel,
  orderStatusLabel,
  paymentStatusLabel,
} from '../../../core/models/enums';
import { ToastService } from '../../../core/ui/toast.service';
import { PageHeader } from '../../../shared/ui/page-header';
import { ErrorState, LoadingState } from '../../../shared/ui/state-panels';
import { StatusChip } from '../../../shared/ui/status-chip';
import { extensionFrom, saveBlob } from '../../../shared/util/download';
import { CustomersApiService, formatAddress } from '../../customers/data/customers-api.service';
import {
  bucketLabel,
  bucketTone,
  currentOwner,
  formatAmount,
  paymentTone,
  statusTone,
} from '../data/order-buckets';
import { OrdersApiService } from '../data/orders-api.service';
import { OrdersStore } from '../data/orders.store';
import { CancelOrderData, CancelOrderDialog } from '../dialogs/cancel-order-dialog';
import { ReassignOrderData, ReassignOrderDialog } from '../dialogs/reassign-order-dialog';

@Component({
  selector: 'app-order-detail',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    DatePipe,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatDividerModule,
    PageHeader,
    LoadingState,
    ErrorState,
    StatusChip,
  ],
  template: `
    @if (loading()) {
      <app-loading-state message="Loading order…" />
    } @else if (error()) {
      <app-error-state [message]="error()!" [forbidden]="forbidden()" (retry)="load()" />
    } @else if (order(); as row) {
      <app-page-header
        [title]="row.orderNumber || '#' + row.orderId"
        [subtitle]="'Placed ' + (row.createdOn | date: 'medium')"
      >
        <div headerActions>
          <button matButton (click)="back()">
            <mat-icon>arrow_back</mat-icon>
            Back
          </button>
          @if (canReassign()) {
            <button matButton="filled" (click)="reassign()">
              <mat-icon>swap_horiz</mat-icon>
              Reassign to chemist
            </button>
          }
          @if (canCancel()) {
            <button matButton (click)="cancel()">
              <mat-icon>cancel</mat-icon>
              Cancel order
            </button>
          }
        </div>
      </app-page-header>

      @if (row.cancellationReason) {
        <div class="banner" role="status">
          <mat-icon>cancel</mat-icon>
          <div>
            <strong>This order was cancelled.</strong>
            <p>{{ row.cancellationReason }}</p>
          </div>
        </div>
      }

      <div class="chips">
        <app-status-chip
          [label]="orderStatusLabel(row.orderStatus)"
          [tone]="statusTone(row.orderStatus)"
        />
        <app-status-chip [label]="bucketLabel(row.assignTo)" [tone]="bucketTone(row.assignTo)" />
        <app-status-chip
          [label]="paymentStatusLabel(row.orderPaymentStatus)"
          [tone]="paymentTone(row.orderPaymentStatus)"
        />
        <span class="amount">{{ formatAmount(row.totalAmount) }}</span>
      </div>

      <div class="cards">
        <mat-card appearance="outlined">
          <mat-card-header><mat-card-title>Customer</mat-card-title></mat-card-header>
          <mat-card-content>
            <dl>
              <dt>Name</dt>
              <dd>{{ row.customerName || customerName() || '—' }}</dd>
              <dt>Mobile</dt>
              <dd>{{ customer()?.mobileNumber || '—' }}</dd>
              <dt>Delivery address</dt>
              <dd>{{ deliveryAddress() }}</dd>
              <dt>Pin code</dt>
              <dd>{{ pinCode() || '—' }}</dd>
            </dl>
          </mat-card-content>
        </mat-card>

        <mat-card appearance="outlined">
          <mat-card-header><mat-card-title>What was ordered</mat-card-title></mat-card-header>
          <mat-card-content>
            <dl>
              <dt>Input type</dt>
              <dd>{{ orderInputTypeLabel(row.orderInputType) }}</dd>
            </dl>

            @if (row.orderInputType === OrderInputType.Text) {
              <pre class="text-input">{{ row.orderInputText || 'No text supplied.' }}</pre>
            } @else if (row.orderInputFileLocation) {
              <button matButton="outlined" [disabled]="downloading()" (click)="downloadInput()">
                <mat-icon>download</mat-icon>
                Download {{ row.orderInputType === OrderInputType.Image ? 'prescription' : 'voice note' }}
              </button>
            } @else {
              <p class="hint">No attachment on this order.</p>
            }
          </mat-card-content>
        </mat-card>

        <mat-card appearance="outlined">
          <mat-card-header><mat-card-title>Current assignment</mat-card-title></mat-card-header>
          <mat-card-content>
            <dl>
              <dt>Bucket</dt>
              <dd>{{ assignToLabel(row.assignTo) }}</dd>
              <dt>Owner</dt>
              <dd>{{ currentOwner(row) }}</dd>
              <dt>Assigned by</dt>
              <dd>{{ row.assignedByType === 1 ? 'Customer support' : 'System' }}</dd>
              @if (row.medicalStoreName) {
                <dt>Chemist</dt>
                <dd>{{ row.medicalStoreName }}</dd>
              }
              @if (row.customerSupportName) {
                <dt>Support agent</dt>
                <dd>{{ row.customerSupportName }}</dd>
              }
              @if (row.managerName) {
                <dt>Manager</dt>
                <dd>{{ row.managerName }}</dd>
              }
              @if (row.deliveryBoyName) {
                <dt>Delivery partner</dt>
                <dd>{{ row.deliveryBoyName }}</dd>
              }
            </dl>
            <p class="hint">
              Names above stay on the record after a hand-off, so they show the order's history as
              well as its present owner.
            </p>
          </mat-card-content>
        </mat-card>

        <mat-card appearance="outlined">
          <mat-card-header><mat-card-title>Bill &amp; payment</mat-card-title></mat-card-header>
          <mat-card-content>
            @if (row.orderBillFileLocation) {
              <button matButton="outlined" [disabled]="downloading()" (click)="downloadBill()">
                <mat-icon>receipt</mat-icon>
                Download bill
              </button>
              <mat-divider class="spacer" />
            } @else {
              <p class="hint">No bill uploaded yet.</p>
            }

            @if (row.payments?.length) {
              <dl>
                @for (payment of row.payments; track payment.id) {
                  <dt>{{ payment.paymentDate ? (payment.paymentDate | date: 'mediumDate') : 'Payment' }}</dt>
                  <dd>{{ formatAmount(payment.amount) }}</dd>
                }
              </dl>
            } @else {
              <p class="hint">No payments recorded.</p>
            }
          </mat-card-content>
        </mat-card>

        <mat-card appearance="outlined" class="wide">
          <mat-card-header><mat-card-title>Assignment history</mat-card-title></mat-card-header>
          <mat-card-content>
            @if (!row.assignmentHistory?.length) {
              <p class="hint">No history recorded for this order.</p>
            } @else {
              <ol class="timeline">
                @for (entry of row.assignmentHistory; track entry.id) {
                  <li>
                    <div class="dot"></div>
                    <div class="entry">
                      <span class="entry-title">
                        {{ entry.assignTo }}
                        @if (entry.assigneeName) {
                          — {{ entry.assigneeName }}
                        }
                      </span>
                      <span class="entry-meta">
                        {{ entry.assignmentStatus }} ·
                        {{ entry.assignedOn | date: 'medium' }} ·
                        by {{ entry.assignedByType === 1 ? 'customer support' : 'the system' }}
                      </span>
                    </div>
                  </li>
                }
              </ol>
            }
          </mat-card-content>
        </mat-card>
      </div>
    }
  `,
  styles: `
    :host { display: block; }

    .chips {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      gap: 8px;
      margin-bottom: 20px;
    }
    .amount { margin-left: auto; font: var(--mat-sys-title-medium); }

    .banner {
      display: flex;
      gap: 12px;
      align-items: flex-start;
      padding: 14px 16px;
      margin-bottom: 20px;
      border-radius: 12px;
      background: var(--mat-sys-error-container);
      color: var(--mat-sys-on-error-container);
    }
    .banner p { margin: 4px 0 0; font: var(--mat-sys-body-medium); }

    .cards {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
      gap: 16px;
      align-items: start;
    }
    .wide { grid-column: 1 / -1; }

    dl { display: grid; grid-template-columns: auto 1fr; gap: 10px 20px; margin: 0; }
    dt { color: var(--mat-sys-on-surface-variant); font: var(--mat-sys-body-small); }
    dd { margin: 0; font: var(--mat-sys-body-medium); text-align: right; word-break: break-word; }

    .text-input {
      margin: 12px 0 0;
      padding: 12px;
      border-radius: 8px;
      background: var(--mat-sys-surface-container-highest);
      font: var(--mat-sys-body-medium);
      white-space: pre-wrap;
      word-break: break-word;
    }

    .hint { margin: 12px 0 0; color: var(--mat-sys-on-surface-variant); font: var(--mat-sys-body-small); }
    .spacer { margin: 16px 0; }

    .timeline { list-style: none; margin: 0; padding: 0; display: grid; gap: 4px; }
    .timeline li { display: flex; gap: 12px; padding: 8px 0; }
    .dot {
      flex: none;
      width: 10px;
      height: 10px;
      margin-top: 6px;
      border-radius: 50%;
      background: var(--mat-sys-primary);
    }
    .entry { display: flex; flex-direction: column; }
    .entry-title { font: var(--mat-sys-body-medium); }
    .entry-meta { color: var(--mat-sys-on-surface-variant); font: var(--mat-sys-body-small); }

    [headerActions] { display: flex; gap: 8px; flex-wrap: wrap; }
  `,
})
export class OrderDetail {
  readonly id = input.required<string>();

  private readonly api = inject(OrdersApiService);
  private readonly customersApi = inject(CustomersApiService);
  private readonly store = inject(OrdersStore);
  private readonly dialog = inject(MatDialog);
  private readonly toast = inject(ToastService);
  private readonly router = inject(Router);
  private readonly capabilities = inject(CapabilityService);

  protected readonly order = signal<Order | null>(null);
  protected readonly customer = signal<Customer | null>(null);
  protected readonly addresses = signal<CustomerAddress[]>([]);
  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);
  protected readonly forbidden = signal(false);
  protected readonly downloading = signal(false);

  // Referenced from the template.
  protected readonly orderStatusLabel = orderStatusLabel;
  protected readonly paymentStatusLabel = paymentStatusLabel;
  protected readonly orderInputTypeLabel = orderInputTypeLabel;
  protected readonly assignToLabel = assignToLabel;
  protected readonly OrderInputType = OrderInputType;
  protected readonly statusTone = statusTone;
  protected readonly paymentTone = paymentTone;
  protected readonly bucketTone = bucketTone;
  protected readonly bucketLabel = bucketLabel;
  protected readonly currentOwner = currentOwner;
  protected readonly formatAmount = formatAmount;

  protected readonly customerName = computed(() => {
    const c = this.customer();
    return c ? `${c.customerFirstName} ${c.customerLastName}`.trim() : '';
  });

  /** The address the order was placed against, not merely the customer's current default. */
  private readonly orderAddress = computed(() => {
    const order = this.order();
    if (!order) {
      return null;
    }
    return this.addresses().find((a) => a.id === order.customerAddressId) ?? null;
  });

  protected readonly deliveryAddress = computed(() => {
    const address = this.orderAddress();
    return address ? formatAddress(address) : '—';
  });

  protected readonly pinCode = computed(() => this.orderAddress()?.postalCode ?? null);

  /** Reassignment only makes sense while support or a manager holds the order. */
  protected readonly canReassign = computed(() => {
    const order = this.order();
    if (!order || !this.capabilities.can('reassignOrder')) {
      return false;
    }
    return order.assignTo === AssignTo.CustomerSupport || order.assignTo === AssignTo.Manager;
  });

  protected readonly canCancel = computed(() => {
    const order = this.order();
    if (!order || !this.capabilities.can('cancelOrder')) {
      return false;
    }
    return !order.cancellationReason;
  });

  constructor() {
    effect(() => {
      const id = Number(this.id());
      void this.load(id);
    });
  }

  protected async load(orderId = Number(this.id())): Promise<void> {
    this.loading.set(true);
    this.error.set(null);
    this.forbidden.set(false);

    try {
      const order = await firstValueFrom(this.api.get(orderId));
      this.order.set(order);

      // The customer record and their addresses are extras — a 403 here must not kill the page.
      const [customer, addresses] = await Promise.all([
        firstValueFrom(this.customersApi.get(order.customerId)).catch(() => null),
        firstValueFrom(this.customersApi.addresses(order.customerId)).catch(() => []),
      ]);
      this.customer.set(customer);
      this.addresses.set(customer?.addresses?.length ? customer.addresses : addresses);
    } catch (err) {
      const error = err as HttpErrorResponse;
      this.forbidden.set(error.status === 403);
      this.error.set(describeHttpError(error));
    } finally {
      this.loading.set(false);
    }
  }

  protected back(): void {
    void this.router.navigate(['/orders/all']);
  }

  protected async downloadInput(): Promise<void> {
    const order = this.order();
    if (!order) {
      return;
    }

    this.downloading.set(true);

    try {
      const blob = await firstValueFrom(this.api.downloadInputFile(order.orderId));
      const extension = extensionFrom(order.orderInputFileLocation, 'jpg');
      saveBlob(blob, `order-${order.orderNumber || order.orderId}-input.${extension}`);
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    } finally {
      this.downloading.set(false);
    }
  }

  protected async downloadBill(): Promise<void> {
    const order = this.order();
    if (!order) {
      return;
    }

    this.downloading.set(true);

    try {
      const blob = await firstValueFrom(this.api.downloadBill(order.orderId));
      const extension = extensionFrom(order.orderBillFileLocation, 'pdf');
      saveBlob(blob, `order-${order.orderNumber || order.orderId}-bill.${extension}`);
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    } finally {
      this.downloading.set(false);
    }
  }

  protected async reassign(): Promise<void> {
    const order = this.order();
    if (!order) {
      return;
    }

    const ref = this.dialog.open<ReassignOrderDialog, ReassignOrderData, boolean>(
      ReassignOrderDialog,
      {
        data: {
          orderId: order.orderId,
          orderNumber: order.orderNumber,
          pinCode: this.pinCode(),
          currentStoreName: order.medicalStoreName,
        },
        width: '520px',
        maxWidth: '94vw',
      },
    );

    if (await firstValueFrom(ref.afterClosed())) {
      this.store.invalidate();
      await this.load();
    }
  }

  protected async cancel(): Promise<void> {
    const order = this.order();
    if (!order) {
      return;
    }

    const ref = this.dialog.open<CancelOrderDialog, CancelOrderData, boolean>(CancelOrderDialog, {
      data: {
        orderId: order.orderId,
        orderNumber: order.orderNumber,
        customerName: order.customerName ?? this.customerName(),
      },
      width: '540px',
      maxWidth: '94vw',
    });

    if (await firstValueFrom(ref.afterClosed())) {
      this.store.invalidate();
      await this.load();
    }
  }
}
