# Security Audit Report - MedicineDelivery Backend

**Date:** 2026-02-07
**Audited By:** AI Security Review
**Status:** Pending Fixes

---

## CRITICAL Severity

### 1. Every New User is Auto-Assigned "Admin" Role

- **File:** `MedicineDelivery.Infrastructure/Services/AuthService.cs` (line 99)
- **Issue:** `RegisterAsync` assigns the "Admin" role to every newly registered user.
- **Impact:** Any anonymous user can register and gain full administrative access.
- **Fix:** Assign a default non-privileged role (e.g., "Customer") or require admin approval for role assignment.
- [ ] Fixed

---

### 2. Entire Setup Controller is [AllowAnonymous]

- **File:** `MedicineDelivery.API/Controllers/SetupController.cs`
- **Issue:** All endpoints (create roles, permissions, users) are accessible without authentication.
- **Impact:** Anyone on the internet can create admin users, roles, and permissions.
- **Fix:** Remove in production, protect with admin authentication, or gate behind a one-time setup secret/token.
- [ ] Fixed

---

### 3. Hardcoded Credentials & PII in Source Code

- **File:** `MedicineDelivery.API/Controllers/SetupController.cs` (lines 312-406)
- **Issue:** Admin, manager, chemist, support, and customer passwords are hardcoded. A real person's mobile number and email are embedded (`dipmala.patil@medicine.com`, `8793583675`).
- **Impact:** Leaked credentials; PII exposure in source control.
- **Fix:** Use environment variables or a secrets manager. Remove real PII.
- [ ] Fixed

---

### 4. JWT Secret Key Hardcoded in appsettings.json

- **File:** `MedicineDelivery.API/appsettings.json` (line 8)
- **Issue:** JWT signing key is `"ThisIsAVeryLongSecretKeyThatShouldBeAtLeast32CharactersLong"` — predictable and committed to source control.
- **Impact:** Anyone with repo access can forge valid JWT tokens for any user.
- **Fix:** Use `dotnet user-secrets`, environment variables, or Azure Key Vault.
- [ ] Fixed

---

### 5. Database Password in Plain Text in All Config Files

- **Files:** `appsettings.json`, `appsettings.Development.json`, `appsettings.Production.json`
- **Issue:** Database password `123` is committed in plain text across all config files.
- **Impact:** Full database access for anyone with repo access.
- **Fix:** Use environment variables or a secrets manager. Never commit passwords.
- [ ] Fixed

---

### 6. Forgot Password Returns Reset Token Directly to Client

- **File:** `MedicineDelivery.Infrastructure/Services/AuthService.cs` (lines 269-277)
- **Issue:** The password reset token is returned in the HTTP response body instead of being sent via SMS/email.
- **Impact:** Any attacker who knows a user's mobile number can reset their password.
- **Fix:** Send the reset token via SMS or email only. Return a generic success message to the client.
- [ ] Fixed

---

## HIGH Severity

### 7. Wide-Open CORS Policy

- **File:** `MedicineDelivery.API/Program.cs` (lines 373-379)
- **Issue:** `AllowAnyOrigin()`, `AllowAnyMethod()`, `AllowAnyHeader()` — no restrictions.
- **Impact:** Any malicious website can make cross-origin requests to the API using a victim's browser.
- **Fix:** Restrict to known, trusted origins.
- [ ] Fixed

---

### 8. Account Lockout is Configured but Not Enforced

- **Files:** `Program.cs` (lines 105-108), `Infrastructure/Services/AuthService.cs` (line 53), `API/Services/AuthService.cs` (line 51)
- **Issue:** `CheckPasswordSignInAsync` is called with `lockoutOnFailure: false`.
- **Impact:** Unlimited brute-force password attempts.
- **Fix:** Change to `CheckPasswordSignInAsync(user, password, true)`.
- [ ] Fixed

---

### 9. No IDOR Protection on Orders Controller

- **File:** `MedicineDelivery.API/Controllers/OrdersController.cs`
- **Issue:** Permission checks exist but there is no verification that the authenticated user owns the specific resource (e.g., orders for a given customerId).
- **Impact:** A customer with `ReadOrders` can view any other customer's orders by changing the `customerId` parameter.
- **Fix:** Verify the authenticated user's identity matches the resource owner, or filter results server-side.
- [ ] Fixed

---

### 10. Hardcoded Temp Password for Admin-Created Customers

- **File:** `MedicineDelivery.API/Controllers/CustomersController.cs` (line 187)
- **Issue:** Password is hardcoded to `"TempPassword123!"` when admin creates a customer.
- **Impact:** All admin-created customers share the same known password with no forced change.
- **Fix:** Require password in the request body or generate a secure random password with forced reset.
- [ ] Fixed

---

### 11. Change Password Has No Ownership Check

- **File:** `MedicineDelivery.API/Controllers/AuthController.cs` (lines 135-143)
- **Issue:** Any authenticated user can change any other user's password by supplying a different mobile number.
- **Impact:** Account takeover by any authenticated user.
- **Fix:** Validate that the mobile number in the request matches the currently authenticated user's claims.
- [ ] Fixed

---

## MEDIUM Severity

### 12. Swagger Enabled in Production

- **File:** `MedicineDelivery.API/Program.cs` (lines 354-362)
- **Issue:** `UseSwagger()` and `UseSwaggerUI()` are called both inside and outside the `IsDevelopment()` check.
- **Impact:** Full API surface documentation exposed in production.
- **Fix:** Remove the duplicate calls outside the `IsDevelopment()` block.
- [ ] Fixed

---

### 13. Exception Message Leakage to Clients

- **File:** `MedicineDelivery.API/Middleware/GlobalExceptionMiddleware.cs` (lines 57-61)
- **Issue:** `exception.Message` is returned directly in the HTTP response.
- **Impact:** Internal implementation details, database info, or stack traces may be exposed to attackers.
- **Fix:** Return a generic error message. Log full details server-side only.
- [ ] Fixed

---

### 14. Include Error Detail=true in Connection String

- **File:** `appsettings.json` (lines 4-5)
- **Issue:** `Include Error Detail=true` in the connection string causes PostgreSQL to return detailed error messages.
- **Impact:** Database schema and query details may be leaked via error messages.
- **Fix:** Remove from all non-development configs.
- [ ] Fixed

---

### 15. Debug Console.WriteLine Statements with Sensitive Data

- **File:** `MedicineDelivery.Infrastructure/Services/AuthService.cs` (lines 132, 141, 188, 194-214)
- **Issue:** `Console.WriteLine` calls log user IDs, roles, and entity IDs.
- **Impact:** Sensitive data in stdout logs; not controlled by log level configuration.
- **Fix:** Remove or convert to structured `ILogger` logging at `Debug` level.
- [ ] Fixed

---

### 16. Test Logging Endpoint Exposed

- **File:** `MedicineDelivery.API/Program.cs` (lines 389-395)
- **Issue:** An unauthenticated `/test-logging` endpoint is available.
- **Impact:** Log pollution; indicates debug code not cleaned up before deployment.
- **Fix:** Remove before deploying to any non-development environment.
- [ ] Fixed

---

### 17. User Enumeration via Forgot Password

- **File:** `MedicineDelivery.API/Services/AuthService.cs` (lines 273-279)
- **Issue:** Returns "User not found" when mobile number doesn't exist, allowing attackers to enumerate valid mobile numbers.
- **Impact:** Attackers can discover which mobile numbers are registered.
- **Fix:** Return the same generic success response regardless of whether the user exists.
- [ ] Fixed

---

## Quick Reference Summary

| #  | Severity | Issue                                      | File                                    |
|----|----------|--------------------------------------------|-----------------------------------------|
| 1  | CRITICAL | Auto-Admin on registration                 | Infrastructure/Services/AuthService.cs  |
| 2  | CRITICAL | SetupController is anonymous               | API/Controllers/SetupController.cs      |
| 3  | CRITICAL | Hardcoded credentials & PII                | API/Controllers/SetupController.cs      |
| 4  | CRITICAL | Hardcoded JWT secret                       | API/appsettings.json                    |
| 5  | CRITICAL | DB password in config files                | appsettings.*.json                      |
| 6  | CRITICAL | Reset token returned to client             | Infrastructure/Services/AuthService.cs  |
| 7  | HIGH     | Wide-open CORS                             | API/Program.cs                          |
| 8  | HIGH     | Lockout not enforced                       | Both AuthService.cs files               |
| 9  | HIGH     | IDOR on orders                             | API/Controllers/OrdersController.cs     |
| 10 | HIGH     | Hardcoded temp password                    | API/Controllers/CustomersController.cs  |
| 11 | HIGH     | No ownership check on change-password      | API/Controllers/AuthController.cs       |
| 12 | MEDIUM   | Swagger in production                      | API/Program.cs                          |
| 13 | MEDIUM   | Exception message leakage                  | API/Middleware/GlobalExceptionMiddleware |
| 14 | MEDIUM   | Include Error Detail=true                  | appsettings.json                        |
| 15 | MEDIUM   | Debug Console.WriteLine with sensitive data| Infrastructure/Services/AuthService.cs  |
| 16 | MEDIUM   | Test endpoint exposed                      | API/Program.cs                          |
| 17 | MEDIUM   | User enumeration via forgot password       | API/Services/AuthService.cs             |
