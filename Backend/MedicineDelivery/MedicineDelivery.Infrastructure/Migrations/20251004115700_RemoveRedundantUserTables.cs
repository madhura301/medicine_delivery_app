using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MedicineDelivery.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class RemoveRedundantUserTables : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Drop foreign key constraints first
            migrationBuilder.DropForeignKey(
                name: "FK_Customers_Users_UserId",
                table: "Customers");

            migrationBuilder.DropForeignKey(
                name: "FK_CustomerSupports_Users_UserId",
                table: "CustomerSupports");

            migrationBuilder.DropForeignKey(
                name: "FK_Managers_Users_UserId",
                table: "Managers");

            migrationBuilder.DropForeignKey(
                name: "FK_MedicalStores_Users_UserId",
                table: "MedicalStores");

            migrationBuilder.DropForeignKey(
                name: "FK_RolePermissions_Roles_RoleId",
                table: "RolePermissions");

            // Drop the redundant tables
            migrationBuilder.DropTable(
                name: "UserRoles");

            migrationBuilder.DropTable(
                name: "Roles");

            migrationBuilder.DropTable(
                name: "Users");

            // Update RolePermissions table to use string RoleId
            migrationBuilder.AlterColumn<string>(
                name: "RoleId",
                table: "RolePermissions",
                type: "text",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "integer");

            // Add foreign key constraints to AspNetUsers
            migrationBuilder.AddForeignKey(
                name: "FK_Customers_AspNetUsers_UserId",
                table: "Customers",
                column: "UserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_CustomerSupports_AspNetUsers_UserId",
                table: "CustomerSupports",
                column: "UserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Managers_AspNetUsers_UserId",
                table: "Managers",
                column: "UserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_MedicalStores_AspNetUsers_UserId",
                table: "MedicalStores",
                column: "UserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_RolePermissions_AspNetRoles_RoleId",
                table: "RolePermissions",
                column: "RoleId",
                principalTable: "AspNetRoles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            // Insert seed data for Identity roles
            migrationBuilder.InsertData(
                table: "AspNetRoles",
                columns: new[] { "Id", "Name", "NormalizedName", "ConcurrencyStamp" },
                values: new object[,]
                {
                    { "1", "Admin", "ADMIN", Guid.NewGuid().ToString() },
                    { "2", "Manager", "MANAGER", Guid.NewGuid().ToString() },
                    { "3", "Chemist", "CHEMIST", Guid.NewGuid().ToString() },
                    { "4", "Customer", "CUSTOMER", Guid.NewGuid().ToString() },
                    { "5", "CustomerSupport", "CUSTOMERSUPPORT", Guid.NewGuid().ToString() }
                });

            // Insert seed data for RolePermissions with string RoleId
            migrationBuilder.InsertData(
                table: "RolePermissions",
                columns: new[] { "PermissionId", "RoleId", "GrantedAt", "IsActive" },
                values: new object[,]
                {
                    // Admin permissions (RoleId = "1")
                    { 1, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 2, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 3, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 4, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 5, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 6, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 7, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 8, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 9, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 10, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 11, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 12, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 13, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 14, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 15, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 16, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 17, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 18, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 19, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 20, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 21, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 22, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 23, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 24, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 25, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 26, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 27, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 28, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 29, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 30, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 31, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 32, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 33, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 34, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 35, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 36, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 37, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 38, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 39, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 40, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 41, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 43, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 46, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 47, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true },
                    { 48, "1", new DateTime(2025, 10, 4, 17, 57, 0, 0, DateTimeKind.Utc), true }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Remove foreign key constraints
            migrationBuilder.DropForeignKey(
                name: "FK_Customers_AspNetUsers_UserId",
                table: "Customers");

            migrationBuilder.DropForeignKey(
                name: "FK_CustomerSupports_AspNetUsers_UserId",
                table: "CustomerSupports");

            migrationBuilder.DropForeignKey(
                name: "FK_Managers_AspNetUsers_UserId",
                table: "Managers");

            migrationBuilder.DropForeignKey(
                name: "FK_MedicalStores_AspNetUsers_UserId",
                table: "MedicalStores");

            migrationBuilder.DropForeignKey(
                name: "FK_RolePermissions_AspNetRoles_RoleId",
                table: "RolePermissions");

            // Revert RoleId column back to integer
            migrationBuilder.AlterColumn<int>(
                name: "RoleId",
                table: "RolePermissions",
                type: "integer",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "text");

            // Recreate the redundant tables (simplified version)
            migrationBuilder.CreateTable(
                name: "Roles",
                columns: table => new
                {
                    RoleId = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", Npgsql.EntityFrameworkCore.PostgreSQL.Metadata.NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    RoleName = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Description = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Roles", x => x.RoleId);
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    UserId = table.Column<Guid>(type: "uuid", nullable: false),
                    Username = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Email = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    PasswordHash = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    FirstName = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    LastName = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.UserId);
                });

            migrationBuilder.CreateTable(
                name: "UserRoles",
                columns: table => new
                {
                    UserId = table.Column<Guid>(type: "uuid", nullable: false),
                    RoleId = table.Column<int>(type: "integer", nullable: false),
                    AssignedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    AssignedBy = table.Column<Guid>(type: "uuid", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserRoles", x => new { x.UserId, x.RoleId });
                    table.ForeignKey(
                        name: "FK_UserRoles_Roles_RoleId",
                        column: x => x.RoleId,
                        principalTable: "Roles",
                        principalColumn: "RoleId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_UserRoles_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Cascade);
                });

            // Restore foreign key constraints to old tables
            migrationBuilder.AddForeignKey(
                name: "FK_Customers_Users_UserId",
                table: "Customers",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "UserId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_CustomerSupports_Users_UserId",
                table: "CustomerSupports",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "UserId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Managers_Users_UserId",
                table: "Managers",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "UserId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_MedicalStores_Users_UserId",
                table: "MedicalStores",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "UserId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_RolePermissions_Roles_RoleId",
                table: "RolePermissions",
                column: "RoleId",
                principalTable: "Roles",
                principalColumn: "RoleId",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
