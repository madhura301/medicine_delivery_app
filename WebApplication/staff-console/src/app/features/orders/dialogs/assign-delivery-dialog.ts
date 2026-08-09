import { HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatRadioModule } from '@angular/material/radio';
import { RouterLink } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { describeHttpError } from '../../../core/http/interceptors';
import { DeliveryBoy } from '../../../core/models/api.models';
import { ToastService } from '../../../core/ui/toast.service';
import { LoadingState } from '../../../shared/ui/state-panels';
import { deliveryBoyName } from '../../delivery-boys/data/delivery-boys-api.service';
import { OrdersApiService } from '../data/orders-api.service';

export interface AssignDeliveryData {
  orderId: number;
  orderNumber: string | null;
  /** Shown so the user can see which delivery region the candidate list came from. */
  pinCode: string | null;
  currentPartnerName: string | null;
}

/**
 * Hands an order to a delivery partner.
 *
 * Normally the chemist does this from their own portal; this dialog lets Admin, Manager and
 * Customer Support step in. Candidates come from the delivery region covering the order's pin
 * code, so an empty list means a coverage gap rather than a missing partner.
 */
@Component({
  selector: 'app-assign-delivery-dialog',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    FormsModule,
    RouterLink,
    MatDialogModule,
    MatRadioModule,
    MatButtonModule,
    MatIconModule,
    MatProgressBarModule,
    LoadingState,
  ],
  template: `
    <h2 mat-dialog-title>Assign a delivery partner</h2>
    @if (saving()) {
      <mat-progress-bar mode="indeterminate" />
    }

    <mat-dialog-content>
      <p class="context">
        Order <strong>{{ data.orderNumber || data.orderId }}</strong>
        @if (data.currentPartnerName) {
          — currently with {{ data.currentPartnerName }}
        }
      </p>

      @if (loading()) {
        <app-loading-state message="Finding eligible partners…" />
      } @else if (loadError()) {
        <p class="error">{{ loadError() }}</p>
      } @else if (!partners().length) {
        <div class="empty">
          <mat-icon>person_off</mat-icon>
          <p>
            No delivery partner is eligible for pin code
            <strong>{{ data.pinCode || 'this address' }}</strong
            >.
          </p>
          <p class="muted">
            Eligibility comes from the delivery region covering the pin code. Either no region covers
            it, or the region has no active partner.
          </p>
          <a matButton routerLink="/regions/delivery" mat-dialog-close>
            <mat-icon>map</mat-icon>
            Open delivery regions
          </a>
        </div>
      } @else {
        <p class="muted">
          Partners covering pin code {{ data.pinCode || '—' }}:
        </p>
        <mat-radio-group class="options" [(ngModel)]="selectedId">
          @for (partner of partners(); track partner.id) {
            <mat-radio-button [value]="partner.id">
              <span class="name">{{ name(partner) }}</span>
              <span class="sub">{{ partner.mobileNumber || 'No mobile on file' }}</span>
            </mat-radio-button>
          }
        </mat-radio-group>
      }
    </mat-dialog-content>

    <mat-dialog-actions align="end">
      <button matButton mat-dialog-close [disabled]="saving()">Cancel</button>
      <button matButton="filled" [disabled]="selectedId === null || saving()" (click)="save()">
        Assign
      </button>
    </mat-dialog-actions>
  `,
  styles: `
    mat-dialog-content { min-width: min(460px, 82vw); }
    .context { margin: 0 0 12px; font: var(--mat-sys-body-medium); }
    .muted { color: var(--mat-sys-on-surface-variant); font: var(--mat-sys-body-small); }
    .options { display: flex; flex-direction: column; gap: 6px; max-height: 320px; overflow-y: auto; }
    .name { display: block; font: var(--mat-sys-body-medium); }
    .sub { display: block; color: var(--mat-sys-on-surface-variant); font: var(--mat-sys-body-small); }
    .error { color: var(--mat-sys-error); font: var(--mat-sys-body-medium); }

    .empty {
      display: flex;
      flex-direction: column;
      align-items: center;
      text-align: center;
      gap: 6px;
      padding: 16px 8px;
    }
    .empty mat-icon { width: 40px; height: 40px; font-size: 40px; opacity: 0.5; }
    .empty p { margin: 0; }
    .empty a { margin-top: 12px; }
  `,
})
export class AssignDeliveryDialog {
  readonly data = inject<AssignDeliveryData>(MAT_DIALOG_DATA);
  private readonly api = inject(OrdersApiService);
  private readonly toast = inject(ToastService);
  private readonly ref = inject(MatDialogRef<AssignDeliveryDialog, boolean>);

  protected readonly partners = signal<DeliveryBoy[]>([]);
  protected readonly loading = signal(true);
  protected readonly loadError = signal<string | null>(null);
  protected readonly saving = signal(false);
  protected selectedId: number | null = null;

  protected readonly name = deliveryBoyName;

  constructor() {
    void this.load();
  }

  private async load(): Promise<void> {
    try {
      const partners = (await firstValueFrom(this.api.eligibleDeliveryBoys(this.data.orderId))) ?? [];
      this.partners.set(partners.filter((p) => p.isActive && !p.isDeleted));
    } catch (err) {
      this.loadError.set(describeHttpError(err as HttpErrorResponse));
    } finally {
      this.loading.set(false);
    }
  }

  protected async save(): Promise<void> {
    if (this.selectedId === null) {
      return;
    }

    this.saving.set(true);

    try {
      await firstValueFrom(this.api.assignDelivery(this.data.orderId, this.selectedId));
      this.toast.success('Delivery partner assigned. The order is now out for delivery.');
      this.ref.close(true);
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    } finally {
      this.saving.set(false);
    }
  }
}
