import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { AuthStore } from '../../core/auth/auth.store';
import { firstErrorMessage, mobileNumberValidator } from '../../shared/util/validators';

@Component({
  selector: 'app-login',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    ReactiveFormsModule,
    RouterLink,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatCheckboxModule,
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
          <div class="brand">
            <mat-icon class="brand-icon">medical_services</mat-icon>
            <div>
              <h1>Pharmaish</h1>
              <p>Staff console</p>
            </div>
          </div>

          @if (error()) {
            <div class="error" role="alert">
              <mat-icon>error_outline</mat-icon>
              <span>{{ error() }}</span>
            </div>
          }

          <form [formGroup]="form" (ngSubmit)="submit()">
            <mat-form-field appearance="outline">
              <mat-label>Mobile number</mat-label>
              <input
                matInput
                formControlName="mobileNumber"
                inputmode="numeric"
                autocomplete="username"
                maxlength="10"
              />
              @if (form.controls.mobileNumber.touched && form.controls.mobileNumber.invalid) {
                <mat-error>{{ messageFor('mobileNumber', 'Mobile number') }}</mat-error>
              }
            </mat-form-field>

            <mat-form-field appearance="outline">
              <mat-label>Password</mat-label>
              <input
                matInput
                formControlName="password"
                [type]="showPassword() ? 'text' : 'password'"
                autocomplete="current-password"
              />
              <button
                matIconButton
                matSuffix
                type="button"
                [attr.aria-label]="showPassword() ? 'Hide password' : 'Show password'"
                (click)="showPassword.set(!showPassword())"
              >
                <mat-icon>{{ showPassword() ? 'visibility_off' : 'visibility' }}</mat-icon>
              </button>
              @if (form.controls.password.touched && form.controls.password.invalid) {
                <mat-error>{{ messageFor('password', 'Password') }}</mat-error>
              }
            </mat-form-field>

            <div class="row">
              <mat-checkbox formControlName="stayLoggedIn">Keep me signed in</mat-checkbox>
              <a routerLink="/forgot-password">Forgot password?</a>
            </div>

            <button matButton="filled" type="submit" class="submit" [disabled]="busy()">
              Sign in
            </button>
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

    .brand {
      display: flex;
      align-items: center;
      gap: 12px;
      margin-bottom: 24px;
    }
    .brand-icon { color: var(--mat-sys-primary); width: 36px; height: 36px; font-size: 36px; }
    h1 { margin: 0; font: var(--mat-sys-headline-small); }
    .brand p { margin: 0; color: var(--mat-sys-on-surface-variant); font: var(--mat-sys-body-small); }

    form { display: flex; flex-direction: column; gap: 4px; }
    mat-form-field { width: 100%; }

    .row {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
      flex-wrap: wrap;
      margin-bottom: 16px;
    }
    .row a { color: var(--mat-sys-primary); font: var(--mat-sys-body-small); }

    .submit { width: 100%; }

    .error {
      display: flex;
      align-items: flex-start;
      gap: 8px;
      padding: 12px;
      margin-bottom: 16px;
      border-radius: 8px;
      background: var(--mat-sys-error-container);
      color: var(--mat-sys-on-error-container);
      font: var(--mat-sys-body-small);
    }
    .error mat-icon { flex: none; }
  `,
})
export class Login {
  private readonly fb = inject(FormBuilder);
  private readonly auth = inject(AuthStore);
  private readonly router = inject(Router);
  private readonly route = inject(ActivatedRoute);

  protected readonly busy = signal(false);
  protected readonly error = signal<string | null>(null);
  protected readonly showPassword = signal(false);

  protected readonly form = this.fb.nonNullable.group({
    mobileNumber: ['', [Validators.required, mobileNumberValidator()]],
    password: ['', [Validators.required]],
    stayLoggedIn: [false],
  });

  protected messageFor(control: 'mobileNumber' | 'password', label: string): string {
    return firstErrorMessage(this.form.controls[control], label);
  }

  protected async submit(): Promise<void> {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    this.busy.set(true);
    this.error.set(null);

    const { mobileNumber, password, stayLoggedIn } = this.form.getRawValue();
    const outcome = await this.auth.login(mobileNumber.trim(), password, stayLoggedIn);

    this.busy.set(false);

    if (!outcome.ok) {
      this.error.set(outcome.error ?? 'Sign-in failed.');
      return;
    }

    const returnUrl = this.route.snapshot.queryParamMap.get('returnUrl') ?? '/dashboard';
    void this.router.navigateByUrl(returnUrl);
  }
}
