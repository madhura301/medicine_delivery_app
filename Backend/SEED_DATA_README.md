# Medicine Delivery Application - Seed Data Documentation

## Overview
This directory contains SQL scripts and utilities for seeding initial data into the Medicine Delivery Application database.

## Files

### 1. `seed_data_script.sql`
Complete PostgreSQL script that seeds:
- **5 Identity Roles** (AspNetRoles)
- **51 Permissions** (Permissions table)
- **Role-Permission Mappings** (RolePermissions table)
- **5 Default Users** (AspNetUsers)
- **User-Role Mappings** (AspNetUserRoles)

### 2. `run_seed_data.ps1`
PowerShell script to execute the seed data script with parameters.

## Seed Data Details

### Roles (5 total)
| Role ID | Role Name | Description |
|---------|-----------|-------------|
| `11111111-1111-1111-1111-111111111111` | Admin | Full system access |
| `22222222-2222-2222-2222-222222222222` | Manager | Management level access |
| `33333333-3333-3333-3333-333333333333` | CustomerSupport | Customer support access |
| `44444444-4444-4444-4444-444444444444` | Customer | Customer access |
| `55555555-5555-5555-5555-555555555555` | Chemist | Chemist/Pharmacist access |

### Default Users (5 total)
| Username (Mobile) | Email | Password | Role | First Name | Last Name |
|-------------------|-------|----------|------|------------|-----------|
| 9999999999 | admin@medicine.com | `Admin@123` | Admin | System | Administrator |
| 8888888888 | manager@medicine.com | `Manager@123` | Manager | John | Manager |
| 7777777777 | support@medicine.com | `Support@123` | CustomerSupport | Jane | Support |
| 6666666666 | customer@medicine.com | `Customer@123` | Customer | Alice | Customer |
| 5555555555 | chemist@medicine.com | `Chemist@123` | Chemist | Bob | Chemist |

> ⚠️ **IMPORTANT**: These passwords are for **DEVELOPMENT ONLY**. Change them immediately in production!

### Permissions (51 total)

#### Base Permissions (1-12)
- **Users Module** (1-4): ReadUsers, CreateUsers, UpdateUsers, DeleteUsers
- **Products Module** (5-8): ReadProducts, CreateProducts, UpdateProducts, DeleteProducts
- **Orders Module** (9-12): ReadOrders, CreateOrders, UpdateOrders, DeleteOrders

#### User Management Permissions (13-28)
- **Admin User Management** (13-16): AdminReadUsers, AdminCreateUsers, AdminUpdateUsers, AdminDeleteUsers
- **Manager User Management** (17-20): ManagerReadUsers, ManagerCreateUsers, ManagerUpdateUsers, ManagerDeleteUsers
- **CustomerSupport User Management** (21-24): CustomerSupportReadUsers, CustomerSupportCreateUsers, CustomerSupportUpdateUsers, CustomerSupportDeleteUsers
- **Chemist User Management** (25-28): ChemistReadUsers, ChemistCreateUsers, ChemistUpdateUsers, ChemistDeleteUsers

#### Role Management (29)
- **Permission 29**: ManageRolePermission

#### Entity CRUD Permissions (30-51)
- **Chemist CRUD** (30-33): ChemistRead, ChemistCreate, ChemistUpdate, ChemistDelete
- **CustomerSupport CRUD** (34-37): CustomerSupportRead, CustomerSupportCreate, CustomerSupportUpdate, CustomerSupportDelete
- **Manager CRUD** (38-41): ManagerSupportRead, ManagerSupportCreate, ManagerSupportUpdate, ManagerSupportDelete
- **Customer CRUD - Own Records** (42-45): CustomerRead, CustomerCreate, CustomerUpdate, CustomerDelete
- **Customer CRUD - All Records** (46-48): AllCustomerRead, AllCustomerUpdate, AllCustomerDelete
- **Chemist/Medical Store - All Records** (49-51): AllChemistRead, AllChemistUpdate, AllChemistDelete

### Role-Permission Matrix

#### Admin Role
✅ **ALL 51 permissions** - Complete system access

#### Manager Role (33 permissions)
- Base: Read & Update permissions (Users, Products, Orders)
- Manager User Management permissions (17-20)
- CustomerSupport User Management permissions (21-24)
- Chemist User Management permissions (25-28)
- All Chemist CRUD permissions (30-33)
- All CustomerSupport CRUD permissions (34-37)
- Manager Self-Management (38, 40-41) - *Cannot create other managers*
- Customer Create & All Customer CRUD (43, 46-48)
- All MedicalStore/Chemist CRUD (49-51)

#### CustomerSupport Role (25 permissions)
- Read Products & Orders, Create Orders (5, 9-10)
- CustomerSupport User Management permissions (21-24)
- Chemist User Management permissions (25-28)
- All Chemist CRUD permissions (30-33)
- CustomerSupport Self-Management (34, 36-37) - *Cannot create other support users*
- Customer Create & All Customer CRUD (43, 46-48)
- All MedicalStore/Chemist CRUD (49-51)

#### Customer Role (6 permissions)
- Read Products (5)
- Read & Create Orders (9-10)
- Customer Self-Management (42, 44-45) - *Own records only*

#### Chemist Role (11 permissions)
- Full Products CRUD (5-8)
- Full Orders CRUD (9-12)
- Chemist Self-Management (30, 32-33) - *Cannot create other chemists*

## Usage

### Option 1: Using PowerShell Script (Recommended)

#### Basic Usage (Interactive Password Prompt)
```powershell
.\run_seed_data.ps1
```

#### With Parameters
```powershell
.\run_seed_data.ps1 -Server "localhost" -Port 5432 -Database "MedicineDeliveryDB" -Username "postgres" -Password "your_password"
```

#### Parameters
- `-Server`: PostgreSQL server address (default: `localhost`)
- `-Port`: PostgreSQL port (default: `5432`)
- `-Database`: Database name (default: `MedicineDeliveryDB`)
- `-Username`: PostgreSQL username (default: `postgres`)
- `-Password`: PostgreSQL password (if not provided, will be prompted securely)

### Option 2: Using psql Directly

```bash
# Set password environment variable
$env:PGPASSWORD="your_password"

# Run the script
psql -h localhost -p 5432 -U postgres -d MedicineDeliveryDB -f seed_data_script.sql

# Clear password
Remove-Item Env:\PGPASSWORD
```

### Option 3: Using pgAdmin or Other GUI Tools
1. Open pgAdmin or your preferred PostgreSQL GUI
2. Connect to your database
3. Open the Query Tool
4. Load `seed_data_script.sql`
5. Execute the script

## Important Notes

### ⚠️ Password Hashes
The password hashes in the SQL script are **PLACEHOLDERS** and may not work for actual authentication. For proper password hashing:

1. **Option A**: Use the application's `SeedData.cs` class which properly generates password hashes using ASP.NET Core Identity's `UserManager`.

2. **Option B**: Generate proper password hashes and update the script:
```csharp
// In your application
var passwordHasher = new PasswordHasher<ApplicationUser>();
var user = new ApplicationUser();
var hash = passwordHasher.HashPassword(user, "YourPassword123");
Console.WriteLine(hash);
```

### 🔒 Security Recommendations
1. **Change default passwords** immediately after first deployment
2. **Enable two-factor authentication** for admin and manager accounts
3. **Use strong passwords** (minimum 12 characters, mix of uppercase, lowercase, numbers, symbols)
4. **Rotate passwords** regularly
5. **Disable default accounts** if not needed

### 🔄 Conflict Handling
The script uses `ON CONFLICT DO NOTHING` to prevent errors if data already exists. This means:
- ✅ Safe to run multiple times
- ✅ Won't duplicate data
- ⚠️ Won't update existing data

If you need to update existing seed data:
1. Delete existing records first, OR
2. Modify the script to use `ON CONFLICT ... DO UPDATE`

### 📊 Verification
After running the script, verify the data:

```sql
-- Check counts
SELECT COUNT(*) as "Total Roles" FROM "AspNetRoles";
SELECT COUNT(*) as "Total Permissions" FROM "Permissions";
SELECT COUNT(*) as "Total Users" FROM "AspNetUsers";

-- View users with roles
SELECT u."UserName", u."Email", r."Name" as "RoleName"
FROM "AspNetUsers" u
JOIN "AspNetUserRoles" ur ON u."Id" = ur."UserId"
JOIN "AspNetRoles" r ON ur."RoleId" = r."Id"
ORDER BY r."Name";

-- View permissions by role
SELECT r."Name" as "Role", COUNT(rp."PermissionId") as "Permission Count"
FROM "AspNetRoles" r
LEFT JOIN "RolePermissions" rp ON r."Id" = rp."RoleId" AND rp."IsActive" = true
GROUP BY r."Name"
ORDER BY r."Name";
```

Expected Results:
- Roles: 5
- Permissions: 51
- Users: 5
- User-Role Mappings: 5
- Role-Permission Mappings: ~130 (varies by role)

## Troubleshooting

### Error: "relation does not exist"
**Cause**: Database tables haven't been created yet.
**Solution**: Run Entity Framework migrations first:
```powershell
cd MedicineDelivery/MedicineDelivery.API
dotnet ef database update
```

### Error: "duplicate key value violates unique constraint"
**Cause**: Seed data already exists in the database.
**Solution**: This is expected behavior with `ON CONFLICT DO NOTHING`. No action needed.

### Error: "psql: command not found"
**Cause**: PostgreSQL client tools not installed or not in PATH.
**Solution**: 
1. Install PostgreSQL client tools
2. Add PostgreSQL bin directory to system PATH
3. Restart PowerShell/terminal

### Authentication Fails with Seeded Users
**Cause**: Password hashes in script are placeholders.
**Solution**: 
1. Use the application's registration endpoint to create users, OR
2. Use `SeedData.cs` class which properly generates password hashes, OR
3. Manually generate proper password hashes and update the script

## Integration with Application

The seed data complements the C# `SeedData.cs` class. Differences:

### SeedData.cs
- ✅ Properly generates password hashes using `UserManager`
- ✅ Uses ASP.NET Core Identity APIs
- ✅ Runs automatically on application startup
- ❌ Slower (creates users one by one via Identity)
- ❌ Doesn't seed permissions (handled by EF migrations)

### seed_data_script.sql
- ✅ Seeds ALL data (roles, permissions, users, mappings)
- ✅ Fast bulk insert
- ✅ Can be run independently of application
- ✅ Idempotent (safe to run multiple times)
- ⚠️ Password hashes need to be properly generated

### Recommended Approach
For **development**: Use either method (SeedData.cs is easier)
For **production**: Use SeedData.cs or generate proper password hashes for this script

## Maintenance

### Updating Permissions
If you add new permissions:
1. Update `ApplicationDbContext.cs` OnModelCreating method
2. Create a new EF migration
3. Update `seed_data_script.sql` with new permissions
4. Update this README

### Adding New Default Users
1. Add user to `seed_data_script.sql` (Section 4)
2. Generate proper password hash
3. Add user-role mapping (Section 5)
4. Update this README

### Changing Role-Permission Mappings
1. Update `ApplicationDbContext.cs` RolePermission seed data
2. Update `seed_data_script.sql` (Section 3)
3. Update Role-Permission Matrix in this README

## Related Files
- `MedicineDelivery/MedicineDelivery.API/Data/SeedData.cs` - C# seed data class
- `MedicineDelivery/MedicineDelivery.Infrastructure/Data/ApplicationDbContext.cs` - EF Core configuration & seed data
- `Prod_All_Script.sql` - Complete production database script
- `USER_CREDENTIALS.md` - User credentials documentation

## Support
For issues or questions:
1. Check the Troubleshooting section above
2. Review the application logs in `MedicineDelivery/MedicineDelivery.API/Logs/`
3. Check Entity Framework migration status
4. Verify database connection settings in `appsettings.json`

---
*Last Updated: October 2025*

