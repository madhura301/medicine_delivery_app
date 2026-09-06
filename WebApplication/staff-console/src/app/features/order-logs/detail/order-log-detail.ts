import { DatePipe } from '@angular/common';
import { HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, computed, effect, inject, input, signal } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { Router } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { describeHttpError } from '../../../core/http/interceptors';
import { OrderLog } from '../../../core/models/api.models';
import { OrderLogReason, orderLogReasonLabel } from '../../../core/models/enums';
import { LocationMap } from '../../../shared/ui/location-map';
import { PageHeader } from '../../../shared/ui/page-header';
import { ErrorState, LoadingState } from '../../../shared/ui/state-panels';
import { StatusChip } from '../../../shared/ui/status-chip';
import { OrderLogsApiService } from '../data/order-logs-api.service';

@Component({
  selector: 'app-order-log-detail',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    DatePipe,
    MatButtonModule,
    MatCardModule,
    MatIconModule,
    PageHeader,
    LoadingState,
    ErrorState,
    StatusChip,
    LocationMap,
  ],
  template: `
    @if (loading()) {
      <app-loading-state message="Loading order log…" />
    } @else if (error()) {
      <app-error-state [message]="error()!" [forbidden]="forbidden()" (retry)="load()" />
    } @else if (log(); as row) {
      <app-page-header
        [title]="row.customerName || 'Refused order'"
        [subtitle]="(row.createdOn | date: 'dd MMM yyyy, HH:mm') ?? ''"
      >
        <div headerActions>
          <button matButton (click)="back()">
            <mat-icon>arrow_back</mat-icon>
            Back
          </button>
        </div>
      </app-page-header>

      <div class="cards">
        <mat-card appearance="outlined">
          <mat-card-header><mat-card-title>Why the order was refused</mat-card-title></mat-card-header>
          <mat-card-content>
            <dl>
              <dt>Reason</dt>
              <dd>
                <app-status-chip [label]="reasonLabel()" [tone]="reasonTone()" />
              </dd>
              <dt>Summary</dt>
              <dd>{{ row.reasonSummary || '—' }}</dd>
              <dt>Chemist</dt>
              <dd>
                <app-status-chip
                  [label]="row.chemistUnavailable ? 'Not available' : 'Available'"
                  [tone]="row.chemistUnavailable ? 'danger' : 'positive'"
                />
              </dd>
              <dt>Customer support</dt>
              <dd>
                <app-status-chip
                  [label]="row.customerSupportUnavailable ? 'Not available' : 'Available'"
                  [tone]="row.customerSupportUnavailable ? 'danger' : 'positive'"
                />
              </dd>
              <dt>Delivery partner</dt>
              <dd>
                <app-status-chip
                  [label]="row.deliveryBoyUnavailable ? 'Not available' : 'Available'"
                  [tone]="row.deliveryBoyUnavailable ? 'danger' : 'positive'"
                />
              </dd>
              <dt>Recorded</dt>
              <dd>{{ row.createdOn | date: 'dd MMM yyyy, HH:mm:ss' }}</dd>
            </dl>

            @if (row.reason === serviceAreaUnavailable) {
              <p class="hint">
                To make this area serviceable, map the pin code to a customer-support region and a
                delivery region with at least one active person in each, and make sure an eligible
                chemist (payout account Active and activation fee Paid) covers the address.
              </p>
            }
          </mat-card-content>
        </mat-card>

        <mat-card appearance="outlined">
          <mat-card-header><mat-card-title>Customer</mat-card-title></mat-card-header>
          <mat-card-content>
            <dl>
              <dt>Name</dt>
              <dd>{{ row.customerName || '—' }}</dd>
              <dt>Mobile</dt>
              <dd>{{ row.customerMobileNumber || '—' }}</dd>
            </dl>

            @if (row.customerId) {
              <p class="hint">
                <button matButton (click)="openCustomer(row.customerId!)">
                  <mat-icon>person</mat-icon>
                  Open customer
                </button>
              </p>
            }
          </mat-card-content>
        </mat-card>

        <mat-card appearance="outlined" class="wide">
          <mat-card-header><mat-card-title>Delivery address</mat-card-title></mat-card-header>
          <mat-card-content>
            <dl>
              <dt>Address</dt>
              <dd>{{ row.deliveryAddress || '—' }}</dd>
              <dt>Pin code</dt>
              <dd>{{ row.postalCode || '—' }}</dd>
              <dt>Latitude</dt>
              <dd>{{ row.latitude ?? '—' }}</dd>
              <dt>Longitude</dt>
              <dd>{{ row.longitude ?? '—' }}</dd>
            </dl>

            <app-location-map
              class="map"
              [latitude]="row.latitude"
              [longitude]="row.longitude"
              [label]="row.deliveryAddress ?? ''"
            />
          </mat-card-content>
        </mat-card>

        <mat-card appearance="outlined" class="wide">
          <mat-card-header><mat-card-title>Full log</mat-card-title></mat-card-header>
          <mat-card-content>
            @if (row.details) {
              <pre>{{ row.details }}</pre>
            } @else {
              <p class="hint">No additional detail was recorded for this attempt.</p>
            }
          </mat-card-content>
        </mat-card>
      </div>
    }
  `,
  styles: `
    :host { display: block; }
    .cards {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
      gap: 16px;
    }
    dl { display: grid; grid-template-columns: auto 1fr; gap: 10px 20px; margin: 0; }
    dt { color: var(--mat-sys-on-surface-variant); font: var(--mat-sys-body-small); }
    dd { margin: 0; font: var(--mat-sys-body-medium); text-align: right; word-break: break-word; }
    .hint {
      margin: 12px 0 0;
      color: var(--mat-sys-on-surface-variant);
      font: var(--mat-sys-body-small);
    }
    .wide { grid-column: 1 / -1; }
    .map { display: block; margin-top: 16px; --map-height: 300px; }
    pre {
      margin: 0;
      padding: 12px;
      border-radius: 8px;
      background: var(--mat-sys-surface-container-low);
      font: var(--mat-sys-body-small);
      font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
      white-space: pre-wrap;
      word-break: break-word;
      overflow-x: auto;
    }
    [headerActions] { display: flex; gap: 8px; flex-wrap: wrap; }
  `,
})
export class OrderLogDetail {
  private readonly api = inject(OrderLogsApiService);
  private readonly router = inject(Router);

  /** Bound from the `:id` route parameter via withComponentInputBinding(). */
  readonly id = input.required<string>();

  protected readonly serviceAreaUnavailable = OrderLogReason.ServiceAreaUnavailable;

  protected readonly log = signal<OrderLog | null>(null);
  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);
  protected readonly forbidden = signal(false);

  protected readonly reasonLabel = computed(() => {
    const row = this.log();
    return row ? orderLogReasonLabel(row.reason) : '';
  });

  protected readonly reasonTone = computed(() =>
    this.log()?.reason === OrderLogReason.ServiceAreaUnavailable ? ('warning' as const) : ('danger' as const),
  );

  constructor() {
    effect(() => {
      this.id();
      void this.load();
    });
  }

  protected async load(): Promise<void> {
    this.loading.set(true);
    this.error.set(null);
    this.forbidden.set(false);

    try {
      this.log.set(await firstValueFrom(this.api.get(Number(this.id()))));
    } catch (err) {
      const error = err as HttpErrorResponse;
      this.forbidden.set(error.status === 403);
      this.error.set(describeHttpError(error));
    } finally {
      this.loading.set(false);
    }
  }

  protected back(): void {
    void this.router.navigate(['/order-logs']);
  }

  protected openCustomer(customerId: string): void {
    void this.router.navigate(['/customers', customerId]);
  }
}
