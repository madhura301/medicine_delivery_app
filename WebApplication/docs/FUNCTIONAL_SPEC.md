# Pharmaish Staff Console — Functional Specification

**Application:** Angular staff/back-office console for the Pharmaish medicine delivery platform
**Location:** `WebApplication/`
**Backend:** existing .NET 10 API (`Backend/MedicineDelivery`) — no new API surface required except the items in §11
**Status:** Draft for sign-off
**Last updated:** 2026-08-02

---

## 1. Purpose and scope

A responsive web console used by **Admin**, **Manager** and **Customer Support** staff to:

- manage the people in the system — managers, customer support agents, delivery boys, chemists, customers;
- manage the two kinds of service region and the pin codes they cover;
- assign customer support agents and delivery boys to regions;
- monitor every order in the system, grouped by who currently owns it, and act on it (reassign to another chemist, cancel with a reason).

**Out of scope:** the customer-facing and delivery-boy-facing mobile apps (Flutter), the chemist portal, order creation, payments, and anything a customer does.

### 1.1 Who logs in

| Role | Access |
|---|---|
| **Admin** | Every menu, every action |
| **Manager** | Everything except Manager CRUD and role/permission administration |
| **CustomerSupport** | Own order queue, chemists, customers; read-only elsewhere (see §10) |

Customers, delivery boys and chemists **never log into this application**. They are only *managed* from it.

---

## 2. Navigation / menu structure

Your requested menus mapped to the labels used in the app:

| You asked for | Menu label in app | Route |
|---|---|---|
| manager | **Managers** | `/managers` |
| customer support | **Customer Support** | `/customer-support` |
| delivery boy | **Delivery Boys** | `/delivery-boys` |
| chemist | **Chemists** | `/chemists` |
| customer | **Customers** | `/customers` |
| customer support region | **Regions → Support Regions** | `/regions/support` |
| delivery boy region | **Regions → Delivery Regions** | `/regions/delivery` |
| All Order | **Orders → All Orders** | `/orders/all` |
| order assign to nobody / order belong to customer | **Orders → Awaiting Assignment** | `/orders/awaiting-assignment` |
| orders assigned to chemist | **Orders → With Chemist** | `/orders/with-chemist` |
| order belong to customer support | **Orders → With Customer Support** | `/orders/with-support` |
| orders assign to manager | **Orders → With Manager** | `/orders/with-manager` |
| order assign to delivery boy | **Orders → Out for Delivery** | `/orders/with-delivery` |

Final sidebar:

```
Dashboard
Managers
Customer Support
Delivery Boys
Chemists
Customers
Regions
  ├─ Support Regions
  └─ Delivery Regions
Orders
  ├─ All Orders
  ├─ Awaiting Assignment
  ├─ With Chemist
  ├─ With Customer Support
  ├─ With Manager
  └─ Out for Delivery
```

Sidebar behaviour: permanent drawer ≥1024 px, collapsible rail 768–1023 px, off-canvas drawer with a hamburger below 768 px. Groups auto-expand when a child route is active. Menu items hidden entirely when the role has no access (§10).

---

## 3. Cross-cutting behaviour

### 3.1 Authentication
- Login with **mobile number + password** (not email) and a *Keep me signed in* toggle.
- `POST /api/Auth/login` returns a `token`. **Verified 2026-08-02: `role`, `userId`, `expiresAt` and `entityId` come back null** — the registered `AuthService` never fills them in. The console therefore reads role, user id and expiry from the **JWT claims**, and resolves `entityId` separately.
- `entityId` is the **ManagerId / CustomerSupportId** of the signed-in user and is required by the "my queue" screens. It is not in the JWT, so after login it is fetched via `GET /api/Managers/by-email/{email}` or `GET /api/CustomerSupports/by-email/{email}` using the token's email claim, then cached in the session.
- Token stored in `localStorage` when *Keep me signed in* is on, otherwise `sessionStorage`.
- Forgot password → OTP to mobile → reset. Change password available from the profile menu.
- **Only Admin, Manager and CustomerSupport may enter.** Any other role that authenticates is signed straight back out with "This portal is for staff only."

### 3.2 Authorization in the UI
The JWT carries the **role only** — the server never tells the client which permissions it holds. Therefore:
- menus and buttons are gated by a **hardcoded role → capability map** (§10);
- every screen must still handle a **403** from the API gracefully ("You do not have permission to do this") rather than assuming the client-side map is correct.

### 3.3 List screens — common pattern
Every list screen shares one behaviour set:
- text search across the primary fields, plus screen-specific filters;
- sortable columns, client-side paging (25/50/100 per page);
- row click → detail; row actions in an overflow menu;
- **Active / Inactive** chips; deleted records are never shown;
- toolbar primary action (e.g. *Add Manager*);
- states: loading skeleton, empty ("No managers yet — add the first one"), error with Retry;
- **responsive**: table on desktop, stacked cards on mobile — no horizontal scrolling.

### 3.4 Forms — common pattern
- Reactive forms, validation shown on blur and on submit, first invalid field focused.
- Mobile number: exactly 10 digits. Email: valid format. Pin code: exactly 6 digits.
- Save is disabled while submitting; success and failure both raise a toast.
- Leaving a dirty form asks for confirmation.
- Server validation errors are mapped onto the offending fields where the API identifies them, otherwise shown as a form-level error.

### 3.5 Destructive actions
Delete/deactivate always opens a confirmation dialog naming the record. Order cancellation additionally requires a reason (§8.7).

### 3.6 Responsiveness
Breakpoints: `<600` mobile, `600–1023` tablet, `≥1024` desktop. Tables collapse to cards, dialogs go full-screen on mobile, filters collapse into a "Filters" sheet, and touch targets stay ≥44 px.

---

## 4. Dashboard

Landing page after login; content varies by role.

| Card | Content | Source |
|---|---|---|
| Order buckets | Count per bucket — Awaiting Assignment, With Chemist, With Customer Support, With Manager, Out for Delivery — each clickable through to the list | `GET /api/Orders` (Admin/Manager) |
| My queue | *CustomerSupport:* orders awaiting my action. *Manager:* orders escalated to me | `/api/Orders/customersupport/{entityId}/assignedtocustomersupport`, `/api/Orders/manager/{entityId}/assignedtomanager` |
| People | Counts of active managers, support agents, delivery boys, chemists, customers | respective list endpoints |
| Coverage | Count of support regions and delivery regions, and the number of pin codes covered | `GET /api/ServiceRegions` |

---

## 5. Managers

**Menu:** Managers · **Access:** Admin only (create/edit/delete). Manager role may view the list.

### 5.1 List
Columns: Employee ID · Name · Mobile · Email · City · Status · Actions.
Filters: search (name / mobile / email / employee id), status.
Actions: *Add Manager*, row → View, Edit, Delete.
`GET /api/Managers`

### 5.2 Create
`POST /api/Managers/register`
Fields: First name\*, Middle name, Last name\*, Employee ID\*, Mobile\*, Alternative mobile, Email\*, Address, City, State, Photo (upload).
On success the console shows: **"Manager created. Temporary password: `Pass@123` — ask them to change it on first login."**
Duplicate mobile number is rejected by the server; surface it on the mobile field.

### 5.3 View / Edit / Delete
- View: read-only detail with photo, contact block, audit block (created on/by, updated on/by).
- Edit: `PUT /api/Managers/{id}` — all fields except mobile-derived login; includes an **Active** toggle.
- Photo: `POST /api/Managers/{id}/photo`.
- Delete: `DELETE /api/Managers/{id}` — soft delete, confirmation required.

---

## 6. Customer Support

**Menu:** Customer Support · **Access:** Admin, Manager (full CRUD). CustomerSupport may view.

### 6.1 List
Columns: Employee ID · Name · Mobile · Email · **Assigned Region** · Status · Actions.
Filters: search, status, **region** (including "Unassigned").
Actions: *Add Agent*; row → View, Edit, **Assign Region**, Delete.
`GET /api/CustomerSupports` joined client-side with `GET /api/ServiceRegions` to display the region name.

### 6.2 Create / Edit / Delete
Same field set as Managers plus **Service Region** (optional at creation).
`POST /api/CustomerSupports/register`, `PUT /api/CustomerSupports/{id}`, `DELETE /api/CustomerSupports/{id}`, `POST /api/CustomerSupports/{id}/photo`.
Temporary password `Pass@123`, same message as §5.2.

### 6.3 Assign region (from the agent side)
Dialog with a single-select of **Support Regions only** (`RegionType = CustomerSupport`), showing region name, city and pin-code count. Includes a **Clear assignment** option.
`POST /api/ServiceRegions/assign` — `{ customerSupportId, serviceRegionId }`; `serviceRegionId: null` clears it.

**Rule:** an agent belongs to **exactly one** region; a region may hold **many** agents.
**Guard:** the region dropdown must exclude delivery regions — the API does not validate the region type.

### 6.4 Why the region matters (shown as a hint on the screen)
When a chemist rejects an order, the system looks up the customer's pin code, finds the **support region** that covers it, and assigns the order to the **least-loaded active agent** in that region. If no region covers the pin code, or the region has no active agent, the order escalates to a **manager** instead.

---

## 7. Delivery Boys

**Menu:** Delivery Boys · **Access:** Admin, Manager (full CRUD). See §11.3 — CustomerSupport currently cannot list them.

### 7.1 List
Columns: Name · Mobile · Driving Licence · **Assigned Region** · Medical Store · Status · Actions.
Filters: search, status, region (incl. "Unassigned"), medical store.
Actions: *Add Delivery Boy*; row → View, Edit, **Assign Region**, Delete.
`GET /api/Deliveries`

### 7.2 Create
`POST /api/Deliveries`
Fields: First name\*, Middle name, Last name\*, Mobile\*, Driving licence number\*, Medical Store (optional), Service Region (optional — delivery regions only).
Creating a delivery boy also creates their **mobile-app login** (username = mobile number, role DeliveryBoy, password `Pass@123`). Show the same temporary-password message.
Mobile numbers are globally unique across all users — "A user with this mobile number already exists" must be surfaced on the mobile field.

### 7.3 Edit / Delete
`PUT /api/Deliveries/{id}` (includes Active toggle), `DELETE /api/Deliveries/{id}` (soft delete, confirmation).

### 7.4 Assign region (from the delivery-boy side)
Dialog with a single-select of **Delivery Regions only** (`RegionType = DeliveryBoy`), plus a Clear option.
`POST /api/ServiceRegions/assign-delivery` — `{ deliveryId, serviceRegionId }`.

**Rule:** one delivery boy → one region; one region → many delivery boys.
**Note:** a delivery boy may also be linked to a medical store, but **only the region decides which orders they are eligible for**. The form states this explicitly.

---

## 8. Chemists

**Menu:** Chemists · **Access:** Admin, Manager, CustomerSupport.

### 8.1 List
Columns: Store name · Owner · Mobile · City · Pin code · **Payout/Activation state** · Status · Actions.
Filters: search (store / owner / mobile), city, pin code, status.
Row actions: View, Edit, **Activate / Deactivate**, Delete.
`GET /api/MedicalStores`

### 8.2 View
Sections: store identity (name, owner, contact), address with pin code and geo-coordinates, statutory details (GSTIN, PAN, FSSAI, Drug Licence, registration status), pharmacist details, payout/activation status (`GET /api/chemist-payout/{storeId}`, `/{storeId}/activation`).

### 8.3 Edit
`PUT /api/MedicalStores/{id}` — the same field groups as View.

### 8.4 Activate / Deactivate
`POST /api/MedicalStores/{id}/activate` · `POST /api/MedicalStores/{id}/deactivate`
Confirmation dialog. The dialog warns that **a deactivated chemist stops receiving new order assignments**.

### 8.5 Delete
`DELETE /api/MedicalStores/{id}` (soft). Hard delete (`DELETE /{id}/hard`) is **Admin-only** and behind a second, type-the-store-name confirmation.

> Note: chemist *registration* is a public self-service flow (`POST /api/MedicalStores/register`) and is **not** part of this console. The console manages existing chemists.

---

## 9. Customers

**Menu:** Customers · **Access:** Admin, Manager, CustomerSupport.

### 9.1 List
Columns: Customer number · Name · Mobile · Email · City (from default address) · Status · Actions.
Filters: search (name / mobile / customer number), status.
`GET /api/Customers`

### 9.2 View
Profile block (name, mobile, alt mobile, email, DOB, gender, photo), **address list** with the default address flagged, and a link to the customer's orders.
`GET /api/Customers/{id}`, `GET /api/CustomerAddresses/customer/{customerId}`

### 9.3 Create / Edit / Delete
`POST /api/Customers`, `PUT /api/Customers/{id}`, `DELETE /api/Customers/{id}`.
Addresses are managed in-line on the customer detail page: add (`POST /api/CustomerAddresses`), edit (`PUT /{id}`), delete (`DELETE /{id}`), set default (`PUT /api/CustomerAddresses/customer/{customerId}/set-default/{addressId}`).

---

## 10. Regions

Two menus over one concept. A region is `Name`, `City`, `Region Name`, `Region Type`, and a set of **pin codes**. The two menus differ only by `RegionType`:

| Menu | RegionType | Purpose |
|---|---|---|
| Support Regions | `CustomerSupport (0)` | Decides which support agent picks up a rejected order |
| Delivery Regions | `DeliveryBoy (1)` | Decides which delivery boys are eligible for an order |

Both screens are the same component with a different type — described once.

### 10.1 List
Columns: Name · City · Region name · **Pin codes** (first few + "+N more") · **Assigned staff count** · Actions.
Filters: search (name / city / region name / pin code).
Actions: *Add Region*; row → View, Edit, **Manage Assignments**, Delete.
`GET /api/ServiceRegions` filtered client-side by type.

### 10.2 Create / Edit
`POST /api/ServiceRegions` · `PUT /api/ServiceRegions/{id}`
Fields: Name\*, City\*, Region name\*, Region type (**fixed by the menu, not editable**), Pin codes (chip input, 6 digits each, duplicates rejected).
Pin codes may also be added/removed one at a time from the detail screen: `POST /api/ServiceRegions/add-pincode`, `POST /api/ServiceRegions/remove-pincode`.

### 10.3 Manage Assignments (from the region side)
The mirror of §6.3 / §7.4 — this is the bulk workbench.

- **Support Regions** → two panes: *Agents in this region* and *Unassigned / other agents*, with multi-select and **Assign selected** / **Remove selected**.
  `POST /api/ServiceRegions/assign/bulk` — `{ serviceRegionId, customerSupportIds[] }`; removal = single-assign with `serviceRegionId: null`.
- **Delivery Regions** → the same two panes for delivery boys.
  `POST /api/ServiceRegions/assign-delivery/bulk` — `{ serviceRegionId, deliveryIds[] }`.

Moving someone who already belongs to another region silently reassigns them — the UI must show their current region in the list and confirm the move.

### 10.4 Delete
`DELETE /api/ServiceRegions/{id}` — **hard delete**, and the API does not check for assigned staff.
The console therefore performs its own pre-check and blocks deletion with:
*"This region has 3 support agents and 5 pin codes. Reassign the agents before deleting."*
Deletion is only offered once no staff are attached.

### 10.5 Pin-code lookup
A search box on both list screens: enter a pin code → shows which region serves it (`GET /api/ServiceRegions/by-pincode/{pinCode}`), or "No region covers this pin code" — which for a support region means **orders from that pin code escalate straight to a manager**.

---

## 11. Orders

### 11.1 The five buckets
`Order.AssignTo` says who currently owns the order. The five submenus map exactly onto its five values:

| Menu | `AssignTo` | Meaning |
|---|---|---|
| Awaiting Assignment | `Customer (0)` | Not assigned to any chemist, support agent, manager or delivery boy — sitting with the customer |
| With Chemist | `Chemist (1)` | Assigned to a medical store |
| With Customer Support | `CustomerSupport (2)` | Rejected by a chemist, now with a support agent |
| Out for Delivery | `Delivery (3)` | Assigned to a delivery boy |
| With Manager | `Manager (4)` | Escalated to a manager |

**All Orders** shows every order with a bucket column and a bucket filter.

> `AssignTo` and `DeliveryId` were added to the API in Phase 0 — see §13.1.
> Always bucket by `assignTo`. The assignee ids persist after a hand-off, so an order can still
> carry a `deliveryId` while sitting in a different bucket.

### 11.2 Order list (shared component, one filter per menu)
Columns: Order # · Customer · Created on · Status · Payment · Amount · **Current owner** (chemist / agent / manager / delivery boy name) · Actions.
Filters: search (order number / customer), order status, payment status, date range.
Sorted newest first. Row click → order detail.
Source: `GET /api/Orders` for Admin/Manager; CustomerSupport is served from `/api/Orders/customersupport/{entityId}` and only ever sees their own orders.

### 11.3 Order detail
One page for all buckets; the action bar changes by bucket and role.

**Sections**
1. **Header** — order number, status chip, bucket chip, created/updated timestamps, total amount.
2. **Customer** — name, mobile, and the full **delivery address including pin code**.
3. **Order content** — input type (image / text / audio); text shown inline; image/audio downloadable via `GET /api/Orders/{id}/download-input-file`.
4. **Current assignment** — chemist / support agent / manager / delivery boy with contact details, and how it got there (System vs Customer Support).
5. **Bill** — uploaded bill download (`GET /api/Orders/{id}/download-bill`) when present.
6. **Payment** — payment records and Razorpay split (`GET /api/Payments/order/{id}`, `GET /api/Razorpay/payment-split/{id}`).
7. **Assignment history** — the full audit trail already returned inside the order (`AssignmentHistory`): who it was assigned to, by whom, when, and the outcome.
8. **Cancellation reason** — shown when the order is cancelled.

The delivery OTP is never shown to staff — the API deliberately withholds it.

### 11.4 Actions per bucket

| Bucket | Reassign to another chemist | Cancel with reason | Notes |
|---|---|---|---|
| Awaiting Assignment | — | Admin, Manager | View only by default |
| With Chemist | — | Admin, Manager | View only |
| **With Customer Support** | **Yes** (Admin, Manager, CS) | Admin, Manager, CS | The core support workflow |
| **With Manager** | **Yes** (Admin, Manager) | **Yes** (Admin, Manager) | The escalation workflow |
| Out for Delivery | — | Admin, Manager | View only |

### 11.5 Reassign to another chemist
Dialog: shows the order's delivery pin code, then a searchable list of candidate chemists.
Candidate source, in order of preference:
1. `GET /api/Orders/{orderId}/medical-stores-by-pincode` — same pin code;
2. `GET /api/Orders/{orderId}/medical-stores-by-city` — widen to the city;
3. `GET /api/Orders/{orderId}/nearby-chemists/{orderNumber}` — nearest by distance.
The dialog defaults to (1), with a "Widen search" control. Each row shows store name, address, distance where available, and whether the store is active.
Submit → `PUT /api/Orders/{orderId}/reassign` with `{ medicalStoreId }`.
On success the order moves to **With Chemist** and the user is returned to the list with a toast.

### 11.6 Cancel order
Dialog requiring a **reason** (free text, mandatory, 10–500 chars) and a confirmation checkbox.
`PUT /api/Orders/{orderId}/cancel` with the reason. The reason is then shown permanently on the order detail.

### 11.7 Assign a delivery boy *(optional — see §13, Q2)*
Not in your list, but the API supports it and Managers may need it:
`GET /api/Orders/{orderId}/eligible-delivery-boys` (filtered by the delivery region covering the order's pin code) → `PUT /api/Orders/{orderId}/assign-delivery` with `{ deliveryId }`.
Included behind a flag; confirm whether you want it.

### 11.8 Order lifecycle reference (rendered as a status legend)
```
PendingPayment → AssignedToChemist ┬→ AcceptedByChemist → BillUploaded → Paid → OutForDelivery → Completed
                                   └→ RejectedByChemist → AssignedToCustomerSupport → (reassign to chemist)
                                                        └→ AssignedToManager        → (reassign to chemist)
Any state → Cancelled (with reason)
```

---

## 12. Role → menu access matrix

| Menu | Admin | Manager | CustomerSupport |
|---|:--:|:--:|:--:|
| Dashboard | ✅ | ✅ | ✅ |
| Managers | CRUD | read | ✖ |
| Customer Support | CRUD | CRUD | read |
| Delivery Boys | CRUD | CRUD | ✖ *(see §13.3)* |
| Chemists | CRUD + activate | CRUD + activate | CRUD + activate |
| Customers | CRUD | CRUD | CRUD |
| Support Regions | CRUD + assign | CRUD + assign | read |
| Delivery Regions | CRUD + assign | CRUD + assign | read |
| Orders → All Orders | ✅ | ✅ | ✖ *(no ListAllOrders permission)* |
| Orders → other buckets | ✅ | ✅ | own queue only |
| Reassign order | ✅ | ✅ | ✅ |
| Cancel order | ✅ | ✅ | ✅ |

Menus a role cannot use are **hidden**, not disabled.

---

## 13. Backend prerequisites and known gaps

### 13.1 ~~Required before the Orders module can be built~~ — **DONE 2026-08-02**
`OrderDto` did not expose `AssignTo` or `DeliveryId`, although `Order` carries both.

**Shipped:** `AssignTo`, `DeliveryId`, plus `MedicalStoreName`, `CustomerSupportName`, `ManagerName` and `DeliveryBoyName`, populated by a batched lookup on the six staff-facing order reads. See Phase 0 in the implementation plan.

Two behaviours the console must respect:
- Legacy rows with a NULL `AssignTo` materialise as `0` (`Customer`) and correctly land in **Awaiting Assignment**.
- Assignee ids **persist after hand-off** — an order can carry a `deliveryId` while sitting in another bucket. Always bucket by `assignTo`, never by "which id is non-null".

### 13.2 `GET /api/Orders` is unpaginated
It returns every order in one response. Acceptable now with client-side paging; server-side paging and filtering will be needed as volume grows. Tracked, not blocking.

### 13.3 CustomerSupport cannot list delivery boys
`GET /api/Deliveries` requires the `DeliveryRead` permission, which the CustomerSupport role does not hold — yet delivery-boy *create/update/delete* are gated by `UpdateOrders`, which it does hold. The console hides the Delivery Boys menu from CustomerSupport until this is resolved.

### 13.4 Over-permissive endpoints (backend defects, flagged not fixed)
- Delivery-boy create/update/delete and **all** region write operations are gated by `UpdateOrders`, a permission held by the **Customer** and **DeliveryBoy** roles. The dedicated `DeliveryCreate/Update/Delete` permissions exist but are unused.
- Region reads are gated by `ReadOrders`, held by every role including Customer.

These do not block the console (it is role-gated on the client and the affected roles cannot log in here), but they are exploitable directly against the API.

### 13.5 Region-type is not validated on assignment
The API will happily assign a support agent to a delivery region. The console prevents it by filtering the dropdowns; a server-side check is still advisable.

### 13.6 Region delete is unguarded
Hard delete with no referential check. Mitigated by the client-side pre-check in §10.4.

### 13.7 No activity/audit log
There is no audit table. "Manager / support / admin activity" is therefore served by **order queues, workload counts and the per-order assignment history** — not by a "what did user X do" log. A real audit trail needs new backend work; out of scope for this build.

---

## 14. Open questions

1. ~~**UI library**~~ — **Angular Material confirmed (2026-08-02).**
2. **Assign delivery boy from the console** (§11.7) — include it or leave it to the chemist's own portal?
3. **Reassign from the *Awaiting Assignment* and *With Chemist* buckets** — currently view-only. Should Admin/Manager be able to push those orders to a chemist too?
4. **Relationship to the existing React app** ([WebApp/](../../WebApp/)) — does this Angular console eventually replace it, and if so does the chemist portal need to move here as well?
5. **API environment** — dev `http://localhost:5000/api`, prod `http://188.241.187.172/MediMartAPI1/api` (taken from the React app). Confirm these are the right targets.

---

## 15. Test accounts (local development only)

> ⚠️ **Local development database only** (`MedicineDeliveryNew` on `localhost:5432`).
> Never put staging or production credentials in this file — it is committed to the repository.
> Anything listed here should be treated as public.

### 15.1 Who can sign into this console

| Role | Signs in here | Sign-in name |
|---|:--:|---|
| **Admin** | ✅ | mobile number |
| **Manager** | ✅ | mobile number |
| **CustomerSupport** | ✅ | mobile number |
| Chemist | ✖ | — (uses the chemist portal) |
| Customer | ✖ | — (mobile app) |
| DeliveryBoy | ✖ | — (mobile app) |

Sign-in is always by **mobile number**, never by email — the Identity `UserName` is the mobile number.
A non-staff account that authenticates is signed straight back out with *"This portal is for staff only."*

### 15.2 Verified working credentials

Both confirmed against `POST /api/Auth/login` on 2026-08-02:

| Role | Mobile number | Password | Email on the account |
|---|---|---|---|
| **Admin** | `9999999999` | `Admin@123` | admin@medicine.com |
| **Admin** | `8793583675` | `Admin@123` | dipmala.patil@medicine.com |

### 15.3 The other seeded accounts

The local database also holds 3 support agents, 2 managers, 4 delivery partners, 9 chemists and
~200 customers. **Their passwords are not recoverable** — they are bcrypt hashes created by earlier
test runs, and the documented defaults do not open them (`Pass@123`, `Admin@123` and `E2eFunc@123`
were all tried against representative accounts and rejected).

To sign in as a non-admin role, either:

1. **Create a fresh account through this console** (Managers / Customer Support / Delivery Boys →
   *Add*). The API assigns every new staff account the same starter password, and the console shows
   it in a dialog immediately after creation:

   | Created as | Sign-in name | Password |
   |---|---|---|
   | Manager | the mobile number you entered | `Pass@123` |
   | Customer support | the mobile number you entered | `Pass@123` |
   | Delivery partner | the mobile number you entered | `Pass@123` |

   This is `DefaultCredentials.StaffPassword` in
   `Backend/MedicineDelivery/MedicineDelivery.Domain/Constants/DefaultCredentials.cs`, used by
   `ManagerService`, `CustomerSupportService` and `DeliveryService`. Chemists are the exception —
   they set their own password at registration, or get a generated one.

2. **Reset an existing account's password** with the forgot-password flow (an OTP is sent by SMS;
   in local development the console SMS provider writes it to the API log).

### 15.4 Local sign-in checklist

The API must be pointed at the local database *and* local file storage, or order requests fail on
the placeholder Azure Blob connection string:

```bash
cd Backend/MedicineDelivery && ConnectionStrings__PostgresConnection="Host=localhost;Port=5432;Database=MedicineDeliveryNew;Username=postgres;Password=123;Include Error Detail=true;" FileStorage__Provider="Local" dotnet run --project MedicineDelivery.API
```

Then start the console with `npm start` in `WebApplication/staff-console` and sign in at
`http://localhost:4200` with one of the admin accounts above.

---

## 16. Sign-off

| Item | Owner | Status |
|---|---|---|
| Menu structure (§2) | | ☐ |
| Staff CRUD screens (§5–§9) | | ☐ |
| Region model & assignment (§10) | | ☐ |
| Order buckets & actions (§11) | | ☐ |
| Role access matrix (§12) | | ☐ |
| Backend prerequisite §13.1 approved | | ☐ |
| Open questions §14 answered | | ☐ |
