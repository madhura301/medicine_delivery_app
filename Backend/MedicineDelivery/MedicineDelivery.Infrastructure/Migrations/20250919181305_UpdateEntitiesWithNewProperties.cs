using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MedicineDelivery.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class UpdateEntitiesWithNewProperties : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "Address",
                table: "MedicalStores",
                newName: "AddressLine2");

            migrationBuilder.AlterColumn<string>(
                name: "GSTIN",
                table: "MedicalStores",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(100)",
                oldMaxLength: 100);

            migrationBuilder.AddColumn<string>(
                name: "AddressLine1",
                table: "MedicalStores",
                type: "nvarchar(300)",
                maxLength: 300,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "City",
                table: "MedicalStores",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "PharmacistFirstName",
                table: "MedicalStores",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "PharmacistLastName",
                table: "MedicalStores",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "PharmacistMobileNumber",
                table: "MedicalStores",
                type: "nvarchar(15)",
                maxLength: 15,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "PharmacistRegistrationNumber",
                table: "MedicalStores",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "PostalCode",
                table: "MedicalStores",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<bool>(
                name: "RegistrationStatus",
                table: "MedicalStores",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "State",
                table: "MedicalStores",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "EmployeeId",
                table: "Managers",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "ManagerPhoto",
                table: "Managers",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "CustomerSupportPhoto",
                table: "CustomerSupports",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "EmployeeId",
                table: "CustomerSupports",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "");

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(958));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(960));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(961));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(963));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(964));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(965));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(966));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(967));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 9,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(970));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 10,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(971));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 11,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(972));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 12,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(973));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 13,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(975));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 14,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(976));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 15,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(977));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 16,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(978));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 17,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(979));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 18,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(981));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 19,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(982));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 20,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(983));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 21,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(984));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 22,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(986));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 23,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(987));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 24,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(988));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 25,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(989));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 26,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(991));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 27,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(992));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 28,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(994));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 29,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(995));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 30,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(996));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 31,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(998));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 32,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(999));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 33,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1000));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 34,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1001));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 35,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1003));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 36,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1004));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 37,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1040));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 38,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1042));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 39,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1043));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 40,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1044));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 41,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1046));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 1, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1283));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 2, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1285));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 3, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1286));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 4, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1287));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1289));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 6, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1290));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1291));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 8, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1292));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1293));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1294));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1295));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 12, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1296));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 13, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1297));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 14, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1298));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 15, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1299));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 16, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1300));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 17, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1301));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 18, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1302));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 19, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1303));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 20, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1304));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1305));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1306));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1307));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1308));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1309));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1310));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1311));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1312));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 29, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1313));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1314));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1315));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1316));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1317));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1318));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 35, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1319));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1320));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1321));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 38, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1322));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 39, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1323));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 40, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1324));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 41, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1325));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 1, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1326));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 3, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1327));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1328));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1329));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1330));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1331));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 17, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1332));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 18, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1333));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 19, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1334));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 20, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1335));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1336));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1337));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1338));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1339));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1340));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1341));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1342));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1343));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1344));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1345));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1346));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1347));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1348));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 35, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1348));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1349));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1350));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 38, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1351));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 40, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1352));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 41, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1354));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1355));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1379));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1380));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1381));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1382));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1383));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1384));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1385));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1386));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1387));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1388));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1389));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1390));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1391));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1392));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1393));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1394));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1395));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1396));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1397));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1397));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1398));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 6, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1399));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1400));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 8, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1401));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1402));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1403));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1404));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 12, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1405));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1406));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1407));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1408));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1252));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1254));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1256));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1257));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 19, 18, 13, 3, 250, DateTimeKind.Utc).AddTicks(1262));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "AddressLine1",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "City",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "PharmacistFirstName",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "PharmacistLastName",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "PharmacistMobileNumber",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "PharmacistRegistrationNumber",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "PostalCode",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "RegistrationStatus",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "State",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "EmployeeId",
                table: "Managers");

            migrationBuilder.DropColumn(
                name: "ManagerPhoto",
                table: "Managers");

            migrationBuilder.DropColumn(
                name: "CustomerSupportPhoto",
                table: "CustomerSupports");

            migrationBuilder.DropColumn(
                name: "EmployeeId",
                table: "CustomerSupports");

            migrationBuilder.RenameColumn(
                name: "AddressLine2",
                table: "MedicalStores",
                newName: "Address");

            migrationBuilder.AlterColumn<string>(
                name: "GSTIN",
                table: "MedicalStores",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(100)",
                oldMaxLength: 100,
                oldNullable: true);

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(3943));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(3945));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(3947));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(3948));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(3950));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(3951));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(3952));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(3953));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 9,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(3955));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 10,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(3956));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 11,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(3958));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 12,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(3959));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 13,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(3960));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 14,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(3961));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 15,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(3963));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 16,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(3990));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 17,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(3993));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 18,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(3994));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 19,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(3996));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 20,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(3998));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 21,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(3999));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 22,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4000));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 23,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4002));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 24,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4003));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 25,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4005));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 26,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4007));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 27,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4011));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 28,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4013));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 29,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4015));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 30,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4016));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 31,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4018));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 32,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4019));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 33,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4021));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 34,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4022));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 35,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4023));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 36,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4024));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 37,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4025));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 38,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4026));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 39,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4028));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 40,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4029));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 41,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4030));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 1, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4241));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 2, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4243));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 3, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4244));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 4, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4245));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4245));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 6, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4246));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4247));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 8, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4248));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4249));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4250));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4251));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 12, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4252));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 13, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4254));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 14, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4255));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 15, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4256));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 16, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4257));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 17, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4258));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 18, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4258));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 19, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4259));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 20, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4260));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4261));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4262));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4263));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4264));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4266));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4267));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4268));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4269));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 29, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4269));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4270));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4271));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4272));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4273));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4274));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 35, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4275));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4276));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4276));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 38, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4277));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 39, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4278));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 40, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4297));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 41, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4298));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 1, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4298));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 3, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4299));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4300));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4301));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4302));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4304));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 17, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4304));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 18, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4305));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 19, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4306));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 20, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4307));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4308));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4309));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4310));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4311));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4312));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4313));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4313));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4314));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4315));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4316));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4317));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4318));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4319));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 35, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4319));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4320));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4321));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 38, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4322));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 40, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4323));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 41, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4324));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4325));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4326));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4327));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4328));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4329));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4330));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4331));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4332));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4332));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4333));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4334));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4335));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4336));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4337));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4338));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4339));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4340));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4341));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4342));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4343));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4343));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4344));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 6, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4345));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4346));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 8, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4347));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4348));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4349));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4350));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 12, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4351));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4352));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4352));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4353));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4216));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4218));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4219));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4220));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 19, 18, 19, 87, DateTimeKind.Utc).AddTicks(4222));
        }
    }
}
