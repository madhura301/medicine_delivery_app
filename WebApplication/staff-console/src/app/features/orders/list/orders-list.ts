import { DatePipe } from '@angular/common';
import { ChangeDetectionStrategy, Component, computed, effect, inject, input, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatSelectModule } from '@angular/material/select';
import { Router } from '@angular/router';
import { Order } from '../../../core/models/api.models';
import {
  ORDER_STATUS_LABELS,
  OrderPaymentStatus,
  OrderStatus,
  PAYMENT_STATUS_LABELS,
  orderStatusLabel,
  paymentStatusLabel,
} from '../../../core/models/enums';
import { DataTable, TableColumn } from '../../../shared/ui/data-table';
import { FilterBar } from '../../../shared/ui/filter-bar';
import { PageHeader } from '../../../shared/ui/page-header';
import {
  BucketDefinition,
  bucketBySlug,
  bucketLabel,
  bucketTone,
  currentOwner,
  formatAmount,
  paymentTone,
  statusTone,
} from '../data/order-buckets';
import { OrdersStore } from '../data/orders.store';

type StatusFilter = OrderStatus | 'all';
type PaymentFilter = OrderPaymentStatus | 'all';

/**
 * Serves all six order menus. The route supplies a slug; everything else — title, filtering,
 * empty copy — follows from the bucket definition.
 */
@Component({
  selector: 'app-orders-list',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [FormsModule, MatFormFieldModule, MatSelectModule, PageHeader, FilterBar, DataTable],
  template: `
    <app-page-header [title]="definition().title" [subtitle]="definition().subtitle" />

    @if (store.scopedToOwnQueue()) {
      <p class="scope-note">Showing only the orders assigned to you.</p>
    }

    <app-filter-bar
      [(search)]="search"
      searchLabel="Search order number or customer"
      (resetFilters)="resetFilters()"
    >
      <mat-form-field appearance="outline" subscriptSizing="dynamic">
        <mat-label>Status</mat-label>
        <mat-select [(ngModel)]="statusFilter">
          <mat-option value="all">All statuses</mat-option>
          @for (option of statusOptions; track option.value) {
            <mat-option [value]="option.value">{{ option.label }}</mat-option>
          }
        </mat-select>
      </mat-form-field>

      <mat-form-field appearance="outline" subscriptSizing="dynamic">
        <mat-label>Payment</mat-label>
        <mat-select [(ngModel)]="paymentFilter">
          <mat-option value="all">All payments</mat-option>
          @for (option of paymentOptions; track option.value) {
            <mat-option [value]="option.value">{{ option.label }}</mat-option>
          }
        </mat-select>
      </mat-form-field>
    </app-filter-bar>

    <app-data-table
      [rows]="filtered()"
      [columns]="columns()"
      [loading]="store.loading()"
      [error]="store.error()"
      [forbidden]="store.forbidden()"
      [trackBy]="trackBy"
      [emptyIcon]="definition().icon"
      [emptyTitle]="definition().emptyTitle"
      [emptyMessage]="definition().emptyMessage"
      clickable
      (rowClick)="open($event)"
      (retry)="reload()"
    />
  `,
  styles: `
    :host { display: block; }
    mat-form-field { min-width: 170px; }
    .scope-note {
      margin: -8px 0 16px;
      color: var(--mat-sys-on-surface-variant);
      font: var(--mat-sys-body-small);
    }
  `,
})
export class OrdersList {
  /** Route segment: all | awaiting-assignment | with-chemist | with-support | with-manager | with-delivery */
  readonly slug = input.required<string>();

  protected readonly store = inject(OrdersStore);
  private readonly router = inject(Router);
  private readonly datePipe = new DatePipe('en-US');

  protected readonly search = signal('');
  protected readonly statusFilter = signal<StatusFilter>('all');
  protected readonly paymentFilter = signal<PaymentFilter>('all');

  protected readonly definition = computed<BucketDefinition>(() => bucketBySlug(this.slug()));
  protected readonly trackBy = (row: Order) => row.orderId;

  protected readonly statusOptions = Object.entries(ORDER_STATUS_LABELS).map(([value, label]) => ({
    value: Number(value) as OrderStatus,
    label,
  }));

  protected readonly paymentOptions = Object.entries(PAYMENT_STATUS_LABELS).map(([value, label]) => ({
    value: Number(value) as OrderPaymentStatus,
    label,
  }));

  protected readonly columns = computed<TableColumn<Order>[]>(() => {
    const columns: TableColumn<Order>[] = [
      {
        key: 'orderNumber',
        header: 'Order',
        primary: true,
        value: (row) => row.orderNumber || `#${row.orderId}`,
      },
      { key: 'customerName', header: 'Customer', value: (row) => row.customerName || '—' },
      {
        key: 'createdOn',
        header: 'Created',
        value: (row) => this.datePipe.transform(row.createdOn, 'dd MMM y, HH:mm') ?? '—',
        sortValue: (row) => new Date(row.createdOn).getTime(),
      },
      {
        key: 'orderStatus',
        header: 'Status',
        value: (row) => orderStatusLabel(row.orderStatus),
        chip: (row) => ({
          label: orderStatusLabel(row.orderStatus),
          tone: statusTone(row.orderStatus),
        }),
      },
      {
        key: 'payment',
        header: 'Payment',
        value: (row) => paymentStatusLabel(row.orderPaymentStatus),
        chip: (row) => ({
          label: paymentStatusLabel(row.orderPaymentStatus),
          tone: paymentTone(row.orderPaymentStatus),
        }),
      },
      {
        key: 'totalAmount',
        header: 'Amount',
        value: (row) => formatAmount(row.totalAmount),
        sortValue: (row) => row.totalAmount ?? 0,
      },
      { key: 'owner', header: 'Current owner', value: (row) => currentOwner(row) },
    ];

    // The bucket screens all share one owner, so the column only earns its place on All Orders.
    if (this.definition().bucket === 'all') {
      columns.splice(6, 0, {
        key: 'bucket',
        header: 'Bucket',
        value: (row) => bucketLabel(row.assignTo),
        chip: (row) => ({ label: bucketLabel(row.assignTo), tone: bucketTone(row.assignTo) }),
      });
    }

    return columns;
  });

  protected readonly filtered = computed(() => {
    const bucket = this.definition().bucket;
    const term = this.search().trim().toLowerCase();
    const status = this.statusFilter();
    const payment = this.paymentFilter();

    return this.store
      .orders()
      .filter((order) => {
        if (bucket !== 'all' && order.assignTo !== bucket) {
          return false;
        }
        if (status !== 'all' && order.orderStatus !== status) {
          return false;
        }
        if (payment !== 'all' && order.orderPaymentStatus !== payment) {
          return false;
        }
        if (!term) {
          return true;
        }
        return [order.orderNumber, order.customerName, currentOwner(order)]
          .join(' ')
          .toLowerCase()
          .includes(term);
      })
      .sort((a, b) => new Date(b.createdOn).getTime() - new Date(a.createdOn).getTime());
  });

  constructor() {
    effect(() => {
      // Re-runs when the route moves between buckets.
      this.slug();
      void this.store.load();
    });
  }

  protected resetFilters(): void {
    this.search.set('');
    this.statusFilter.set('all');
    this.paymentFilter.set('all');
  }

  protected reload(): void {
    void this.store.load(true);
  }

  protected open(order: Order): void {
    void this.router.navigate(['/orders', order.orderId]);
  }
}
