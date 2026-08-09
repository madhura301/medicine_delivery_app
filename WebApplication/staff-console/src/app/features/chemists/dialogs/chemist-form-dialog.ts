import { HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { firstValueFrom } from 'rxjs';
import { describeHttpError } from '../../../core/http/interceptors';
import { MedicalStore } from '../../../core/models/api.models';
import { ToastService } from '../../../core/ui/toast.service';
import {
  firstErrorMessage,
  mobileNumberValidator,
  pinCodeValidator,
} from '../../../shared/util/validators';
import { ChemistsApiService } from '../data/chemists-api.service';

export interface ChemistFormData {
  chemist: MedicalStore;
}

/**
 * Edit-only. Chemists register themselves through the public endpoint, so this console never
 * creates one — it maintains the record afterwards.
 */
@Component({
  selector: 'app-chemist-form-dialog',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    ReactiveFormsModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatSlideToggleModule,
    MatProgressBarModule,
  ],
  template: `
    <h2 mat-dialog-title>Edit chemist</h2>
    @if (busy()) {
      <mat-progress-bar mode="indeterminate" />
    }

    <mat-dialog-content>
      <form [formGroup]="form" (ngSubmit)="save()">
        <h3>Store</h3>
        <div class="grid">
          <mat-form-field appearance="outline" class="span-2">
            <mat-label>Store name</mat-label>
            <input matInput formControlName="medicalName" />
            @if (invalid('medicalName')) {
              <mat-error>{{ error('medicalName', 'Store name') }}</mat-error>
            }
          </mat-form-field>

          <mat-form-field appearance="outline">
            <mat-label>Owner first name</mat-label>
            <input matInput formControlName="ownerFirstName" />
          </mat-form-field>

          <mat-form-field appearance="outline">
            <mat-label>Owner last name</mat-label>
            <input matInput formControlName="ownerLastName" />
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

          <mat-form-field appearance="outline" class="span-2">
            <mat-label>Email</mat-label>
            <input matInput type="email" formControlName="emailId" />
            @if (invalid('emailId')) {
              <mat-error>{{ error('emailId', 'Email') }}</mat-error>
            }
          </mat-form-field>
        </div>

        <h3>Address</h3>
        <div class="grid">
          <mat-form-field appearance="outline" class="span-2">
            <mat-label>Address line 1</mat-label>
            <input matInput formControlName="addressLine1" />
          </mat-form-field>

          <mat-form-field appearance="outline" class="span-2">
            <mat-label>Address line 2</mat-label>
            <input matInput formControlName="addressLine2" />
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
            <mat-hint>Decides which orders route to this store.</mat-hint>
          </mat-form-field>
        </div>

        <h3>Statutory</h3>
        <div class="grid">
          <mat-form-field appearance="outline">
            <mat-label>GSTIN</mat-label>
            <input matInput formControlName="gstin" />
          </mat-form-field>

          <mat-form-field appearance="outline">
            <mat-label>PAN</mat-label>
            <input matInput formControlName="pan" />
          </mat-form-field>

          <mat-form-field appearance="outline">
            <mat-label>FSSAI number</mat-label>
            <input matInput formControlName="fssaiNo" />
          </mat-form-field>

          <mat-form-field appearance="outline">
            <mat-label>Drug licence number</mat-label>
            <input matInput formControlName="dlNo" />
          </mat-form-field>

          <mat-slide-toggle formControlName="registrationStatus" class="span-2">
            Registration complete
          </mat-slide-toggle>
        </div>

        <h3>Pharmacist</h3>
        <div class="grid">
          <mat-form-field appearance="outline">
            <mat-label>First name</mat-label>
            <input matInput formControlName="pharmacistFirstName" />
          </mat-form-field>

          <mat-form-field appearance="outline">
            <mat-label>Last name</mat-label>
            <input matInput formControlName="pharmacistLastName" />
          </mat-form-field>

          <mat-form-field appearance="outline">
            <mat-label>Registration number</mat-label>
            <input matInput formControlName="pharmacistRegistrationNumber" />
          </mat-form-field>

          <mat-form-field appearance="outline">
            <mat-label>Mobile number</mat-label>
            <input
              matInput
              formControlName="pharmacistMobileNumber"
              inputmode="numeric"
              maxlength="10"
            />
            @if (invalid('pharmacistMobileNumber')) {
              <mat-error>{{ error('pharmacistMobileNumber', 'Pharmacist mobile') }}</mat-error>
            }
          </mat-form-field>
        </div>
      </form>
    </mat-dialog-content>

    <mat-dialog-actions align="end">
      <button matButton mat-dialog-close [disabled]="busy()">Cancel</button>
      <button matButton="filled" [disabled]="busy()" (click)="save()">Save changes</button>
    </mat-dialog-actions>
  `,
  styles: `
    h3 {
      margin: 16px 0 8px;
      font: var(--mat-sys-title-small);
      color: var(--mat-sys-primary);
    }
    h3:first-of-type { margin-top: 4px; }
    .grid {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 4px 16px;
    }
    mat-form-field { width: 100%; }
    .span-2 { grid-column: 1 / -1; }
    mat-slide-toggle { margin: 8px 0; }

    @media (max-width: 599px) {
      .grid { grid-template-columns: 1fr; }
    }
  `,
})
export class ChemistFormDialog {
  private readonly fb = inject(FormBuilder);
  private readonly api = inject(ChemistsApiService);
  private readonly toast = inject(ToastService);
  private readonly ref = inject(MatDialogRef<ChemistFormDialog, boolean>);
  private readonly data = inject<ChemistFormData>(MAT_DIALOG_DATA);

  protected readonly busy = signal(false);

  private readonly chemist = this.data.chemist;

  protected readonly form = this.fb.nonNullable.group({
    medicalName: [this.chemist.medicalName ?? '', [Validators.required]],
    ownerFirstName: [this.chemist.ownerFirstName ?? ''],
    ownerMiddleName: [this.chemist.ownerMiddleName ?? ''],
    ownerLastName: [this.chemist.ownerLastName ?? ''],
    addressLine1: [this.chemist.addressLine1 ?? ''],
    addressLine2: [this.chemist.addressLine2 ?? ''],
    city: [this.chemist.city ?? ''],
    state: [this.chemist.state ?? ''],
    postalCode: [this.chemist.postalCode ?? '', [pinCodeValidator()]],
    mobileNumber: [this.chemist.mobileNumber ?? '', [Validators.required, mobileNumberValidator()]],
    alternativeMobileNumber: [this.chemist.alternativeMobileNumber ?? '', [mobileNumberValidator()]],
    emailId: [this.chemist.emailId ?? '', [Validators.email]],
    registrationStatus: [this.chemist.registrationStatus ?? false],
    gstin: [this.chemist.gstin ?? ''],
    pan: [this.chemist.pan ?? ''],
    fssaiNo: [this.chemist.fssaiNo ?? ''],
    dlNo: [this.chemist.dlNo ?? ''],
    pharmacistFirstName: [this.chemist.pharmacistFirstName ?? ''],
    pharmacistLastName: [this.chemist.pharmacistLastName ?? ''],
    pharmacistRegistrationNumber: [this.chemist.pharmacistRegistrationNumber ?? ''],
    pharmacistMobileNumber: [this.chemist.pharmacistMobileNumber ?? '', [mobileNumberValidator()]],
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

    this.busy.set(true);

    try {
      await firstValueFrom(
        this.api.update(this.chemist.medicalStoreId, {
          ...this.form.getRawValue(),
          latitude: this.chemist.latitude,
          longitude: this.chemist.longitude,
          isActive: this.chemist.isActive,
        }),
      );
      this.toast.success('Chemist updated.');
      this.ref.close(true);
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    } finally {
      this.busy.set(false);
    }
  }
}
