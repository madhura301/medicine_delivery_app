---
name: add-migration
description: Create and apply an EF Core database migration
user_invocable: true
---

# Add Migration Skill

When the user invokes `/add-migration <MigrationName>`, create and optionally apply an EF Core migration.

## Steps

1. Navigate to the backend solution directory: `Backend/MedicineDelivery`

2. Create the migration:
   ```bash
   cd Backend/MedicineDelivery && dotnet ef migrations add {MigrationName} --project MedicineDelivery.Infrastructure --startup-project MedicineDelivery.API
   ```

3. Show the user the generated migration file for review.

4. Ask the user if they want to apply it immediately.

5. If yes, apply:
   ```bash
   cd Backend/MedicineDelivery && dotnet ef database update --project MedicineDelivery.Infrastructure --startup-project MedicineDelivery.API
   ```

6. If the migration fails, diagnose the issue (missing DbSet, entity configuration errors, etc.) and help fix it.

## Rules
- Never edit auto-generated migration files
- Always show the migration to the user before applying
- If there are pending model changes, warn the user
