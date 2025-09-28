using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MedicineDelivery.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddCustomerAddressTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Address",
                table: "Customers");

            migrationBuilder.DropColumn(
                name: "City",
                table: "Customers");

            migrationBuilder.DropColumn(
                name: "PostalCode",
                table: "Customers");

            migrationBuilder.DropColumn(
                name: "State",
                table: "Customers");

            migrationBuilder.AlterColumn<DateTime>(
                name: "UpdatedOn",
                table: "MedicalStores",
                type: "timestamp with time zone",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "CreatedOn",
                table: "MedicalStores",
                type: "timestamp with time zone",
                nullable: false,
                oldClrType: typeof(DateTime),
                oldType: "timestamp");

            migrationBuilder.AlterColumn<DateTime>(
                name: "UpdatedOn",
                table: "Managers",
                type: "timestamp with time zone",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "CreatedOn",
                table: "Managers",
                type: "timestamp with time zone",
                nullable: false,
                oldClrType: typeof(DateTime),
                oldType: "timestamp");

            migrationBuilder.AlterColumn<DateTime>(
                name: "UpdatedOn",
                table: "CustomerSupports",
                type: "timestamp with time zone",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "CreatedOn",
                table: "CustomerSupports",
                type: "timestamp with time zone",
                nullable: false,
                oldClrType: typeof(DateTime),
                oldType: "timestamp");

            migrationBuilder.AlterColumn<DateTime>(
                name: "UpdatedOn",
                table: "Customers",
                type: "timestamp with time zone",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "CreatedOn",
                table: "Customers",
                type: "timestamp with time zone",
                nullable: false,
                oldClrType: typeof(DateTime),
                oldType: "timestamp");

            migrationBuilder.CreateTable(
                name: "CustomerAddresses",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    CustomerId = table.Column<Guid>(type: "uuid", nullable: false),
                    Address = table.Column<string>(type: "character varying(300)", maxLength: 300, nullable: true),
                    City = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    State = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    PostalCode = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    IsDefault = table.Column<bool>(type: "boolean", nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedOn = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedOn = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CustomerAddresses", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CustomerAddresses_Customers_CustomerId",
                        column: x => x.CustomerId,
                        principalTable: "Customers",
                        principalColumn: "CustomerId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7395));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7429));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7430));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7432));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7433));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7435));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7436));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7437));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 9,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7438));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 10,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7440));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 11,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7441));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 12,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7442));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 13,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7443));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 14,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7444));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 15,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7446));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 16,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7447));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 17,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7448));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 18,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7450));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 19,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7451));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 20,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7453));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 21,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7454));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 22,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7455));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 23,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7456));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 24,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7457));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 25,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7459));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 26,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7460));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 27,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7461));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 28,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7462));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 29,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7464));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 30,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7465));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 31,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7466));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 32,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7467));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 33,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7468));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 34,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7469));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 35,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7470));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 36,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7472));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 37,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7474));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 38,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7475));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 39,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7476));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 40,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7477));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 41,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7478));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 42,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7479));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 43,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7481));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 44,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7482));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 45,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7483));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 46,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7484));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 47,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7485));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 48,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7487));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 49,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7488));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 50,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7490));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 51,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7491));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 1, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7810));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 2, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7813));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 3, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7814));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 4, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7815));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7816));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 6, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7817));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7818));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 8, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7819));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7820));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7821));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7823));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 12, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7824));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 13, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7825));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 14, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7826));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 15, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7827));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 16, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7828));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 17, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7829));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 18, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7830));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 19, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7831));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 20, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7832));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7833));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7834));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7835));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7836));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7837));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7838));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7839));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7840));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 29, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7841));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7842));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7843));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7844));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7845));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7846));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 35, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7847));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7848));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7849));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 38, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7850));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 39, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7851));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 40, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7852));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 41, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7853));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 43, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7857));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 46, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7854));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 47, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7855));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 48, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7856));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 49, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7858));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 50, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7859));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 51, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7860));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 1, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7861));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 3, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7861));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7862));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7863));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7864));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7865));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 17, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7866));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 18, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7867));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 19, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7868));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 20, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7870));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7871));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7871));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7872));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7873));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7874));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7875));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7876));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7877));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7878));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7880));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7881));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7881));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7882));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 35, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7883));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7884));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7885));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 38, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7886));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 40, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7887));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 41, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7888));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 43, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7892));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 46, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7889));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 47, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7890));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 48, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7891));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 49, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7892));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 50, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7893));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 51, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7894));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7895));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7896));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7897));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7898));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7899));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7900));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7900));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7901));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7902));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7903));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7904));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7905));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7906));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7907));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7908));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7908));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7909));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7910));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 43, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7914));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 46, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7911));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 47, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7912));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 48, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7913));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 49, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7915));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 50, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7916));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 51, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7916));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7917));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7918));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7919));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 42, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7920));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 44, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7921));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 45, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7922));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7922));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 6, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7923));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7924));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 8, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7925));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7926));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7927));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7928));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 12, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7929));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7930));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7930));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7931));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7740));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7743));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7744));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7746));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 28, 15, 1, 43, 836, DateTimeKind.Utc).AddTicks(7748));

            migrationBuilder.CreateIndex(
                name: "IX_CustomerAddresses_CustomerId",
                table: "CustomerAddresses",
                column: "CustomerId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "CustomerAddresses");

            migrationBuilder.AlterColumn<DateTime>(
                name: "UpdatedOn",
                table: "MedicalStores",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp with time zone",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "CreatedOn",
                table: "MedicalStores",
                type: "timestamp",
                nullable: false,
                oldClrType: typeof(DateTime),
                oldType: "timestamp with time zone");

            migrationBuilder.AlterColumn<DateTime>(
                name: "UpdatedOn",
                table: "Managers",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp with time zone",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "CreatedOn",
                table: "Managers",
                type: "timestamp",
                nullable: false,
                oldClrType: typeof(DateTime),
                oldType: "timestamp with time zone");

            migrationBuilder.AlterColumn<DateTime>(
                name: "UpdatedOn",
                table: "CustomerSupports",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp with time zone",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "CreatedOn",
                table: "CustomerSupports",
                type: "timestamp",
                nullable: false,
                oldClrType: typeof(DateTime),
                oldType: "timestamp with time zone");

            migrationBuilder.AlterColumn<DateTime>(
                name: "UpdatedOn",
                table: "Customers",
                type: "timestamp",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp with time zone",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "CreatedOn",
                table: "Customers",
                type: "timestamp",
                nullable: false,
                oldClrType: typeof(DateTime),
                oldType: "timestamp with time zone");

            migrationBuilder.AddColumn<string>(
                name: "Address",
                table: "Customers",
                type: "character varying(300)",
                maxLength: 300,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "City",
                table: "Customers",
                type: "character varying(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PostalCode",
                table: "Customers",
                type: "character varying(20)",
                maxLength: 20,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "State",
                table: "Customers",
                type: "character varying(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6087));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6091));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6092));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6094));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6095));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6096));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6098));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6099));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 9,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6100));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 10,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6101));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 11,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6103));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 12,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6104));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 13,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6106));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 14,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6107));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 15,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6108));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 16,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6109));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 17,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6110));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 18,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6111));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 19,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6112));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 20,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6113));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 21,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6115));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 22,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6116));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 23,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6117));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 24,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6118));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 25,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6119));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 26,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6121));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 27,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6122));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 28,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6123));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 29,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6125));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 30,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6126));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 31,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6127));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 32,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6128));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 33,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6129));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 34,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6130));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 35,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6131));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 36,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6132));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 37,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6134));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 38,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6135));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 39,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6136));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 40,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6137));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 41,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6138));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 42,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6139));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 43,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6141));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 44,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6142));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 45,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6143));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 46,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6144));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 47,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6146));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 48,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6147));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 49,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6149));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 50,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6150));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 51,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6151));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 1, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6484));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 2, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6485));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 3, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6486));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 4, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6487));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6488));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 6, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6489));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6490));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 8, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6491));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6492));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6493));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6495));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 12, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6496));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 13, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6497));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 14, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6497));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 15, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6498));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 16, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6500));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 17, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6501));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 18, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6501));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 19, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6502));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 20, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6503));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6504));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6505));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6506));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6507));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6507));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6508));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6509));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6510));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 29, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6511));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6512));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6513));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6513));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6514));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6516));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 35, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6517));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6518));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6519));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 38, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6519));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 39, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6520));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 40, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6521));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 41, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6522));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 43, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6525));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 46, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6523));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 47, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6524));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 48, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6524));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 49, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6526));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 50, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6527));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 51, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6528));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 1, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6529));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 3, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6530));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6531));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6532));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6532));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6533));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 17, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6534));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 18, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6535));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 19, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6536));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 20, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6538));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6538));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6539));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6540));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6541));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6542));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6543));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6544));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6545));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6545));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6546));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6547));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6551));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6551));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 35, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6552));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6553));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6554));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 38, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6555));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 40, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6556));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 41, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6556));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 43, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6560));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 46, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6557));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 47, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6558));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 48, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6559));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 49, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6561));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 50, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6562));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 51, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6563));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6564));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6565));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6566));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6570));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6572));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6573));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6582));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6582));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6583));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6584));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6585));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6586));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6587));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6588));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6589));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6590));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6590));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6591));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 43, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6595));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 46, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6592));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 47, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6593));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 48, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6594));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 49, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6596));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 50, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6597));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 51, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6598));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6598));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6599));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6600));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 42, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6601));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 44, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6602));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 45, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6603));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6604));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 6, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6605));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6606));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 8, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6607));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6608));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6630));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6631));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 12, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6632));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6633));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6634));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6635));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6434));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6436));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6438));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6439));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 25, 19, 39, 54, 513, DateTimeKind.Utc).AddTicks(6440));
        }
    }
}
