-- Migration Script: Add CustomerAddress Table
-- Generated from: 20250928150145_AddCustomerAddressTable
-- Description: Creates CustomerAddresses table and removes address columns from Customers table

-- =============================================
-- STEP 1: Remove address columns from Customers table
-- =============================================

-- Drop address columns from Customers table
ALTER TABLE "Customers" DROP COLUMN IF EXISTS "Address";
ALTER TABLE "Customers" DROP COLUMN IF EXISTS "City";
ALTER TABLE "Customers" DROP COLUMN IF EXISTS "State";
ALTER TABLE "Customers" DROP COLUMN IF EXISTS "PostalCode";

-- =============================================
-- STEP 2: Create CustomerAddresses table
-- =============================================

-- Create CustomerAddresses table
CREATE TABLE "CustomerAddresses" (
    "Id" uuid NOT NULL,
    "CustomerId" uuid NOT NULL,
    "Address" character varying(300) NULL,
    "City" character varying(100) NULL,
    "State" character varying(100) NULL,
    "PostalCode" character varying(20) NULL,
    "IsDefault" boolean NOT NULL,
    "IsActive" boolean NOT NULL,
    "CreatedOn" timestamp with time zone NOT NULL,
    "UpdatedOn" timestamp with time zone NULL,
    CONSTRAINT "PK_CustomerAddresses" PRIMARY KEY ("Id")
);

-- =============================================
-- STEP 3: Create foreign key constraint
-- =============================================

-- Add foreign key constraint
ALTER TABLE "CustomerAddresses" 
ADD CONSTRAINT "FK_CustomerAddresses_Customers_CustomerId" 
FOREIGN KEY ("CustomerId") 
REFERENCES "Customers" ("CustomerId") 
ON DELETE CASCADE;

-- =============================================
-- STEP 4: Create index for performance
-- =============================================

-- Create index on CustomerId for better query performance
CREATE INDEX "IX_CustomerAddresses_CustomerId" ON "CustomerAddresses" ("CustomerId");

-- =============================================
-- STEP 5: Update timestamp columns (if needed)
-- =============================================

-- Update timestamp columns to use timezone-aware timestamps
-- Note: These changes may already be applied in your database
-- Uncomment only if you need to update existing timestamp columns

-- ALTER TABLE "MedicalStores" ALTER COLUMN "UpdatedOn" TYPE timestamp with time zone;
-- ALTER TABLE "MedicalStores" ALTER COLUMN "CreatedOn" TYPE timestamp with time zone;
-- ALTER TABLE "Managers" ALTER COLUMN "UpdatedOn" TYPE timestamp with time zone;
-- ALTER TABLE "Managers" ALTER COLUMN "CreatedOn" TYPE timestamp with time zone;
-- ALTER TABLE "CustomerSupports" ALTER COLUMN "UpdatedOn" TYPE timestamp with time zone;
-- ALTER TABLE "CustomerSupports" ALTER COLUMN "CreatedOn" TYPE timestamp with time zone;
-- ALTER TABLE "Customers" ALTER COLUMN "UpdatedOn" TYPE timestamp with time zone;
-- ALTER TABLE "Customers" ALTER COLUMN "CreatedOn" TYPE timestamp with time zone;

-- =============================================
-- VERIFICATION QUERIES
-- =============================================

-- Verify the table was created successfully
SELECT 
    table_name, 
    column_name, 
    data_type, 
    is_nullable,
    character_maximum_length
FROM information_schema.columns 
WHERE table_name = 'CustomerAddresses' 
ORDER BY ordinal_position;

-- Verify foreign key constraint
SELECT 
    tc.constraint_name, 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
    AND tc.table_name = 'CustomerAddresses';

-- Verify index was created
SELECT 
    indexname, 
    tablename, 
    indexdef 
FROM pg_indexes 
WHERE tablename = 'CustomerAddresses';

-- =============================================
-- ROLLBACK SCRIPT (if needed)
-- =============================================

/*
-- To rollback this migration, run the following:

-- Drop the CustomerAddresses table
DROP TABLE IF EXISTS "CustomerAddresses";

-- Add back address columns to Customers table
ALTER TABLE "Customers" ADD COLUMN "Address" character varying(300) NULL;
ALTER TABLE "Customers" ADD COLUMN "City" character varying(100) NULL;
ALTER TABLE "Customers" ADD COLUMN "State" character varying(100) NULL;
ALTER TABLE "Customers" ADD COLUMN "PostalCode" character varying(20) NULL;
*/
