-- Script to drop redundant tables from PostgreSQL database
-- Run this script directly on your PostgreSQL database

-- First, drop foreign key constraints
ALTER TABLE "Customers" DROP CONSTRAINT IF EXISTS "FK_Customers_Users_UserId";
ALTER TABLE "CustomerSupports" DROP CONSTRAINT IF EXISTS "FK_CustomerSupports_Users_UserId";
ALTER TABLE "Managers" DROP CONSTRAINT IF EXISTS "FK_Managers_Users_UserId";
ALTER TABLE "MedicalStores" DROP CONSTRAINT IF EXISTS "FK_MedicalStores_Users_UserId";
ALTER TABLE "RolePermissions" DROP CONSTRAINT IF EXISTS "FK_RolePermissions_Roles_RoleId";

-- Drop the redundant tables
DROP TABLE IF EXISTS "UserRoles";
DROP TABLE IF EXISTS "Roles";
DROP TABLE IF EXISTS "Users";

-- First, clear existing RolePermissions data since RoleId format is different
DELETE FROM "RolePermissions";

-- Update RolePermissions table to use string RoleId if it's still integer
ALTER TABLE "RolePermissions" ALTER COLUMN "RoleId" TYPE text;

-- Add foreign key constraints to AspNetUsers and AspNetRoles
ALTER TABLE "Customers" ADD CONSTRAINT "FK_Customers_AspNetUsers_UserId" 
    FOREIGN KEY ("UserId") REFERENCES "AspNetUsers"("Id") ON DELETE CASCADE;

ALTER TABLE "CustomerSupports" ADD CONSTRAINT "FK_CustomerSupports_AspNetUsers_UserId" 
    FOREIGN KEY ("UserId") REFERENCES "AspNetUsers"("Id") ON DELETE CASCADE;

ALTER TABLE "Managers" ADD CONSTRAINT "FK_Managers_AspNetUsers_UserId" 
    FOREIGN KEY ("UserId") REFERENCES "AspNetUsers"("Id") ON DELETE CASCADE;

ALTER TABLE "MedicalStores" ADD CONSTRAINT "FK_MedicalStores_AspNetUsers_UserId" 
    FOREIGN KEY ("UserId") REFERENCES "AspNetUsers"("Id") ON DELETE CASCADE;

ALTER TABLE "RolePermissions" ADD CONSTRAINT "FK_RolePermissions_AspNetRoles_RoleId" 
    FOREIGN KEY ("RoleId") REFERENCES "AspNetRoles"("Id") ON DELETE CASCADE;

-- Insert Identity roles if they don't exist and get their actual IDs
INSERT INTO "AspNetRoles" ("Id", "Name", "NormalizedName", "ConcurrencyStamp")
VALUES 
    ('1', 'Admin', 'ADMIN', gen_random_uuid()::text),
    ('2', 'Manager', 'MANAGER', gen_random_uuid()::text),
    ('3', 'Chemist', 'CHEMIST', gen_random_uuid()::text),
    ('4', 'Customer', 'CUSTOMER', gen_random_uuid()::text),
    ('5', 'CustomerSupport', 'CUSTOMERSUPPORT', gen_random_uuid()::text)
ON CONFLICT ("NormalizedName") DO NOTHING;

-- Insert role permissions using the actual role IDs from AspNetRoles table
-- Admin role permissions
INSERT INTO "RolePermissions" ("PermissionId", "RoleId", "GrantedAt", "IsActive")
SELECT 1, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 2, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 3, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 4, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 5, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 6, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 7, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 8, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 9, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 10, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 11, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 12, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 13, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 14, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 15, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 16, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 17, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 18, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 19, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 20, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 21, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 22, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 23, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 24, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 25, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 26, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 27, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 28, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 29, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 30, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 31, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 32, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 33, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 34, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 35, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 36, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 37, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 38, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 39, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 40, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 41, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 43, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 46, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 47, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 48, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 49, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 50, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
UNION ALL
SELECT 51, "Id", NOW(), true FROM "AspNetRoles" WHERE "NormalizedName" = 'ADMIN'
ON CONFLICT ("RoleId", "PermissionId") DO NOTHING;
