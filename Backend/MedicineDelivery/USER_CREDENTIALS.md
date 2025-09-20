# Medicine Delivery App - User Credentials

This document contains the default user credentials for all user types in the Medicine Delivery application.

## Default Users

All users use their mobile number as the username for login.

### 1. Admin User
- **Mobile Number (Username)**: `9999999999`
- **Password**: `Admin@123`
- **Email**: `admin@medicine.com`
- **Name**: System Administrator
- **Role**: Admin
- **Permissions**: Full system access

### 2. Manager User
- **Mobile Number (Username)**: `8888888888`
- **Password**: `Manager@123`
- **Email**: `manager@medicine.com`
- **Name**: John Manager
- **Role**: Manager
- **Permissions**: Management level access

### 3. Customer Support User
- **Mobile Number (Username)**: `7777777777`
- **Password**: `Support@123`
- **Email**: `support@medicine.com`
- **Name**: Jane Support
- **Role**: CustomerSupport
- **Permissions**: Customer support access

### 4. Customer User
- **Mobile Number (Username)**: `6666666666`
- **Password**: `Customer@123`
- **Email**: `customer@medicine.com`
- **Name**: Alice Customer
- **Role**: Customer
- **Permissions**: Customer access

### 5. Chemist User
- **Mobile Number (Username)**: `5555555555`
- **Password**: `Chemist@123`
- **Email**: `chemist@medicine.com`
- **Name**: Bob Chemist
- **Role**: Chemist
- **Permissions**: Chemist/pharmacist access

## Authentication Endpoints

### Login
- **Endpoint**: `POST /api/auth/login`
- **Request Body**:
```json
{
  "mobileNumber": "9999999999",
  "password": "Admin@123"
}
```

### Register
- **Endpoint**: `POST /api/auth/register`
- **Request Body**:
```json
{
  "mobileNumber": "1234567890",
  "email": "user@example.com",
  "password": "Password@123",
  "firstName": "John",
  "lastName": "Doe"
}
```

### Forgot Password
- **Endpoint**: `POST /api/auth/forgot-password`
- **Request Body**:
```json
{
  "mobileNumber": "9999999999"
}
```

### Reset Password
- **Endpoint**: `POST /api/auth/reset-password`
- **Request Body**:
```json
{
  "mobileNumber": "9999999999",
  "token": "reset_token_from_forgot_password",
  "newPassword": "NewPassword@123"
}
```

### Change Password
- **Endpoint**: `POST /api/auth/change-password`
- **Authorization**: Required (Bearer Token)
- **Request Body**:
```json
{
  "mobileNumber": "9999999999",
  "currentPassword": "Admin@123",
  "newPassword": "NewPassword@123"
}
```

## Important Notes

1. **Username**: All users use their mobile number as the username for login
2. **Password Requirements**: Passwords must meet the following criteria:
   - At least 6 characters long
   - Contains at least one uppercase letter
   - Contains at least one lowercase letter
   - Contains at least one digit
   - Contains at least one special character
3. **Token Expiry**: JWT tokens expire after 1 hour
4. **Password Reset**: Reset tokens are returned in the response for testing purposes. In production, these should be sent via SMS
5. **User Creation**: All user types (Admin, Manager, CustomerSupport, Customer, Chemist) are created with mobile numbers as usernames

## Testing

You can use these credentials to test different user roles and their respective permissions in the application. Each role has different access levels to various features and endpoints.

## Security

- Change default passwords in production
- Implement proper SMS/Email services for password reset tokens
- Use HTTPS in production
- Implement proper logging and monitoring
