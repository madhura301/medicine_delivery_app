-- =====================================================
-- Update Role Data with Proper GUIDs Script
-- Medicine Delivery Application
-- Generated: 2025-10-05
-- =====================================================

-- This script updates the role and role permission data to use proper GUIDs
-- instead of simple string values for ASP.NET Core Identity compatibility

BEGIN TRANSACTION;

-- =====================================================
-- Step 1: Clear existing role permission data
-- =====================================================
PRINT 'Clearing existing role permission data...';
DELETE FROM "RolePermissions";

-- =====================================================
-- Step 2: Clear existing identity roles
-- =====================================================
PRINT 'Clearing existing identity roles...';
DELETE FROM "AspNetRoles";

-- =====================================================
-- Step 3: Insert new identity roles with proper GUIDs
-- =====================================================
PRINT 'Inserting new identity roles with proper GUIDs...';

INSERT INTO "AspNetRoles" ("Id", "Name", "NormalizedName", "ConcurrencyStamp")
VALUES 
    ('11111111-1111-1111-1111-111111111111', 'Admin', 'ADMIN', 'eb3b6bd2-e740-45bd-91b5-a5627c4ab27d'),
    ('22222222-2222-2222-2222-222222222222', 'Manager', 'MANAGER', '38424e1e-b8df-4484-bb7c-2b01feecebe4'),
    ('33333333-3333-3333-3333-333333333333', 'CustomerSupport', 'CUSTOMERSUPPORT', 'ff9cf118-d192-4c50-900c-8eb5c92d5288'),
    ('44444444-4444-4444-4444-444444444444', 'Customer', 'CUSTOMER', '8c8930a9-68c0-4849-a307-0f8be968d489'),
    ('55555555-5555-5555-5555-555555555555', 'Chemist', 'CHEMIST', '79ec17b2-a6fc-4709-bfaf-71308fa70fd1');

-- =====================================================
-- Step 4: Insert role permission mappings
-- =====================================================
PRINT 'Inserting role permission mappings...';

-- Admin Role Permissions (RoleId: 11111111-1111-1111-1111-111111111111)
INSERT INTO "RolePermissions" ("PermissionId", "RoleId", "GrantedAt", "GrantedBy", "IsActive")
VALUES 
    (1, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (2, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (3, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (4, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (5, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (6, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (7, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (8, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (9, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (10, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (11, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (12, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (13, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (14, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (15, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (16, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (17, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (18, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (19, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (20, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (21, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (22, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (23, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (24, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (25, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (26, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (27, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (28, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (29, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (30, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (31, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (32, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (33, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (34, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (35, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (36, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (37, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (38, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (39, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (40, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (41, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (43, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (46, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (47, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (48, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (49, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (50, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true),
    (51, '11111111-1111-1111-1111-111111111111', NOW(), NULL, true);

-- Manager Role Permissions (RoleId: 22222222-2222-2222-2222-222222222222)
INSERT INTO "RolePermissions" ("PermissionId", "RoleId", "GrantedAt", "GrantedBy", "IsActive")
VALUES 
    (1, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (3, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (5, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (7, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (9, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (11, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (17, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (18, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (19, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (20, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (21, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (22, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (23, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (24, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (25, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (26, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (27, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (28, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (30, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (31, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (32, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (33, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (34, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (35, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (36, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (37, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (38, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (40, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (41, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (43, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (46, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (47, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (48, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (49, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (50, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true),
    (51, '22222222-2222-2222-2222-222222222222', NOW(), NULL, true);

-- CustomerSupport Role Permissions (RoleId: 33333333-3333-3333-3333-333333333333)
INSERT INTO "RolePermissions" ("PermissionId", "RoleId", "GrantedAt", "GrantedBy", "IsActive")
VALUES 
    (5, '33333333-3333-3333-3333-333333333333', NOW(), NULL, true),
    (9, '33333333-3333-3333-3333-333333333333', NOW(), NULL, true),
    (10, '33333333-3333-3333-3333-333333333333', NOW(), NULL, true),
    (21, '33333333-3333-3333-3333-333333333333', NOW(), NULL, true),
    (22, '33333333-3333-3333-3333-333333333333', NOW(), NULL, true),
    (23, '33333333-3333-3333-3333-333333333333', NOW(), NULL, true),
    (24, '33333333-3333-3333-3333-333333333333', NOW(), NULL, true),
    (25, '33333333-3333-3333-3333-333333333333', NOW(), NULL, true),
    (26, '33333333-3333-3333-3333-333333333333', NOW(), NULL, true),
    (27, '33333333-3333-3333-3333-333333333333', NOW(), NULL, true),
    (28, '33333333-3333-3333-3333-333333333333', NOW(), NULL, true),
    (30, '33333333-3333-3333-3333-333333333333', NOW(), NULL, true),
    (31, '33333333-3333-3333-3333-333333333333', NOW(), NULL, true),
    (32, '33333333-3333-3333-3333-333333333333', NOW(), NULL, true),
    (33, '33333333-3333-3333-3333-333333333333', NOW(), NULL, true),
    (34, '33333333-3333-3333-3333-333333333333', NOW(), NULL, true),
    (36, '33333333-3333-3333-3333-333333333333', NOW(), NULL, true),
    (37, '33333333-3333-3333-3333-333333333333', NOW(), NULL, true),
    (43, '33333333-3333-3333-3333-333333333333', NOW(), NULL, true),
    (46, '33333333-3333-3333-3333-333333333333', NOW(), NULL, true),
    (47, '33333333-3333-3333-3333-333333333333', NOW(), NULL, true),
    (48, '33333333-3333-3333-3333-333333333333', NOW(), NULL, true),
    (49, '33333333-3333-3333-3333-333333333333', NOW(), NULL, true),
    (50, '33333333-3333-3333-3333-333333333333', NOW(), NULL, true),
    (51, '33333333-3333-3333-3333-333333333333', NOW(), NULL, true);

-- Customer Role Permissions (RoleId: 44444444-4444-4444-4444-444444444444)
INSERT INTO "RolePermissions" ("PermissionId", "RoleId", "GrantedAt", "GrantedBy", "IsActive")
VALUES 
    (5, '44444444-4444-4444-4444-444444444444', NOW(), NULL, true),
    (9, '44444444-4444-4444-4444-444444444444', NOW(), NULL, true),
    (10, '44444444-4444-4444-4444-444444444444', NOW(), NULL, true),
    (42, '44444444-4444-4444-4444-444444444444', NOW(), NULL, true),
    (44, '44444444-4444-4444-4444-444444444444', NOW(), NULL, true),
    (45, '44444444-4444-4444-4444-444444444444', NOW(), NULL, true);

-- Chemist Role Permissions (RoleId: 55555555-5555-5555-5555-555555555555)
INSERT INTO "RolePermissions" ("PermissionId", "RoleId", "GrantedAt", "GrantedBy", "IsActive")
VALUES 
    (5, '55555555-5555-5555-5555-555555555555', NOW(), NULL, true),
    (6, '55555555-5555-5555-5555-555555555555', NOW(), NULL, true),
    (7, '55555555-5555-5555-5555-555555555555', NOW(), NULL, true),
    (8, '55555555-5555-5555-5555-555555555555', NOW(), NULL, true),
    (9, '55555555-5555-5555-5555-555555555555', NOW(), NULL, true),
    (10, '55555555-5555-5555-5555-555555555555', NOW(), NULL, true),
    (11, '55555555-5555-5555-5555-555555555555', NOW(), NULL, true),
    (12, '55555555-5555-5555-5555-555555555555', NOW(), NULL, true),
    (30, '55555555-5555-5555-5555-555555555555', NOW(), NULL, true),
    (32, '55555555-5555-5555-5555-555555555555', NOW(), NULL, true),
    (33, '55555555-5555-5555-5555-555555555555', NOW(), NULL, true);

-- =====================================================
-- Step 5: Update existing user role assignments (if any)
-- =====================================================
PRINT 'Updating existing user role assignments...';

-- Update any existing user role assignments to use new GUIDs
-- Note: This assumes you have existing user role assignments that need to be updated
-- If you don't have existing assignments, these statements will have no effect

UPDATE "AspNetUserRoles" 
SET "RoleId" = '11111111-1111-1111-1111-111111111111' 
WHERE "RoleId" = '1';

UPDATE "AspNetUserRoles" 
SET "RoleId" = '22222222-2222-2222-2222-222222222222' 
WHERE "RoleId" = '2';

UPDATE "AspNetUserRoles" 
SET "RoleId" = '33333333-3333-3333-3333-333333333333' 
WHERE "RoleId" = '3';

UPDATE "AspNetUserRoles" 
SET "RoleId" = '44444444-4444-4444-4444-444444444444' 
WHERE "RoleId" = '4';

UPDATE "AspNetUserRoles" 
SET "RoleId" = '55555555-5555-5555-5555-555555555555' 
WHERE "RoleId" = '5';

-- =====================================================
-- Step 6: Verification queries
-- =====================================================
PRINT 'Verification completed. Checking results...';

-- Verify roles were inserted correctly
SELECT 'AspNetRoles' as TableName, COUNT(*) as RecordCount FROM "AspNetRoles";
SELECT 'RolePermissions' as TableName, COUNT(*) as RecordCount FROM "RolePermissions";

-- Show role summary
SELECT 
    r."Name" as RoleName,
    COUNT(rp."PermissionId") as PermissionCount
FROM "AspNetRoles" r
LEFT JOIN "RolePermissions" rp ON r."Id" = rp."RoleId"
GROUP BY r."Id", r."Name"
ORDER BY r."Name";

COMMIT TRANSACTION;

PRINT 'Role data update completed successfully!';
PRINT 'All roles now use proper GUID identifiers.';
PRINT 'Role permission mappings have been updated accordingly.';
