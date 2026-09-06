import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../../environments/environment';

/**
 * A login account as returned by GET /api/Users. The API's UserDto carries more than this;
 * only the fields this screen shows are modelled.
 */
export interface UserAccount {
  id: string;
  email: string;
  firstName: string;
  middleName: string | null;
  lastName: string;
  /** The login itself - usernames are mobile numbers in this system. */
  mobileNumber: string | null;
  roleName: string | null;
  isActive: boolean;
  createdAt: string;
  lastLoginAt: string | null;
}

export interface UserAccountUpdateResult {
  success: boolean;
  message: string;
  userName: string | null;
  /** Which profile table had its mobile number kept in step, if any. */
  profileUpdated: string | null;
  errors: string[];
}

export function userAccountFullName(user: UserAccount): string {
  return [user.firstName, user.middleName, user.lastName].filter(Boolean).join(' ').trim();
}

@Injectable({ providedIn: 'root' })
export class UserAccountsApiService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiBaseUrl}/Users`;

  list(): Observable<UserAccount[]> {
    return this.http.get<UserAccount[]>(this.base);
  }

  /**
   * Renames the login. The API also updates the owning profile's mobile number so the two
   * cannot drift apart, and signs the user out of existing sessions.
   */
  changeUserName(userId: string, newUserName: string): Observable<UserAccountUpdateResult> {
    return this.http.put<UserAccountUpdateResult>(`${this.base}/${userId}/username`, { newUserName });
  }

  /** Sets a new password without needing the user's current one. */
  resetPassword(userId: string, newPassword: string): Observable<UserAccountUpdateResult> {
    return this.http.post<UserAccountUpdateResult>(`${this.base}/${userId}/reset-password`, {
      newPassword,
    });
  }
}
