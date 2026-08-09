import { HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, computed, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { firstValueFrom } from 'rxjs';
import { describeHttpError } from '../../../core/http/interceptors';
import { CustomerAddress } from '../../../core/models/api.models';
import { ToastService } from '../../../core/ui/toast.service';
import { MapLocationPicker } from '../../../shared/ui/map-location-picker';
import { firstErrorMessage, pinCodeValidator } from '../../../shared/util/validators';
import { CustomersApiService } from '../data/customers-api.service';

export interface AddressFormData {
  customerId: string;
  address?: CustomerAddress;
}

@Component({
  selector: 'app-address-form-dialog',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    ReactiveFormsModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatCheckboxModule,
    MatProgressBarModule,
    MapLocationPicker,
  ],
  template: `
    <h2 mat-dialog-title>{{ isEdit() ? 'Edit address' : 'Add address' }}</h2>
    @if (busy()) {
      <mat-progress-bar mode="indeterminate" />
    }

    <mat-dialog-content>
      <form [formGroup]="form" class="grid" (ngSubmit)="save()">
        <mat-form-field appearance="outline" class="span-2">
          <mat-label>Address line 1</mat-label>
          <input matInput formControlName="addressLine1" />
        </mat-form-field>

        <mat-form-field appearance="outline" class="span-2">
          <mat-label>Address line 2</mat-label>
          <input matInput formControlName="addressLine2" />
        </mat-form-field>

        <mat-form-field appearance="outline" class="span-2">
          <mat-label>Landmark / line 3</mat-label>
          <input matInput formControlName="addressLine3" />
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>City</mat-label>
          <input matInput formControlName="city" />
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>State</mat-label>
          <input matInput formControlName="state" />
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Pin code</mat-label>
          <input matInput formControlName="postalCode" inputmode="numeric" maxlength="6" />
          @if (invalid('postalCode')) {
            <mat-error>{{ error('postalCode', 'Pin code') }}</mat-error>
          }
          <mat-hint>Decides which chemist and delivery region serve this address.</mat-hint>
        </mat-form-field>

        <app-map-location-picker
          class="span-2 picker"
          [(latitude)]="latitude"
          [(longitude)]="longitude"
          [label]="pickerLabel()"
        />

        <mat-checkbox formControlName="isDefault" class="span-2">
          Use as the default delivery address
        </mat-checkbox>
      </form>
    </mat-dialog-content>

    <mat-dialog-actions align="end">
      <button matButton mat-dialog-close [disabled]="busy()">Cancel</button>
      <button matButton="filled" [disabled]="busy()" (click)="save()">
        {{ isEdit() ? 'Save changes' : 'Add address' }}
      </button>
    </mat-dialog-actions>
  `,
  styles: `
    .grid {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 4px 16px;
      padding-top: 8px;
      min-width: min(520px, 78vw);
    }
    mat-form-field { width: 100%; }
    .span-2 { grid-column: 1 / -1; }
    mat-checkbox { margin: 8px 0 4px; }
    .picker {
      margin: 12px 0 4px;
      padding-top: 12px;
      border-top: 1px solid var(--mat-sys-outline-variant);
    }

    @media (max-width: 599px) {
      .grid { grid-template-columns: 1fr; min-width: 0; }
    }
  `,
})
export class AddressFormDialog {
  private readonly fb = inject(FormBuilder);
  private readonly api = inject(CustomersApiService);
  private readonly toast = inject(ToastService);
  private readonly ref = inject(MatDialogRef<AddressFormDialog, boolean>);
  private readonly data = inject<AddressFormData>(MAT_DIALOG_DATA);

  protected readonly busy = signal(false);
  protected readonly isEdit = computed(() => !!this.data.address);

  /** Bound two-way to the picker; kept outside the form because the map writes to them. */
  protected readonly latitude = signal<number | null>(this.data.address?.latitude ?? null);
  protected readonly longitude = signal<number | null>(this.data.address?.longitude ?? null);

  protected readonly form = this.fb.nonNullable.group({
    addressLine1: [this.data.address?.addressLine1 ?? ''],
    addressLine2: [this.data.address?.addressLine2 ?? ''],
    addressLine3: [this.data.address?.addressLine3 ?? ''],
    city: [this.data.address?.city ?? ''],
    state: [this.data.address?.state ?? ''],
    postalCode: [this.data.address?.postalCode ?? '', [pinCodeValidator()]],
    isDefault: [this.data.address?.isDefault ?? false],
  });

  protected pickerLabel(): string {
    const value = this.form.getRawValue();
    return [value.addressLine1, value.city, value.postalCode].filter(Boolean).join(', ');
  }

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
    const payload = {
      addressLine1: value.addressLine1 || null,
      addressLine2: value.addressLine2 || null,
      addressLine3: value.addressLine3 || null,
      city: value.city || null,
      state: value.state || null,
      postalCode: value.postalCode || null,
      isDefault: value.isDefault,
      latitude: this.latitude(),
      longitude: this.longitude(),
      // Keep the free-text field in step with the structured lines so both readers agree.
      address:
        [value.addressLine1, value.addressLine2, value.addressLine3, value.city, value.state, value.postalCode]
          .filter(Boolean)
          .join(', ') || null,
    };

    this.busy.set(true);

    try {
      if (this.data.address) {
        await firstValueFrom(this.api.updateAddress(this.data.address.id, payload));
        this.toast.success('Address updated.');
      } else {
        await firstValueFrom(this.api.createAddress({ ...payload, customerId: this.data.customerId }));
        this.toast.success('Address added.');
      }
      this.ref.close(true);
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    } finally {
      this.busy.set(false);
    }
  }
}
