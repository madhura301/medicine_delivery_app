# Database Migration Quick Start Guide

## 🚀 Quick Start (Fresh Database)

### Step 1: Clean Database Migration History (If Database Exists)

If you have an existing database, remove the migration history table:

```sql
-- Connect to your database
USE [MedicineDelivery_Database];

-- Drop the migration history table
DROP TABLE IF EXISTS __EFMigrationsHistory;
```

### Step 2: Create Fresh Initial Migration

```powershell
# From solution root directory
dotnet ef migrations add InitialCreate `
    --context ApplicationDbContext `
    --project MedicineDelivery.Infrastructure `
    --startup-project MedicineDelivery.API
```

### Step 3: Review Migration

Open `MedicineDelivery.Infrastructure/Migrations/[timestamp]_InitialCreate.cs` and verify:
- ✅ All entities are included
- ✅ Seed data is included (Roles, Permissions, RolePermissions)
- ✅ All relationships are correct

### Step 4: Apply Migration

#### Development Environment:
```powershell
dotnet ef database update `
    --context ApplicationDbContext `
    --project MedicineDelivery.Infrastructure `
    --startup-project MedicineDelivery.API
```

#### Test/Staging Environment:
```powershell
# Set connection string
$env:ConnectionStrings__DefaultConnection = "Server=test-server;Database=MedicineDelivery_Test;User Id=user;Password=pass;TrustServerCertificate=True;"

# Apply migration
dotnet ef database update `
    --context ApplicationDbContext `
    --project MedicineDelivery.Infrastructure `
    --startup-project MedicineDelivery.API
```

#### Production Environment (Recommended: SQL Script):
```powershell
# Generate SQL script first
dotnet ef migrations script `
    --context ApplicationDbContext `
    --project MedicineDelivery.Infrastructure `
    --startup-project MedicineDelivery.API `
    --output migration_script.sql

# Review migration_script.sql
# Then execute in SQL Server Management Studio
```

---

## 🗑️ If Database Already Exists (Drop and Recreate)

### Option A: Drop and Recreate Database
```powershell
# Drop database
dotnet ef database drop `
    --context ApplicationDbContext `
    --project MedicineDelivery.Infrastructure `
    --startup-project MedicineDelivery.API `
    --force

# Create fresh migration
dotnet ef migrations add InitialCreate `
    --context ApplicationDbContext `
    --project MedicineDelivery.Infrastructure `
    --startup-project MedicineDelivery.API

# Apply migration
dotnet ef database update `
    --context ApplicationDbContext `
    --project MedicineDelivery.Infrastructure `
    --startup-project MedicineDelivery.API
```

### Option B: Keep Database, Remove History Only
```sql
-- Keep data, just remove migration history
USE [MedicineDelivery_Database];
DROP TABLE IF EXISTS __EFMigrationsHistory;
```

Then create fresh migration and apply it.

---

## 📋 Checklist Before Production Migration

- [ ] Backup production database
- [ ] Test migration in Test/Staging environment
- [ ] Review generated SQL script
- [ ] Verify seed data in migration
- [ ] Schedule maintenance window
- [ ] Have rollback plan ready
- [ ] Notify team of maintenance window
- [ ] Monitor application after migration

---

## 🔄 Common Commands

### List all migrations
```powershell
dotnet ef migrations list `
    --context ApplicationDbContext `
    --project MedicineDelivery.Infrastructure `
    --startup-project MedicineDelivery.API
```

### Check migration status in database
```sql
SELECT * FROM __EFMigrationsHistory ORDER BY MigrationId;
```

### Remove last migration (if not applied)
```powershell
dotnet ef migrations remove `
    --context ApplicationDbContext `
    --project MedicineDelivery.Infrastructure `
    --startup-project MedicineDelivery.API
```

---

## ⚠️ Important Notes

1. **Always backup production database** before applying migrations
2. **Test in Test/Staging** environment first
3. **Review SQL script** before executing in production
4. **Seed data** should be in initial migration
5. **Verify application** works after migration

---

**For detailed migration plan, see: `DATABASE_MIGRATION_PLAN.md`**








