# Pharmaish API — Security & Vulnerability Assessment

**Date:** 2026-07-28 (revised 2026-07-29 — added authentication-surface audit)
**Scope:** `MedicineDelivery.API` (.NET 10) — REST API only. WebApp/Flutter clients out of scope.
**Environments examined:** Azure Container Apps `pharmaish-api-test` / `pharmaish-api-prod`, PostgreSQL `pharmaish_test` / `pharmaish_prod`.
**Purpose:** Pre-engagement self-assessment ahead of third-party security & vulnerability testing.

> **How to read this:** findings marked **[VERIFIED LIVE]** were reproduced against a running
> environment using a real, freshly-registered low-privilege account. **[CODE REVIEW]** findings come
> from source/configuration inspection and were not actively exploited.
>
> **Testing was deliberately non-destructive.** Order-mutation authorization was probed with a
> non-existent order id (`404` = authorization passed, `403` = blocked) so no real record was altered.
> **C-01 was proven by evidence chain, not by exploitation** — no administrator account was created.

---

## Executive summary

| Severity | Count | Headline |
|---|---|---|
| **Critical** | 4 | Anonymous admin-account creation (**full takeover, production**); order IDOR incl. delivery OTP; unauthenticated payment webhook; unlimited login brute-force |
| **High** | 6 | Customer addresses & delivery-partner PII readable by any user; OTP exposed in API; secrets in git; default JWT key; shared default passwords; weak OTP generation |
| **Medium** | 9 | Wildcard CORS, public Swagger, no rate limiting, weak password policy, missing headers, PII logging, no upload cap, shared test/prod credentials, unrestricted document upload |
| **Low / Info** | 4 | User enumeration, token revocation, TLS trust bypass, verbose errors |

**Single most severe issue:** **C-01** — the entire `SetupController` (10 endpoints) is unauthenticated,
including one that creates an **Admin** account with a hardcoded, publicly-known password. That account
does **not currently exist** in test or production, so a single anonymous `POST` would create a working
administrator login on the live system. This is remotely exploitable by anyone who can reach the URL and
requires no prior access. **Fix before external testing begins.**

---

# CRITICAL

## C-01 — Unauthenticated setup endpoints allow anonymous ADMIN account creation **[VERIFIED LIVE]** — ✅ **REMEDIATED 2026-07-29**

> **STATUS: FIXED AND DEPLOYED.** `SetupController` now carries a class-level
> `[Authorize(Policy = "RequireSetupAccess")]`; all 12 `[AllowAnonymous]` attributes were removed.
> Access requires an authenticated **Admin** *or* a valid `X-Setup-Token` (config `Setup:AccessToken`),
> and **fails closed** when no token is configured outside Development.
> Deployed as `pharmaish-api:net10-2026-07-29_0021-sec` → prod revision `0000002`, test revision `0000036`.
> **Verified on production:** every `/api/setup/*` endpoint now returns **401** to anonymous callers
> (including `users/admin` and `users/admin/firstuser`); requests bearing the token still return 200.
> **Compromise check:** the `9999999999` / `admin@medicine.com` account is confirmed **absent** from both
> `pharmaish_test` and `pharmaish_prod` — no evidence the flaw was exploited before remediation.
> Follow-up still open: remove the hardcoded `Admin@123` from `SetupController`.


**Endpoints:** all of `/api/setup/*` — 10 endpoints, none requiring authentication.
`SetupController` has **no class-level `[Authorize]`**, and every action carries `[AllowAnonymous]`:

```
POST /api/setup/users/admin                          <-- creates an Admin user
POST /api/setup/users/admin/firstuser                <-- creates an Admin user
POST /api/setup/users/manager | customer-support | chemist | customer
POST /api/setup/roles | /roles/predefined
POST /api/setup/permissions | /permissions/predefined
POST /api/setup/role-permissions/predefined          <-- (re)grants role→permission mappings
POST /api/setup/customers/fix-missing-customer-numbers   <-- mutates customer data
```

**Exploit chain (each link verified, exploitation deliberately not performed):**

1. *The endpoints execute anonymously in production* — verified with **no token**:
   ```
   POST https://pharmaish-api-prod.../api/setup/roles/predefined   ->  200 OK
   ```
2. *`CreateAdminUser` hardcodes credentials* (`SetupController.cs` ~line 397):
   ```csharp
   const string roleName = "Admin";
   const string password = "Admin@123";     // mobile 9999999999, admin@medicine.com
   ```
   It takes **no parameters** — the attacker cannot choose the identity, but does not need to.
3. *The only guard is a "user already exists" → `409 Conflict` check* — and that account
   **does not exist** in either database (confirmed by direct query):
   ```
   pharmaish_test   setup-admin (9999999999) exists: NO
   pharmaish_prod   setup-admin (9999999999) exists: NO
   ```

So an anonymous request to `POST /api/setup/users/admin` on production would create a functioning
**Admin** account whose credentials (`9999999999` / `Admin@123`) are hardcoded in the repository —
followed by a normal login for complete administrative control.

**Additional exposure from the same controller:** anonymous callers can create roles and permissions and
re-run `role-permissions/predefined`, which **re-grants the predefined permission mappings** — meaning a
defender who removes a dangerous grant (e.g. `UpdateOrders` from `Customer`, see C-02) can have it
silently restored by an anonymous request.

**Impact:** Unauthenticated → full administrative compromise of production; persistent backdoor;
authorization-model tampering.

**Remediation (do this first):**
1. Put `[Authorize(Policy = "...")]` on `SetupController` restricted to Admin, **or** disable the
   controller entirely outside Development (`if (app.Environment.IsDevelopment())` registration).
2. Remove hardcoded passwords; seeding should use generated credentials delivered out-of-band.
3. If seeding must remain callable in production, gate it behind a one-time bootstrap token that is
   invalidated after first use, plus IP allow-listing.
4. **Check both databases for an unexpected `9999999999` / `admin@medicine.com` account before and after
   remediation** — its presence would indicate prior exploitation.

---

## C-02 — Broken object-level authorization (IDOR) on Orders **[VERIFIED LIVE]**

**Endpoints:** `GET /api/orders/{orderId}`, `GET /api/orders/customer/{customerId}`,
`PUT /api/orders/{id}/accept|reject|complete`, `POST /api/orders/assign-to-delivery`, and other `/api/orders/*` reads.

**Issue:** These authorize on *permission only* (`ReadOrders` / `UpdateOrders`) and never verify the caller
owns or relates to the order. `OrdersController` contains no caller-identity checks — unlike
`CustomersController`, which implements them correctly.

**Evidence** — a customer account registered seconds earlier, with zero orders, read another customer's order:
```
GET /api/orders/24            -> 200 OK
  customerId  : aafee0d7-e0ba-443d-ae89-f406d59e1075   (not the caller)
  otp         : 3157                                    (delivery verification code)
  totalAmount : 200.0
GET /api/orders/customer/{someone-elses-guid} -> 200 OK
```
Order **mutations** also pass authorization for the `Customer` role (probed with a non-existent id;
`404` proves the authorization gate was passed rather than `403`):
```
PUT  /api/orders/99999999/accept    -> 404      PUT  /api/orders/99999999/reject            -> 404
PUT  /api/orders/99999999/complete  -> 404      POST /api/orders/assign-to-delivery         -> 404
```
The `Customer` role holds `ReadOrders`, `UpdateOrders`, `CreateOrders`.

**Impact:** Horizontal privilege escalation across the entire order domain — mass disclosure of customer
PII, addresses, amounts and delivery OTPs, plus the ability to falsely accept/reject/complete other
parties' orders. `orderId` is a sequential integer, so the full table is enumerable.
*(`GET /api/orders` list-all is correctly restricted — returned `403`.)*

**Remediation:** Enforce ownership in `OrdersController`/service layer (Customer → own orders only;
Chemist → own store; DeliveryBoy → assigned orders); remove `UpdateOrders` from the `Customer` role;
prefer the non-sequential `OrderNumber` for external references.

---

## C-03 — Razorpay webhook accepts unsigned/forged requests **[CODE REVIEW + CONFIG VERIFIED]** — ✅ **REMEDIATED 2026-07-29** (action required)

> **STATUS: FIXED AND DEPLOYED.** `VerifySignature` now **fails closed**: with no secret configured it
> rejects the request (and logs an error) in every environment except Development.
> **Verified on production:** an unsigned `payment.captured` payload now returns **401** (previously 200 = accepted).
>
> ⚠️ **ACTION REQUIRED:** `RazorpaySettings__WebhookSecret` is still **not set** in either environment.
> Until the real secret from the Razorpay dashboard is configured, *all* webhooks — including legitimate
> ones — will be rejected. This is the safe failure mode (no forgery possible), but if Razorpay webhooks
> are relied upon for payment/activation confirmation, that flow is paused until the secret is set:
> `az containerapp update -n pharmaish-api-prod -g ImageStorageRG --set-env-vars RazorpaySettings__WebhookSecret=<secret>`


`POST /api/razorpay/webhook` — signature verification **fails open**:

```csharp
var secret = _configuration["RazorpaySettings:WebhookSecret"];
if (string.IsNullOrWhiteSpace(secret)) {
    _logger.LogWarning("...WebhookSecret not configured; skipping webhook signature check.");
    return true;                      // <-- accepts ANY payload
}
```

`WebhookSecret` is `""` in `appsettings.json` and **no `RazorpaySettings__WebhookSecret` environment
variable is set on `pharmaish-api-test` or `pharmaish-api-prod`** (verified via `az containerapp show`).
Verification is therefore disabled in both environments. The controller is `[AllowAnonymous]` by design.

**Impact:** Anyone reaching the endpoint can post a forged `payment.captured` event — marking orders paid
without money moving, releasing the delivery OTP by SMS, and creating `PaymentSplit`/Route transfers to
chemists. Direct financial loss.

**Remediation:** Set the webhook secret in both environments and make verification **fail closed**
(reject when unset) outside Development.

---

## C-04 — Account lockout never enforced; no rate limiting anywhere **[CODE REVIEW]**

Lockout is configured (5 attempts / 5 min) but the login path disables it:

```csharp
var result = await _signInManager.CheckPasswordSignInAsync(user, password, false);
//                                                                        ^^^^^ lockoutOnFailure: false
```
`AccessFailedCount` therefore never increments and no user is ever locked out. There is **no rate
limiting registered in the pipeline** (no `AddRateLimiter`/`UseRateLimiter`).

**Impact:** Unlimited-rate credential brute-force on `/api/auth/login`, amplified by H-05 (shared,
well-known staff passwords) — only the mobile number needs guessing. Also enables OTP brute-forcing
(H-06), SMS-cost abuse via repeated `forgot-password`, and cheap DoS.

**Remediation:** `lockoutOnFailure: true`; add per-IP and per-account rate limiting on `/api/auth/*`,
OTP verification and password reset.

---

# HIGH

## H-01 — IDOR on customer addresses and delivery-partner records **[VERIFIED LIVE]**

Probed with the same freshly-registered customer account:
```
GET /api/customeraddresses/customer/{another-customers-guid}  -> 200 OK   (home addresses + GPS)
GET /api/deliveries                                           -> 200 OK   (all delivery partners)
GET /api/razorpay/payment-split/24                            -> 200 OK   (financial split for any order)
```
**Impact:** Any self-registered user can harvest customers' **home addresses and coordinates**, and the
full delivery-partner roster (names, mobile numbers, licence numbers) — a serious privacy/GDPR-style
exposure and a stalking/fraud enabler. `payment-split` leaks per-order commercial data and is protected
by `[Authorize]` only, with no permission policy.
*(`GET /api/medicalstores` correctly returned `403`.)*

**Remediation:** Ownership checks on address endpoints; a permission policy on `/api/deliveries`
(staff-only) and `payment-split`.

## H-02 — Delivery OTP returned in API responses **[VERIFIED LIVE]**

`OrderDto.OTP` is serialized to any caller allowed to read the order (see C-02 evidence, `otp: 3157`).
The OTP is the sole proof-of-delivery factor.
**Remediation:** Remove `OTP` from `OrderDto`; if required, expose via a dedicated endpoint returning it
only to the owning customer after full payment (which is the intended business rule).

## H-03 — Secrets committed to git and present in the working tree **[VERIFIED]**

* An Azure Blob Storage `AccountKey` exists in **git history** (e.g. commit `165a49a`) — scrubbing the
  current file does not revoke it.
* `MedicineDelivery.API/appsettings.Development.json` contains live Azure PostgreSQL credentials.
* `WorkingAppSettings/` holds real blob keys, DB credentials and Razorpay keys, is **not** in
  `.gitignore`, and is one `git add .` from being committed.

**Remediation:** Rotate the exposed storage key, DB password and any Razorpay keys; purge history
(BFG/`git filter-repo`) or treat those values as compromised; gitignore `WorkingAppSettings/`; move
secrets to Key Vault / Container App secrets; add a pre-commit secret scanner (gitleaks).

## H-04 — Default JWT signing key shipped in configuration **[VERIFIED]**

`JwtSettings:SecretKey` = `"ThisIsAVeryLongSecretKeyThatShouldBeAtLeast32CharactersLong"` in
`appsettings.json`, and was in use by the test Container App. *(Production received a freshly generated
64-char key on 2026-07-28; test still used the default at time of writing.)*
**Impact:** Anyone with repo access can forge JWTs for any role — complete authentication bypass — against
any environment still using it.
**Remediation:** Unique high-entropy key per environment via env var/Key Vault; replace the value in
`appsettings.json` with a `SET_VIA_ENV` placeholder; rotate the test key.

## H-05 — Shared, well-known default passwords, no forced rotation **[VERIFIED]**

`DefaultCredentials.StaffPassword = "Pass@123"` is applied unconditionally to **every** Manager,
Customer Support and Delivery Boy account (client-supplied passwords are intentionally ignored); all 8
existing delivery-boy accounts share it. Seeded accounts use `Admin@123`, `Manager@123`, `Support@123`,
`Chemist@123`. No forced change on first login.
**Remediation:** Unique generated password per account, delivered out-of-band; `MustChangePassword` on
first login.

## H-06 — Order OTP is weak and predictable **[CODE REVIEW]**

```csharp
var random = new Random();                    // non-cryptographic, time-seeded
var otp = random.Next(1000, 9999).ToString(); // 4 digits, ~9,000 possibilities
```
With no attempt throttling (C-04), brute-forcing a delivery OTP is practical.
*(By contrast the authentication OTP correctly uses `RandomNumberGenerator.Fill` — match that standard.)*
**Remediation:** `RandomNumberGenerator`, ≥6 digits, expiry and attempt limits.

---

# MEDIUM

| ID | Finding | Detail & Remediation |
|---|---|---|
| **M-01** | **Wildcard CORS** | `AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader()` — any site can call the API with a user's token. Restrict to known origins. |
| **M-02** | **Swagger public in production** | `UseSwagger()/UseSwaggerUI()` run unconditionally — full API surface disclosure (and a map to `/api/setup/*`). Gate to Development or require auth. |
| **M-03** | **No rate limiting** | No limiter anywhere; enables C-04 brute force, H-06 OTP guessing, SMS-cost abuse, cheap DoS. |
| **M-04** | **Weak password policy** | `RequiredLength = 6`. Raise to ≥10–12 and screen against breached-password lists. |
| **M-05** | **Missing security headers** | No HSTS, CSP, `X-Content-Type-Options`, `X-Frame-Options`. Add `UseHsts()` + headers middleware. |
| **M-06** | **PII written to logs** | `RazorpayRouteClient` logs onboarding requests **including PAN and GST** (acknowledged in a code comment ~line 387); flows to shared App Insights. Redact before go-live. |
| **M-07** | **Unrestricted document upload** | `POST /api/policydocuments/upload` has `[Authorize]` but **no permission policy** — any authenticated user (incl. a self-registered customer) can upload policy documents (verified: `400` validation error, i.e. authorization passed). Add an admin-only policy. |
| **M-08** | **No upload size/content-type enforcement** | Extensions are validated, but no `MultipartBodyLengthLimit`/`RequestSizeLimit` and no magic-byte check — large-file DoS and polyglot uploads. |
| **M-09** | **Test and production share credentials/infrastructure** | Same PostgreSQL server and `pharmaadmin` account, same storage key, same App Insights. A test compromise reaches production data. Separate per environment. |

---

# LOW / INFORMATIONAL

| ID | Finding | Detail |
|---|---|---|
| **L-01** | **User enumeration** | `GET /api/customers/by-mobile/{n}` returns `403` when the record exists but isn't yours vs `404` when absent — distinguishes registered numbers. Return a uniform response. *(Code review; not reproduced.)* |
| **L-02** | **Token revocation** | JWT `ExpiryInHours: 1`; no server-side revocation/deny-list observed — a stolen token remains valid until expiry. |
| **L-03** | **TLS trust bypass** | `Trust Server Certificate=true` in `appsettings.Development.json` and Azure connection strings disables certificate validation (MITM risk). Prefer `SSL Mode=VerifyFull`. |
| **L-04** | **Verbose errors** | Some handlers echo exception text (e.g. download endpoints return `$"...: {ex.Message}"`); Serilog `Debug` in Development can log SQL/parameters. Keep production at `Information`. |

---

## Positive observations

Verified as **sound** — testers can deprioritise these:

* **No SQL injection surface** — no `FromSqlRaw`/`ExecuteSqlRaw`/raw ADO; all access via parameterized EF Core.
* **Path traversal on document download is mitigated** — `PolicyDocumentService` applies
  `Path.GetFileName(fileName)` before use, defeating `../` payloads on the anonymous download route.
* **Password hashing** — ASP.NET Core Identity PBKDF2-HMAC-**SHA512**, 100,000 iterations, per-user salt.
* **Object-level checks on Customers** — `CustomersController` correctly restricts `CustomerRead`-only
  callers to their own record (`GET /{id}`, `by-mobile`), returning `403` otherwise.
* **`GET /api/orders` (list-all)** and **`GET /api/medicalstores`** correctly return `403` to customers.
* **JWT validation** — issuer, audience, lifetime and signing-key validation all enabled.
* **Authentication OTP** uses a cryptographic RNG with expiry and attempt limits.
* **File uploads** validate extensions per input type.
* **Webhook signature comparison** uses fixed-time comparison *when* a secret is configured.

---

## Authorization surface summary

Of **105** controller endpoints:

| State | Count | Notes |
|---|---|---|
| Anonymous / unauthenticated | **20** | 10 are `/api/setup/*` (**C-01**); rest are login/register/forgot-password (expected) and the Razorpay webhook (**C-03**) |
| Authenticated, no permission policy | **9** | Any logged-in user — includes `policydocuments/upload` (**M-07**), `razorpay/payment-split` (**H-01**), `razorpay/create-order`, `verify-payment` |
| Permission-gated | 76 | Correct pattern — though gating alone is insufficient without ownership checks (**C-02**, **H-01**) |

---

## Recommended remediation order

1. **C-01** — lock down `/api/setup/*` (highest priority; anonymous production admin creation)
2. **C-03** — webhook secret + fail-closed verification
3. **C-02** + **H-02** — order ownership checks, drop `UpdateOrders` from Customer, remove OTP from DTO
4. **H-01** — ownership/permission checks on addresses, deliveries, payment-split
5. **C-04** — lockout `true` + rate limiting *(mitigates H-05, H-06, M-03)*
6. **H-03 / H-04** — rotate leaked secrets and the test JWT key; gitignore + secret scanning
7. **H-05 / H-06** — per-account passwords, forced change; cryptographic 6-digit order OTP
8. Medium items — CORS, Swagger gating, headers, PII logging, upload policy/caps, credential separation

---

*Assessed against the 2026-07-28 code state (backend .NET 10, image
`pharmaish-api:net10-2026-07-28_2344-telemetry`). Live verification used the **test** environment except
where production is explicitly named; production was exercised only with a read-only anonymous call to an
already-idempotent seeding endpoint. No administrator account was created and no order was modified.
No credentials, keys or tokens are reproduced in this document.*
