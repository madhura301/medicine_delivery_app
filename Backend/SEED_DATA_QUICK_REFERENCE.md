# Seed Data Quick Reference Card

## 🚀 Quick Start
```powershell
# Run seed script (will prompt for password)
.\run_seed_data.ps1

# Or with parameters
.\run_seed_data.ps1 -Server "localhost" -Database "MedicineDeliveryDB" -Username "postgres"
```

## 👥 Default Users

| Mobile | Email | Password | Role | Name |
|--------|-------|----------|------|------|
| 9999999999 | admin@medicine.com | `Admin@123` | Admin | System Administrator |
| 8888888888 | manager@medicine.com | `Manager@123` | Manager | John Manager |
| 7777777777 | support@medicine.com | `Support@123` | CustomerSupport | Jane Support |
| 6666666666 | customer@medicine.com | `Customer@123` | Customer | Alice Customer |
| 5555555555 | chemist@medicine.com | `Chemist@123` | Chemist | Bob Chemist |

> ⚠️ **Change passwords after first login in production!**

## 🔑 Roles & Permission Count

| Role | Permissions | Description |
|------|------------|-------------|
| **Admin** | 51 (ALL) | Full system access |
| **Manager** | 33 | Management operations |
| **CustomerSupport** | 25 | Customer support operations |
| **Customer** | 6 | Read products, manage own orders |
| **Chemist** | 11 | Manage products & orders |

## 📋 Permission Categories

### Base Permissions (12)
- **Users**: Read, Create, Update, Delete
- **Products**: Read, Create, Update, Delete
- **Orders**: Read, Create, Update, Delete

### User Management (16)
- **Admin**: Read, Create, Update, Delete Users
- **Manager**: Read, Create, Update, Delete Users
- **CustomerSupport**: Read, Create, Update, Delete Users
- **Chemist**: Read, Create, Update, Delete Users

### Role Management (1)
- ManageRolePermission

### Entity CRUD (22)
- **Chemist**: Read, Create, Update, Delete
- **CustomerSupport**: Read, Create, Update, Delete
- **Manager**: Read, Create, Update, Delete
- **Customer (Own)**: Read, Create, Update, Delete
- **Customer (All)**: Read, Update, Delete
- **Medical Store (All)**: Read, Update, Delete

## 📊 What Each Role Can Do

### 👑 Admin (Superuser)
- ✅ Everything
- ✅ Manage all users (all roles)
- ✅ Manage all products
- ✅ Manage all orders
- ✅ Manage role permissions
- ✅ Full CRUD on all entities

### 👔 Manager
- ✅ Read & Update users, products, orders
- ✅ Manage Managers, CustomerSupport, Chemists, Customers
- ✅ CRUD CustomerSupport, Chemist, Medical Store accounts
- ✅ Manage all customers
- ❌ Cannot create other managers
- ❌ Cannot delete products/orders
- ❌ Cannot manage permissions

### 🎧 CustomerSupport
- ✅ Read products
- ✅ Read & create orders
- ✅ Manage CustomerSupport users
- ✅ Manage Chemists
- ✅ CRUD Chemist & Medical Store accounts
- ✅ Manage all customers
- ✅ Update own profile
- ❌ Cannot create other support users
- ❌ Cannot manage products
- ❌ Cannot manage managers

### 🛒 Customer
- ✅ Read products
- ✅ Read & create orders (own)
- ✅ Read, update, delete own profile
- ❌ Cannot see other customers
- ❌ Cannot manage products
- ❌ Cannot see all orders

### 💊 Chemist
- ✅ Full CRUD on products
- ✅ Full CRUD on orders
- ✅ Read, update, delete own profile
- ❌ Cannot create other chemists
- ❌ Cannot manage users
- ❌ Cannot manage customers

## 🗂️ Database Tables Seeded

| Table | Count | Description |
|-------|-------|-------------|
| AspNetRoles | 5 | Identity roles |
| AspNetUsers | 5 | Application users |
| AspNetUserRoles | 5 | User-role mappings |
| Permissions | 51 | All permissions |
| RolePermissions | ~130 | Role-permission mappings |

## 🔍 Verification Queries

### Check Counts
```sql
SELECT COUNT(*) FROM "AspNetRoles";          -- Should be 5
SELECT COUNT(*) FROM "AspNetUsers";          -- Should be 5
SELECT COUNT(*) FROM "Permissions";          -- Should be 51
SELECT COUNT(*) FROM "RolePermissions";      -- Should be ~130
SELECT COUNT(*) FROM "AspNetUserRoles";      -- Should be 5
```

### View Users with Roles
```sql
SELECT u."UserName", u."Email", r."Name" as "Role"
FROM "AspNetUsers" u
JOIN "AspNetUserRoles" ur ON u."Id" = ur."UserId"
JOIN "AspNetRoles" r ON ur."RoleId" = r."Id"
ORDER BY r."Name";
```

### View Permissions by Role
```sql
SELECT r."Name" as "Role", COUNT(rp."PermissionId") as "Permissions"
FROM "AspNetRoles" r
LEFT JOIN "RolePermissions" rp ON r."Id" = rp."RoleId"
WHERE rp."IsActive" = true
GROUP BY r."Name"
ORDER BY "Permissions" DESC;
```

## 🧪 Testing Login

### PowerShell
```powershell
$body = @{
    username = "9999999999"
    password = "Admin@123"
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://localhost:5001/api/auth/login" `
    -Method POST -Body $body -ContentType "application/json"
```

### cURL
```bash
curl -X POST https://localhost:5001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"9999999999","password":"Admin@123"}'
```

### Expected Response
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "userId": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
  "username": "9999999999",
  "email": "admin@medicine.com",
  "roles": ["Admin"],
  "firstName": "System",
  "lastName": "Administrator"
}
```

## 🚨 Common Issues & Fixes

### Issue: "relation does not exist"
**Fix:** Run migrations first
```powershell
cd MedicineDelivery/MedicineDelivery.API
dotnet ef database update
```

### Issue: Login fails with correct credentials
**Fix:** Password hashes are placeholders. Generate real hashes:
```powershell
# See GENERATE_PASSWORD_HASHES.md for details
dotnet new console -n HashGen
# Add password hasher code
dotnet run
```

### Issue: "psql: command not found"
**Fix:** Install PostgreSQL client tools and add to PATH

### Issue: "duplicate key value" error
**Fix:** Data already exists. Safe to ignore (uses ON CONFLICT DO NOTHING)

## 📁 Related Files

| File | Purpose |
|------|---------|
| `seed_data_script.sql` | Main SQL seed script |
| `run_seed_data.ps1` | PowerShell runner script |
| `SEED_DATA_README.md` | Complete documentation |
| `GENERATE_PASSWORD_HASHES.md` | Password hash generation guide |
| `SeedData.cs` | C# seed data class (alternative) |

## 🔧 Useful Commands

### Reset Seed Data
```sql
-- WARNING: This deletes all users and role mappings!
BEGIN;
DELETE FROM "AspNetUserRoles";
DELETE FROM "AspNetUsers" WHERE "Id" IN (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    'dddddddd-dddd-dddd-dddd-dddddddddddd',
    'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee'
);
DELETE FROM "RolePermissions";
DELETE FROM "Permissions";
DELETE FROM "AspNetRoles" WHERE "Id" IN (
    '11111111-1111-1111-1111-111111111111',
    '22222222-2222-2222-2222-222222222222',
    '33333333-3333-3333-3333-333333333333',
    '44444444-4444-4444-4444-444444444444',
    '55555555-5555-5555-5555-555555555555'
);
COMMIT;
```

### View User's Permissions
```sql
SELECT p."Name", p."Description", p."Module"
FROM "Permissions" p
JOIN "RolePermissions" rp ON p."Id" = rp."PermissionId"
JOIN "AspNetUserRoles" ur ON rp."RoleId" = ur."RoleId"
WHERE ur."UserId" = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
  AND rp."IsActive" = true
  AND p."IsActive" = true
ORDER BY p."Module", p."Name";
```

### Check User's Roles
```sql
SELECT r."Name" as "Role"
FROM "AspNetRoles" r
JOIN "AspNetUserRoles" ur ON r."Id" = ur."RoleId"
JOIN "AspNetUsers" u ON ur."UserId" = u."Id"
WHERE u."UserName" = '9999999999';
```

## 📞 Support

Need help?
1. Check `SEED_DATA_README.md` for detailed docs
2. Review `TROUBLESHOOTING_401_ERRORS.md`
3. Check application logs in `MedicineDelivery/MedicineDelivery.API/Logs/`

## 🔐 Security Checklist

- [ ] Changed all default passwords
- [ ] Generated proper password hashes
- [ ] Enabled two-factor authentication
- [ ] Configured account lockout policies
- [ ] Reviewed and adjusted role permissions
- [ ] Disabled/removed unused default accounts
- [ ] Set up password expiration policies
- [ ] Configured IP whitelisting for admin accounts

---

**⚡ Pro Tip:** Bookmark this file for quick access during development!

*Last Updated: October 2025*

