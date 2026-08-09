import { HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, computed, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatSelectModule } from '@angular/material/select';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { firstValueFrom } from 'rxjs';
import { describeHttpError } from '../../../core/http/interceptors';
import { CustomerSupport, ServiceRegion } from '../../../core/models/api.models';
import { RegionType } from '../../../core/models/enums';
import { ToastService } from '../../../core/ui/toast.service';
import {
  CredentialsNoticeService,
  DEFAULT_STAFF_PASSWORD,
} from '../../../shared/ui/credentials-notice';
import { firstErrorMessage, mobileNumberValidator } from '../../../shared/util/validators';
import { RegionsApiService, describeRegion } from '../../regions/data/regions-api.service';
import { CustomerSupportApiService } from '../data/customer-support-api.service';

export interface CustomerSupportFormData {
  agent?: CustomerSupport;
}

@Component({
  selector: 'app-customer-support-form-dialog',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    ReactiveFormsModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatButtonModule,
    MatSlideToggleModule,
    MatProgressBarModule,
  ],
  template: `
    <h2 mat-dialog-title>{{ isEdit() ? 'Edit support agent' : 'Add support agent' }}</h2>
    @if (busy()) {
      <mat-progress-bar mode="indeterminate" />
    }

    <mat-dialog-content>
      <form [formGroup]="form" class="grid" (ngSubmit)="save()">
        <mat-form-field appearance="outline">
          <mat-label>First name</mat-label>
          <input matInput formControlName="customerSupportFirstName" />
          @if (invalid('customerSupportFirstName')) {
            <mat-error>{{ error('customerSupportFirstName', 'First name') }}</mat-error>
          }
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Middle name</mat-label>
          <input matInput formControlName="customerSupportMiddleName" />
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Last name</mat-label>
          <input matInput formControlName="customerSupportLastName" />
          @if (invalid('customerSupportLastName')) {
            <mat-error>{{ error('customerSupportLastName', 'Last name') }}</mat-error>
          }
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Employee ID</mat-label>
          <input matInput formControlName="employeeId" />
          @if (invalid('employeeId')) {
            <mat-error>{{ error('employeeId', 'Employee ID') }}</mat-error>
          }
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Mobile number</mat-label>
          <input matInput formControlName="mobileNumber" inputmode="numeric" maxlength="10" />
          @if (invalid('mobileNumber')) {
            <mat-error>{{ error('mobileNumber', 'Mobile number') }}</mat-error>
          }
          @if (!isEdit()) {
            <mat-hint>This becomes their sign-in name.</mat-hint>
          }
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Alternative mobile</mat-label>
          <input matInput formControlName="alternativeMobileNumber" inputmode="numeric" maxlength="10" />
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

        <mat-form-field appearance="outline" class="span-2">
          <mat-label>Support region</mat-label>
          <mat-select formControlName="serviceRegionId">
            <mat-option [value]="null">— Unassigned —</mat-option>
            @for (region of regions(); track region.id) {
              <mat-option [value]="region.id">{{ describe(region) }}</mat-option>
            }
          </mat-select>
          <mat-hint>
            Rejected orders from this region’s pin codes are routed to its agents.
          </mat-hint>
        </mat-form-field>

        <mat-form-field appearance="outline" class="span-2">
          <mat-label>Address</mat-label>
          <input matInput formControlName="address" />
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>City</mat-label>
          <input matInput formControlName="city" />
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>State</mat-label>
          <input matInput formControlName="state" />
        </mat-form-field>

        @if (isEdit()) {
          <mat-slide-toggle formControlName="isActive" class="span-2">Active</mat-slide-toggle>
        }
      </form>
    </mat-dialog-content>

    <mat-dialog-actions align="end">
      <button matButton mat-dialog-close [disabled]="busy()">Cancel</button>
      <button matButton="filled" [disabled]="busy()" (click)="save()">
        {{ isEdit() ? 'Save changes' : 'Create agent' }}
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
export class CustomerSupportFormDialog {
  private readonly fb = inject(FormBuilder);
  private readonly api = inject(CustomerSupportApiService);
  private readonly regionsApi = inject(RegionsApiService);
  private readonly toast = inject(ToastService);
  private readonly credentials = inject(CredentialsNoticeService);
  private readonly ref = inject(MatDialogRef<CustomerSupportFormDialog, boolean>);
  private readonly data = inject<CustomerSupportFormData>(MAT_DIALOG_DATA);

  protected readonly busy = signal(false);
  protected readonly regions = signal<ServiceRegion[]>([]);
  protected readonly isEdit = computed(() => !!this.data.agent);
  protected readonly describe = describeRegion;

  protected readonly form = this.fb.nonNullable.group({
    customerSupportFirstName: [
      this.data.agent?.customerSupportFirstName ?? '',
      [Validators.required],
    ],
    customerSupportMiddleName: [this.data.agent?.customerSupportMiddleName ?? ''],
    customerSupportLastName: [this.data.agent?.customerSupportLastName ?? '', [Validators.required]],
    employeeId: [this.data.agent?.employeeId ?? '', [Validators.required]],
    mobileNumber: [
      this.data.agent?.mobileNumber ?? '',
      [Validators.required, mobileNumberValidator()],
    ],
    alternativeMobileNumber: [
      this.data.agent?.alternativeMobileNumber ?? '',
      [mobileNumberValidator()],
    ],
    emailId: [this.data.agent?.emailId ?? '', [Validators.required, Validators.email]],
    serviceRegionId: [this.data.agent?.serviceRegionId ?? (null as number | null)],
    address: [this.data.agent?.address ?? ''],
    city: [this.data.agent?.city ?? ''],
    state: [this.data.agent?.state ?? ''],
    isActive: [this.data.agent?.isActive ?? true],
  });

  constructor() {
    void this.loadRegions();
  }

  private async loadRegions(): Promise<void> {
    try {
      this.regions.set(await firstValueFrom(this.regionsApi.listByType(RegionType.CustomerSupport)));
    } catch {
      // A region list failure must not block creating an agent — they can be assigned later.
      this.regions.set([]);
    }
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
      if (this.data.agent) {
        await firstValueFrom(this.api.update(this.data.agent.customerSupportId, value));
        this.toast.success('Support agent updated.');
      } else {
        const { isActive: _isActive, ...registration } = value;
        const created = await firstValueFrom(this.api.create(registration));
        this.toast.success('Support agent created.');
        await this.credentials.show({
          title: 'Support agent account created',
          userName: value.mobileNumber,
          password: created?.password || DEFAULT_STAFF_PASSWORD,
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
    const lower = message.toLowerCase();

    if (lower.includes('mobile')) {
      this.form.controls.mobileNumber.setErrors({ server: message });
      this.form.controls.mobileNumber.markAsTouched();
    } else if (lower.includes('email')) {
      this.form.controls.emailId.setErrors({ server: message });
      this.form.controls.emailId.markAsTouched();
    } else {
      this.toast.error(message);
    }
  }
}
