import { HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, inject, input, output, signal } from '@angular/core';
import {
  AbstractControl,
  FormBuilder,
  ReactiveFormsModule,
  ValidationErrors,
  ValidatorFn,
  Validators,
} from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { firstValueFrom } from 'rxjs';
import { describeHttpError } from '../../../core/http/interceptors';
import { MedicalStoreRegistration } from '../../../core/models/api.models';
import {
  firstErrorMessage,
  mobileNumberValidator,
  pinCodeValidator,
} from '../../../shared/util/validators';
import { ChemistsApiService } from '../data/chemists-api.service';

export interface ChemistRegistered {
  medicalStoreId: string;
  medicalName: string;
}

/**
 * The chemist registration form itself, with no chrome of its own, so it can be hosted both by the
 * staff dialog and by the public sign-up page.
 *
 * Owns validation and the API call; the host decides what "done" looks like. Call `submit()` from
 * the host's action button and listen to `registered`.
 *
 * Password rules mirror the mobile self-registration screen exactly (8+ characters with an
 * uppercase, a lowercase, a digit and a symbol), so a chemist faces the same rules whichever way
 * they sign up.
 */
@Component({
  selector: 'app-chemist-register-form',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    ReactiveFormsModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatIconModule,
    MatSlideToggleModule,
  ],
  template: `
    @if (serverErrors().length) {
      <div class="errors" role="alert">
        <mat-icon>error_outline</mat-icon>
        <ul>
          @for (message of serverErrors(); track message) {
            <li>{{ message }}</li>
          }
        </ul>
      </div>
    }

    <form [formGroup]="form" (ngSubmit)="submit()">
      <h3>Store</h3>
      <div class="grid">
        <mat-form-field appearance="outline" class="span-2">
          <mat-label>Store name</mat-label>
          <input matInput formControlName="medicalName" />
          @if (invalid('medicalName')) {
            <mat-error>{{ error('medicalName', 'Store name') }}</mat-error>
          }
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Owner first name</mat-label>
          <input matInput formControlName="ownerFirstName" />
          @if (invalid('ownerFirstName')) {
            <mat-error>{{ error('ownerFirstName', 'Owner first name') }}</mat-error>
          }
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Owner last name</mat-label>
          <input matInput formControlName="ownerLastName" />
          @if (invalid('ownerLastName')) {
            <mat-error>{{ error('ownerLastName', 'Owner last name') }}</mat-error>
          }
        </mat-form-field>

        <mat-form-field appearance="outline" class="span-2">
          <mat-label>Owner middle name</mat-label>
          <input matInput formControlName="ownerMiddleName" />
        </mat-form-field>
      </div>

      <h3>Login</h3>
      <div class="grid">
        <mat-form-field appearance="outline">
          <mat-label>Mobile number</mat-label>
          <input
            matInput
            formControlName="mobileNumber"
            inputmode="numeric"
            autocomplete="username"
            maxlength="10"
          />
          @if (invalid('mobileNumber')) {
            <mat-error>{{ error('mobileNumber', 'Mobile number') }}</mat-error>
          }
          <mat-hint>This becomes the username.</mat-hint>
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Email</mat-label>
          <input matInput type="email" formControlName="emailId" autocomplete="email" />
          @if (invalid('emailId')) {
            <mat-error>{{ error('emailId', 'Email') }}</mat-error>
          }
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Password</mat-label>
          <input
            matInput
            [type]="reveal() ? 'text' : 'password'"
            formControlName="password"
            autocomplete="new-password"
          />
          <button
            matIconButton
            matSuffix
            type="button"
            (click)="reveal.set(!reveal())"
            [attr.aria-label]="reveal() ? 'Hide password' : 'Show password'"
          >
            <mat-icon>{{ reveal() ? 'visibility_off' : 'visibility' }}</mat-icon>
          </button>
          @if (invalid('password')) {
            <mat-error>{{ passwordError() }}</mat-error>
          }
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Confirm password</mat-label>
          <input
            matInput
            [type]="reveal() ? 'text' : 'password'"
            formControlName="confirmPassword"
            autocomplete="new-password"
          />
          @if (form.controls.confirmPassword.touched && form.hasError('passwordMismatch')) {
            <mat-error>Passwords do not match.</mat-error>
          }
        </mat-form-field>

        <p class="hint span-2">
          At least 8 characters, with an uppercase letter, a lowercase letter, a number and a symbol.
          @if (showGenerator()) {
            <button matButton type="button" (click)="generatePassword()">
              <mat-icon>casino</mat-icon>
              Generate
            </button>
          }
        </p>

        <mat-form-field appearance="outline" class="span-2">
          <mat-label>Alternative mobile</mat-label>
          <input
            matInput
            formControlName="alternativeMobileNumber"
            inputmode="numeric"
            maxlength="10"
          />
          @if (invalid('alternativeMobileNumber')) {
            <mat-error>{{ error('alternativeMobileNumber', 'Alternative mobile') }}</mat-error>
          }
        </mat-form-field>
      </div>

      <h3>Address</h3>
      <div class="grid">
        <mat-form-field appearance="outline" class="span-2">
          <mat-label>Address line 1</mat-label>
          <input matInput formControlName="addressLine1" />
        </mat-form-field>

        <mat-form-field appearance="outline" class="span-2">
          <mat-label>Address line 2</mat-label>
          <input matInput formControlName="addressLine2" />
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>City</mat-label>
          <input matInput formControlName="city" />
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>State</mat-label>
          <input matInput formControlName="state" />
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Pin code</mat-label>
          <input matInput formControlName="postalCode" inputmode="numeric" maxlength="6" />
          @if (invalid('postalCode')) {
            <mat-error>{{ error('postalCode', 'Pin code') }}</mat-error>
          }
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Latitude</mat-label>
          <input matInput formControlName="latitude" inputmode="decimal" />
          @if (invalid('latitude')) {
            <mat-error>{{ error('latitude', 'Latitude') }}</mat-error>
          }
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Longitude</mat-label>
          <input matInput formControlName="longitude" inputmode="decimal" />
          @if (invalid('longitude')) {
            <mat-error>{{ error('longitude', 'Longitude') }}</mat-error>
          }
        </mat-form-field>

        <p class="hint span-2">
          Orders are matched to the nearest store within 5 km using these coordinates. Without them
          the store can only be found by pin code.
          <button matButton type="button" (click)="useCurrentLocation()" [disabled]="locating()">
            <mat-icon>my_location</mat-icon>
            {{ locating() ? 'Locating…' : 'Use my current location' }}
          </button>
        </p>
        @if (locationError()) {
          <p class="hint span-2 warn">{{ locationError() }}</p>
        }
      </div>

      <h3>Statutory</h3>
      <div class="grid">
        <mat-form-field appearance="outline">
          <mat-label>GSTIN</mat-label>
          <input matInput formControlName="gstin" />
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>PAN</mat-label>
          <input matInput formControlName="pan" />
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>FSSAI number</mat-label>
          <input matInput formControlName="fssaiNo" />
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Drug licence number</mat-label>
          <input matInput formControlName="dlNo" />
        </mat-form-field>

        <mat-slide-toggle formControlName="registrationStatus" class="span-2">
          GST registered
        </mat-slide-toggle>
      </div>

      <h3>Pharmacist</h3>
      <div class="grid">
        <mat-form-field appearance="outline">
          <mat-label>First name</mat-label>
          <input matInput formControlName="pharmacistFirstName" />
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Last name</mat-label>
          <input matInput formControlName="pharmacistLastName" />
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Registration number</mat-label>
          <input matInput formControlName="pharmacistRegistrationNumber" />
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Mobile number</mat-label>
          <input
            matInput
            formControlName="pharmacistMobileNumber"
            inputmode="numeric"
            maxlength="10"
          />
          @if (invalid('pharmacistMobileNumber')) {
            <mat-error>{{ error('pharmacistMobileNumber', 'Pharmacist mobile') }}</mat-error>
          }
        </mat-form-field>
      </div>
    </form>
  `,
  styles: `
    :host { display: block; }
    h3 {
      margin: 16px 0 8px;
      font: var(--mat-sys-title-small);
      color: var(--mat-sys-primary);
    }
    h3:first-of-type { margin-top: 4px; }
    .grid {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 4px 16px;
    }
    mat-form-field { width: 100%; }
    .span-2 { grid-column: 1 / -1; }
    mat-slide-toggle { margin: 8px 0; }
    .hint {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
      flex-wrap: wrap;
      margin: 0 0 8px;
      color: var(--mat-sys-on-surface-variant);
      font: var(--mat-sys-body-small);
    }
    .warn { color: var(--mat-sys-error); }
    .errors {
      display: flex;
      gap: 10px;
      padding: 12px 14px;
      margin-bottom: 8px;
      border-radius: 8px;
      background: var(--mat-sys-error-container);
      color: var(--mat-sys-on-error-container);
      font: var(--mat-sys-body-medium);
    }
    .errors ul { margin: 0; padding-left: 18px; }

    @media (max-width: 599px) {
      .grid { grid-template-columns: 1fr; }
    }
  `,
})
export class ChemistRegisterForm {
  private readonly fb = inject(FormBuilder);
  private readonly api = inject(ChemistsApiService);

  /** Staff registering on someone's behalf get a generator; a chemist signing up picks their own. */
  readonly showGenerator = input(true);

  readonly registered = output<ChemistRegistered>();

  readonly busy = signal(false);
  protected readonly reveal = signal(false);
  protected readonly locating = signal(false);
  protected readonly locationError = signal<string | null>(null);
  /** Duplicate email / mobile come back as a list from the API, not as field errors. */
  protected readonly serverErrors = signal<string[]>([]);

  protected readonly form = this.fb.nonNullable.group(
    {
      medicalName: ['', [Validators.required]],
      ownerFirstName: ['', [Validators.required]],
      ownerMiddleName: [''],
      ownerLastName: ['', [Validators.required]],
      mobileNumber: ['', [Validators.required, mobileNumberValidator()]],
      emailId: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required, passwordPolicyValidator()]],
      confirmPassword: ['', [Validators.required]],
      alternativeMobileNumber: ['', [mobileNumberValidator()]],
      addressLine1: [''],
      addressLine2: [''],
      city: [''],
      state: [''],
      postalCode: ['', [Validators.required, pinCodeValidator()]],
      latitude: ['', [coordinateValidator(-90, 90)]],
      longitude: ['', [coordinateValidator(-180, 180)]],
      registrationStatus: [false],
      gstin: [''],
      pan: [''],
      fssaiNo: [''],
      dlNo: [''],
      pharmacistFirstName: [''],
      pharmacistLastName: [''],
      pharmacistRegistrationNumber: [''],
      pharmacistMobileNumber: ['', [mobileNumberValidator()]],
    },
    { validators: [passwordsMatchValidator] },
  );

  protected invalid(control: keyof typeof this.form.controls): boolean {
    const field = this.form.controls[control];
    return field.touched && field.invalid;
  }

  protected error(control: keyof typeof this.form.controls, label: string): string {
    return firstErrorMessage(this.form.controls[control], label);
  }

  protected passwordError(): string {
    const control = this.form.controls.password;
    if (control.hasError('required')) {
      return 'Password is required.';
    }
    if (control.hasError('passwordPolicy')) {
      return 'Needs 8+ characters with an uppercase, a lowercase, a number and a symbol.';
    }
    return firstErrorMessage(control, 'Password');
  }

  protected generatePassword(): void {
    const password = generateStrongPassword();
    this.form.patchValue({ password, confirmPassword: password });
    // Staff have to read this out to the chemist, so show it rather than leaving dots on screen.
    this.reveal.set(true);
  }

  /**
   * Fills the coordinates from the browser. Worth the extra control: a store saved without
   * coordinates is skipped entirely by the geo search that routes orders.
   */
  protected useCurrentLocation(): void {
    this.locationError.set(null);

    if (!navigator.geolocation) {
      this.locationError.set('This browser cannot report a location. Enter the coordinates manually.');
      return;
    }

    this.locating.set(true);
    navigator.geolocation.getCurrentPosition(
      (position) => {
        this.form.patchValue({
          latitude: position.coords.latitude.toFixed(6),
          longitude: position.coords.longitude.toFixed(6),
        });
        this.locating.set(false);
      },
      () => {
        this.locating.set(false);
        this.locationError.set(
          'Could not read your location. Allow location access, or type the coordinates in.',
        );
      },
      { enableHighAccuracy: true, timeout: 10000 },
    );
  }

  async submit(): Promise<void> {
    this.serverErrors.set([]);

    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    const value = this.form.getRawValue();
    const payload: MedicalStoreRegistration = {
      medicalName: value.medicalName.trim(),
      ownerFirstName: value.ownerFirstName.trim(),
      ownerMiddleName: value.ownerMiddleName.trim(),
      ownerLastName: value.ownerLastName.trim(),
      password: value.password,
      addressLine1: value.addressLine1.trim(),
      addressLine2: value.addressLine2.trim(),
      city: value.city.trim(),
      state: value.state.trim(),
      postalCode: value.postalCode.trim(),
      latitude: parseCoordinate(value.latitude),
      longitude: parseCoordinate(value.longitude),
      mobileNumber: value.mobileNumber.trim(),
      emailId: value.emailId.trim(),
      alternativeMobileNumber: value.alternativeMobileNumber.trim(),
      registrationStatus: value.registrationStatus,
      gstin: value.gstin.trim() || null,
      pan: value.pan.trim(),
      fssaiNo: value.fssaiNo.trim(),
      dlNo: value.dlNo.trim(),
      pharmacistFirstName: value.pharmacistFirstName.trim(),
      pharmacistLastName: value.pharmacistLastName.trim(),
      pharmacistRegistrationNumber: value.pharmacistRegistrationNumber.trim(),
      pharmacistMobileNumber: value.pharmacistMobileNumber.trim(),
    };

    this.busy.set(true);

    try {
      const result = await firstValueFrom(this.api.register(payload));

      // The endpoint can answer 200 with success:false, so a 2xx alone is not confirmation.
      if (!result?.success || !result.medicalStore) {
        this.serverErrors.set(
          result?.errors?.length
            ? result.errors
            : ['Registration failed. Please check the details and try again.'],
        );
        return;
      }

      this.registered.emit({
        medicalStoreId: result.medicalStore.medicalStoreId,
        medicalName: payload.medicalName,
      });
    } catch (err) {
      const error = err as HttpErrorResponse;
      const errors = error.error?.errors;
      if (Array.isArray(errors) && errors.length) {
        this.serverErrors.set(errors.map(String));
      } else {
        this.serverErrors.set([describeHttpError(error)]);
      }
    } finally {
      this.busy.set(false);
    }
  }
}

/** Mirrors the mobile app's rule: 8+ chars with upper, lower, digit and symbol. */
function passwordPolicyValidator(): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    const value = String(control.value ?? '');
    if (!value) {
      return null;
    }
    const ok =
      value.length >= 8 &&
      /[A-Z]/.test(value) &&
      /[a-z]/.test(value) &&
      /[0-9]/.test(value) &&
      /[!@#$%^&*(),.?":{}|<>]/.test(value);
    return ok ? null : { passwordPolicy: true };
  };
}

const passwordsMatchValidator: ValidatorFn = (group: AbstractControl): ValidationErrors | null => {
  const password = group.get('password')?.value;
  const confirm = group.get('confirmPassword')?.value;
  return !confirm || password === confirm ? null : { passwordMismatch: true };
};

/** Blank is allowed — coordinates are optional; anything present must be a number in range. */
function coordinateValidator(min: number, max: number): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    const raw = String(control.value ?? '').trim();
    if (!raw) {
      return null;
    }
    const parsed = Number(raw);
    if (!Number.isFinite(parsed)) {
      return { coordinate: 'must be a number' };
    }
    return parsed >= min && parsed <= max
      ? null
      : { coordinate: `must be between ${min} and ${max}` };
  };
}

function parseCoordinate(raw: string): number | null {
  const trimmed = raw.trim();
  if (!trimmed) {
    return null;
  }
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? parsed : null;
}

function generateStrongPassword(): string {
  const upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  const lower = 'abcdefghijkmnpqrstuvwxyz';
  const digits = '23456789';
  const symbols = '!@#$%^&*';
  const all = upper + lower + digits + symbols;

  const random = (set: string) => set[randomInt(set.length)];
  // One of each class first, so the result always satisfies the policy above.
  const chars = [random(upper), random(lower), random(digits), random(symbols)];
  while (chars.length < 12) {
    chars.push(random(all));
  }

  // Fisher-Yates, so the guaranteed characters are not always in the same positions.
  for (let i = chars.length - 1; i > 0; i--) {
    const j = randomInt(i + 1);
    [chars[i], chars[j]] = [chars[j], chars[i]];
  }
  return chars.join('');
}

function randomInt(bound: number): number {
  const buffer = new Uint32Array(1);
  crypto.getRandomValues(buffer);
  return buffer[0] % bound;
}
