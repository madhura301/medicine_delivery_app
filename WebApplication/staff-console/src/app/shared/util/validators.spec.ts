import { FormControl, Validators } from '@angular/forms';
import { firstErrorMessage, mobileNumberValidator, pinCodeValidator } from './validators';

describe('mobileNumberValidator', () => {
  const validate = (value: string) => mobileNumberValidator()(new FormControl(value));

  it('accepts exactly 10 digits', () => {
    expect(validate('9876543210')).toBeNull();
  });

  it('rejects the wrong length or non-digits', () => {
    expect(validate('98765')).toEqual({ mobileNumber: true });
    expect(validate('98765432101')).toEqual({ mobileNumber: true });
    expect(validate('98765abcde')).toEqual({ mobileNumber: true });
  });

  it('stays quiet when empty so Validators.required owns that message', () => {
    expect(validate('')).toBeNull();
  });
});

describe('pinCodeValidator', () => {
  const validate = (value: string) => pinCodeValidator()(new FormControl(value));

  it('accepts exactly 6 digits', () => {
    expect(validate('411001')).toBeNull();
  });

  it('rejects anything else', () => {
    expect(validate('41100')).toEqual({ pinCode: true });
    expect(validate('4110011')).toEqual({ pinCode: true });
    expect(validate('4110a1')).toEqual({ pinCode: true });
  });
});

describe('firstErrorMessage', () => {
  it('names the field for a required error', () => {
    const control = new FormControl('', Validators.required);
    control.markAsTouched();
    expect(firstErrorMessage(control, 'Mobile number')).toBe('Mobile number is required.');
  });

  it('explains a mobile-number error', () => {
    const control = new FormControl('123', mobileNumberValidator());
    expect(firstErrorMessage(control)).toBe('Enter a 10-digit mobile number.');
  });

  it('surfaces a server-supplied message verbatim', () => {
    const control = new FormControl('9876543210');
    control.setErrors({ server: 'A user with this mobile number already exists.' });
    expect(firstErrorMessage(control)).toBe('A user with this mobile number already exists.');
  });

  it('returns nothing for a valid control', () => {
    expect(firstErrorMessage(new FormControl('ok'))).toBe('');
  });
});
