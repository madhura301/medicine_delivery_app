import { DatePipe } from '@angular/common';
import { HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { provideNativeDateAdapter } from '@angular/material/core';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { Router } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { describeHttpError } from '../../../core/http/interceptors';
import { OrderLogListItem } from '../../../core/models/api.models';
import { ORDER_LOG_REASON_LABELS, OrderLogReason, orderLogReasonLabel } from '../../../core/models/enums';
import { DataTable, TableColumn } from '../../../shared/ui/data-table';
import { FilterBar } from '../../../shared/ui/filter-bar';
import { PageHeader } from '../../../shared/ui/page-header';
import { OrderLogsApiService } from '../data/order-logs-api.service';

const PAGE_SIZE = 200;

@Component({
  selector: 'app-order-logs-list',
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [provideNativeDateAdapter()],
  imports: [
    FormsModule,
    MatButtonModule,
    MatDatepickerModule,
    MatFormFieldModule,
    MatIconModule,
    MatInputModule,
    MatSelectModule,
    PageHeader,
    FilterBar,
    DataTable,
  ],
  template: `
    <app-page-header
      title="Order Log"
      subtitle="Every order a customer tried to place and could not, with the reason it was refused."
    >
      <div headerActions>
        <button matButton (click)="load()">
          <mat-icon>refresh</mat-icon>
          Refresh
        </button>
      </div>
    </app-page-header>

    <app-filter-bar
      [(search)]="search"
      searchLabel="Search name, mobile, address or reason"
      (resetFilters)="resetFilters()"
    >
      <mat-form-field appearance="outline" subscriptSizing="dynamic">
        <mat-label>Reason</mat-label>
        <mat-select [ngModel]="reason()" (ngModelChange)="onReasonChange($event)">
          <mat-option [value]="null">All reasons</mat-option>
          @for (option of reasonOptions; track option.value) {
            <mat-option [value]="option.value">{{ option.label }}</mat-option>
          }
        </mat-select>
      </mat-form-field>

      <mat-form-field appearance="outline" subscriptSizing="dynamic" class="pin">
        <mat-label>Pin code</mat-label>
        <input matInput [ngModel]="postalCode()" (ngModelChange)="onPostalCodeChange($event)" />
      </mat-form-field>

      <mat-form-field appearance="outline" subscriptSizing="dynamic">
        <mat-label>From</mat-label>
        <input matInput [matDatepicker]="fromPicker" [ngModel]="fromDate()" (ngModelChange)="onFromChange($event)" />
        <mat-datepicker-toggle matIconSuffix [for]="fromPicker" />
        <mat-datepicker #fromPicker />
      </mat-form-field>

      <mat-form-field appearance="outline" subscriptSizing="dynamic">
        <mat-label>To</mat-label>
        <input matInput [matDatepicker]="toPicker" [ngModel]="toDate()" (ngModelChange)="onToChange($event)" />
        <mat-datepicker-toggle matIconSuffix [for]="toPicker" />
        <mat-datepicker #toPicker />
      </mat-form-field>
    </app-filter-bar>

    <app-data-table
      [rows]="filtered()"
      [columns]="columns"
      [loading]="loading()"
      [error]="error()"
      [forbidden]="forbidden()"
      [trackBy]="trackBy"
      clickable
      emptyIcon="fact_check"
      emptyTitle="No refused orders"
      emptyMessage="Nothing matched your filters. When a customer cannot place an order, the reason appears here."
      (rowClick)="open($event)"
      (retry)="load()"
    />

    @if (hasMore()) {
      <div class="more">
        <span>Showing {{ logs().length }} of {{ totalCount() }} refused orders.</span>
        <button matButton (click)="loadMore()" [disabled]="loadingMore()">
          <mat-icon>expand_more</mat-icon>
          {{ loadingMore() ? 'Loading…' : 'Load more' }}
        </button>
      </div>
    }
  `,
  styles: `
    :host { display: block; }
    mat-form-field { min-width: 180px; }
    mat-form-field.pin { min-width: 120px; }
    [headerActions] { display: flex; gap: 8px; flex-wrap: wrap; }
    .more {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 12px;
      flex-wrap: wrap;
      margin-top: 16px;
      color: var(--mat-sys-on-surface-variant);
      font: var(--mat-sys-body-small);
    }
  `,
})
export class OrderLogsList {
  private readonly api = inject(OrderLogsApiService);
  private readonly router = inject(Router);
  private readonly datePipe = new DatePipe('en-IN');

  protected readonly logs = signal<OrderLogListItem[]>([]);
  protected readonly totalCount = signal(0);
  protected readonly page = signal(1);

  protected readonly loading = signal(true);
  protected readonly loadingMore = signal(false);
  protected readonly error = signal<string | null>(null);
  protected readonly forbidden = signal(false);

  protected readonly search = signal('');
  protected readonly reason = signal<OrderLogReason | null>(null);
  protected readonly postalCode = signal('');
  protected readonly fromDate = signal<Date | null>(null);
  protected readonly toDate = signal<Date | null>(null);

  protected readonly trackBy = (row: OrderLogListItem) => row.orderLogId;
  protected readonly hasMore = computed(() => this.logs().length < this.totalCount());

  protected readonly reasonOptions = Object.entries(ORDER_LOG_REASON_LABELS).map(([value, label]) => ({
    value: Number(value) as OrderLogReason,
    label,
  }));

  /**
   * Reason / pin code / dates are applied by the API; the free-text box additionally filters what is
   * already on screen so typing narrows the list immediately rather than on every keystroke's round
   * trip. Both use the same term, so the two can never disagree.
   */
  protected readonly filtered = computed(() => {
    const term = this.search().trim().toLowerCase();
    if (!term) {
      return this.logs();
    }
    return this.logs().filter((log) =>
      [log.customerName, log.customerMobileNumber, log.deliveryAddress, log.postalCode, log.reasonSummary]
        .filter(Boolean)
        .join(' ')
        .toLowerCase()
        .includes(term),
    );
  });

  protected readonly columns: TableColumn<OrderLogListItem>[] = [
    {
      key: 'createdOn',
      header: 'When',
      value: (row) => this.datePipe.transform(row.createdOn, 'dd MMM yyyy, HH:mm') ?? '—',
      sortValue: (row) => row.createdOn,
    },
    {
      key: 'customerName',
      header: 'Customer',
      primary: true,
      value: (row) => row.customerName || '—',
    },
    {
      key: 'customerMobileNumber',
      header: 'Mobile',
      value: (row) => row.customerMobileNumber || '—',
      hideOnMobile: true,
    },
    {
      key: 'postalCode',
      header: 'Pin code',
      value: (row) => row.postalCode || '—',
    },
    {
      key: 'reason',
      header: 'Reason',
      value: (row) => orderLogReasonLabel(row.reason),
      chip: (row) => ({
        label: orderLogReasonLabel(row.reason),
        tone: row.reason === OrderLogReason.ServiceAreaUnavailable ? 'warning' : 'danger',
      }),
    },
    {
      key: 'missing',
      header: 'Not available',
      value: (row) => missingRoles(row) || '—',
      sortable: false,
    },
    {
      key: 'deliveryAddress',
      header: 'Address',
      value: (row) => row.deliveryAddress || '—',
      hideOnMobile: true,
      sortable: false,
    },
  ];

  constructor() {
    void this.load();
  }

  protected async load(): Promise<void> {
    this.loading.set(true);
    this.error.set(null);
    this.forbidden.set(false);
    this.page.set(1);

    try {
      const result = await firstValueFrom(this.api.list(this.filters(1)));
      this.logs.set(result?.items ?? []);
      this.totalCount.set(result?.totalCount ?? 0);
    } catch (err) {
      const error = err as HttpErrorResponse;
      this.forbidden.set(error.status === 403);
      this.error.set(describeHttpError(error));
      this.logs.set([]);
      this.totalCount.set(0);
    } finally {
      this.loading.set(false);
    }
  }

  protected async loadMore(): Promise<void> {
    const next = this.page() + 1;
    this.loadingMore.set(true);
    try {
      const result = await firstValueFrom(this.api.list(this.filters(next)));
      this.logs.update((current) => [...current, ...(result?.items ?? [])]);
      this.totalCount.set(result?.totalCount ?? this.totalCount());
      this.page.set(next);
    } catch (err) {
      this.error.set(describeHttpError(err as HttpErrorResponse));
    } finally {
      this.loadingMore.set(false);
    }
  }

  protected open(log: OrderLogListItem): void {
    void this.router.navigate(['/order-logs', log.orderLogId]);
  }

  protected onReasonChange(value: OrderLogReason | null): void {
    this.reason.set(value);
    void this.load();
  }

  protected onPostalCodeChange(value: string): void {
    this.postalCode.set(value ?? '');
    void this.load();
  }

  protected onFromChange(value: Date | null): void {
    this.fromDate.set(value);
    void this.load();
  }

  protected onToChange(value: Date | null): void {
    this.toDate.set(value);
    void this.load();
  }

  protected resetFilters(): void {
    this.search.set('');
    this.reason.set(null);
    this.postalCode.set('');
    this.fromDate.set(null);
    this.toDate.set(null);
    void this.load();
  }

  private filters(page: number) {
    return {
      postalCode: this.postalCode(),
      reason: this.reason(),
      fromDate: this.fromDate(),
      toDate: this.toDate(),
      page,
      pageSize: PAGE_SIZE,
    };
  }
}

/** The human-readable list of roles that were missing, e.g. "Chemist, Delivery partner". */
export function missingRoles(log: OrderLogListItem): string {
  return [
    log.chemistUnavailable ? 'Chemist' : null,
    log.customerSupportUnavailable ? 'Customer support' : null,
    log.deliveryBoyUnavailable ? 'Delivery partner' : null,
  ]
    .filter(Boolean)
    .join(', ');
}
