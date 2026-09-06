import { HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { AbstractControl, FormBuilder, ReactiveFormsModule, ValidationErrors, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { firstValueFrom } from 'rxjs';
import { describeHttpError } from '../../../core/http/interceptors';
import { ToastService } from '../../../core/ui/toast.service';
import { firstErrorMessage } from '../../../shared/util/validators';
import { UserAccount, UserAccountsApiService, userAccountFullName } from '../data/user-accounts-api.service';

export interface ResetPasswordDialogData {
  user: UserAccount;
}

/** Both fields must match before the reset is allowed. */
function passwordsMatch(group: AbstractControl): ValidationErrors | null {
  const password = group.get('newPassword')?.value;
  const confirm = group.get('confirmPassword')?.value;
  return password && confirm && password !== confirm ? { passwordMismatch: true } : null;
}

@Component({
  selector: 'app-reset-password-dialog',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    ReactiveFormsModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatProgressBarModule,
  ],
  template: `
    <h2 mat-dialog-title>Reset password</h2>
    @if (busy()) {
      <mat-progress-bar mode="indeterminate" />
    }

    <mat-dialog-content>
      <p class="who">
        <strong>{{ name }}</strong>
        @if (data.user.roleName) {
          <span class="role">{{ data.user.roleName }}</span>
        }
      </p>
      <p class="current">Username: <strong>{{ data.user.mobileNumber || '—' }}</strong></p>

      <form [formGroup]="form" (ngSubmit)="save()">
        <mat-form-field appearance="outline">
          <mat-label>New password</mat-label>
          <input matInput type="password" formControlName="newPassword" autocomplete="new-password" />
          @if (invalid('newPassword')) {
            <mat-error>{{ error('newPassword', 'Password') }}</mat-error>
          }
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Confirm password</mat-label>
          <input matInput type="password" formControlName="confirmPassword" autocomplete="new-password" />
          @if (invalid('confirmPassword')) {
            <mat-error>{{ error('confirmPassword', 'Confirmation') }}</mat-error>
          }
        </mat-form-field>

        @if (form.hasError('passwordMismatch') && form.get('confirmPassword')?.touched) {
          <p class="failure">The two passwords do not match.</p>
        }
      </form>

      <p class="note">
        Tell the user their new password through a channel other than this system. Resetting signs
        them out of any active session.
      </p>

      @if (failure()) {
        <p class="failure">{{ failure() }}</p>
      }
    </mat-dialog-content>

    <mat-dialog-actions align="end">
      <button mat-button type="button" (click)="close()" [disabled]="busy()">Cancel</button>
      <button mat-flat-button type="button" (click)="save()" [disabled]="busy() || form.invalid">
        Reset password
      </button>
    </mat-dialog-actions>
  `,
  styles: `
    :host { display: block; }
    mat-dialog-content { min-width: 360px; }
    form { display: flex; flex-direction: column; margin-top: 8px; }
    mat-form-field { width: 100%; }
    .who { margin: 0 0 4px; display: flex; gap: 8px; align-items: baseline; }
    .role { font-size: 12px; opacity: 0.7; }
    .current { margin: 0 0 12px; font-size: 13px; opacity: 0.85; }
    .note { margin: 4px 0 0; font-size: 12px; opacity: 0.75; line-height: 1.45; }
    .failure { margin: 8px 0 0; font-size: 13px; color: var(--mat-sys-error, #b3261e); }
  `,
})
export class ResetPasswordDialog {
  private readonly api = inject(UserAccountsApiService);
  private readonly toast = inject(ToastService);
  private readonly fb = inject(FormBuilder);
  private readonly ref = inject(MatDialogRef<ResetPasswordDialog, boolean>);
  protected readonly data = inject<ResetPasswordDialogData>(MAT_DIALOG_DATA);

  protected readonly busy = signal(false);
  protected readonly failure = signal<string | null>(null);
  protected readonly name = userAccountFullName(this.data.user) || '(no name)';

  protected readonly form = this.fb.nonNullable.group(
    {
      // Mirrors the API's Identity policy: at least 6 characters.
      newPassword: ['', [Validators.required, Validators.minLength(6)]],
      confirmPassword: ['', [Validators.required]],
    },
    { validators: passwordsMatch },
  );

  protected invalid(control: string): boolean {
    const c = this.form.get(control);
    return !!c && c.invalid && (c.dirty || c.touched);
  }

  protected error(control: string, label: string): string {
    return firstErrorMessage(this.form.get(control), label);
  }

  protected close(): void {
    this.ref.close(false);
  }

  protected async save(): Promise<void> {
    if (this.form.invalid || this.busy()) {
      this.form.markAllAsTouched();
      return;
    }

    this.busy.set(true);
    this.failure.set(null);

    try {
      const { newPassword } = this.form.getRawValue();
      await firstValueFrom(this.api.resetPassword(this.data.user.id, newPassword));
      this.toast.success('Password reset. The user has been signed out of existing sessions.');
      this.ref.close(true);
    } catch (err) {
      const error = err as HttpErrorResponse;
      this.failure.set(describeHttpError(error));
    } finally {
      this.busy.set(false);
    }
  }
}
