IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
GO

CREATE TABLE [AspNetRoles] (
    [Id] nvarchar(450) NOT NULL,
    [Name] nvarchar(256) NULL,
    [NormalizedName] nvarchar(256) NULL,
    [ConcurrencyStamp] nvarchar(max) NULL,
    CONSTRAINT [PK_AspNetRoles] PRIMARY KEY ([Id])
);
GO

CREATE TABLE [AspNetUsers] (
    [Id] nvarchar(450) NOT NULL,
    [FirstName] nvarchar(max) NULL,
    [LastName] nvarchar(max) NULL,
    [CreatedAt] datetime2 NOT NULL,
    [LastLoginAt] datetime2 NULL,
    [IsActive] bit NOT NULL,
    [UserName] nvarchar(256) NULL,
    [NormalizedUserName] nvarchar(256) NULL,
    [Email] nvarchar(256) NULL,
    [NormalizedEmail] nvarchar(256) NULL,
    [EmailConfirmed] bit NOT NULL,
    [PasswordHash] nvarchar(max) NULL,
    [SecurityStamp] nvarchar(max) NULL,
    [ConcurrencyStamp] nvarchar(max) NULL,
    [PhoneNumber] nvarchar(max) NULL,
    [PhoneNumberConfirmed] bit NOT NULL,
    [TwoFactorEnabled] bit NOT NULL,
    [LockoutEnd] datetimeoffset NULL,
    [LockoutEnabled] bit NOT NULL,
    [AccessFailedCount] int NOT NULL,
    CONSTRAINT [PK_AspNetUsers] PRIMARY KEY ([Id])
);
GO

CREATE TABLE [Orders] (
    [Id] int NOT NULL IDENTITY,
    [CustomerName] nvarchar(max) NOT NULL,
    [CustomerEmail] nvarchar(max) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [Status] nvarchar(max) NOT NULL,
    [CreatedAt] datetime2 NOT NULL,
    [UpdatedAt] datetime2 NULL,
    CONSTRAINT [PK_Orders] PRIMARY KEY ([Id])
);
GO

CREATE TABLE [Permissions] (
    [Id] int NOT NULL IDENTITY,
    [Name] nvarchar(max) NOT NULL,
    [Description] nvarchar(max) NOT NULL,
    [Module] nvarchar(max) NOT NULL,
    [CreatedAt] datetime2 NOT NULL,
    [IsActive] bit NOT NULL,
    CONSTRAINT [PK_Permissions] PRIMARY KEY ([Id])
);
GO

CREATE TABLE [Products] (
    [Id] int NOT NULL IDENTITY,
    [Name] nvarchar(max) NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [Category] nvarchar(max) NOT NULL,
    [Description] nvarchar(max) NOT NULL,
    [StockQuantity] int NOT NULL,
    [IsActive] bit NOT NULL,
    [CreatedAt] datetime2 NOT NULL,
    [UpdatedAt] datetime2 NULL,
    CONSTRAINT [PK_Products] PRIMARY KEY ([Id])
);
GO

CREATE TABLE [Roles] (
    [Id] int NOT NULL IDENTITY,
    [Name] nvarchar(max) NOT NULL,
    [Description] nvarchar(max) NOT NULL,
    [CreatedAt] datetime2 NOT NULL,
    [IsActive] bit NOT NULL,
    CONSTRAINT [PK_Roles] PRIMARY KEY ([Id])
);
GO

CREATE TABLE [Users] (
    [Id] nvarchar(450) NOT NULL,
    [Email] nvarchar(max) NOT NULL,
    [FirstName] nvarchar(max) NOT NULL,
    [LastName] nvarchar(max) NOT NULL,
    [CreatedAt] datetime2 NOT NULL,
    [LastLoginAt] datetime2 NULL,
    [IsActive] bit NOT NULL,
    CONSTRAINT [PK_Users] PRIMARY KEY ([Id])
);
GO

CREATE TABLE [AspNetRoleClaims] (
    [Id] int NOT NULL IDENTITY,
    [RoleId] nvarchar(450) NOT NULL,
    [ClaimType] nvarchar(max) NULL,
    [ClaimValue] nvarchar(max) NULL,
    CONSTRAINT [PK_AspNetRoleClaims] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_AspNetRoleClaims_AspNetRoles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [AspNetRoles] ([Id]) ON DELETE CASCADE
);
GO

CREATE TABLE [AspNetUserClaims] (
    [Id] int NOT NULL IDENTITY,
    [UserId] nvarchar(450) NOT NULL,
    [ClaimType] nvarchar(max) NULL,
    [ClaimValue] nvarchar(max) NULL,
    CONSTRAINT [PK_AspNetUserClaims] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_AspNetUserClaims_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE CASCADE
);
GO

CREATE TABLE [AspNetUserLogins] (
    [LoginProvider] nvarchar(450) NOT NULL,
    [ProviderKey] nvarchar(450) NOT NULL,
    [ProviderDisplayName] nvarchar(max) NULL,
    [UserId] nvarchar(450) NOT NULL,
    CONSTRAINT [PK_AspNetUserLogins] PRIMARY KEY ([LoginProvider], [ProviderKey]),
    CONSTRAINT [FK_AspNetUserLogins_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE CASCADE
);
GO

CREATE TABLE [AspNetUserRoles] (
    [UserId] nvarchar(450) NOT NULL,
    [RoleId] nvarchar(450) NOT NULL,
    CONSTRAINT [PK_AspNetUserRoles] PRIMARY KEY ([UserId], [RoleId]),
    CONSTRAINT [FK_AspNetUserRoles_AspNetRoles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [AspNetRoles] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_AspNetUserRoles_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE CASCADE
);
GO

CREATE TABLE [AspNetUserTokens] (
    [UserId] nvarchar(450) NOT NULL,
    [LoginProvider] nvarchar(450) NOT NULL,
    [Name] nvarchar(450) NOT NULL,
    [Value] nvarchar(max) NULL,
    CONSTRAINT [PK_AspNetUserTokens] PRIMARY KEY ([UserId], [LoginProvider], [Name]),
    CONSTRAINT [FK_AspNetUserTokens_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE CASCADE
);
GO

CREATE TABLE [OrderItems] (
    [Id] int NOT NULL IDENTITY,
    [OrderId] int NOT NULL,
    [ProductId] int NOT NULL,
    [Quantity] int NOT NULL,
    [UnitPrice] decimal(18,2) NOT NULL,
    [TotalPrice] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_OrderItems] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_OrderItems_Orders_OrderId] FOREIGN KEY ([OrderId]) REFERENCES [Orders] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_OrderItems_Products_ProductId] FOREIGN KEY ([ProductId]) REFERENCES [Products] ([Id]) ON DELETE NO ACTION
);
GO

CREATE TABLE [RolePermissions] (
    [RoleId] int NOT NULL,
    [PermissionId] int NOT NULL,
    [GrantedAt] datetime2 NOT NULL,
    [GrantedBy] nvarchar(max) NULL,
    [IsActive] bit NOT NULL,
    CONSTRAINT [PK_RolePermissions] PRIMARY KEY ([RoleId], [PermissionId]),
    CONSTRAINT [FK_RolePermissions_Permissions_PermissionId] FOREIGN KEY ([PermissionId]) REFERENCES [Permissions] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_RolePermissions_Roles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [Roles] ([Id]) ON DELETE CASCADE
);
GO

CREATE TABLE [UserRoles] (
    [UserId] nvarchar(450) NOT NULL,
    [RoleId] int NOT NULL,
    [AssignedAt] datetime2 NOT NULL,
    [AssignedBy] nvarchar(max) NULL,
    [IsActive] bit NOT NULL,
    CONSTRAINT [PK_UserRoles] PRIMARY KEY ([UserId], [RoleId]),
    CONSTRAINT [FK_UserRoles_Roles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [Roles] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_UserRoles_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Users] ([Id]) ON DELETE CASCADE
);
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'Id', N'CreatedAt', N'Description', N'IsActive', N'Module', N'Name') AND [object_id] = OBJECT_ID(N'[Permissions]'))
    SET IDENTITY_INSERT [Permissions] ON;
INSERT INTO [Permissions] ([Id], [CreatedAt], [Description], [IsActive], [Module], [Name])
VALUES (1, '2025-09-15T14:17:02.1487799Z', N'Can view user information', CAST(1 AS bit), N'Users', N'ReadUsers'),
(2, '2025-09-15T14:17:02.1487800Z', N'Can create new users', CAST(1 AS bit), N'Users', N'CreateUsers'),
(3, '2025-09-15T14:17:02.1487802Z', N'Can update user information', CAST(1 AS bit), N'Users', N'UpdateUsers'),
(4, '2025-09-15T14:17:02.1487803Z', N'Can delete users', CAST(1 AS bit), N'Users', N'DeleteUsers'),
(5, '2025-09-15T14:17:02.1487804Z', N'Can view products', CAST(1 AS bit), N'Products', N'ReadProducts'),
(6, '2025-09-15T14:17:02.1487805Z', N'Can create new products', CAST(1 AS bit), N'Products', N'CreateProducts'),
(7, '2025-09-15T14:17:02.1487806Z', N'Can update products', CAST(1 AS bit), N'Products', N'UpdateProducts'),
(8, '2025-09-15T14:17:02.1487808Z', N'Can delete products', CAST(1 AS bit), N'Products', N'DeleteProducts'),
(9, '2025-09-15T14:17:02.1487809Z', N'Can view orders', CAST(1 AS bit), N'Orders', N'ReadOrders'),
(10, '2025-09-15T14:17:02.1487810Z', N'Can create new orders', CAST(1 AS bit), N'Orders', N'CreateOrders'),
(11, '2025-09-15T14:17:02.1487811Z', N'Can update orders', CAST(1 AS bit), N'Orders', N'UpdateOrders'),
(12, '2025-09-15T14:17:02.1487812Z', N'Can delete orders', CAST(1 AS bit), N'Orders', N'DeleteOrders');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'Id', N'CreatedAt', N'Description', N'IsActive', N'Module', N'Name') AND [object_id] = OBJECT_ID(N'[Permissions]'))
    SET IDENTITY_INSERT [Permissions] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'Id', N'CreatedAt', N'Description', N'IsActive', N'Name') AND [object_id] = OBJECT_ID(N'[Roles]'))
    SET IDENTITY_INSERT [Roles] ON;
INSERT INTO [Roles] ([Id], [CreatedAt], [Description], [IsActive], [Name])
VALUES (1, '2025-09-15T14:17:02.1487926Z', N'Full system access', CAST(1 AS bit), N'Admin'),
(2, '2025-09-15T14:17:02.1487928Z', N'Management level access', CAST(1 AS bit), N'Manager'),
(3, '2025-09-15T14:17:02.1487929Z', N'Basic employee access', CAST(1 AS bit), N'Employee'),
(4, '2025-09-15T14:17:02.1487931Z', N'Customer access', CAST(1 AS bit), N'Customer');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'Id', N'CreatedAt', N'Description', N'IsActive', N'Name') AND [object_id] = OBJECT_ID(N'[Roles]'))
    SET IDENTITY_INSERT [Roles] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'PermissionId', N'RoleId', N'GrantedAt', N'GrantedBy', N'IsActive') AND [object_id] = OBJECT_ID(N'[RolePermissions]'))
    SET IDENTITY_INSERT [RolePermissions] ON;
INSERT INTO [RolePermissions] ([PermissionId], [RoleId], [GrantedAt], [GrantedBy], [IsActive])
VALUES (1, 1, '2025-09-15T14:17:02.1487950Z', NULL, CAST(1 AS bit)),
(2, 1, '2025-09-15T14:17:02.1487952Z', NULL, CAST(1 AS bit)),
(3, 1, '2025-09-15T14:17:02.1487953Z', NULL, CAST(1 AS bit)),
(4, 1, '2025-09-15T14:17:02.1487954Z', NULL, CAST(1 AS bit)),
(5, 1, '2025-09-15T14:17:02.1487955Z', NULL, CAST(1 AS bit)),
(6, 1, '2025-09-15T14:17:02.1487956Z', NULL, CAST(1 AS bit)),
(7, 1, '2025-09-15T14:17:02.1487957Z', NULL, CAST(1 AS bit)),
(8, 1, '2025-09-15T14:17:02.1487958Z', NULL, CAST(1 AS bit)),
(9, 1, '2025-09-15T14:17:02.1487959Z', NULL, CAST(1 AS bit)),
(10, 1, '2025-09-15T14:17:02.1487960Z', NULL, CAST(1 AS bit)),
(11, 1, '2025-09-15T14:17:02.1487961Z', NULL, CAST(1 AS bit)),
(12, 1, '2025-09-15T14:17:02.1487962Z', NULL, CAST(1 AS bit)),
(1, 2, '2025-09-15T14:17:02.1487964Z', NULL, CAST(1 AS bit)),
(3, 2, '2025-09-15T14:17:02.1487966Z', NULL, CAST(1 AS bit)),
(5, 2, '2025-09-15T14:17:02.1487967Z', NULL, CAST(1 AS bit)),
(7, 2, '2025-09-15T14:17:02.1487969Z', NULL, CAST(1 AS bit)),
(9, 2, '2025-09-15T14:17:02.1487971Z', NULL, CAST(1 AS bit)),
(11, 2, '2025-09-15T14:17:02.1487972Z', NULL, CAST(1 AS bit)),
(5, 3, '2025-09-15T14:17:02.1487974Z', NULL, CAST(1 AS bit)),
(9, 3, '2025-09-15T14:17:02.1487975Z', NULL, CAST(1 AS bit)),
(10, 3, '2025-09-15T14:17:02.1487977Z', NULL, CAST(1 AS bit)),
(5, 4, '2025-09-15T14:17:02.1487978Z', NULL, CAST(1 AS bit)),
(9, 4, '2025-09-15T14:17:02.1487980Z', NULL, CAST(1 AS bit)),
(10, 4, '2025-09-15T14:17:02.1487981Z', NULL, CAST(1 AS bit));
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'PermissionId', N'RoleId', N'GrantedAt', N'GrantedBy', N'IsActive') AND [object_id] = OBJECT_ID(N'[RolePermissions]'))
    SET IDENTITY_INSERT [RolePermissions] OFF;
GO

CREATE INDEX [IX_AspNetRoleClaims_RoleId] ON [AspNetRoleClaims] ([RoleId]);
GO

CREATE UNIQUE INDEX [RoleNameIndex] ON [AspNetRoles] ([NormalizedName]) WHERE [NormalizedName] IS NOT NULL;
GO

CREATE INDEX [IX_AspNetUserClaims_UserId] ON [AspNetUserClaims] ([UserId]);
GO

CREATE INDEX [IX_AspNetUserLogins_UserId] ON [AspNetUserLogins] ([UserId]);
GO

CREATE INDEX [IX_AspNetUserRoles_RoleId] ON [AspNetUserRoles] ([RoleId]);
GO

CREATE INDEX [EmailIndex] ON [AspNetUsers] ([NormalizedEmail]);
GO

CREATE UNIQUE INDEX [UserNameIndex] ON [AspNetUsers] ([NormalizedUserName]) WHERE [NormalizedUserName] IS NOT NULL;
GO

CREATE INDEX [IX_OrderItems_OrderId] ON [OrderItems] ([OrderId]);
GO

CREATE INDEX [IX_OrderItems_ProductId] ON [OrderItems] ([ProductId]);
GO

CREATE INDEX [IX_RolePermissions_PermissionId] ON [RolePermissions] ([PermissionId]);
GO

CREATE INDEX [IX_UserRoles_RoleId] ON [UserRoles] ([RoleId]);
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250915141703_InitialCreate', N'8.0.0');
GO

COMMIT;
GO

