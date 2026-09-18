import { HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { firstValueFrom } from 'rxjs';
import { describeHttpError } from '../../../core/http/interceptors';
import { ToastService } from '../../../core/ui/toast.service';
import { OrdersApiService } from '../data/orders-api.service';

export interface RejectOrderData {
  orderId: number;
  orderNumber: string | null;
}

/**
 * Chemist declines an order routed to their store. The reason is required by the API and is shown
 * to the support agent who has to place the order with another chemist, so the copy asks for
 * something useful rather than "no".
 */
@Component({
  selector: 'app-reject-order-dialog',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    ReactiveFormsModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatProgressBarModule,
  ],
  template: `
    <h2 mat-dialog-title>Reject order {{ data.orderNumber ?? '#' + data.orderId }}</h2>
    @if (busy()) {
      <mat-progress-bar mode="indeterminate" />
    }

    <mat-dialog-content>
      <p class="lead">
        The order goes back to customer support, who will try another chemist. Tell them why so they
        do not send it straight back.
      </p>

      <form [formGroup]="form" (ngSubmit)="submit()">
        <mat-form-field appearance="outline">
          <mat-label>Reason for rejecting</mat-label>
          <textarea
            matInput
            formControlName="rejectNote"
            rows="3"
            placeholder="e.g. Item out of stock until Friday"
          ></textarea>
          @if (form.controls.rejectNote.touched && form.controls.rejectNote.invalid) {
            <mat-error>A reason is required.</mat-error>
          }
        </mat-form-field>
      </form>
    </mat-dialog-content>

    <mat-dialog-actions align="end">
      <button matButton mat-dialog-close [disabled]="busy()">Cancel</button>
      <button matButton="filled" [disabled]="busy()" (click)="submit()">Reject order</button>
    </mat-dialog-actions>
  `,
  styles: `
    .lead {
      margin: 0 0 12px;
      color: var(--mat-sys-on-surface-variant);
      font: var(--mat-sys-body-medium);
    }
    mat-form-field { width: 100%; }
  `,
})
export class RejectOrderDialog {
  private readonly fb = inject(FormBuilder);
  private readonly api = inject(OrdersApiService);
  private readonly toast = inject(ToastService);
  private readonly ref = inject(MatDialogRef<RejectOrderDialog, boolean>);

  protected readonly data = inject<RejectOrderData>(MAT_DIALOG_DATA);
  protected readonly busy = signal(false);

  protected readonly form = this.fb.nonNullable.group({
    rejectNote: ['', [Validators.required, Validators.maxLength(500)]],
  });

  protected async submit(): Promise<void> {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    this.busy.set(true);

    try {
      await firstValueFrom(
        this.api.reject(this.data.orderId, this.form.controls.rejectNote.value.trim()),
      );
      this.toast.success('Order rejected and sent back to customer support.');
      this.ref.close(true);
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    } finally {
      this.busy.set(false);
    }
  }
}
