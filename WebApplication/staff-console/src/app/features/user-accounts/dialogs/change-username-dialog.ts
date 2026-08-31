import { HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { firstValueFrom } from 'rxjs';
import { describeHttpError } from '../../../core/http/interceptors';
import { ToastService } from '../../../core/ui/toast.service';
import { firstErrorMessage, mobileNumberValidator } from '../../../shared/util/validators';
import { UserAccount, UserAccountsApiService, userAccountFullName } from '../data/user-accounts-api.service';

export interface ChangeUserNameDialogData {
  user: UserAccount;
}

@Component({
  selector: 'app-change-username-dialog',
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
    <h2 mat-dialog-title>Change username</h2>
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

      <p class="current">Current username: <strong>{{ data.user.mobileNumber || '—' }}</strong></p>

      <form [formGroup]="form" (ngSubmit)="save()">
        <mat-form-field appearance="outline">
          <mat-label>New username (mobile number)</mat-label>
          <input matInput formControlName="newUserName" inputmode="numeric" maxlength="10" />
          @if (invalid('newUserName')) {
            <mat-error>{{ error('newUserName', 'Username') }}</mat-error>
          }
        </mat-form-field>
      </form>

      <p class="note">
        The username is the user's login and mobile number. Changing it updates their profile
        record too, and signs them out of any active session.
      </p>

      @if (failure()) {
        <p class="failure">{{ failure() }}</p>
      }
    </mat-dialog-content>

    <mat-dialog-actions align="end">
      <button mat-button type="button" (click)="close()" [disabled]="busy()">Cancel</button>
      <button mat-flat-button type="button" (click)="save()" [disabled]="busy() || form.invalid">
        Change username
      </button>
    </mat-dialog-actions>
  `,
  styles: `
    :host { display: block; }
    mat-dialog-content { min-width: 360px; }
    form { display: block; margin-top: 8px; }
    mat-form-field { width: 100%; }
    .who { margin: 0 0 4px; display: flex; gap: 8px; align-items: baseline; }
    .role { font-size: 12px; opacity: 0.7; }
    .current { margin: 0 0 12px; font-size: 13px; opacity: 0.85; }
    .note { margin: 4px 0 0; font-size: 12px; opacity: 0.75; line-height: 1.45; }
    .failure { margin: 12px 0 0; font-size: 13px; color: var(--mat-sys-error, #b3261e); }
  `,
})
export class ChangeUserNameDialog {
  private readonly api = inject(UserAccountsApiService);
  private readonly toast = inject(ToastService);
  private readonly fb = inject(FormBuilder);
  private readonly ref = inject(MatDialogRef<ChangeUserNameDialog, boolean>);
  protected readonly data = inject<ChangeUserNameDialogData>(MAT_DIALOG_DATA);

  protected readonly busy = signal(false);
  protected readonly failure = signal<string | null>(null);
  protected readonly name = userAccountFullName(this.data.user) || '(no name)';

  protected readonly form = this.fb.nonNullable.group({
    newUserName: ['', [Validators.required, mobileNumberValidator()]],
  });

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

    const newUserName = this.form.getRawValue().newUserName.trim();
    if (newUserName === (this.data.user.mobileNumber ?? '')) {
      this.failure.set('That is already this user’s username.');
      return;
    }

    this.busy.set(true);
    this.failure.set(null);

    try {
      const result = await firstValueFrom(this.api.changeUserName(this.data.user.id, newUserName));
      const synced = result.profileUpdated ? ` ${result.profileUpdated} profile updated too.` : '';
      this.toast.success(`Username changed to ${newUserName}.${synced}`);
      this.ref.close(true);
    } catch (err) {
      const error = err as HttpErrorResponse;
      // 409 means the number is taken - the most likely failure, so name it plainly.
      this.failure.set(
        error.status === 409
          ? 'That mobile number already belongs to another account.'
          : describeHttpError(error),
      );
    } finally {
      this.busy.set(false);
    }
  }
}
