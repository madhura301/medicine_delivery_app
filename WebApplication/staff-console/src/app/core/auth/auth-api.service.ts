import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import {
  Customer,
  CustomerSupport,
  LoginRequest,
  LoginResponse,
  Manager,
  MedicalStore,
} from '../models/api.models';

@Injectable({ providedIn: 'root' })
export class AuthApiService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiBaseUrl}/Auth`;

  login(request: LoginRequest): Observable<LoginResponse> {
    return this.http.post<LoginResponse>(`${this.base}/login`, request);
  }

  /** Sends a password-reset OTP to the given mobile number. */
  forgotPassword(phoneNumber: string): Observable<unknown> {
    return this.http.post(`${this.base}/forgot-password`, { phoneNumber });
  }

  verifyOtpAndResetPassword(payload: {
    phoneNumber: string;
    otpCode: string;
    newPassword: string;
    confirmPassword: string;
  }): Observable<unknown> {
    return this.http.post(`${this.base}/verify-otp-reset-password`, payload);
  }

  changePassword(payload: {
    mobileNumber: string;
    currentPassword: string;
    newPassword: string;
  }): Observable<unknown> {
    return this.http.post(`${this.base}/change-password`, payload);
  }

  /**
   * Resolves the Manager row behind a signed-in user. The JWT has no entityId claim, so the
   * manager queue screens depend on this lookup by the token's email claim.
   */
  managerByEmail(email: string): Observable<Manager> {
    return this.http.get<Manager>(
      `${environment.apiBaseUrl}/Managers/by-email/${encodeURIComponent(email)}`,
    );
  }

  customerSupportByEmail(email: string): Observable<CustomerSupport> {
    return this.http.get<CustomerSupport>(
      `${environment.apiBaseUrl}/CustomerSupports/by-email/${encodeURIComponent(email)}`,
    );
  }

  /**
   * Resolves the store behind a signed-in chemist. Every chemist screen is scoped by
   * medicalStoreId, and the token does not carry it — the mobile app resolves it the same way.
   */
  /**
   * The signed-in customer's own record. Unlike staff and chemists, customers are resolved by
   * their token rather than by email — many customers register without one.
   */
  myCustomerProfile(): Observable<Customer> {
    return this.http.get<Customer>(`${environment.apiBaseUrl}/Customers/my-profile`);
  }

  medicalStoreByEmail(email: string): Observable<MedicalStore> {
    return this.http.get<MedicalStore>(
      `${environment.apiBaseUrl}/MedicalStores/by-email/${encodeURIComponent(email)}`,
    );
  }
}
