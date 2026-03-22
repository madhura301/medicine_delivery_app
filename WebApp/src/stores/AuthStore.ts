import { makeAutoObservable, runInAction } from 'mobx';
import { authApi } from '../api/authApi';
import { storage } from '../utils/storage';
import { decodeToken, type DecodedUser } from '../utils/jwtUtils';
import type { UserRole } from '../models/OrderEnums';

export class AuthStore {
  token: string | null = null;
  userId = '';
  role: UserRole | null = null;
  email = '';
  firstName = '';
  lastName = '';
  mobileNumber = '';
  isLoading = false;
  error = '';

  constructor() {
    makeAutoObservable(this);
    this.loadFromStorage();
  }

  get isAuthenticated(): boolean {
    return !!this.token && !!this.role;
  }

  get fullName(): string {
    return `${this.firstName} ${this.lastName}`.trim();
  }

  get dashboardRoute(): string {
    switch (this.role) {
      case 'Admin': return '/admin/dashboard';
      case 'Chemist': return '/chemist/dashboard';
      case 'Manager': return '/manager/dashboard';
      case 'CustomerSupport': return '/support/dashboard';
      default: return '/login';
    }
  }

  loadFromStorage() {
    const token = storage.getToken();
    if (!token) return;
    try {
      const user = decodeToken(token);
      this.token = token;
      this.setUserInfo(user);
    } catch {
      storage.clearAll();
    }
  }

  private setUserInfo(user: DecodedUser) {
    this.userId = user.userId;
    this.role = user.role;
    this.email = user.email;
    this.firstName = user.firstName;
    this.lastName = user.lastName;
    this.mobileNumber = user.mobileNumber;

    storage.setUserField('id', user.userId);
    storage.setUserField('role', user.role);
    storage.setUserField('email', user.email);
    storage.setUserField('firstName', user.firstName);
    storage.setUserField('lastName', user.lastName);
    storage.setUserField('mobileNumber', user.mobileNumber);
  }

  async login(mobileNumber: string, password: string, stayLoggedIn = false) {
    this.isLoading = true;
    this.error = '';
    try {
      const res = await authApi.login({ mobileNumber, password, stayLoggedIn });
      const data = res.data;
      if (data.success && data.token) {
        const user = decodeToken(data.token);
        // Block Customer and DeliveryBoy roles on web
        if (user.role === 'Customer' || user.role === 'DeliveryBoy') {
          runInAction(() => {
            this.error = 'This role is only accessible on the mobile app.';
            this.isLoading = false;
          });
          return false;
        }
        runInAction(() => {
          this.token = data.token;
          this.setUserInfo(user);
          storage.setToken(data.token);
          if (data.refreshToken) storage.setRefreshToken(data.refreshToken);
          this.isLoading = false;
        });
        return true;
      }
      runInAction(() => {
        this.error = 'Login failed. Please check your credentials.';
        this.isLoading = false;
      });
      return false;
    } catch (e: unknown) {
      runInAction(() => {
        const err = e as { response?: { data?: { message?: string } } };
        this.error = err.response?.data?.message || 'Network error. Please try again.';
        this.isLoading = false;
      });
      return false;
    }
  }

  logout() {
    this.token = null;
    this.userId = '';
    this.role = null;
    this.email = '';
    this.firstName = '';
    this.lastName = '';
    this.mobileNumber = '';
    storage.clearAll();
  }
}
