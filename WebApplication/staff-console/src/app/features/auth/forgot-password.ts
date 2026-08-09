import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { Router, RouterLink } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { AuthApiService } from '../../core/auth/auth-api.service';
import { describeHttpError } from '../../core/http/interceptors';
import { ToastService } from '../../core/ui/toast.service';
import { firstErrorMessage, mobileNumberValidator } from '../../shared/util/validators';

/**
 * Step one of the reset flow: send an OTP to the staff member's mobile. The OTP itself is
 * redeemed on the reset page.
 */
@Component({
  selector: 'app-forgot-password',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    ReactiveFormsModule,
    RouterLink,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatIconModule,
    MatProgressBarModule,
  ],
  template: `
    <div class="page">
      <mat-card class="card">
        @if (busy()) {
          <mat-progress-bar mode="indeterminate" />
        }
        <mat-card-content>
          <h1>Forgot password</h1>
          <p class="lead">
            Enter your registered mobile number and we'll text you a one-time code.
          </p>

          <form [formGroup]="form" (ngSubmit)="submit()">
            <mat-form-field appearance="outline">
              <mat-label>Mobile number</mat-label>
              <input matInput formControlName="mobileNumber" inputmode="numeric" maxlength="10" />
              @if (form.controls.mobileNumber.touched && form.controls.mobileNumber.invalid) {
                <mat-error>{{ error('mobileNumber') }}</mat-error>
              }
            </mat-form-field>

            <button matButton="filled" type="submit" class="full" [disabled]="busy()">
              Send code
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
    .card { width: min(420px, 100%); overflow: hidden; }
    h1 { margin: 0 0 4px; font: var(--mat-sys-headline-small); }
    .lead { margin: 0 0 20px; color: var(--mat-sys-on-surface-variant); font: var(--mat-sys-body-medium); }
    form { display: flex; flex-direction: column; gap: 8px; }
    mat-form-field { width: 100%; }
    .full { width: 100%; }
  `,
})
export class ForgotPassword {
  private readonly fb = inject(FormBuilder);
  private readonly api = inject(AuthApiService);
  private readonly toast = inject(ToastService);
  private readonly router = inject(Router);

  protected readonly busy = signal(false);

  protected readonly form = this.fb.nonNullable.group({
    mobileNumber: ['', [Validators.required, mobileNumberValidator()]],
  });

  protected error(control: 'mobileNumber'): string {
    return firstErrorMessage(this.form.controls[control], 'Mobile number');
  }

  protected async submit(): Promise<void> {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    const mobileNumber = this.form.controls.mobileNumber.value.trim();
    this.busy.set(true);

    try {
      await firstValueFrom(this.api.forgotPassword(mobileNumber));
      this.toast.success('If that number is registered, a code is on its way.');
      void this.router.navigate(['/reset-password'], { queryParams: { mobile: mobileNumber } });
    } catch (err) {
      this.toast.error(describeHttpError(err as never));
    } finally {
      this.busy.set(false);
    }
  }
}
