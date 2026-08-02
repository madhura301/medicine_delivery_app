import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { AbstractControl, FormBuilder, ReactiveFormsModule, ValidationErrors, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { AuthApiService } from '../../core/auth/auth-api.service';
import { describeHttpError } from '../../core/http/interceptors';
import { ToastService } from '../../core/ui/toast.service';
import { firstErrorMessage, mobileNumberValidator } from '../../shared/util/validators';

function passwordsMatch(group: AbstractControl): ValidationErrors | null {
  const password = group.get('newPassword')?.value;
  const confirm = group.get('confirmPassword')?.value;
  return password && confirm && password !== confirm ? { mismatch: true } : null;
}

@Component({
  selector: 'app-reset-password',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    ReactiveFormsModule,
    RouterLink,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatProgressBarModule,
  ],
  template: `
    <div class="page">
      <mat-card class="card">
        @if (busy()) {
          <mat-progress-bar mode="indeterminate" />
        }
        <mat-card-content>
          <h1>Set a new password</h1>
          <p class="lead">Enter the code we texted you along with your new password.</p>

          <form [formGroup]="form" (ngSubmit)="submit()">
            <mat-form-field appearance="outline">
              <mat-label>Mobile number</mat-label>
              <input matInput formControlName="phoneNumber" inputmode="numeric" maxlength="10" />
              @if (form.controls.phoneNumber.touched && form.controls.phoneNumber.invalid) {
                <mat-error>{{ message('phoneNumber', 'Mobile number') }}</mat-error>
              }
            </mat-form-field>

            <mat-form-field appearance="outline">
              <mat-label>One-time code</mat-label>
              <input matInput formControlName="otpCode" inputmode="numeric" autocomplete="one-time-code" />
              @if (form.controls.otpCode.touched && form.controls.otpCode.invalid) {
                <mat-error>{{ message('otpCode', 'Code') }}</mat-error>
              }
            </mat-form-field>

            <mat-form-field appearance="outline">
              <mat-label>New password</mat-label>
              <input matInput type="password" formControlName="newPassword" autocomplete="new-password" />
              @if (form.controls.newPassword.touched && form.controls.newPassword.invalid) {
                <mat-error>{{ message('newPassword', 'Password') }}</mat-error>
              }
            </mat-form-field>

            <mat-form-field appearance="outline">
              <mat-label>Confirm new password</mat-label>
              <input matInput type="password" formControlName="confirmPassword" autocomplete="new-password" />
              @if (form.controls.confirmPassword.touched && form.hasError('mismatch')) {
                <mat-error>Passwords do not match.</mat-error>
              }
            </mat-form-field>

            <button matButton="filled" type="submit" class="full" [disabled]="busy()">
              Update password
            </button>
            <a matButton routerLink="/login" class="full">Back to sign in</a>
          </form>
        </mat-card-content>
      </mat-card>
    </div>
  `,
  styles: `
    .page {
      display: grid;
      place-items: center;
      min-height: 100dvh;
      padding: 16px;
      background: var(--mat-sys-surface-container);
    }
    .card { width: min(440px, 100%); overflow: hidden; }
    h1 { margin: 0 0 4px; font: var(--mat-sys-headline-small); }
    .lead { margin: 0 0 20px; color: var(--mat-sys-on-surface-variant); font: var(--mat-sys-body-medium); }
    form { display: flex; flex-direction: column; gap: 4px; }
    mat-form-field { width: 100%; }
    .full { width: 100%; }
  `,
})
export class ResetPassword {
  private readonly fb = inject(FormBuilder);
  private readonly api = inject(AuthApiService);
  private readonly toast = inject(ToastService);
  private readonly router = inject(Router);
  private readonly route = inject(ActivatedRoute);

  protected readonly busy = signal(false);

  protected readonly form = this.fb.nonNullable.group(
    {
      phoneNumber: [
        this.route.snapshot.queryParamMap.get('mobile') ?? '',
        [Validators.required, mobileNumberValidator()],
      ],
      otpCode: ['', [Validators.required]],
      newPassword: ['', [Validators.required, Validators.minLength(6)]],
      confirmPassword: ['', [Validators.required]],
    },
    { validators: passwordsMatch },
  );

  protected message(control: 'phoneNumber' | 'otpCode' | 'newPassword', label: string): string {
    return firstErrorMessage(this.form.controls[control], label);
  }

  protected async submit(): Promise<void> {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    this.busy.set(true);
    try {
      await firstValueFrom(this.api.verifyOtpAndResetPassword(this.form.getRawValue()));
      this.toast.success('Password updated. Please sign in with your new password.');
      void this.router.navigate(['/login']);
    } catch (err) {
      this.toast.error(describeHttpError(err as never));
    } finally {
      this.busy.set(false);
    }
  }
}
