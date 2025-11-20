# Database Migration Plan
## Medicine Delivery Application

This document outlines the database migration strategy for Test/Staging and Production environments.

---

## 📋 Table of Contents
1. [Overview](#overview)
2. [Migration Strategy](#migration-strategy)
3. [Environment Setup](#environment-setup)
4. [Step-by-Step Migration Process](#step-by-step-migration-process)
5. [Rollback Procedures](#rollback-procedures)
6. [Best Practices](#best-practices)

---

## 📖 Overview

This application uses **Entity Framework Core Migrations** with **SQL Server** database. All migrations are stored in the `MedicineDelivery.Infrastructure/Migrations` folder.

### Key Principles
- ✅ **Idempotent Migrations**: Each migration can be applied safely multiple times
- ✅ **Version Control**: All migrations are committed to source control
- ✅ **Testing First**: Always test migrations in Development/Test before Production
- ✅ **Backup Before Migration**: Always backup production database before applying migrations
- ✅ **Seed Data**: Initial data (roles, permissions) is seeded automatically

---

## 🎯 Migration Strategy

### Environments
1. **Development** - Local developer machines
2. **Test/Staging** - Testing environment (mirrors production)
3. **Production** - Live environment

### Migration Flow
```
Development → Test/Staging → Production
```

---

## 🛠️ Environment Setup

### Prerequisites
1. .NET 8.0 SDK installed
2. SQL Server installed and accessible
3. Connection strings configured in `appsettings.json`
4. Entity Framework Core Tools installed globally:
   ```bash
   dotnet tool install --global dotnet-ef
   ```

### Connection Strings
- **Development**: `appsettings.Development.json`
- **Test/Staging**: Environment variables or separate config
- **Production**: Environment variables or secure vault

---

## 📝 Step-by-Step Migration Process

### Phase 1: Development Environment (Fresh Start)

#### Step 1: Clean Existing Migrations
```powershell
# Navigate to Infrastructure project
cd MedicineDelivery.Infrastructure

# Delete all existing migration files
Remove-Item -Path "Migrations\*.cs" -Exclude "ApplicationDbContextModelSnapshot.cs"
Remove-Item -Path "Migrations\ApplicationDbContextModelSnapshot.cs"
```

#### Step 2: Create Initial Migration
```powershell
# From solution root
dotnet ef migrations add InitialCreate --context ApplicationDbContext --project MedicineDelivery.Infrastructure --startup-project MedicineDelivery.API
```

#### Step 3: Review Migration
- Open `Migrations/[timestamp]_InitialCreate.cs`
- Verify all entities are included:
  - Users
  - Roles
  - Permissions
  - RolePermissions
  - UserRoles
  - Products
  - Orders
  - OrderItems
  - CustomerAddress (if applicable)

#### Step 4: Apply to Development Database
```powershell
# Update development database
dotnet ef database update --context ApplicationDbContext --project MedicineDelivery.Infrastructure --startup-project MedicineDelivery.API
```

#### Step 5: Verify
- Check database tables created
- Verify seed data (roles, permissions, admin user)
- Test application functionality

---

### Phase 2: Test/Staging Environment

#### Step 1: Backup Database
```sql
-- Create backup of Test database
BACKUP DATABASE [MedicineDelivery_Test] 
TO DISK = 'C:\Backups\MedicineDelivery_Test_Backup_' + CONVERT(VARCHAR, GETDATE(), 112) + '.bak'
WITH FORMAT, COMPRESSION;
```

#### Step 2: Update Connection String
Update `appsettings.json` or environment variable:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=test-server;Database=MedicineDelivery_Test;User Id=test-user;Password=test-password;TrustServerCertificate=True;"
  }
}
```

#### Step 3: Apply Migrations
```powershell
# Apply all pending migrations
dotnet ef database update --context ApplicationDbContext --project MedicineDelivery.Infrastructure --startup-project MedicineDelivery.API
```

#### Step 4: Verify in Test Environment
- Test all endpoints
- Verify data integrity
- Test user registration
- Test role/permission assignments

#### Step 5: Run Integration Tests
```powershell
# If you have integration tests
dotnet test
```

---

### Phase 3: Production Environment

#### Step 1: Backup Production Database ⚠️ **CRITICAL**
```sql
-- Full backup with verification
BACKUP DATABASE [MedicineDelivery_Production] 
TO DISK = '\\BackupServer\Backups\MedicineDelivery_Production_Backup_' + CONVERT(VARCHAR, GETDATE(), 112) + '_' + REPLACE(CONVERT(VARCHAR, GETDATE(), 108), ':', '') + '.bak'
WITH FORMAT, COMPRESSION, CHECKSUM, INIT;

-- Verify backup
RESTORE VERIFYONLY 
FROM DISK = '\\BackupServer\Backups\MedicineDelivery_Production_Backup_[timestamp].bak';
```

#### Step 2: Create Migration Script (Recommended)
```powershell
# Generate SQL script instead of direct update
dotnet ef migrations script --context ApplicationDbContext --project MedicineDelivery.Infrastructure --startup-project MedicineDelivery.API --output migration_script.sql
```

#### Step 3: Review SQL Script
- Open `migration_script.sql`
- Review all changes
- Check for data loss warnings
- Verify seed data insertions

#### Step 4: Apply to Production (Option A: Using Script)
```sql
-- Execute script in SQL Server Management Studio
-- Review output for errors
```

#### Step 4: Apply to Production (Option B: Direct Update)
```powershell
# Set production connection string as environment variable
$env:ConnectionStrings__DefaultConnection = "Server=prod-server;Database=MedicineDelivery_Prod;User Id=prod-user;Password=prod-password;TrustServerCertificate=True;"

# Apply migrations
dotnet ef database update --context ApplicationDbContext --project MedicineDelivery.Infrastructure --startup-project MedicineDelivery.API
```

#### Step 5: Post-Migration Verification
- ✅ Check database schema matches expectations
- ✅ Verify all tables exist
- ✅ Verify seed data applied (roles, permissions, admin user)
- ✅ Test critical endpoints
- ✅ Monitor application logs for errors

---

## 🔄 Rollback Procedures

### Option 1: Rollback Last Migration
```powershell
# Remove last migration from database
dotnet ef database update [PreviousMigrationName] --context ApplicationDbContext --project MedicineDelivery.Infrastructure --startup-project MedicineDelivery.API

# Remove migration files
Remove-Item -Path "Migrations\[Timestamp]_[MigrationName].cs"
Remove-Item -Path "Migrations\[Timestamp]_[MigrationName].Designer.cs"
```

### Option 2: Restore from Backup
```sql
-- Restore database from backup (USE WITH CAUTION)
RESTORE DATABASE [MedicineDelivery_Production] 
FROM DISK = '\\BackupServer\Backups\MedicineDelivery_Production_Backup_[timestamp].bak'
WITH REPLACE, NORECOVERY;

RESTORE DATABASE [MedicineDelivery_Production] WITH RECOVERY;
```

---

## ✅ Best Practices

### 1. Migration Naming Convention
```
[Timestamp]_[DescriptiveName].cs
Example: 20250115120000_AddOrderHistoryTable.cs
```

### 2. Migration Checklist
- [ ] Migration name is descriptive
- [ ] Migration is reversible (has Down method)
- [ ] No data loss in migration
- [ ] Seed data migrations are idempotent
- [ ] Tested in Development first
- [ ] Reviewed SQL script before Production
- [ ] Backup created before Production migration

### 3. Seed Data Strategy
- Seed data should be in `OnModelCreating` method
- Use `HasData()` for initial data
- Ensure seed data is idempotent
- Roles and Permissions should always be seeded

### 4. Schema Changes
- **Adding Columns**: Use nullable columns or provide defaults
- **Removing Columns**: Create migration, verify no dependencies
- **Renaming Columns**: Use `RenameColumn()` instead of drop/add
- **Changing Types**: Be careful with data loss warnings

### 5. Performance Considerations
- Large data migrations should be done during maintenance window
- Consider splitting large migrations into multiple smaller ones
- Use transactions for data migrations
- Test migration duration in Test environment first

---

## 📊 Migration Status Commands

### Check Pending Migrations
```powershell
dotnet ef migrations list --context ApplicationDbContext --project MedicineDelivery.Infrastructure --startup-project MedicineDelivery.API
```

### Check Applied Migrations (in database)
```sql
SELECT * FROM __EFMigrationsHistory ORDER BY MigrationId;
```

### Generate Script for Specific Migration
```powershell
dotnet ef migrations script [FromMigration] [ToMigration] --context ApplicationDbContext --project MedicineDelivery.Infrastructure --startup-project MedicineDelivery.API --output script.sql
```

---

## 🚨 Troubleshooting

### Issue: Migration conflicts
**Solution**: Remove conflicting migrations and recreate

### Issue: Seed data not applied
**Solution**: Ensure `OnModelCreating` includes seed data and migration includes `HasData()`

### Issue: Connection string errors
**Solution**: Verify connection string format and SQL Server accessibility

### Issue: Migration timeout
**Solution**: Increase command timeout in DbContext options or split migration

---

## 📅 Recommended Schedule

- **Development**: Migrations applied immediately as needed
- **Test/Staging**: Migrations applied weekly or before testing cycles
- **Production**: Migrations applied during scheduled maintenance windows

---

## 📞 Support

For migration issues:
1. Check application logs
2. Review migration script output
3. Verify database connection
4. Check EF Core migration history table

---

**Last Updated**: 2025-01-15
**Version**: 1.0


