import * as dotenv from 'dotenv';
import * as path from 'path';

dotenv.config({ path: path.resolve(__dirname, '..', '.env') });

function env(key: string, fallback: string): string {
  return process.env[key]?.trim() || fallback;
}

export const config = {
  apiBaseUrl: env('API_BASE_URL', 'http://localhost:5000'),
  webappBaseUrl: env('WEBAPP_BASE_URL', 'http://localhost:5173'),
  flutterBaseUrl: env('FLUTTER_BASE_URL', 'http://localhost:8080'),
};

export type RoleName = 'admin' | 'manager' | 'support' | 'customer' | 'chemist';

export interface Credentials {
  mobileNumber: string;
  password: string;
}

export const credentials: Record<RoleName, Credentials> = {
  admin: { mobileNumber: env('ADMIN_MOBILE', '8793583675'), password: env('ADMIN_PASSWORD', 'Admin@123') },
  manager: { mobileNumber: env('MANAGER_MOBILE', '8888888888'), password: env('MANAGER_PASSWORD', 'Manager@123') },
  support: { mobileNumber: env('SUPPORT_MOBILE', '7777777777'), password: env('SUPPORT_PASSWORD', 'Support@123') },
  customer: { mobileNumber: env('CUSTOMER_MOBILE', '6666666666'), password: env('CUSTOMER_PASSWORD', 'Customer@123') },
  chemist: { mobileNumber: env('CHEMIST_MOBILE', '5555555555'), password: env('CHEMIST_PASSWORD', 'Chemist@123') },
};
