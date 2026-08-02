import { HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, computed, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatSelectModule } from '@angular/material/select';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { provideNativeDateAdapter } from '@angular/material/core';
import { firstValueFrom } from 'rxjs';
import { describeHttpError } from '../../../core/http/interceptors';
import { Customer } from '../../../core/models/api.models';
import { ToastService } from '../../../core/ui/toast.service';
import { firstErrorMessage, mobileNumberValidator } from '../../../shared/util/validators';
import { CustomersApiService } from '../data/customers-api.service';

export interface CustomerFormData {
  customer?: Customer;
}

@Component({
  selector: 'app-customer-form-dialog',
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [provideNativeDateAdapter()],
  imports: [
    ReactiveFormsModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatDatepickerModule,
    MatButtonModule,
    MatSlideToggleModule,
    MatProgressBarModule,
  ],
  template: `
    <h2 mat-dialog-title>{{ isEdit() ? 'Edit customer' : 'Add customer' }}</h2>
    @if (busy()) {
      <mat-progress-bar mode="indeterminate" />
    }

    <mat-dialog-content>
      <form [formGroup]="form" class="grid" (ngSubmit)="save()">
        <mat-form-field appearance="outline">
          <mat-label>First name</mat-label>
          <input matInput formControlName="customerFirstName" />
          @if (invalid('customerFirstName')) {
            <mat-error>{{ error('customerFirstName', 'First name') }}</mat-error>
          }
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Middle name</mat-label>
          <input matInput formControlName="customerMiddleName" />
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Last name</mat-label>
          <input matInput formControlName="customerLastName" />
          @if (invalid('customerLastName')) {
            <mat-error>{{ error('customerLastName', 'Last name') }}</mat-error>
          }
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Mobile number</mat-label>
          <input matInput formControlName="mobileNumber" inputmode="numeric" maxlength="10" />
          @if (invalid('mobileNumber')) {
            <mat-error>{{ error('mobileNumber', 'Mobile number') }}</mat-error>
          }
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Alternative mobile</mat-label>
          <input
            matInput
            formControlName="alternativeMobileNumber"
            inputmode="numeric"
            maxlength="10"
          />
          @if (invalid('alternativeMobileNumber')) {
            <mat-error>{{ error('alternativeMobileNumber', 'Alternative mobile') }}</mat-error>
          }
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Email</mat-label>
          <input matInput type="email" formControlName="emailId" />
          @if (invalid('emailId')) {
            <mat-error>{{ error('emailId', 'Email') }}</mat-error>
          }
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Date of birth</mat-label>
          <input matInput [matDatepicker]="picker" formControlName="dateOfBirth" />
          <mat-datepicker-toggle matIconSuffix [for]="picker" />
          <mat-datepicker #picker />
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Gender</mat-label>
          <mat-select formControlName="gender">
            <mat-option [value]="null">Not specified</mat-option>
            <mat-option value="Male">Male</mat-option>
            <mat-option value="Female">Female</mat-option>
            <mat-option value="Other">Other</mat-option>
          </mat-select>
        </mat-form-field>

        @if (isEdit()) {
          <mat-slide-toggle formControlName="isActive" class="span-2">Active</mat-slide-toggle>
        }
      </form>
    </mat-dialog-content>

    <mat-dialog-actions align="end">
      <button matButton mat-dialog-close [disabled]="busy()">Cancel</button>
      <button matButton="filled" [disabled]="busy()" (click)="save()">
        {{ isEdit() ? 'Save changes' : 'Create customer' }}
      </button>
    </mat-dialog-actions>
  `,
  styles: `
    .grid {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 4px 16px;
      padding-top: 8px;
    }
    mat-form-field { width: 100%; }
    .span-2 { grid-column: 1 / -1; }
    mat-slide-toggle { margin: 8px 0 4px; }

    @media (max-width: 599px) {
      .grid { grid-template-columns: 1fr; }
    }
  `,
})
export class CustomerFormDialog {
  private readonly fb = inject(FormBuilder);
  private readonly api = inject(CustomersApiService);
  private readonly toast = inject(ToastService);
  private readonly ref = inject(MatDialogRef<CustomerFormDialog, boolean>);
  private readonly data = inject<CustomerFormData>(MAT_DIALOG_DATA);

  protected readonly busy = signal(false);
  protected readonly isEdit = computed(() => !!this.data.customer);

  protected readonly form = this.fb.nonNullable.group({
    customerFirstName: [this.data.customer?.customerFirstName ?? '', [Validators.required]],
    customerMiddleName: [this.data.customer?.customerMiddleName ?? ''],
    customerLastName: [this.data.customer?.customerLastName ?? '', [Validators.required]],
    mobileNumber: [
      this.data.customer?.mobileNumber ?? '',
      [Validators.required, mobileNumberValidator()],
    ],
    alternativeMobileNumber: [
      this.data.customer?.alternativeMobileNumber ?? '',
      [mobileNumberValidator()],
    ],
    emailId: [this.data.customer?.emailId ?? '', [Validators.email]],
    dateOfBirth: [
      this.data.customer?.dateOfBirth ? new Date(this.data.customer.dateOfBirth) : (null as Date | null),
    ],
    gender: [this.data.customer?.gender ?? (null as string | null)],
    isActive: [this.data.customer?.isActive ?? true],
  });

  protected invalid(control: keyof typeof this.form.controls): boolean {
    const field = this.form.controls[control];
    return field.touched && field.invalid;
  }

  protected error(control: keyof typeof this.form.controls, label: string): string {
    return firstErrorMessage(this.form.controls[control], label);
  }

  protected async save(): Promise<void> {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    const value = this.form.getRawValue();
    // The API models DateOfBirth as a non-nullable DateTime, so send the epoch when it is unknown.
    const payload = {
      customerFirstName: value.customerFirstName,
      customerMiddleName: value.customerMiddleName || null,
      customerLastName: value.customerLastName,
      mobileNumber: value.mobileNumber,
      alternativeMobileNumber: value.alternativeMobileNumber || null,
      emailId: value.emailId || null,
      dateOfBirth: (value.dateOfBirth ?? new Date(0)).toISOString(),
      gender: value.gender,
    };

    this.busy.set(true);

    try {
      if (this.data.customer) {
        await firstValueFrom(
          this.api.update(this.data.customer.customerId, { ...payload, isActive: value.isActive }),
        );
        this.toast.success('Customer updated.');
      } else {
        await firstValueFrom(this.api.create(payload));
        this.toast.success('Customer created.');
      }
      this.ref.close(true);
    } catch (err) {
      this.handleError(err as HttpErrorResponse);
    } finally {
      this.busy.set(false);
    }
  }

  private handleError(error: HttpErrorResponse): void {
    const message = describeHttpError(error);

    if (message.toLowerCase().includes('mobile')) {
      this.form.controls.mobileNumber.setErrors({ server: message });
      this.form.controls.mobileNumber.markAsTouched();
    } else {
      this.toast.error(message);
    }
  }
}
