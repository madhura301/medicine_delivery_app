import { AbstractControl, ValidationErrors, ValidatorFn, Validators } from '@angular/forms';

/** Indian mobile number: exactly 10 digits. */
export function mobileNumberValidator(): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    const value = (control.value ?? '').toString().trim();
    if (!value) {
      return null;
    }
    return /^\d{10}$/.test(value) ? null : { mobileNumber: true };
  };
}

/** Indian pin code: exactly 6 digits. */
export function pinCodeValidator(): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    const value = (control.value ?? '').toString().trim();
    if (!value) {
      return null;
    }
    return /^\d{6}$/.test(value) ? null : { pinCode: true };
  };
}

export const emailValidator = Validators.email;

/** Human-readable message for the first error on a control. */
export function firstErrorMessage(control: AbstractControl | null, label = 'This field'): string {
  if (!control || !control.errors) {
    return '';
  }

  const errors = control.errors;
  if (errors['required']) {
    return `${label} is required.`;
  }
  if (errors['mobileNumber']) {
    return 'Enter a 10-digit mobile number.';
  }
  if (errors['pinCode']) {
    return 'Enter a 6-digit pin code.';
  }
  if (errors['email']) {
    return 'Enter a valid email address.';
  }
  if (errors['minlength']) {
    return `${label} must be at least ${errors['minlength'].requiredLength} characters.`;
  }
  if (errors['maxlength']) {
    return `${label} must be at most ${errors['maxlength'].requiredLength} characters.`;
  }
  if (errors['server']) {
    return errors['server'] as string;
  }
  return `${label} is not valid.`;
}
