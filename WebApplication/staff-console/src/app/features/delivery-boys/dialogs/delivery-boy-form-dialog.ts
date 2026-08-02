import { HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, computed, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatSelectModule } from '@angular/material/select';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { firstValueFrom } from 'rxjs';
import { describeHttpError } from '../../../core/http/interceptors';
import { DeliveryBoy, MedicalStore, ServiceRegion } from '../../../core/models/api.models';
import { RegionType } from '../../../core/models/enums';
import { ToastService } from '../../../core/ui/toast.service';
import {
  CredentialsNoticeService,
  DEFAULT_STAFF_PASSWORD,
} from '../../../shared/ui/credentials-notice';
import { firstErrorMessage, mobileNumberValidator } from '../../../shared/util/validators';
import { ChemistsApiService } from '../../chemists/data/chemists-api.service';
import { RegionsApiService, describeRegion } from '../../regions/data/regions-api.service';
import { DeliveryBoysApiService, deliveryBoyName } from '../data/delivery-boys-api.service';

export interface DeliveryBoyFormData {
  deliveryBoy?: DeliveryBoy;
}

@Component({
  selector: 'app-delivery-boy-form-dialog',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    ReactiveFormsModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatButtonModule,
    MatIconModule,
    MatSlideToggleModule,
    MatProgressBarModule,
  ],
  template: `
    <h2 mat-dialog-title>{{ isEdit() ? 'Edit delivery partner' : 'Add delivery partner' }}</h2>
    @if (busy()) {
      <mat-progress-bar mode="indeterminate" />
    }

    <mat-dialog-content>
      <form [formGroup]="form" class="grid" (ngSubmit)="save()">
        <mat-form-field appearance="outline">
          <mat-label>First name</mat-label>
          <input matInput formControlName="firstName" />
          @if (invalid('firstName')) {
            <mat-error>{{ error('firstName', 'First name') }}</mat-error>
          }
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Middle name</mat-label>
          <input matInput formControlName="middleName" />
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Last name</mat-label>
          <input matInput formControlName="lastName" />
          @if (invalid('lastName')) {
            <mat-error>{{ error('lastName', 'Last name') }}</mat-error>
          }
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Driving licence number</mat-label>
          <input matInput formControlName="drivingLicenceNumber" />
          @if (invalid('drivingLicenceNumber')) {
            <mat-error>{{ error('drivingLicenceNumber', 'Driving licence number') }}</mat-error>
          }
        </mat-form-field>

        <mat-form-field appearance="outline" class="span-2">
          <mat-label>Mobile number</mat-label>
          <input matInput formControlName="mobileNumber" inputmode="numeric" maxlength="10" />
          @if (invalid('mobileNumber')) {
            <mat-error>{{ error('mobileNumber', 'Mobile number') }}</mat-error>
          }
          @if (!isEdit()) {
            <mat-hint>Becomes their mobile-app sign-in name and must be unique across all users.</mat-hint>
          }
        </mat-form-field>

        <mat-form-field appearance="outline" class="span-2">
          <mat-label>Delivery region</mat-label>
          <mat-select formControlName="serviceRegionId">
            <mat-option [value]="null">— Unassigned —</mat-option>
            @for (region of regions(); track region.id) {
              <mat-option [value]="region.id">{{ describe(region) }}</mat-option>
            }
          </mat-select>
          <mat-hint>Only the region decides which orders this partner is eligible for.</mat-hint>
        </mat-form-field>

        <mat-form-field appearance="outline" class="span-2">
          <mat-label>Medical store (optional)</mat-label>
          <mat-select formControlName="medicalStoreId">
            <mat-option [value]="null">— None —</mat-option>
            @for (store of stores(); track store.medicalStoreId) {
              <mat-option [value]="store.medicalStoreId">{{ store.medicalName }}</mat-option>
            }
          </mat-select>
          <mat-hint>Record-keeping only — it does not affect order eligibility.</mat-hint>
        </mat-form-field>

        @if (isEdit()) {
          <mat-slide-toggle formControlName="isActive" class="span-2">Active</mat-slide-toggle>
        }
      </form>
    </mat-dialog-content>

    <mat-dialog-actions align="end">
      <button matButton mat-dialog-close [disabled]="busy()">Cancel</button>
      <button matButton="filled" [disabled]="busy()" (click)="save()">
        {{ isEdit() ? 'Save changes' : 'Create partner' }}
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
export class DeliveryBoyFormDialog {
  private readonly fb = inject(FormBuilder);
  private readonly api = inject(DeliveryBoysApiService);
  private readonly regionsApi = inject(RegionsApiService);
  private readonly chemistsApi = inject(ChemistsApiService);
  private readonly toast = inject(ToastService);
  private readonly credentials = inject(CredentialsNoticeService);
  private readonly ref = inject(MatDialogRef<DeliveryBoyFormDialog, boolean>);
  private readonly data = inject<DeliveryBoyFormData>(MAT_DIALOG_DATA);

  protected readonly busy = signal(false);
  protected readonly regions = signal<ServiceRegion[]>([]);
  protected readonly stores = signal<MedicalStore[]>([]);
  protected readonly isEdit = computed(() => !!this.data.deliveryBoy);
  protected readonly describe = describeRegion;

  protected readonly form = this.fb.nonNullable.group({
    firstName: [this.data.deliveryBoy?.firstName ?? '', [Validators.required]],
    middleName: [this.data.deliveryBoy?.middleName ?? ''],
    lastName: [this.data.deliveryBoy?.lastName ?? '', [Validators.required]],
    drivingLicenceNumber: [
      this.data.deliveryBoy?.drivingLicenceNumber ?? '',
      [Validators.required],
    ],
    mobileNumber: [
      this.data.deliveryBoy?.mobileNumber ?? '',
      [Validators.required, mobileNumberValidator()],
    ],
    serviceRegionId: [this.data.deliveryBoy?.serviceRegionId ?? (null as number | null)],
    medicalStoreId: [this.data.deliveryBoy?.medicalStoreId ?? (null as string | null)],
    isActive: [this.data.deliveryBoy?.isActive ?? true],
  });

  constructor() {
    void this.loadOptions();
  }

  private async loadOptions(): Promise<void> {
    const [regions, stores] = await Promise.all([
      firstValueFrom(this.regionsApi.listByType(RegionType.DeliveryBoy)).catch(() => []),
      firstValueFrom(this.chemistsApi.list()).catch(() => []),
    ]);
    this.regions.set(regions);
    this.stores.set(stores.filter((s) => !s.isDeleted));
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
    this.busy.set(true);

    try {
      if (this.data.deliveryBoy) {
        await firstValueFrom(this.api.update(this.data.deliveryBoy.id, value));
        this.toast.success('Delivery partner updated.');
      } else {
        const { isActive: _isActive, ...payload } = value;
        await firstValueFrom(this.api.create(payload));
        this.toast.success('Delivery partner created.');
        await this.credentials.show({
          title: 'Delivery partner account created',
          userName: value.mobileNumber,
          password: DEFAULT_STAFF_PASSWORD,
          note: `${deliveryBoyName({ ...value } as never)} can now sign in to the delivery mobile app.`,
        });
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

    // "A user with this mobile number already exists" is the common failure — put it on the field.
    if (message.toLowerCase().includes('mobile')) {
      this.form.controls.mobileNumber.setErrors({ server: message });
      this.form.controls.mobileNumber.markAsTouched();
    } else {
      this.toast.error(message);
    }
  }
}
