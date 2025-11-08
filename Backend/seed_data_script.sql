-- =====================================================
-- MEDICINE DELIVERY APPLICATION - SEED DATA SCRIPT
-- Database: PostgreSQL
-- =====================================================
-- This script seeds all initial data required for the application
-- Including: Roles, Permissions, Role-Permissions, Users, and User-Roles
-- =====================================================

-- Start Transaction
BEGIN;

-- =====================================================
-- SECTION 1: IDENTITY ROLES (AspNetRoles)
-- =====================================================
-- Insert Identity Roles with predefined GUIDs for consistency
INSERT INTO "AspNetRoles" ("Id", "Name", "NormalizedName", "ConcurrencyStamp")
VALUES 
    ('11111111-1111-1111-1111-111111111111', 'Admin', 'ADMIN', 'c7e4c8d1-1234-5678-90ab-cdef12345678'),
    ('22222222-2222-2222-2222-222222222222', 'Manager', 'MANAGER', 'c7e4c8d1-1234-5678-90ab-cdef12345679'),
    ('33333333-3333-3333-3333-333333333333', 'CustomerSupport', 'CUSTOMERSUPPORT', 'c7e4c8d1-1234-5678-90ab-cdef12345680'),
    ('44444444-4444-4444-4444-444444444444', 'Customer', 'CUSTOMER', 'c7e4c8d1-1234-5678-90ab-cdef12345681'),
    ('55555555-5555-5555-5555-555555555555', 'Chemist', 'CHEMIST', 'c7e4c8d1-1234-5678-90ab-cdef12345682')
ON CONFLICT ("Id") DO NOTHING;

-- =====================================================
-- SECTION 2: PERMISSIONS
-- =====================================================
-- Insert all 51 permissions
INSERT INTO "Permissions" ("Id", "Name", "Description", "Module", "CreatedAt", "IsActive")
VALUES 
    -- Original Base Permissions (1-12)
    (1, 'ReadUsers', 'Can view user information', 'Users', NOW(), true),
    (2, 'CreateUsers', 'Can create new users', 'Users', NOW(), true),
    (3, 'UpdateUsers', 'Can update user information', 'Users', NOW(), true),
    (4, 'DeleteUsers', 'Can delete users', 'Users', NOW(), true),
    (5, 'ReadProducts', 'Can view products', 'Products', NOW(), true),
    (6, 'CreateProducts', 'Can create new products', 'Products', NOW(), true),
    (7, 'UpdateProducts', 'Can update products', 'Products', NOW(), true),
    (8, 'DeleteProducts', 'Can delete products', 'Products', NOW(), true),
    (9, 'ReadOrders', 'Can view orders', 'Orders', NOW(), true),
    (10, 'CreateOrders', 'Can create new orders', 'Orders', NOW(), true),
    (11, 'UpdateOrders', 'Can update orders', 'Orders', NOW(), true),
    (12, 'DeleteOrders', 'Can delete orders', 'Orders', NOW(), true),
    
    -- Admin User Management Permissions (13-16)
    (13, 'AdminReadUsers', 'Admin can view all user information', 'UserManagement', NOW(), true),
    (14, 'AdminCreateUsers', 'Admin can create users', 'UserManagement', NOW(), true),
    (15, 'AdminUpdateUsers', 'Admin can update user information', 'UserManagement', NOW(), true),
    (16, 'AdminDeleteUsers', 'Admin can delete users', 'UserManagement', NOW(), true),
    
    -- Manager User Management Permissions (17-20)
    (17, 'ManagerReadUsers', 'Manager can view user information', 'UserManagement', NOW(), true),
    (18, 'ManagerCreateUsers', 'Manager can create users', 'UserManagement', NOW(), true),
    (19, 'ManagerUpdateUsers', 'Manager can update user information', 'UserManagement', NOW(), true),
    (20, 'ManagerDeleteUsers', 'Manager can delete users', 'UserManagement', NOW(), true),
    
    -- CustomerSupport User Management Permissions (21-24)
    (21, 'CustomerSupportReadUsers', 'CustomerSupport can view user information', 'UserManagement', NOW(), true),
    (22, 'CustomerSupportCreateUsers', 'CustomerSupport can create users', 'UserManagement', NOW(), true),
    (23, 'CustomerSupportUpdateUsers', 'CustomerSupport can update user information', 'UserManagement', NOW(), true),
    (24, 'CustomerSupportDeleteUsers', 'CustomerSupport can delete users', 'UserManagement', NOW(), true),
    
    -- Chemist User Management Permissions (25-28)
    (25, 'ChemistReadUsers', 'Chemist can view user information', 'UserManagement', NOW(), true),
    (26, 'ChemistCreateUsers', 'Chemist can create users', 'UserManagement', NOW(), true),
    (27, 'ChemistUpdateUsers', 'Chemist can update user information', 'UserManagement', NOW(), true),
    (28, 'ChemistDeleteUsers', 'Chemist can delete users', 'UserManagement', NOW(), true),
    
    -- Role Permission Management Permission (29)
    (29, 'ManageRolePermission', 'Can manage role permissions', 'RoleManagement', NOW(), true),
    
    -- Chemist CRUD Permissions (30-33)
    (30, 'ChemistRead', 'Can read chemist information', 'Chemist', NOW(), true),
    (31, 'ChemistCreate', 'Can create chemist accounts', 'Chemist', NOW(), true),
    (32, 'ChemistUpdate', 'Can update chemist information', 'Chemist', NOW(), true),
    (33, 'ChemistDelete', 'Can delete chemist accounts', 'Chemist', NOW(), true),
    
    -- CustomerSupport CRUD Permissions (34-37)
    (34, 'CustomerSupportRead', 'Can read customer support information', 'CustomerSupport', NOW(), true),
    (35, 'CustomerSupportCreate', 'Can create customer support accounts', 'CustomerSupport', NOW(), true),
    (36, 'CustomerSupportUpdate', 'Can update customer support information', 'CustomerSupport', NOW(), true),
    (37, 'CustomerSupportDelete', 'Can delete customer support accounts', 'CustomerSupport', NOW(), true),
    
    -- Manager CRUD Permissions (38-41)
    (38, 'ManagerSupportRead', 'Can read manager information', 'Manager', NOW(), true),
    (39, 'ManagerSupportCreate', 'Can create manager accounts', 'Manager', NOW(), true),
    (40, 'ManagerSupportUpdate', 'Can update manager information', 'Manager', NOW(), true),
    (41, 'ManagerSupportDelete', 'Can delete manager accounts', 'Manager', NOW(), true),
    
    -- Customer CRUD Permissions - Own Records (42-45)
    (42, 'CustomerRead', 'Can read own customer information', 'Customer', NOW(), true),
    (43, 'CustomerCreate', 'Can create customer accounts', 'Customer', NOW(), true),
    (44, 'CustomerUpdate', 'Can update own customer information', 'Customer', NOW(), true),
    (45, 'CustomerDelete', 'Can delete own customer account', 'Customer', NOW(), true),
    
    -- All Customer CRUD Permissions - All Records (46-48)
    (46, 'AllCustomerRead', 'Can read all customer information', 'Customer', NOW(), true),
    (47, 'AllCustomerUpdate', 'Can update any customer information', 'Customer', NOW(), true),
    (48, 'AllCustomerDelete', 'Can delete any customer account', 'Customer', NOW(), true),
    
    -- All Chemist CRUD Permissions - All Records (49-51)
    (49, 'AllChemistRead', 'Can read all Chemist information', 'Chemist', NOW(), true),
    (50, 'AllChemistUpdate', 'Can update any Chemist information', 'Chemist', NOW(), true),
    (51, 'AllChemistDelete', 'Can delete any Chemist account', 'Chemist', NOW(), true)
ON CONFLICT ("Id") DO NOTHING;

-- =====================================================
-- SECTION 3: ROLE-PERMISSION MAPPINGS
-- =====================================================

-- Admin Role Permissions (Gets ALL permissions)
INSERT INTO "RolePermissions" ("RoleId", "PermissionId", "GrantedAt", "IsActive", "GrantedBy")
VALUES 
    -- Base Permissions (1-12)
    ('11111111-1111-1111-1111-111111111111', 1, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 2, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 3, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 4, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 5, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 6, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 7, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 8, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 9, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 10, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 11, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 12, NOW(), true, NULL),
    -- Admin User Management Permissions (13-16)
    ('11111111-1111-1111-1111-111111111111', 13, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 14, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 15, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 16, NOW(), true, NULL),
    -- Manager User Management Permissions (17-20)
    ('11111111-1111-1111-1111-111111111111', 17, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 18, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 19, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 20, NOW(), true, NULL),
    -- CustomerSupport User Management Permissions (21-24)
    ('11111111-1111-1111-1111-111111111111', 21, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 22, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 23, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 24, NOW(), true, NULL),
    -- Chemist User Management Permissions (25-28)
    ('11111111-1111-1111-1111-111111111111', 25, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 26, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 27, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 28, NOW(), true, NULL),
    -- Role Permission Management (29)
    ('11111111-1111-1111-1111-111111111111', 29, NOW(), true, NULL),
    -- Chemist CRUD Permissions (30-33)
    ('11111111-1111-1111-1111-111111111111', 30, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 31, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 32, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 33, NOW(), true, NULL),
    -- CustomerSupport CRUD Permissions (34-37)
    ('11111111-1111-1111-1111-111111111111', 34, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 35, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 36, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 37, NOW(), true, NULL),
    -- Manager CRUD Permissions (38-41)
    ('11111111-1111-1111-1111-111111111111', 38, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 39, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 40, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 41, NOW(), true, NULL),
    -- Customer Create (43)
    ('11111111-1111-1111-1111-111111111111', 43, NOW(), true, NULL),
    -- All Customer CRUD Permissions (46-48)
    ('11111111-1111-1111-1111-111111111111', 46, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 47, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 48, NOW(), true, NULL),
    -- All MedicalStore/Chemist CRUD Permissions (49-51)
    ('11111111-1111-1111-1111-111111111111', 49, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 50, NOW(), true, NULL),
    ('11111111-1111-1111-1111-111111111111', 51, NOW(), true, NULL)
ON CONFLICT ("RoleId", "PermissionId") DO NOTHING;

-- Manager Role Permissions
INSERT INTO "RolePermissions" ("RoleId", "PermissionId", "GrantedAt", "IsActive", "GrantedBy")
VALUES 
    -- Base Read and Update Permissions (1,3,5,7,9,11)
    ('22222222-2222-2222-2222-222222222222', 1, NOW(), true, NULL),
    ('22222222-2222-2222-2222-222222222222', 3, NOW(), true, NULL),
    ('22222222-2222-2222-2222-222222222222', 5, NOW(), true, NULL),
    ('22222222-2222-2222-2222-222222222222', 7, NOW(), true, NULL),
    ('22222222-2222-2222-2222-222222222222', 9, NOW(), true, NULL),
    ('22222222-2222-2222-2222-222222222222', 11, NOW(), true, NULL),
    -- Manager User Management Permissions (17-20)
    ('22222222-2222-2222-2222-222222222222', 17, NOW(), true, NULL),
    ('22222222-2222-2222-2222-222222222222', 18, NOW(), true, NULL),
    ('22222222-2222-2222-2222-222222222222', 19, NOW(), true, NULL),
    ('22222222-2222-2222-2222-222222222222', 20, NOW(), true, NULL),
    -- CustomerSupport User Management Permissions (21-24)
    ('22222222-2222-2222-2222-222222222222', 21, NOW(), true, NULL),
    ('22222222-2222-2222-2222-222222222222', 22, NOW(), true, NULL),
    ('22222222-2222-2222-2222-222222222222', 23, NOW(), true, NULL),
    ('22222222-2222-2222-2222-222222222222', 24, NOW(), true, NULL),
    -- Chemist User Management Permissions (25-28)
    ('22222222-2222-2222-2222-222222222222', 25, NOW(), true, NULL),
    ('22222222-2222-2222-2222-222222222222', 26, NOW(), true, NULL),
    ('22222222-2222-2222-2222-222222222222', 27, NOW(), true, NULL),
    ('22222222-2222-2222-2222-222222222222', 28, NOW(), true, NULL),
    -- Chemist CRUD Permissions (30-33)
    ('22222222-2222-2222-2222-222222222222', 30, NOW(), true, NULL),
    ('22222222-2222-2222-2222-222222222222', 31, NOW(), true, NULL),
    ('22222222-2222-2222-2222-222222222222', 32, NOW(), true, NULL),
    ('22222222-2222-2222-2222-222222222222', 33, NOW(), true, NULL),
    -- CustomerSupport CRUD Permissions (34-37)
    ('22222222-2222-2222-2222-222222222222', 34, NOW(), true, NULL),
    ('22222222-2222-2222-2222-222222222222', 35, NOW(), true, NULL),
    ('22222222-2222-2222-2222-222222222222', 36, NOW(), true, NULL),
    ('22222222-2222-2222-2222-222222222222', 37, NOW(), true, NULL),
    -- Manager Self-Management (38,40,41 - not 39, can't create other managers)
    ('22222222-2222-2222-2222-222222222222', 38, NOW(), true, NULL),
    ('22222222-2222-2222-2222-222222222222', 40, NOW(), true, NULL),
    ('22222222-2222-2222-2222-222222222222', 41, NOW(), true, NULL),
    -- Customer Create (43)
    ('22222222-2222-2222-2222-222222222222', 43, NOW(), true, NULL),
    -- All Customer CRUD Permissions (46-48)
    ('22222222-2222-2222-2222-222222222222', 46, NOW(), true, NULL),
    ('22222222-2222-2222-2222-222222222222', 47, NOW(), true, NULL),
    ('22222222-2222-2222-2222-222222222222', 48, NOW(), true, NULL),
    -- All MedicalStore/Chemist CRUD Permissions (49-51)
    ('22222222-2222-2222-2222-222222222222', 49, NOW(), true, NULL),
    ('22222222-2222-2222-2222-222222222222', 50, NOW(), true, NULL),
    ('22222222-2222-2222-2222-222222222222', 51, NOW(), true, NULL)
ON CONFLICT ("RoleId", "PermissionId") DO NOTHING;

-- CustomerSupport Role Permissions
INSERT INTO "RolePermissions" ("RoleId", "PermissionId", "GrantedAt", "IsActive", "GrantedBy")
VALUES 
    -- Read Products and Orders, Create Orders (5,9,10)
    ('33333333-3333-3333-3333-333333333333', 5, NOW(), true, NULL),
    ('33333333-3333-3333-3333-333333333333', 9, NOW(), true, NULL),
    ('33333333-3333-3333-3333-333333333333', 10, NOW(), true, NULL),
    -- CustomerSupport User Management Permissions (21-24)
    ('33333333-3333-3333-3333-333333333333', 21, NOW(), true, NULL),
    ('33333333-3333-3333-3333-333333333333', 22, NOW(), true, NULL),
    ('33333333-3333-3333-3333-333333333333', 23, NOW(), true, NULL),
    ('33333333-3333-3333-3333-333333333333', 24, NOW(), true, NULL),
    -- Chemist User Management Permissions (25-28)
    ('33333333-3333-3333-3333-333333333333', 25, NOW(), true, NULL),
    ('33333333-3333-3333-3333-333333333333', 26, NOW(), true, NULL),
    ('33333333-3333-3333-3333-333333333333', 27, NOW(), true, NULL),
    ('33333333-3333-3333-3333-333333333333', 28, NOW(), true, NULL),
    -- Chemist CRUD Permissions (30-33)
    ('33333333-3333-3333-3333-333333333333', 30, NOW(), true, NULL),
    ('33333333-3333-3333-3333-333333333333', 31, NOW(), true, NULL),
    ('33333333-3333-3333-3333-333333333333', 32, NOW(), true, NULL),
    ('33333333-3333-3333-3333-333333333333', 33, NOW(), true, NULL),
    -- CustomerSupport Self-Management (34,36,37 - not 35, can't create other support)
    ('33333333-3333-3333-3333-333333333333', 34, NOW(), true, NULL),
    ('33333333-3333-3333-3333-333333333333', 36, NOW(), true, NULL),
    ('33333333-3333-3333-3333-333333333333', 37, NOW(), true, NULL),
    -- Customer Create (43)
    ('33333333-3333-3333-3333-333333333333', 43, NOW(), true, NULL),
    -- All Customer CRUD Permissions (46-48)
    ('33333333-3333-3333-3333-333333333333', 46, NOW(), true, NULL),
    ('33333333-3333-3333-3333-333333333333', 47, NOW(), true, NULL),
    ('33333333-3333-3333-3333-333333333333', 48, NOW(), true, NULL),
    -- All MedicalStore/Chemist CRUD Permissions (49-51)
    ('33333333-3333-3333-3333-333333333333', 49, NOW(), true, NULL),
    ('33333333-3333-3333-3333-333333333333', 50, NOW(), true, NULL),
    ('33333333-3333-3333-3333-333333333333', 51, NOW(), true, NULL)
ON CONFLICT ("RoleId", "PermissionId") DO NOTHING;

-- Customer Role Permissions
INSERT INTO "RolePermissions" ("RoleId", "PermissionId", "GrantedAt", "IsActive", "GrantedBy")
VALUES 
    -- Read Products (5)
    ('44444444-4444-4444-4444-444444444444', 5, NOW(), true, NULL),
    -- Read and Create Orders (9,10)
    ('44444444-4444-4444-4444-444444444444', 9, NOW(), true, NULL),
    ('44444444-4444-4444-4444-444444444444', 10, NOW(), true, NULL),
    -- Customer Self-Management (42,44,45)
    ('44444444-4444-4444-4444-444444444444', 42, NOW(), true, NULL),
    ('44444444-4444-4444-4444-444444444444', 44, NOW(), true, NULL),
    ('44444444-4444-4444-4444-444444444444', 45, NOW(), true, NULL)
ON CONFLICT ("RoleId", "PermissionId") DO NOTHING;

-- Chemist Role Permissions
INSERT INTO "RolePermissions" ("RoleId", "PermissionId", "GrantedAt", "IsActive", "GrantedBy")
VALUES 
    -- Full Products CRUD (5-8)
    ('55555555-5555-5555-5555-555555555555', 5, NOW(), true, NULL),
    ('55555555-5555-5555-5555-555555555555', 6, NOW(), true, NULL),
    ('55555555-5555-5555-5555-555555555555', 7, NOW(), true, NULL),
    ('55555555-5555-5555-5555-555555555555', 8, NOW(), true, NULL),
    -- Full Orders CRUD (9-12)
    ('55555555-5555-5555-5555-555555555555', 9, NOW(), true, NULL),
    ('55555555-5555-5555-5555-555555555555', 10, NOW(), true, NULL),
    ('55555555-5555-5555-5555-555555555555', 11, NOW(), true, NULL),
    ('55555555-5555-5555-5555-555555555555', 12, NOW(), true, NULL),
    -- Chemist Self-Management (30,32,33 - not 31, can't create other chemists)
    ('55555555-5555-5555-5555-555555555555', 30, NOW(), true, NULL),
    ('55555555-5555-5555-5555-555555555555', 32, NOW(), true, NULL),
    ('55555555-5555-5555-5555-555555555555', 33, NOW(), true, NULL)
ON CONFLICT ("RoleId", "PermissionId") DO NOTHING;

-- =====================================================
-- SECTION 4: APPLICATION USERS (AspNetUsers)
-- =====================================================
-- Note: The password hashes below are for demonstration purposes.
-- In production, you should generate new password hashes.
-- Passwords: Admin@123, Manager@123, Support@123, Customer@123, Chemist@123

-- Admin User (Mobile: 9999999999, Password: Admin@123)
INSERT INTO "AspNetUsers" 
    ("Id", "UserName", "NormalizedUserName", "Email", "NormalizedEmail", 
     "EmailConfirmed", "PasswordHash", "SecurityStamp", "ConcurrencyStamp",
     "PhoneNumber", "PhoneNumberConfirmed", "TwoFactorEnabled", 
     "LockoutEnd", "LockoutEnabled", "AccessFailedCount", 
     "FirstName", "LastName", "CreatedAt", "LastLoginAt", "IsActive")
VALUES 
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
     '9999999999',
     '9999999999',
     'admin@medicine.com',
     'ADMIN@MEDICINE.COM',
     true,
     'AQAAAAIAAYagAAAAEFQ1Z1x3YzN2VzJ3NzV6V3RzMnN0czN3VzJ2N3Z2dzN2N3Z2N3Y2NjY2N3Z2N2Y=',
     'ADMIN_SECURITY_STAMP_123',
     'admin-concurrency-stamp-123',
     '9999999999',
     true,
     false,
     NULL,
     true,
     0,
     'System',
     'Administrator',
     NOW(),
     NULL,
     true)
ON CONFLICT ("Id") DO NOTHING;

-- Manager User (Mobile: 8888888888, Password: Manager@123)
INSERT INTO "AspNetUsers" 
    ("Id", "UserName", "NormalizedUserName", "Email", "NormalizedEmail", 
     "EmailConfirmed", "PasswordHash", "SecurityStamp", "ConcurrencyStamp",
     "PhoneNumber", "PhoneNumberConfirmed", "TwoFactorEnabled", 
     "LockoutEnd", "LockoutEnabled", "AccessFailedCount", 
     "FirstName", "LastName", "CreatedAt", "LastLoginAt", "IsActive")
VALUES 
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
     '8888888888',
     '8888888888',
     'manager@medicine.com',
     'MANAGER@MEDICINE.COM',
     true,
     'AQAAAAIAAYagAAAAEFQ1Z1x3YzN2VzJ3NzV6V3RzMnN0czN3VzJ2N3Z2dzN2N3Z2N3Y2NjY2N3Z2N2Y=',
     'MANAGER_SECURITY_STAMP_123',
     'manager-concurrency-stamp-123',
     '8888888888',
     true,
     false,
     NULL,
     true,
     0,
     'John',
     'Manager',
     NOW(),
     NULL,
     true)
ON CONFLICT ("Id") DO NOTHING;

-- CustomerSupport User (Mobile: 7777777777, Password: Support@123)
INSERT INTO "AspNetUsers" 
    ("Id", "UserName", "NormalizedUserName", "Email", "NormalizedEmail", 
     "EmailConfirmed", "PasswordHash", "SecurityStamp", "ConcurrencyStamp",
     "PhoneNumber", "PhoneNumberConfirmed", "TwoFactorEnabled", 
     "LockoutEnd", "LockoutEnabled", "AccessFailedCount", 
     "FirstName", "LastName", "CreatedAt", "LastLoginAt", "IsActive")
VALUES 
    ('cccccccc-cccc-cccc-cccc-cccccccccccc',
     '7777777777',
     '7777777777',
     'support@medicine.com',
     'SUPPORT@MEDICINE.COM',
     true,
     'AQAAAAIAAYagAAAAEFQ1Z1x3YzN2VzJ3NzV6V3RzMnN0czN3VzJ2N3Z2dzN2N3Z2N3Y2NjY2N3Z2N2Y=',
     'SUPPORT_SECURITY_STAMP_123',
     'support-concurrency-stamp-123',
     '7777777777',
     true,
     false,
     NULL,
     true,
     0,
     'Jane',
     'Support',
     NOW(),
     NULL,
     true)
ON CONFLICT ("Id") DO NOTHING;

-- Customer User (Mobile: 6666666666, Password: Customer@123)
-- INSERT INTO "AspNetUsers" 
    -- ("Id", "UserName", "NormalizedUserName", "Email", "NormalizedEmail", 
     -- "EmailConfirmed", "PasswordHash", "SecurityStamp", "ConcurrencyStamp",
     -- "PhoneNumber", "PhoneNumberConfirmed", "TwoFactorEnabled", 
     -- "LockoutEnd", "LockoutEnabled", "AccessFailedCount", 
     -- "FirstName", "LastName", "CreatedAt", "LastLoginAt", "IsActive")
-- VALUES 
    -- ('dddddddd-dddd-dddd-dddd-dddddddddddd',
     -- '6666666666',
     -- '6666666666',
     -- 'customer@medicine.com',
     -- 'CUSTOMER@MEDICINE.COM',
     -- true,
     -- 'AQAAAAIAAYagAAAAEFQ1Z1x3YzN2VzJ3NzV6V3RzMnN0czN3VzJ2N3Z2dzN2N3Z2N3Y2NjY2N3Z2N2Y=',
     -- 'CUSTOMER_SECURITY_STAMP_123',
     -- 'customer-concurrency-stamp-123',
     -- '6666666666',
     -- true,
     -- false,
     -- NULL,
     -- true,
     -- 0,
     -- 'Alice',
     -- 'Customer',
     -- NOW(),
     -- NULL,
     -- true)
-- ON CONFLICT ("Id") DO NOTHING;

-- -- Chemist User (Mobile: 5555555555, Password: Chemist@123)
-- INSERT INTO "AspNetUsers" 
    -- ("Id", "UserName", "NormalizedUserName", "Email", "NormalizedEmail", 
     -- "EmailConfirmed", "PasswordHash", "SecurityStamp", "ConcurrencyStamp",
     -- "PhoneNumber", "PhoneNumberConfirmed", "TwoFactorEnabled", 
     -- "LockoutEnd", "LockoutEnabled", "AccessFailedCount", 
     -- "FirstName", "LastName", "CreatedAt", "LastLoginAt", "IsActive")
-- VALUES 
    -- ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
     -- '5555555555',
     -- '5555555555',
     -- 'chemist@medicine.com',
     -- 'CHEMIST@MEDICINE.COM',
     -- true,
     -- 'AQAAAAIAAYagAAAAEFQ1Z1x3YzN2VzJ3NzV6V3RzMnN0czN3VzJ2N3Z2dzN2N3Z2N3Y2NjY2N3Z2N2Y=',
     -- 'CHEMIST_SECURITY_STAMP_123',
     -- 'chemist-concurrency-stamp-123',
     -- '5555555555',
     -- true,
     -- false,
     -- NULL,
     -- true,
     -- 0,
     -- 'Bob',
     -- 'Chemist',
     -- NOW(),
     -- NULL,
     -- true)
-- ON CONFLICT ("Id") DO NOTHING;

-- =====================================================
-- SECTION 5: USER-ROLE MAPPINGS (AspNetUserRoles)
-- =====================================================

-- Assign Admin role to Admin user
INSERT INTO "AspNetUserRoles" ("UserId", "RoleId")
VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111')
ON CONFLICT ("UserId", "RoleId") DO NOTHING;

-- Assign Manager role to Manager user
INSERT INTO "AspNetUserRoles" ("UserId", "RoleId")
VALUES ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '22222222-2222-2222-2222-222222222222')
ON CONFLICT ("UserId", "RoleId") DO NOTHING;

-- Assign CustomerSupport role to Support user
INSERT INTO "AspNetUserRoles" ("UserId", "RoleId")
VALUES ('cccccccc-cccc-cccc-cccc-cccccccccccc', '33333333-3333-3333-3333-333333333333')
ON CONFLICT ("UserId", "RoleId") DO NOTHING;

-- -- Assign Customer role to Customer user
-- INSERT INTO "AspNetUserRoles" ("UserId", "RoleId")
-- VALUES ('dddddddd-dddd-dddd-dddd-dddddddddddd', '44444444-4444-4444-4444-444444444444')
-- ON CONFLICT ("UserId", "RoleId") DO NOTHING;

-- -- Assign Chemist role to Chemist user
-- INSERT INTO "AspNetUserRoles" ("UserId", "RoleId")
-- VALUES ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '55555555-5555-5555-5555-555555555555')
-- ON CONFLICT ("UserId", "RoleId") DO NOTHING;

-- =====================================================
-- COMMIT TRANSACTION
-- =====================================================
COMMIT;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================
-- Uncomment to verify the seed data after running the script

-- SELECT COUNT(*) as "Total Roles" FROM "AspNetRoles";
-- SELECT COUNT(*) as "Total Permissions" FROM "Permissions";
-- SELECT COUNT(*) as "Total Role-Permission Mappings" FROM "RolePermissions";
-- SELECT COUNT(*) as "Total Users" FROM "AspNetUsers";
-- SELECT COUNT(*) as "Total User-Role Mappings" FROM "AspNetUserRoles";

-- View all roles
-- SELECT * FROM "AspNetRoles" ORDER BY "Name";

-- View all users with their roles
-- SELECT u."UserName", u."Email", u."FirstName", u."LastName", r."Name" as "RoleName"
-- FROM "AspNetUsers" u
-- JOIN "AspNetUserRoles" ur ON u."Id" = ur."UserId"
-- JOIN "AspNetRoles" r ON ur."RoleId" = r."Id"
-- ORDER BY r."Name", u."UserName";

-- View permissions by role
-- SELECT r."Name" as "Role", COUNT(rp."PermissionId") as "Permission Count"
-- FROM "AspNetRoles" r
-- LEFT JOIN "RolePermissions" rp ON r."Id" = rp."RoleId" AND rp."IsActive" = true
-- GROUP BY r."Name"
-- ORDER BY r."Name";

-- =====================================================
-- SEED DATA SUMMARY
-- =====================================================
-- 
-- ROLES: 5 (Admin, Manager, CustomerSupport, Customer, Chemist)
--
-- PERMISSIONS: 51 total
--   - Base Permissions: 12
--   - User Management Permissions: 16
--   - Role Management: 1
--   - Entity CRUD Permissions: 22
--
-- USERS: 5 default users
--   - Admin (9999999999 / Admin@123)
--   - Manager (8888888888 / Manager@123)
--   - CustomerSupport (7777777777 / Support@123)
--   - Customer (6666666666 / Customer@123)
--   - Chemist (5555555555 / Chemist@123)
--
-- IMPORTANT NOTES:
-- 1. The password hashes in this script are PLACEHOLDERS
-- 2. Before running in production, generate proper password hashes
-- 3. You can use the application's UserManager to create users with proper hashes
-- 4. Or use the SeedData.cs class which already has the proper hash generation
-- =====================================================

