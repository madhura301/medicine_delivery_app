-- Migration script to add AddressLine1, AddressLine2, AddressLine3 to CustomerAddresses table
-- This script adds the new address line columns to support more detailed address information

-- Add the new address line columns
ALTER TABLE "CustomerAddresses" 
ADD COLUMN "AddressLine1" VARCHAR(255) NULL,
ADD COLUMN "AddressLine2" VARCHAR(255) NULL,
ADD COLUMN "AddressLine3" VARCHAR(255) NULL;

-- Add comments to document the new columns
COMMENT ON COLUMN "CustomerAddresses"."AddressLine1" IS 'First address line (e.g., Building name, Apartment number)';
COMMENT ON COLUMN "CustomerAddresses"."AddressLine2" IS 'Second address line (e.g., Floor, Unit number)';
COMMENT ON COLUMN "CustomerAddresses"."AddressLine3" IS 'Third address line (e.g., Additional location details)';

-- Optional: Update existing records to populate the new columns with data from the main Address field
-- This is a sample migration - you may want to customize this based on your existing data
UPDATE "CustomerAddresses" 
SET 
    "AddressLine1" = CASE 
        WHEN "Address" LIKE '%Building%' OR "Address" LIKE '%Apt%' OR "Address" LIKE '%Unit%' 
        THEN SUBSTRING("Address" FROM 1 FOR LEAST(255, POSITION(',' IN "Address") - 1))
        ELSE NULL 
    END,
    "AddressLine2" = CASE 
        WHEN "Address" LIKE '%Floor%' OR "Address" LIKE '%Level%' 
        THEN SUBSTRING("Address" FROM POSITION(',' IN "Address") + 1 FOR LEAST(255, POSITION(',' IN SUBSTRING("Address" FROM POSITION(',' IN "Address") + 1)) - 1))
        ELSE NULL 
    END
WHERE "Address" IS NOT NULL AND "Address" != '';

-- Verify the migration
SELECT 
    "Id",
    "Address",
    "AddressLine1",
    "AddressLine2", 
    "AddressLine3",
    "City",
    "State",
    "PostalCode"
FROM "CustomerAddresses" 
LIMIT 5;

-- Show migration completion message
DO $$
BEGIN
    RAISE NOTICE 'CustomerAddress migration completed successfully!';
    RAISE NOTICE 'Added columns: AddressLine1, AddressLine2, AddressLine3';
    RAISE NOTICE 'Total CustomerAddresses records: %', (SELECT COUNT(*) FROM "CustomerAddresses");
END $$;
