import { HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatRadioModule } from '@angular/material/radio';
import { firstValueFrom } from 'rxjs';
import { describeHttpError } from '../../../core/http/interceptors';
import { MedicalStoreBasic } from '../../../core/models/api.models';
import { ToastService } from '../../../core/ui/toast.service';
import { LoadingState } from '../../../shared/ui/state-panels';
import { OrdersApiService } from '../data/orders-api.service';

export interface ReassignOrderData {
  orderId: number;
  orderNumber: string | null;
  /** The delivery address pin code, shown so the user can judge the candidate list. */
  pinCode: string | null;
  currentStoreName: string | null;
}

type Scope = 'pincode' | 'city';

/**
 * Moves a rejected or escalated order to a different chemist. Candidates start at the delivery
 * pin code and can be widened to the whole city when nothing nearby is available.
 */
@Component({
  selector: 'app-reassign-order-dialog',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    FormsModule,
    MatDialogModule,
    MatRadioModule,
    MatButtonModule,
    MatIconModule,
    MatProgressBarModule,
    LoadingState,
  ],
  template: `
    <h2 mat-dialog-title>Reassign to another chemist</h2>
    @if (saving()) {
      <mat-progress-bar mode="indeterminate" />
    }

    <mat-dialog-content>
      <p class="context">
        Order <strong>{{ data.orderNumber || data.orderId }}</strong>
        @if (data.currentStoreName) {
          — currently with {{ data.currentStoreName }}
        }
      </p>

      <div class="scope">
        <span class="scope-label">
          Showing chemists
          {{ scope() === 'pincode' ? 'in pin code ' + (data.pinCode || '—') : 'across the city' }}
        </span>
        @if (scope() === 'pincode') {
          <button matButton (click)="widen()">
            <mat-icon>zoom_out_map</mat-icon>
            Widen to city
          </button>
        } @else {
          <button matButton (click)="narrow()">
            <mat-icon>zoom_in_map</mat-icon>
            Back to pin code
          </button>
        }
      </div>

      @if (loading()) {
        <app-loading-state message="Finding chemists…" />
      } @else if (loadError()) {
        <p class="error">{{ loadError() }}</p>
      } @else if (!candidates().length) {
        <p class="error">
          No chemists found {{ scope() === 'pincode' ? 'in this pin code' : 'in this city' }}.
          @if (scope() === 'pincode') {
            Try widening the search.
          }
        </p>
      } @else {
        <mat-radio-group class="options" [(ngModel)]="selectedId">
          @for (store of candidates(); track store.medicalStoreId) {
            <mat-radio-button [value]="store.medicalStoreId">
              {{ store.medicalName }}
            </mat-radio-button>
          }
        </mat-radio-group>
      }
    </mat-dialog-content>

    <mat-dialog-actions align="end">
      <button matButton mat-dialog-close [disabled]="saving()">Cancel</button>
      <button matButton="filled" [disabled]="!selectedId || saving()" (click)="save()">
        Reassign
      </button>
    </mat-dialog-actions>
  `,
  styles: `
    mat-dialog-content { min-width: min(460px, 82vw); }
    .context { margin: 0 0 12px; font: var(--mat-sys-body-medium); }
    .scope {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      justify-content: space-between;
      gap: 8px;
      margin-bottom: 12px;
    }
    .scope-label { color: var(--mat-sys-on-surface-variant); font: var(--mat-sys-body-small); }
    .options { display: flex; flex-direction: column; gap: 4px; max-height: 320px; overflow-y: auto; }
    .error { color: var(--mat-sys-error); font: var(--mat-sys-body-medium); }
  `,
})
export class ReassignOrderDialog {
  readonly data = inject<ReassignOrderData>(MAT_DIALOG_DATA);
  private readonly api = inject(OrdersApiService);
  private readonly toast = inject(ToastService);
  private readonly ref = inject(MatDialogRef<ReassignOrderDialog, boolean>);

  protected readonly candidates = signal<MedicalStoreBasic[]>([]);
  protected readonly loading = signal(true);
  protected readonly loadError = signal<string | null>(null);
  protected readonly saving = signal(false);
  protected readonly scope = signal<Scope>('pincode');
  protected selectedId: string | null = null;

  protected readonly hasPinCode = computed(() => !!this.data.pinCode);

  constructor() {
    void this.load();
  }

  private async load(): Promise<void> {
    this.loading.set(true);
    this.loadError.set(null);
    this.selectedId = null;

    try {
      const request =
        this.scope() === 'pincode'
          ? this.api.candidatesByPinCode(this.data.orderId)
          : this.api.candidatesByCity(this.data.orderId);
      this.candidates.set((await firstValueFrom(request)) ?? []);
    } catch (err) {
      this.candidates.set([]);
      this.loadError.set(describeHttpError(err as HttpErrorResponse));
    } finally {
      this.loading.set(false);
    }
  }

  protected widen(): void {
    this.scope.set('city');
    void this.load();
  }

  protected narrow(): void {
    this.scope.set('pincode');
    void this.load();
  }

  protected async save(): Promise<void> {
    if (!this.selectedId) {
      return;
    }

    this.saving.set(true);

    try {
      await firstValueFrom(this.api.reassign(this.data.orderId, this.selectedId));
      this.toast.success('Order reassigned. It is now with the new chemist.');
      this.ref.close(true);
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    } finally {
      this.saving.set(false);
    }
  }
}
