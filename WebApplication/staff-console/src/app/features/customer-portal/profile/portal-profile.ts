import { DatePipe } from '@angular/common';
import { HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, computed, effect, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { provideNativeDateAdapter } from '@angular/material/core';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { RouterLink } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { describeHttpError } from '../../../core/http/interceptors';
import { ToastService } from '../../../core/ui/toast.service';
import { firstErrorMessage, mobileNumberValidator } from '../../../shared/util/validators';
import { PortalApiService } from '../data/portal-api.service';
import { PortalStore } from '../data/portal.store';

@Component({
  selector: 'app-portal-profile',
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [provideNativeDateAdapter()],
  imports: [
    DatePipe, ReactiveFormsModule, RouterLink, MatButtonModule, MatIconModule, MatFormFieldModule,
    MatInputModule, MatSelectModule, MatDatepickerModule,
  ],
  template: `
    <header class="head"><h1>Profile</h1></header>

    @if (store.profile(); as p) {
      <div class="layout">
        <aside class="card id">
          <span class="avatar">{{ initials() }}</span>
          <strong>{{ p.customerFirstName }} {{ p.customerLastName }}</strong>
          <span class="muted">{{ p.mobileNumber }}</span>
          <span class="since">Member since {{ p.createdOn | date: 'MMMM yyyy' }}</span>
          <a matButton="outlined" class="pt-round" routerLink="/my/change-password"><mat-icon>lock</mat-icon>Change password</a>
        </aside>

        <form class="card" [formGroup]="form" (ngSubmit)="save()">
          <h2>Personal details</h2>
          <div class="grid">
            <mat-form-field appearance="outline">
              <mat-label>First name</mat-label>
              <input matInput formControlName="customerFirstName" autocomplete="given-name" />
              @if (bad('customerFirstName')) { <mat-error>{{ err('customerFirstName', 'First name') }}</mat-error> }
            </mat-form-field>
            <mat-form-field appearance="outline">
              <mat-label>Last name</mat-label>
              <input matInput formControlName="customerLastName" autocomplete="family-name" />
              @if (bad('customerLastName')) { <mat-error>{{ err('customerLastName', 'Last name') }}</mat-error> }
            </mat-form-field>
            <mat-form-field appearance="outline" class="span">
              <mat-label>Email</mat-label>
              <input matInput type="email" formControlName="emailId" autocomplete="email" />
              @if (bad('emailId')) { <mat-error>Enter a valid email address.</mat-error> }
            </mat-form-field>
            <mat-form-field appearance="outline">
              <mat-label>Date of birth</mat-label>
              <input matInput [matDatepicker]="dob" formControlName="dateOfBirth" />
              <mat-datepicker-toggle matIconSuffix [for]="dob" />
              <mat-datepicker #dob />
            </mat-form-field>
            <mat-form-field appearance="outline">
              <mat-label>Gender</mat-label>
              <mat-select formControlName="gender">
                <mat-option value="Female">Female</mat-option>
                <mat-option value="Male">Male</mat-option>
                <mat-option value="Other">Other</mat-option>
              </mat-select>
            </mat-form-field>
            <mat-form-field appearance="outline" class="span">
              <mat-label>Alternative mobile</mat-label>
              <input matInput formControlName="alternativeMobileNumber" inputmode="numeric" maxlength="10" />
              @if (bad('alternativeMobileNumber')) { <mat-error>{{ err('alternativeMobileNumber', 'Alternative mobile') }}</mat-error> }
            </mat-form-field>
          </div>
          <p class="note"><mat-icon>info</mat-icon>Your mobile number is how you sign in, so it can't be changed here. Contact support if you need a new one.</p>
          <div class="actions">
            <button matButton class="pt-round" type="button" (click)="reset()" [disabled]="form.pristine || saving()">Discard</button>
            <button matButton="filled" class="pt-round" type="submit" [disabled]="form.pristine || saving()">{{ saving() ? 'Saving…' : 'Save changes' }}</button>
          </div>
        </form>
      </div>
    }
  `,
  styles: `
    :host { display: flex; flex-direction: column; gap: 22px; }
    h1 { margin: 0; font-size: clamp(1.7rem, 3vw, 2.2rem); font-weight: 800; letter-spacing: -0.025em; color: var(--pt-navy-deep); }
    .muted { color: var(--pt-muted); }
    .layout { display: grid; grid-template-columns: 290px 1fr; gap: 20px; align-items: start; }
    .card { background: var(--pt-card); border: 1px solid var(--pt-line); border-radius: var(--pt-radius); padding: 24px; }
    .id { display: flex; flex-direction: column; align-items: center; text-align: center; gap: 4px; }
    .avatar { width: 88px; height: 88px; border-radius: 50%; background: linear-gradient(145deg, var(--pt-navy), var(--pt-navy-deep)); color: #fff; font: 800 2rem Figtree, sans-serif; display: grid; place-items: center; margin-bottom: 10px; }
    .id strong { font-size: 1.15rem; font-weight: 700; }
    .since { color: var(--pt-faint); font-size: 0.85rem; margin: 6px 0 14px; }
    h2 { margin: 0 0 16px; font-size: 1.1rem; font-weight: 700; }
    .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 4px 16px; }
    .span { grid-column: 1 / -1; }
    mat-form-field { width: 100%; }
    .note { display: flex; gap: 8px; align-items: flex-start; margin: 4px 0 18px; color: var(--pt-muted); font-size: 0.88rem; background: var(--pt-ground); padding: 12px; border-radius: 12px; }
    .note mat-icon { color: var(--pt-navy); font-size: 18px; width: 18px; height: 18px; flex: none; }
    .actions { display: flex; justify-content: flex-end; gap: 10px; }
    @media (max-width: 800px) { .layout { grid-template-columns: 1fr; } .grid { grid-template-columns: 1fr; } }
  `,
})
export class PortalProfile {
  protected readonly store = inject(PortalStore);
  private readonly api = inject(PortalApiService);
  private readonly toast = inject(ToastService);
  private readonly fb = inject(FormBuilder);
  protected readonly saving = signal(false);

  protected readonly form = this.fb.nonNullable.group({
    customerFirstName: ['', [Validators.required, Validators.maxLength(100)]],
    customerLastName: ['', [Validators.required, Validators.maxLength(100)]],
    emailId: ['', [Validators.email]],
    dateOfBirth: [null as Date | null],
    gender: ['' as string],
    alternativeMobileNumber: ['', [mobileNumberValidator()]],
  });

  protected readonly initials = computed(() => {
    const p = this.store.profile();
    return `${p?.customerFirstName?.[0] ?? ''}${p?.customerLastName?.[0] ?? ''}`.toUpperCase();
  });

  constructor() {
    effect(() => {
      if (this.store.profile() && this.form.pristine) {
        this.reset();
      }
    });
  }

  protected reset(): void {
    const p = this.store.profile();
    if (!p) return;
    this.form.reset({
      customerFirstName: p.customerFirstName ?? '',
      customerLastName: p.customerLastName ?? '',
      emailId: p.emailId ?? '',
      dateOfBirth: p.dateOfBirth ? new Date(p.dateOfBirth) : null,
      gender: p.gender ?? '',
      alternativeMobileNumber: p.alternativeMobileNumber ?? '',
    });
  }

  protected bad(name: keyof typeof this.form.controls): boolean {
    const c = this.form.controls[name];
    return c.touched && c.invalid;
  }

  protected err(name: keyof typeof this.form.controls, label: string): string {
    return firstErrorMessage(this.form.controls[name], label);
  }

  protected async save(): Promise<void> {
    const p = this.store.profile();
    if (!p || this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }
    const v = this.form.getRawValue();
    this.saving.set(true);
    try {
      const updated = await firstValueFrom(
        this.api.updateProfile(p.customerId, {
          customerFirstName: v.customerFirstName.trim(),
          customerMiddleName: p.customerMiddleName,
          customerLastName: v.customerLastName.trim(),
          mobileNumber: p.mobileNumber,
          alternativeMobileNumber: v.alternativeMobileNumber.trim() || null,
          emailId: v.emailId.trim() || null,
          dateOfBirth: (v.dateOfBirth ?? new Date(p.dateOfBirth)).toISOString(),
          gender: v.gender || null,
          isActive: p.isActive,
        }),
      );
      this.store.setProfile(updated ?? { ...p, ...v, dateOfBirth: (v.dateOfBirth ?? new Date(p.dateOfBirth)).toISOString() });
      this.form.markAsPristine();
      this.toast.success('Profile saved.');
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    } finally {
      this.saving.set(false);
    }
  }
}
