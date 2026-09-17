import { HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import {
  AbstractControl,
  FormBuilder,
  ReactiveFormsModule,
  ValidationErrors,
  ValidatorFn,
  Validators,
} from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { provideNativeDateAdapter } from '@angular/material/core';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { Router, RouterLink } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { AuthStore } from '../../../core/auth/auth.store';
import { describeHttpError } from '../../../core/http/interceptors';
import { firstErrorMessage, mobileNumberValidator } from '../../../shared/util/validators';
import { PortalApiService } from '../data/portal-api.service';

/** The server's Identity policy: 6+ characters with an uppercase, a lowercase, a digit and a symbol. */
function passwordPolicy(): ValidatorFn {
  return (c: AbstractControl): ValidationErrors | null => {
    const v = String(c.value ?? '');
    if (!v) return null;
    const ok = v.length >= 6 && /[A-Z]/.test(v) && /[a-z]/.test(v) && /\d/.test(v) && /[^A-Za-z0-9]/.test(v);
    return ok ? null : { policy: true };
  };
}

const matches: ValidatorFn = (g: AbstractControl): ValidationErrors | null =>
  g.get('confirm')?.value && g.get('password')?.value !== g.get('confirm')?.value ? { mismatch: true } : null;

/**
 * Public customer sign-up — the web counterpart of the mobile registration screen. On success it
 * signs the customer straight in, so there's no second form to fill.
 */
@Component({
  selector: 'app-customer-register-page',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: { class: 'portal-theme' },
  providers: [provideNativeDateAdapter()],
  imports: [
    ReactiveFormsModule, RouterLink, MatButtonModule, MatIconModule, MatFormFieldModule,
    MatInputModule, MatSelectModule, MatDatepickerModule,
  ],
  template: `
    <div class="page">
      <aside class="brand">
        <a routerLink="/login" class="logo"><img src="logo.png" alt="" width="44" height="44" /><span>Pharmaish</span></a>
        <div class="pitch">
          <h1>Medicines from a chemist near you, delivered.</h1>
          <ul>
            <li><mat-icon>photo_camera</mat-icon><span>Send a photo of your prescription, type it, or say it.</span></li>
            <li><mat-icon>request_quote</mat-icon><span>See the exact bill before you pay a rupee.</span></li>
            <li><mat-icon>verified_user</mat-icon><span>Secure payment and a delivery code only you can share.</span></li>
          </ul>
        </div>
        <p class="small">Already have an account? <a routerLink="/login">Sign in</a></p>
      </aside>

      <main class="panel">
        <form [formGroup]="form" (ngSubmit)="submit()" novalidate>
          <h2>Create your account</h2>
          <p class="lead">It takes a minute. You'll use your mobile number to sign in.</p>

          @if (errors().length) {
            <div class="alert" role="alert">
              <mat-icon>error_outline</mat-icon>
              <ul>@for (e of errors(); track e) { <li>{{ e }}</li> }</ul>
            </div>
          }

          <div class="grid">
            <mat-form-field appearance="outline">
              <mat-label>First name</mat-label>
              <input matInput formControlName="firstName" autocomplete="given-name" />
              @if (bad('firstName')) { <mat-error>{{ err('firstName', 'First name') }}</mat-error> }
            </mat-form-field>
            <mat-form-field appearance="outline">
              <mat-label>Last name</mat-label>
              <input matInput formControlName="lastName" autocomplete="family-name" />
              @if (bad('lastName')) { <mat-error>{{ err('lastName', 'Last name') }}</mat-error> }
            </mat-form-field>

            <mat-form-field appearance="outline" class="span">
              <mat-label>Mobile number</mat-label>
              <span matTextPrefix>+91&nbsp;</span>
              <input matInput formControlName="mobile" inputmode="numeric" maxlength="10" autocomplete="tel-national" />
              <mat-hint>This is your username.</mat-hint>
              @if (bad('mobile')) { <mat-error>{{ err('mobile', 'Mobile number') }}</mat-error> }
            </mat-form-field>

            <mat-form-field appearance="outline" class="span">
              <mat-label>Email (optional)</mat-label>
              <input matInput type="email" formControlName="email" autocomplete="email" />
              @if (bad('email')) { <mat-error>Enter a valid email address.</mat-error> }
            </mat-form-field>

            <mat-form-field appearance="outline">
              <mat-label>Date of birth</mat-label>
              <input matInput [matDatepicker]="dob" formControlName="dob" [max]="today" />
              <mat-datepicker-toggle matIconSuffix [for]="dob" />
              <mat-datepicker #dob startView="multi-year" />
              @if (bad('dob')) { <mat-error>Date of birth is required.</mat-error> }
            </mat-form-field>
            <mat-form-field appearance="outline">
              <mat-label>Gender</mat-label>
              <mat-select formControlName="gender">
                <mat-option value="Female">Female</mat-option>
                <mat-option value="Male">Male</mat-option>
                <mat-option value="Other">Other</mat-option>
              </mat-select>
            </mat-form-field>

            <mat-form-field appearance="outline">
              <mat-label>Password</mat-label>
              <input matInput [type]="show() ? 'text' : 'password'" formControlName="password" autocomplete="new-password" />
              <button matIconButton matSuffix type="button" (click)="show.set(!show())" [attr.aria-label]="show() ? 'Hide password' : 'Show password'">
                <mat-icon>{{ show() ? 'visibility_off' : 'visibility' }}</mat-icon>
              </button>
              @if (bad('password')) { <mat-error>{{ form.controls.password.hasError('policy') ? 'Needs 6+ characters with A-Z, a-z, 0-9 and a symbol.' : 'Password is required.' }}</mat-error> }
            </mat-form-field>
            <mat-form-field appearance="outline">
              <mat-label>Confirm password</mat-label>
              <input matInput [type]="show() ? 'text' : 'password'" formControlName="confirm" autocomplete="new-password" />
              @if (form.controls.confirm.touched && form.hasError('mismatch')) { <mat-error>Passwords don't match.</mat-error> }
            </mat-form-field>
          </div>

          <p class="rules" [class.met]="!form.controls.password.hasError('policy') && form.controls.password.value">
            <mat-icon>{{ !form.controls.password.hasError('policy') && form.controls.password.value ? 'check_circle' : 'info' }}</mat-icon>
            At least 6 characters, with an uppercase letter, a lowercase letter, a number and a symbol.
          </p>

          <button matButton="filled" class="pt-cta submit" type="submit" [disabled]="busy()">
            {{ busy() ? 'Creating your account…' : 'Create account' }}
          </button>
          <p class="small center">Already have an account? <a routerLink="/login">Sign in</a></p>
        </form>
      </main>
    </div>
  `,
  styles: `
    :host { display: block; min-height: 100dvh; background: var(--pt-ground); }
    .page { display: grid; grid-template-columns: minmax(320px, 0.9fr) 1.1fr; min-height: 100dvh; }

    .brand { background: linear-gradient(160deg, var(--pt-navy) 0%, var(--pt-navy-deep) 100%); color: #fff; padding: 40px 48px; display: flex; flex-direction: column; justify-content: space-between; gap: 32px; }
    .logo { display: flex; align-items: center; gap: 10px; color: #fff; text-decoration: none; font-weight: 800; font-size: 1.3rem; }
    .logo img { border-radius: 12px; background: #fff; }
    .pitch h1 { margin: 0 0 28px; font-size: clamp(1.9rem, 3vw, 2.6rem); font-weight: 800; letter-spacing: -0.03em; line-height: 1.1; text-wrap: balance; }
    .pitch ul { list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; gap: 18px; }
    .pitch li { display: flex; gap: 14px; align-items: flex-start; font-size: 1.02rem; line-height: 1.45; color: rgba(255,255,255,0.88); }
    .pitch mat-icon { width: 40px; height: 40px; border-radius: 12px; background: var(--pt-orange); color: #fff; display: grid; place-items: center; flex: none; font-size: 22px; }
    .small { margin: 0; font-size: 0.92rem; }
    .brand .small { color: rgba(255,255,255,0.75); }
    .brand a { color: #fff; font-weight: 700; }

    .panel { display: grid; place-items: center; padding: 40px 24px; }
    form { width: min(520px, 100%); }
    h2 { margin: 0; font-size: 1.8rem; font-weight: 800; letter-spacing: -0.02em; color: var(--pt-navy-deep); }
    .lead { margin: 6px 0 22px; color: var(--pt-muted); }
    .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 2px 14px; }
    .span { grid-column: 1 / -1; }
    mat-form-field { width: 100%; }
    .rules { display: flex; gap: 8px; align-items: flex-start; margin: 2px 0 20px; color: var(--pt-muted); font-size: 0.86rem; }
    .rules mat-icon { font-size: 18px; width: 18px; height: 18px; flex: none; }
    .rules.met { color: var(--pt-good); }
    .submit { width: 100%; height: 52px; font-size: 1.05rem; }
    .center { text-align: center; margin-top: 16px; color: var(--pt-muted); }
    .panel a { color: var(--pt-navy); font-weight: 700; }
    .alert { display: flex; gap: 10px; padding: 12px 14px; border-radius: 12px; background: var(--pt-stop-soft); color: var(--pt-stop); margin-bottom: 16px; }
    .alert ul { margin: 0; padding-left: 16px; }

    @media (max-width: 860px) {
      .page { grid-template-columns: 1fr; }
      .brand { padding: 28px 22px; gap: 20px; }
      .pitch h1 { font-size: 1.6rem; margin-bottom: 16px; }
      .pitch ul, .brand > .small { display: none; }
      .grid { grid-template-columns: 1fr; }
    }
  `,
})
export class CustomerRegisterPage {
  private readonly fb = inject(FormBuilder);
  private readonly api = inject(PortalApiService);
  private readonly auth = inject(AuthStore);
  private readonly router = inject(Router);

  protected readonly today = new Date();
  protected readonly show = signal(false);
  protected readonly busy = signal(false);
  protected readonly errors = signal<string[]>([]);

  protected readonly form = this.fb.nonNullable.group(
    {
      firstName: ['', [Validators.required, Validators.maxLength(100)]],
      lastName: ['', [Validators.required, Validators.maxLength(100)]],
      mobile: ['', [Validators.required, mobileNumberValidator()]],
      email: ['', [Validators.email]],
      dob: [null as Date | null, [Validators.required]],
      gender: [''],
      password: ['', [Validators.required, passwordPolicy()]],
      confirm: ['', [Validators.required]],
    },
    { validators: [matches] },
  );

  protected bad(name: keyof typeof this.form.controls): boolean {
    const c = this.form.controls[name];
    return c.touched && c.invalid;
  }

  protected err(name: keyof typeof this.form.controls, label: string): string {
    return firstErrorMessage(this.form.controls[name], label);
  }

  protected async submit(): Promise<void> {
    this.errors.set([]);
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }
    const v = this.form.getRawValue();
    this.busy.set(true);

    try {
      await firstValueFrom(
        this.api.register({
          customerFirstName: v.firstName.trim(),
          customerMiddleName: null,
          customerLastName: v.lastName.trim(),
          mobileNumber: v.mobile.trim(),
          password: v.password,
          alternativeMobileNumber: null,
          emailId: v.email.trim() || null,
          dateOfBirth: toIsoDate(v.dob!),
          gender: v.gender || null,
        }),
      );
    } catch (err) {
      const e = err as HttpErrorResponse;
      const list = e.error?.errors;
      this.errors.set(Array.isArray(list) && list.length ? list.map(String) : [describeHttpError(e)]);
      this.busy.set(false);
      return;
    }

    // Straight in — no second form.
    const outcome = await this.auth.login(v.mobile.trim(), v.password, false);
    this.busy.set(false);
    if (outcome.ok) {
      void this.router.navigate(['/my']);
    } else {
      void this.router.navigate(['/login']);
    }
  }
}

/** Keeps the chosen calendar day regardless of the browser's timezone. */
function toIsoDate(date: Date): string {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, '0');
  const d = String(date.getDate()).padStart(2, '0');
  return `${y}-${m}-${d}T00:00:00Z`;
}
