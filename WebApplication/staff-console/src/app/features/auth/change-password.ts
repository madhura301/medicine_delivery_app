import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { AbstractControl, FormBuilder, ReactiveFormsModule, ValidationErrors, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { Router } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { AuthApiService } from '../../core/auth/auth-api.service';
import { AuthStore } from '../../core/auth/auth.store';
import { describeHttpError } from '../../core/http/interceptors';
import { ToastService } from '../../core/ui/toast.service';
import { PageHeader } from '../../shared/ui/page-header';
import { firstErrorMessage } from '../../shared/util/validators';

function passwordsMatch(group: AbstractControl): ValidationErrors | null {
  const password = group.get('newPassword')?.value;
  const confirm = group.get('confirmPassword')?.value;
  return password && confirm && password !== confirm ? { mismatch: true } : null;
}

@Component({
  selector: 'app-change-password',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    ReactiveFormsModule,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    PageHeader,
  ],
  template: `
    <app-page-header title="Change password" subtitle="Update the password for your own account." />

    <mat-card class="card">
      <mat-card-content>
        <form [formGroup]="form" (ngSubmit)="submit()">
          <mat-form-field appearance="outline">
            <mat-label>Current password</mat-label>
            <input matInput type="password" formControlName="currentPassword" autocomplete="current-password" />
            @if (form.controls.currentPassword.touched && form.controls.currentPassword.invalid) {
              <mat-error>{{ message('currentPassword', 'Current password') }}</mat-error>
            }
          </mat-form-field>

          <mat-form-field appearance="outline">
            <mat-label>New password</mat-label>
            <input matInput type="password" formControlName="newPassword" autocomplete="new-password" />
            @if (form.controls.newPassword.touched && form.controls.newPassword.invalid) {
              <mat-error>{{ message('newPassword', 'New password') }}</mat-error>
            }
          </mat-form-field>

          <mat-form-field appearance="outline">
            <mat-label>Confirm new password</mat-label>
            <input matInput type="password" formControlName="confirmPassword" autocomplete="new-password" />
            @if (form.controls.confirmPassword.touched && form.hasError('mismatch')) {
              <mat-error>Passwords do not match.</mat-error>
            }
          </mat-form-field>

          <div class="actions">
            <button matButton type="button" (click)="cancel()">Cancel</button>
            <button matButton="filled" type="submit" [disabled]="busy()">Update password</button>
          </div>
        </form>
      </mat-card-content>
    </mat-card>
  `,
  styles: `
    .card { max-width: 520px; }
    form { display: flex; flex-direction: column; gap: 4px; }
    mat-form-field { width: 100%; }
    .actions { display: flex; justify-content: flex-end; gap: 8px; margin-top: 8px; }
    @media (max-width: 599px) {
      .actions { flex-direction: column-reverse; }
      .actions button { width: 100%; }
    }
  `,
})
export class ChangePassword {
  private readonly fb = inject(FormBuilder);
  private readonly api = inject(AuthApiService);
  private readonly auth = inject(AuthStore);
  private readonly toast = inject(ToastService);
  private readonly router = inject(Router);

  protected readonly busy = signal(false);

  protected readonly form = this.fb.nonNullable.group(
    {
      currentPassword: ['', [Validators.required]],
      newPassword: ['', [Validators.required, Validators.minLength(6)]],
      confirmPassword: ['', [Validators.required]],
    },
    { validators: passwordsMatch },
  );

  protected message(control: 'currentPassword' | 'newPassword', label: string): string {
    return firstErrorMessage(this.form.controls[control], label);
  }

  protected cancel(): void {
    void this.router.navigate(['/dashboard']);
  }

  protected async submit(): Promise<void> {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    const mobileNumber = this.auth.claims()?.userName ?? '';
    if (!mobileNumber) {
      this.toast.error('Could not determine your account. Please sign in again.');
      return;
    }

    this.busy.set(true);
    const { currentPassword, newPassword } = this.form.getRawValue();

    try {
      await firstValueFrom(this.api.changePassword({ mobileNumber, currentPassword, newPassword }));
      this.toast.success('Password updated. Please sign in again.');
      this.auth.logout();
    } catch (err) {
      this.toast.error(describeHttpError(err as never));
    } finally {
      this.busy.set(false);
    }
  }
}
