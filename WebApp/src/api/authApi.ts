import api from './axiosInstance';

export interface LoginRequest {
  mobileNumber: string;
  password: string;
  stayLoggedIn?: boolean;
}

export interface LoginResponse {
  success: boolean;
  token: string;
  refreshToken?: string;
}

export interface ChangePasswordRequest {
  mobileNumber: string;
  currentPassword: string;
  newPassword: string;
}

export const authApi = {
  login: (data: LoginRequest) =>
    api.post<LoginResponse>('/Auth/login', data),

  forgotPassword: (mobileNumber: string) =>
    api.post('/Auth/forgot-password', { mobileNumber }),

  resetPassword: (data: { mobileNumber: string; otp: string; newPassword: string }) =>
    api.post('/Auth/reset-password', data),

  changePassword: (data: ChangePasswordRequest) =>
    api.post('/Auth/change-password', data),
};
