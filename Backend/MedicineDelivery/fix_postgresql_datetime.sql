-- Fix PostgreSQL DateTime columns to use timestamp with time zone
-- This script addresses the error: "Cannot write DateTime with Kind=UTC to PostgreSQL type 'timestamp without time zone'"

-- Update MedicalStore DateTime columns
ALTER TABLE "MedicalStores" 
ALTER COLUMN "CreatedOn" TYPE timestamp with time zone USING "CreatedOn" AT TIME ZONE 'UTC';

ALTER TABLE "MedicalStores" 
ALTER COLUMN "UpdatedOn" TYPE timestamp with time zone USING "UpdatedOn" AT TIME ZONE 'UTC';

-- Update CustomerSupport DateTime columns
ALTER TABLE "CustomerSupports" 
ALTER COLUMN "CreatedOn" TYPE timestamp with time zone USING "CreatedOn" AT TIME ZONE 'UTC';

ALTER TABLE "CustomerSupports" 
ALTER COLUMN "UpdatedOn" TYPE timestamp with time zone USING "UpdatedOn" AT TIME ZONE 'UTC';

-- Update Manager DateTime columns
ALTER TABLE "Managers" 
ALTER COLUMN "CreatedOn" TYPE timestamp with time zone USING "CreatedOn" AT TIME ZONE 'UTC';

ALTER TABLE "Managers" 
ALTER COLUMN "UpdatedOn" TYPE timestamp with time zone USING "UpdatedOn" AT TIME ZONE 'UTC';

-- Update Customer DateTime columns
ALTER TABLE "Customers" 
ALTER COLUMN "CreatedOn" TYPE timestamp with time zone USING "CreatedOn" AT TIME ZONE 'UTC';

ALTER TABLE "Customers" 
ALTER COLUMN "UpdatedOn" TYPE timestamp with time zone USING "UpdatedOn" AT TIME ZONE 'UTC';

-- Update ApplicationUser DateTime columns (from AspNetUsers table)
ALTER TABLE "AspNetUsers" 
ALTER COLUMN "CreatedAt" TYPE timestamp with time zone USING "CreatedAt" AT TIME ZONE 'UTC';

ALTER TABLE "AspNetUsers" 
ALTER COLUMN "LastLoginAt" TYPE timestamp with time zone USING "LastLoginAt" AT TIME ZONE 'UTC';

-- Update User DateTime columns
ALTER TABLE "Users" 
ALTER COLUMN "CreatedAt" TYPE timestamp with time zone USING "CreatedAt" AT TIME ZONE 'UTC';

-- Update UserRole DateTime columns
ALTER TABLE "UserRoles" 
ALTER COLUMN "AssignedAt" TYPE timestamp with time zone USING "AssignedAt" AT TIME ZONE 'UTC';

-- Update RolePermission DateTime columns
ALTER TABLE "RolePermissions" 
ALTER COLUMN "GrantedAt" TYPE timestamp with time zone USING "GrantedAt" AT TIME ZONE 'UTC';

-- Update Permission DateTime columns
ALTER TABLE "Permissions" 
ALTER COLUMN "CreatedAt" TYPE timestamp with time zone USING "CreatedAt" AT TIME ZONE 'UTC';

-- Update Role DateTime columns
ALTER TABLE "Roles" 
ALTER COLUMN "CreatedAt" TYPE timestamp with time zone USING "CreatedAt" AT TIME ZONE 'UTC';

-- Update Product DateTime columns
ALTER TABLE "Products" 
ALTER COLUMN "CreatedAt" TYPE timestamp with time zone USING "CreatedAt" AT TIME ZONE 'UTC';

ALTER TABLE "Products" 
ALTER COLUMN "UpdatedAt" TYPE timestamp with time zone USING "UpdatedAt" AT TIME ZONE 'UTC';

-- Update Order DateTime columns
ALTER TABLE "Orders" 
ALTER COLUMN "CreatedAt" TYPE timestamp with time zone USING "CreatedAt" AT TIME ZONE 'UTC';

ALTER TABLE "Orders" 
ALTER COLUMN "UpdatedAt" TYPE timestamp with time zone USING "UpdatedAt" AT TIME ZONE 'UTC';

-- Note: After running this script, you should also update the Entity Framework configuration
-- to use 'timestamp with time zone' for all DateTime properties in your DbContext configuration.
