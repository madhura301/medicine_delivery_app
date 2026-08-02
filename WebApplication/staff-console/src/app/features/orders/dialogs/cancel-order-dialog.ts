import { HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { firstValueFrom } from 'rxjs';
import { describeHttpError } from '../../../core/http/interceptors';
import { ToastService } from '../../../core/ui/toast.service';
import { firstErrorMessage } from '../../../shared/util/validators';
import { OrdersApiService } from '../data/orders-api.service';

export interface CancelOrderData {
  orderId: number;
  orderNumber: string | null;
  customerName: string | null;
}

@Component({
  selector: 'app-cancel-order-dialog',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    ReactiveFormsModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatCheckboxModule,
    MatButtonModule,
    MatProgressBarModule,
  ],
  template: `
    <h2 mat-dialog-title>Cancel order</h2>
    @if (busy()) {
      <mat-progress-bar mode="indeterminate" />
    }

    <mat-dialog-content>
      <p class="context">
        Order <strong>{{ data.orderNumber || data.orderId }}</strong>
        @if (data.customerName) {
          for {{ data.customerName }}
        }
        will be cancelled. The reason is stored on the order permanently.
      </p>

      <form [formGroup]="form" (ngSubmit)="save()">
        <mat-form-field appearance="outline" class="full">
          <mat-label>Reason for cancelling</mat-label>
          <textarea
            matInput
            formControlName="reason"
            rows="3"
            maxlength="500"
            placeholder="e.g. Customer requested cancellation — no longer needs the medicine."
          ></textarea>
          @if (form.controls.reason.touched && form.controls.reason.invalid) {
            <mat-error>{{ error() }}</mat-error>
          }
          <mat-hint align="end">{{ form.controls.reason.value.length }}/500</mat-hint>
        </mat-form-field>

        <mat-checkbox formControlName="confirmed">
          I understand this cannot be undone.
        </mat-checkbox>
      </form>
    </mat-dialog-content>

    <mat-dialog-actions align="end">
      <button matButton mat-dialog-close [disabled]="busy()">Keep order</button>
      <button
        matButton="filled"
        color="warn"
        [disabled]="form.invalid || busy()"
        (click)="save()"
      >
        Cancel order
      </button>
    </mat-dialog-actions>
  `,
  styles: `
    mat-dialog-content { min-width: min(480px, 84vw); }
    .context { margin: 0 0 16px; font: var(--mat-sys-body-medium); }
    .full { width: 100%; }
  `,
})
export class CancelOrderDialog {
  readonly data = inject<CancelOrderData>(MAT_DIALOG_DATA);
  private readonly fb = inject(FormBuilder);
  private readonly api = inject(OrdersApiService);
  private readonly toast = inject(ToastService);
  private readonly ref = inject(MatDialogRef<CancelOrderDialog, boolean>);

  protected readonly busy = signal(false);

  protected readonly form = this.fb.nonNullable.group({
    reason: ['', [Validators.required, Validators.minLength(10), Validators.maxLength(500)]],
    confirmed: [false, [Validators.requiredTrue]],
  });

  protected error(): string {
    return firstErrorMessage(this.form.controls.reason, 'A reason');
  }

  protected async save(): Promise<void> {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    this.busy.set(true);

    try {
      await firstValueFrom(this.api.cancel(this.data.orderId, this.form.controls.reason.value.trim()));
      this.toast.success('Order cancelled.');
      this.ref.close(true);
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    } finally {
      this.busy.set(false);
    }
  }
}
