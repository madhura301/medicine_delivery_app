using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace MedicineDelivery.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class InitialPostgreSQLMigration : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "AspNetRoles",
                columns: table => new
                {
                    Id = table.Column<string>(type: "text", nullable: false),
                    Name = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: true),
                    NormalizedName = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: true),
                    ConcurrencyStamp = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetRoles", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "AspNetUsers",
                columns: table => new
                {
                    Id = table.Column<string>(type: "text", nullable: false),
                    FirstName = table.Column<string>(type: "text", nullable: true),
                    LastName = table.Column<string>(type: "text", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    LastLoginAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    UserName = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: true),
                    NormalizedUserName = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: true),
                    Email = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: true),
                    NormalizedEmail = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: true),
                    EmailConfirmed = table.Column<bool>(type: "boolean", nullable: false),
                    PasswordHash = table.Column<string>(type: "text", nullable: true),
                    SecurityStamp = table.Column<string>(type: "text", nullable: true),
                    ConcurrencyStamp = table.Column<string>(type: "text", nullable: true),
                    PhoneNumber = table.Column<string>(type: "text", nullable: true),
                    PhoneNumberConfirmed = table.Column<bool>(type: "boolean", nullable: false),
                    TwoFactorEnabled = table.Column<bool>(type: "boolean", nullable: false),
                    LockoutEnd = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    LockoutEnabled = table.Column<bool>(type: "boolean", nullable: false),
                    AccessFailedCount = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetUsers", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Permissions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "text", nullable: false),
                    Description = table.Column<string>(type: "text", nullable: false),
                    Module = table.Column<string>(type: "text", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Permissions", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Products",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "text", nullable: false),
                    Price = table.Column<decimal>(type: "numeric", nullable: false),
                    Category = table.Column<string>(type: "text", nullable: false),
                    Description = table.Column<string>(type: "text", nullable: false),
                    StockQuantity = table.Column<int>(type: "integer", nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Products", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Roles",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "text", nullable: false),
                    Description = table.Column<string>(type: "text", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Roles", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    Id = table.Column<string>(type: "text", nullable: false),
                    Email = table.Column<string>(type: "text", nullable: false),
                    FirstName = table.Column<string>(type: "text", nullable: false),
                    LastName = table.Column<string>(type: "text", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    LastLoginAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "AspNetRoleClaims",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    RoleId = table.Column<string>(type: "text", nullable: false),
                    ClaimType = table.Column<string>(type: "text", nullable: true),
                    ClaimValue = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetRoleClaims", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AspNetRoleClaims_AspNetRoles_RoleId",
                        column: x => x.RoleId,
                        principalTable: "AspNetRoles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AspNetUserClaims",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UserId = table.Column<string>(type: "text", nullable: false),
                    ClaimType = table.Column<string>(type: "text", nullable: true),
                    ClaimValue = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetUserClaims", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AspNetUserClaims_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AspNetUserLogins",
                columns: table => new
                {
                    LoginProvider = table.Column<string>(type: "text", nullable: false),
                    ProviderKey = table.Column<string>(type: "text", nullable: false),
                    ProviderDisplayName = table.Column<string>(type: "text", nullable: true),
                    UserId = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetUserLogins", x => new { x.LoginProvider, x.ProviderKey });
                    table.ForeignKey(
                        name: "FK_AspNetUserLogins_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AspNetUserRoles",
                columns: table => new
                {
                    UserId = table.Column<string>(type: "text", nullable: false),
                    RoleId = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetUserRoles", x => new { x.UserId, x.RoleId });
                    table.ForeignKey(
                        name: "FK_AspNetUserRoles_AspNetRoles_RoleId",
                        column: x => x.RoleId,
                        principalTable: "AspNetRoles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_AspNetUserRoles_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AspNetUserTokens",
                columns: table => new
                {
                    UserId = table.Column<string>(type: "text", nullable: false),
                    LoginProvider = table.Column<string>(type: "text", nullable: false),
                    Name = table.Column<string>(type: "text", nullable: false),
                    Value = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetUserTokens", x => new { x.UserId, x.LoginProvider, x.Name });
                    table.ForeignKey(
                        name: "FK_AspNetUserTokens_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "RolePermissions",
                columns: table => new
                {
                    RoleId = table.Column<int>(type: "integer", nullable: false),
                    PermissionId = table.Column<int>(type: "integer", nullable: false),
                    GrantedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    GrantedBy = table.Column<string>(type: "text", nullable: true),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RolePermissions", x => new { x.RoleId, x.PermissionId });
                    table.ForeignKey(
                        name: "FK_RolePermissions_Permissions_PermissionId",
                        column: x => x.PermissionId,
                        principalTable: "Permissions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_RolePermissions_Roles_RoleId",
                        column: x => x.RoleId,
                        principalTable: "Roles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Customers",
                columns: table => new
                {
                    CustomerId = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    CustomerFirstName = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    CustomerLastName = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    CustomerMiddleName = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    MobileNumber = table.Column<string>(type: "character varying(15)", maxLength: 15, nullable: false),
                    AlternativeMobileNumber = table.Column<string>(type: "character varying(15)", maxLength: 15, nullable: true),
                    EmailId = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    Address = table.Column<string>(type: "character varying(300)", maxLength: 300, nullable: true),
                    City = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    State = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    PostalCode = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    DateOfBirth = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Gender = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: true),
                    CustomerPhoto = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedOn = table.Column<DateTime>(type: "timestamp", nullable: false),
                    UpdatedOn = table.Column<DateTime>(type: "timestamp", nullable: true),
                    UserId = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Customers", x => x.CustomerId);
                    table.ForeignKey(
                        name: "FK_Customers_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "CustomerSupports",
                columns: table => new
                {
                    CustomerSupportId = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    CustomerSupportFirstName = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    CustomerSupportLastName = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    CustomerSupportMiddleName = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Address = table.Column<string>(type: "character varying(300)", maxLength: 300, nullable: false),
                    City = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    State = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    MobileNumber = table.Column<string>(type: "character varying(15)", maxLength: 15, nullable: false),
                    EmailId = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    AlternativeMobileNumber = table.Column<string>(type: "character varying(15)", maxLength: 15, nullable: false),
                    EmployeeId = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    CustomerSupportPhoto = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    IsDeleted = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedOn = table.Column<DateTime>(type: "timestamp", nullable: false),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedOn = table.Column<DateTime>(type: "timestamp", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UserId = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CustomerSupports", x => x.CustomerSupportId);
                    table.ForeignKey(
                        name: "FK_CustomerSupports_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "Managers",
                columns: table => new
                {
                    ManagerId = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    ManagerFirstName = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    ManagerLastName = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    ManagerMiddleName = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Address = table.Column<string>(type: "character varying(300)", maxLength: 300, nullable: false),
                    City = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    State = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    MobileNumber = table.Column<string>(type: "character varying(15)", maxLength: 15, nullable: false),
                    EmailId = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    AlternativeMobileNumber = table.Column<string>(type: "character varying(15)", maxLength: 15, nullable: false),
                    EmployeeId = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    ManagerPhoto = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    IsDeleted = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedOn = table.Column<DateTime>(type: "timestamp", nullable: false),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedOn = table.Column<DateTime>(type: "timestamp", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UserId = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Managers", x => x.ManagerId);
                    table.ForeignKey(
                        name: "FK_Managers_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "MedicalStores",
                columns: table => new
                {
                    MedicalStoreId = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    MedicalName = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    OwnerFirstName = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    OwnerLastName = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    OwnerMiddleName = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    AddressLine1 = table.Column<string>(type: "character varying(300)", maxLength: 300, nullable: false),
                    AddressLine2 = table.Column<string>(type: "character varying(300)", maxLength: 300, nullable: false),
                    City = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    State = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    PostalCode = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    Latitude = table.Column<decimal>(type: "numeric(18,6)", nullable: true),
                    Longitude = table.Column<decimal>(type: "numeric(18,6)", nullable: true),
                    MobileNumber = table.Column<string>(type: "character varying(15)", maxLength: 15, nullable: false),
                    EmailId = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    AlternativeMobileNumber = table.Column<string>(type: "character varying(15)", maxLength: 15, nullable: false),
                    RegistrationStatus = table.Column<bool>(type: "boolean", nullable: false),
                    GSTIN = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    PAN = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    FSSAINo = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    DLNo = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    PharmacistFirstName = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    PharmacistLastName = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    PharmacistRegistrationNumber = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    PharmacistMobileNumber = table.Column<string>(type: "character varying(15)", maxLength: 15, nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    IsDeleted = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedOn = table.Column<DateTime>(type: "timestamp", nullable: false),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedOn = table.Column<DateTime>(type: "timestamp", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UserId = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MedicalStores", x => x.MedicalStoreId);
                    table.ForeignKey(
                        name: "FK_MedicalStores_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "UserRoles",
                columns: table => new
                {
                    UserId = table.Column<string>(type: "text", nullable: false),
                    RoleId = table.Column<int>(type: "integer", nullable: false),
                    AssignedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    AssignedBy = table.Column<string>(type: "text", nullable: true),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserRoles", x => new { x.UserId, x.RoleId });
                    table.ForeignKey(
                        name: "FK_UserRoles_Roles_RoleId",
                        column: x => x.RoleId,
                        principalTable: "Roles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_UserRoles_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.InsertData(
                table: "Permissions",
                columns: new[] { "Id", "CreatedAt", "Description", "IsActive", "Module", "Name" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6087), "Can view user information", true, "Users", "ReadUsers" },
                    { 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6091), "Can create new users", true, "Users", "CreateUsers" },
                    { 3, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6092), "Can update user information", true, "Users", "UpdateUsers" },
                    { 4, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6094), "Can delete users", true, "Users", "DeleteUsers" },
                    { 5, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6095), "Can view products", true, "Products", "ReadProducts" },
                    { 6, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6096), "Can create new products", true, "Products", "CreateProducts" },
                    { 7, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6098), "Can update products", true, "Products", "UpdateProducts" },
                    { 8, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6099), "Can delete products", true, "Products", "DeleteProducts" },
                    { 13, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6106), "Admin can view all user information", true, "UserManagement", "AdminReadUsers" },
                    { 14, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6107), "Admin can create users", true, "UserManagement", "AdminCreateUsers" },
                    { 15, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6108), "Admin can update user information", true, "UserManagement", "AdminUpdateUsers" },
                    { 16, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6109), "Admin can delete users", true, "UserManagement", "AdminDeleteUsers" },
                    { 17, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6110), "Manager can view user information", true, "UserManagement", "ManagerReadUsers" },
                    { 18, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6111), "Manager can create users", true, "UserManagement", "ManagerCreateUsers" },
                    { 19, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6112), "Manager can update user information", true, "UserManagement", "ManagerUpdateUsers" },
                    { 20, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6113), "Manager can delete users", true, "UserManagement", "ManagerDeleteUsers" },
                    { 21, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6115), "CustomerSupport can view user information", true, "UserManagement", "CustomerSupportReadUsers" },
                    { 22, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6116), "CustomerSupport can create users", true, "UserManagement", "CustomerSupportCreateUsers" },
                    { 23, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6117), "CustomerSupport can update user information", true, "UserManagement", "CustomerSupportUpdateUsers" },
                    { 24, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6118), "CustomerSupport can delete users", true, "UserManagement", "CustomerSupportDeleteUsers" },
                    { 25, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6119), "Chemist can view user information", true, "UserManagement", "ChemistReadUsers" },
                    { 26, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6121), "Chemist can create users", true, "UserManagement", "ChemistCreateUsers" },
                    { 27, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6122), "Chemist can update user information", true, "UserManagement", "ChemistUpdateUsers" },
                    { 28, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6123), "Chemist can delete users", true, "UserManagement", "ChemistDeleteUsers" },
                    { 29, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6125), "Can manage role permissions", true, "RoleManagement", "ManageRolePermission" },
                    { 30, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6126), "Can read chemist information", true, "Chemist", "ChemistRead" },
                    { 31, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6127), "Can create chemist accounts", true, "Chemist", "ChemistCreate" },
                    { 32, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6128), "Can update chemist information", true, "Chemist", "ChemistUpdate" },
                    { 33, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6129), "Can delete chemist accounts", true, "Chemist", "ChemistDelete" },
                    { 34, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6130), "Can read customer support information", true, "CustomerSupport", "CustomerSupportRead" },
                    { 35, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6131), "Can create customer support accounts", true, "CustomerSupport", "CustomerSupportCreate" },
                    { 36, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6132), "Can update customer support information", true, "CustomerSupport", "CustomerSupportUpdate" },
                    { 37, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6134), "Can delete customer support accounts", true, "CustomerSupport", "CustomerSupportDelete" },
                    { 38, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6135), "Can read manager information", true, "Manager", "ManagerSupportRead" },
                    { 39, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6136), "Can create manager accounts", true, "Manager", "ManagerSupportCreate" },
                    { 40, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6137), "Can update manager information", true, "Manager", "ManagerSupportUpdate" },
                    { 41, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6138), "Can delete manager accounts", true, "Manager", "ManagerSupportDelete" },
                    { 42, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6139), "Can read own customer information", true, "Customer", "CustomerRead" },
                    { 43, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6141), "Can create customer accounts", true, "Customer", "CustomerCreate" },
                    { 44, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6142), "Can update own customer information", true, "Customer", "CustomerUpdate" },
                    { 45, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6143), "Can delete own customer account", true, "Customer", "CustomerDelete" },
                    { 46, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6144), "Can read all customer information", true, "Customer", "AllCustomerRead" },
                    { 47, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6146), "Can update any customer information", true, "Customer", "AllCustomerUpdate" },
                    { 48, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6147), "Can delete any customer account", true, "Customer", "AllCustomerDelete" },
                    { 49, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6149), "Can read all Chemist information", true, "Chemist", "AllChemistRead" },
                    { 50, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6150), "Can update any Chemist information", true, "Chemist", "AllChemistUpdate" },
                    { 51, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6151), "Can delete any Chemist account", true, "Chemist", "AllChemistDelete" }
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "CreatedAt", "Description", "IsActive", "Name" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6434), "Full system access", true, "Admin" },
                    { 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6436), "Management level access", true, "Manager" },
                    { 3, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6438), "Customer support access", true, "CustomerSupport" },
                    { 4, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6439), "Customer access", true, "Customer" },
                    { 5, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6440), "Chemist/pharmacist access", true, "Chemist" }
                });

            migrationBuilder.InsertData(
                table: "RolePermissions",
                columns: new[] { "PermissionId", "RoleId", "GrantedAt", "GrantedBy", "IsActive" },
                values: new object[,]
                {
                    { 1, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6484), null, true },
                    { 2, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6485), null, true },
                    { 3, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6486), null, true },
                    { 4, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6487), null, true },
                    { 5, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6488), null, true },
                    { 6, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6489), null, true },
                    { 7, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6490), null, true },
                    { 8, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6491), null, true },
                    { 9, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6492), null, true },
                    { 10, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6493), null, true },
                    { 11, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6495), null, true },
                    { 12, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6496), null, true },
                    { 13, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6497), null, true },
                    { 14, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6497), null, true },
                    { 15, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6498), null, true },
                    { 16, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6500), null, true },
                    { 17, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6501), null, true },
                    { 18, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6501), null, true },
                    { 19, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6502), null, true },
                    { 20, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6503), null, true },
                    { 21, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6504), null, true },
                    { 22, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6505), null, true },
                    { 23, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6506), null, true },
                    { 24, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6507), null, true },
                    { 25, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6507), null, true },
                    { 26, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6508), null, true },
                    { 27, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6509), null, true },
                    { 28, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6510), null, true },
                    { 29, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6511), null, true },
                    { 30, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6512), null, true },
                    { 31, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6513), null, true },
                    { 32, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6513), null, true },
                    { 33, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6514), null, true },
                    { 34, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6516), null, true },
                    { 35, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6517), null, true },
                    { 36, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6518), null, true },
                    { 37, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6519), null, true },
                    { 38, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6519), null, true },
                    { 39, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6520), null, true },
                    { 40, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6521), null, true },
                    { 41, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6522), null, true },
                    { 43, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6525), null, true },
                    { 46, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6523), null, true },
                    { 47, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6524), null, true },
                    { 48, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6524), null, true },
                    { 49, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6526), null, true },
                    { 50, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6527), null, true },
                    { 51, 1, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6528), null, true },
                    { 1, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6529), null, true },
                    { 3, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6530), null, true },
                    { 5, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6531), null, true },
                    { 7, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6532), null, true },
                    { 9, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6532), null, true },
                    { 11, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6533), null, true },
                    { 17, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6534), null, true },
                    { 18, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6535), null, true },
                    { 19, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6536), null, true },
                    { 20, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6538), null, true },
                    { 21, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6538), null, true },
                    { 22, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6539), null, true },
                    { 23, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6540), null, true },
                    { 24, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6541), null, true },
                    { 25, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6542), null, true },
                    { 26, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6543), null, true },
                    { 27, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6544), null, true },
                    { 28, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6545), null, true },
                    { 30, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6545), null, true },
                    { 31, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6546), null, true },
                    { 32, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6547), null, true },
                    { 33, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6551), null, true },
                    { 34, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6551), null, true },
                    { 35, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6552), null, true },
                    { 36, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6553), null, true },
                    { 37, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6554), null, true },
                    { 38, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6555), null, true },
                    { 40, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6556), null, true },
                    { 41, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6556), null, true },
                    { 43, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6560), null, true },
                    { 46, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6557), null, true },
                    { 47, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6558), null, true },
                    { 48, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6559), null, true },
                    { 49, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6561), null, true },
                    { 50, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6562), null, true },
                    { 51, 2, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6563), null, true },
                    { 5, 3, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6564), null, true },
                    { 9, 3, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6565), null, true },
                    { 10, 3, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6566), null, true },
                    { 21, 3, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6570), null, true },
                    { 22, 3, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6572), null, true },
                    { 23, 3, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6573), null, true },
                    { 24, 3, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6582), null, true },
                    { 25, 3, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6582), null, true },
                    { 26, 3, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6583), null, true },
                    { 27, 3, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6584), null, true },
                    { 28, 3, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6585), null, true },
                    { 30, 3, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6586), null, true },
                    { 31, 3, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6587), null, true },
                    { 32, 3, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6588), null, true },
                    { 33, 3, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6589), null, true },
                    { 34, 3, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6590), null, true },
                    { 36, 3, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6590), null, true },
                    { 37, 3, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6591), null, true },
                    { 43, 3, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6595), null, true },
                    { 46, 3, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6592), null, true },
                    { 47, 3, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6593), null, true },
                    { 48, 3, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6594), null, true },
                    { 49, 3, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6596), null, true },
                    { 50, 3, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6597), null, true },
                    { 51, 3, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6598), null, true },
                    { 5, 4, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6598), null, true },
                    { 9, 4, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6599), null, true },
                    { 10, 4, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6600), null, true },
                    { 42, 4, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6601), null, true },
                    { 44, 4, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6602), null, true },
                    { 45, 4, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6603), null, true },
                    { 5, 5, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6604), null, true },
                    { 6, 5, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6605), null, true },
                    { 7, 5, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6606), null, true },
                    { 8, 5, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6607), null, true },
                    { 9, 5, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6608), null, true },
                    { 10, 5, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6630), null, true },
                    { 11, 5, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6631), null, true },
                    { 12, 5, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6632), null, true },
                    { 30, 5, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6633), null, true },
                    { 32, 5, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6634), null, true },
                    { 33, 5, new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6635), null, true }
                });

            migrationBuilder.CreateIndex(
                name: "IX_AspNetRoleClaims_RoleId",
                table: "AspNetRoleClaims",
                column: "RoleId");

            migrationBuilder.CreateIndex(
                name: "RoleNameIndex",
                table: "AspNetRoles",
                column: "NormalizedName",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_AspNetUserClaims_UserId",
                table: "AspNetUserClaims",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_AspNetUserLogins_UserId",
                table: "AspNetUserLogins",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_AspNetUserRoles_RoleId",
                table: "AspNetUserRoles",
                column: "RoleId");

            migrationBuilder.CreateIndex(
                name: "EmailIndex",
                table: "AspNetUsers",
                column: "NormalizedEmail");

            migrationBuilder.CreateIndex(
                name: "UserNameIndex",
                table: "AspNetUsers",
                column: "NormalizedUserName",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Customers_UserId",
                table: "Customers",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_CustomerSupports_UserId",
                table: "CustomerSupports",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Managers_UserId",
                table: "Managers",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_MedicalStores_UserId",
                table: "MedicalStores",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_RolePermissions_PermissionId",
                table: "RolePermissions",
                column: "PermissionId");

            migrationBuilder.CreateIndex(
                name: "IX_UserRoles_RoleId",
                table: "UserRoles",
                column: "RoleId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AspNetRoleClaims");

            migrationBuilder.DropTable(
                name: "AspNetUserClaims");

            migrationBuilder.DropTable(
                name: "AspNetUserLogins");

            migrationBuilder.DropTable(
                name: "AspNetUserRoles");

            migrationBuilder.DropTable(
                name: "AspNetUserTokens");

            migrationBuilder.DropTable(
                name: "Customers");

            migrationBuilder.DropTable(
                name: "CustomerSupports");

            migrationBuilder.DropTable(
                name: "Managers");

            migrationBuilder.DropTable(
                name: "MedicalStores");

            migrationBuilder.DropTable(
                name: "RolePermissions");

            migrationBuilder.DropTable(
                name: "UserRoles");

            migrationBuilder.DropTable(
                name: "AspNetRoles");

            migrationBuilder.DropTable(
                name: "AspNetUsers");

            migrationBuilder.DropTable(
                name: "Products");

            migrationBuilder.DropTable(
                name: "Permissions");

            migrationBuilder.DropTable(
                name: "Roles");

            migrationBuilder.DropTable(
                name: "Users");
        }
    }
}
