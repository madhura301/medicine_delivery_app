import { COMMA, ENTER, SPACE } from '@angular/cdk/keycodes';
import { HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, computed, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatChipInputEvent, MatChipsModule } from '@angular/material/chips';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { firstValueFrom } from 'rxjs';
import { describeHttpError } from '../../../core/http/interceptors';
import { ServiceRegion } from '../../../core/models/api.models';
import { RegionType } from '../../../core/models/enums';
import { ToastService } from '../../../core/ui/toast.service';
import { firstErrorMessage } from '../../../shared/util/validators';
import { RegionsApiService } from '../data/regions-api.service';

export interface RegionFormData {
  regionType: RegionType;
  region?: ServiceRegion;
}

@Component({
  selector: 'app-region-form-dialog',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    ReactiveFormsModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatChipsModule,
    MatIconModule,
    MatButtonModule,
    MatProgressBarModule,
  ],
  template: `
    <h2 mat-dialog-title>{{ isEdit() ? 'Edit region' : 'Add region' }}</h2>
    @if (busy()) {
      <mat-progress-bar mode="indeterminate" />
    }

    <mat-dialog-content>
      <p class="type">
        <mat-icon>{{ isSupport() ? 'headset_mic' : 'moped' }}</mat-icon>
        <span>{{ isSupport() ? 'Support region' : 'Delivery region' }}</span>
      </p>

      <form [formGroup]="form" class="grid" (ngSubmit)="save()">
        <mat-form-field appearance="outline">
          <mat-label>Name</mat-label>
          <input matInput formControlName="name" />
          @if (invalid('name')) {
            <mat-error>{{ error('name', 'Name') }}</mat-error>
          }
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Region name</mat-label>
          <input matInput formControlName="regionName" />
          @if (invalid('regionName')) {
            <mat-error>{{ error('regionName', 'Region name') }}</mat-error>
          }
          <mat-hint>Shown in dropdowns and order screens.</mat-hint>
        </mat-form-field>

        <mat-form-field appearance="outline" class="span-2">
          <mat-label>City</mat-label>
          <input matInput formControlName="city" />
          @if (invalid('city')) {
            <mat-error>{{ error('city', 'City') }}</mat-error>
          }
        </mat-form-field>

        <mat-form-field appearance="outline" class="span-2">
          <mat-label>Pin codes</mat-label>
          <mat-chip-grid #chipGrid aria-label="Pin codes">
            @for (pin of pinCodes(); track pin) {
              <mat-chip-row (removed)="removePin(pin)">
                {{ pin }}
                <button matChipRemove [attr.aria-label]="'Remove ' + pin">
                  <mat-icon>cancel</mat-icon>
                </button>
              </mat-chip-row>
            }
            <input
              placeholder="Type a 6-digit pin code and press Enter"
              [matChipInputFor]="chipGrid"
              [matChipInputSeparatorKeyCodes]="separators"
              (matChipInputTokenEnd)="addPin($event)"
              inputmode="numeric"
            />
          </mat-chip-grid>
          @if (pinError()) {
            <mat-error>{{ pinError() }}</mat-error>
          }
          <mat-hint>{{ pinHint() }}</mat-hint>
        </mat-form-field>
      </form>
    </mat-dialog-content>

    <mat-dialog-actions align="end">
      <button matButton mat-dialog-close [disabled]="busy()">Cancel</button>
      <button matButton="filled" [disabled]="busy()" (click)="save()">
        {{ isEdit() ? 'Save changes' : 'Create region' }}
      </button>
    </mat-dialog-actions>
  `,
  styles: `
    .type {
      display: flex;
      align-items: center;
      gap: 8px;
      margin: 0 0 16px;
      color: var(--mat-sys-on-surface-variant);
      font: var(--mat-sys-body-small);
    }
    .grid {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 4px 16px;
      min-width: min(560px, 78vw);
    }
    mat-form-field { width: 100%; }
    .span-2 { grid-column: 1 / -1; }

    @media (max-width: 599px) {
      .grid { grid-template-columns: 1fr; min-width: 0; }
    }
  `,
})
export class RegionFormDialog {
  private readonly fb = inject(FormBuilder);
  private readonly api = inject(RegionsApiService);
  private readonly toast = inject(ToastService);
  private readonly ref = inject(MatDialogRef<RegionFormDialog, boolean>);
  private readonly data = inject<RegionFormData>(MAT_DIALOG_DATA);

  protected readonly separators = [ENTER, COMMA, SPACE] as const;
  protected readonly busy = signal(false);
  protected readonly pinCodes = signal<string[]>(this.data.region?.pinCodes ?? []);
  protected readonly pinError = signal<string | null>(null);

  protected readonly isEdit = computed(() => !!this.data.region);
  protected readonly isSupport = computed(() => this.data.regionType === RegionType.CustomerSupport);

  protected readonly form = this.fb.nonNullable.group({
    name: [this.data.region?.name ?? '', [Validators.required]],
    regionName: [this.data.region?.regionName ?? '', [Validators.required]],
    city: [this.data.region?.city ?? '', [Validators.required]],
  });

  protected pinHint(): string {
    return this.isSupport()
      ? 'Orders rejected in these pin codes go to this region’s agents.'
      : 'Partners in this region are eligible for orders delivered to these pin codes.';
  }

  protected invalid(control: keyof typeof this.form.controls): boolean {
    const field = this.form.controls[control];
    return field.touched && field.invalid;
  }

  protected error(control: keyof typeof this.form.controls, label: string): string {
    return firstErrorMessage(this.form.controls[control], label);
  }

  protected addPin(event: MatChipInputEvent): void {
    const value = event.value.trim();
    event.chipInput.clear();

    if (!value) {
      return;
    }

    if (!/^\d{6}$/.test(value)) {
      this.pinError.set('Pin codes must be exactly 6 digits.');
      return;
    }

    if (this.pinCodes().includes(value)) {
      this.pinError.set(`${value} is already in this region.`);
      return;
    }

    this.pinError.set(null);
    this.pinCodes.update((pins) => [...pins, value]);
  }

  protected removePin(pin: string): void {
    this.pinError.set(null);
    this.pinCodes.update((pins) => pins.filter((p) => p !== pin));
  }

  protected async save(): Promise<void> {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    const value = this.form.getRawValue();
    this.busy.set(true);

    try {
      if (this.data.region) {
        await firstValueFrom(
          this.api.update(this.data.region.id, { ...value, pinCodes: this.pinCodes() }),
        );
        this.toast.success('Region updated.');
      } else {
        await firstValueFrom(
          this.api.create({
            ...value,
            regionType: this.data.regionType,
            pinCodes: this.pinCodes(),
          }),
        );
        this.toast.success('Region created.');
      }
      this.ref.close(true);
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    } finally {
      this.busy.set(false);
    }
  }
}
