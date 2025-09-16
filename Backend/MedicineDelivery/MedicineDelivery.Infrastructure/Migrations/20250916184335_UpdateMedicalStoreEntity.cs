using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MedicineDelivery.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class UpdateMedicalStoreEntity : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropPrimaryKey(
                name: "PK_MedicalStores",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "Id",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "CreatedAt",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "Email",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "LicenseNumber",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "Name",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "PhoneNumber",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "UpdatedAt",
                table: "MedicalStores");

            migrationBuilder.AlterColumn<string>(
                name: "Address",
                table: "MedicalStores",
                type: "nvarchar(300)",
                maxLength: 300,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)");

            migrationBuilder.AddColumn<Guid>(
                name: "MedicalStoreId",
                table: "MedicalStores",
                type: "uniqueidentifier",
                nullable: false,
                defaultValueSql: "NEWID()");

            migrationBuilder.AddColumn<string>(
                name: "AlternativeMobileNumber",
                table: "MedicalStores",
                type: "nvarchar(15)",
                maxLength: 15,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<Guid>(
                name: "CreatedBy",
                table: "MedicalStores",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedOn",
                table: "MedicalStores",
                type: "datetime2(7)",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<string>(
                name: "DLNo",
                table: "MedicalStores",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "EmailId",
                table: "MedicalStores",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "FSSAINo",
                table: "MedicalStores",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "GSTIN",
                table: "MedicalStores",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<bool>(
                name: "IsDeleted",
                table: "MedicalStores",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<decimal>(
                name: "Latitude",
                table: "MedicalStores",
                type: "decimal(18,6)",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "Longitude",
                table: "MedicalStores",
                type: "decimal(18,6)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MedicalName",
                table: "MedicalStores",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "MobileNumber",
                table: "MedicalStores",
                type: "nvarchar(15)",
                maxLength: 15,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "OwnerFirstName",
                table: "MedicalStores",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "OwnerLastName",
                table: "MedicalStores",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "OwnerMiddleName",
                table: "MedicalStores",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "PAN",
                table: "MedicalStores",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<Guid>(
                name: "UpdatedBy",
                table: "MedicalStores",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedOn",
                table: "MedicalStores",
                type: "datetime2(7)",
                nullable: true);

            migrationBuilder.AddPrimaryKey(
                name: "PK_MedicalStores",
                table: "MedicalStores",
                column: "MedicalStoreId");

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(891));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(894));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(895));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(897));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(898));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(933));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(935));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(936));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 9,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(938));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 10,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(939));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 11,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(941));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 12,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(942));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 13,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(943));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 14,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(944));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 15,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(945));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 16,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(947));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 17,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(948));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 18,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(949));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 19,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(950));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 20,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(951));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 21,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(952));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 22,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(953));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 23,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(955));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 24,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(956));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 25,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(957));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 26,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(958));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 27,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(960));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 28,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(961));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 29,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(962));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 30,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(963));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 31,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(965));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 32,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(966));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 33,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(967));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 1, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1148));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 2, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1150));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 3, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1151));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 4, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1152));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1153));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 6, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1154));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1155));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 8, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1156));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1157));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1158));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1159));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 12, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1160));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 13, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1161));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 14, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1162));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 15, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1162));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 16, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1163));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 17, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1164));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 18, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1165));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 19, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1166));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 20, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1167));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1168));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1169));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1170));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1171));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1171));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1172));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1174));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1175));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 29, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1175));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1176));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1177));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1179));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1180));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 1, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1181));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 3, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1181));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1182));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1183));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1184));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1207));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 17, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1208));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 18, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1209));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 19, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1210));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 20, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1211));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1212));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1213));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1214));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1215));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1216));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1216));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1217));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1218));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1219));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1220));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1221));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1222));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1224));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1225));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1225));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1226));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1227));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1228));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1229));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1230));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1230));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1231));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1232));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1233));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1234));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1235));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1236));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1237));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1237));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1238));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1239));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 6, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1240));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1241));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 8, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1242));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1243));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1243));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1245));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 12, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1246));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1247));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1248));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1248));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1121));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1124));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1126));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1127));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 43, 34, 270, DateTimeKind.Utc).AddTicks(1128));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropPrimaryKey(
                name: "PK_MedicalStores",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "MedicalStoreId",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "AlternativeMobileNumber",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "CreatedBy",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "CreatedOn",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "DLNo",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "EmailId",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "FSSAINo",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "GSTIN",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "IsDeleted",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "Latitude",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "Longitude",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "MedicalName",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "MobileNumber",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "OwnerFirstName",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "OwnerLastName",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "OwnerMiddleName",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "PAN",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "UpdatedBy",
                table: "MedicalStores");

            migrationBuilder.DropColumn(
                name: "UpdatedOn",
                table: "MedicalStores");

            migrationBuilder.AlterColumn<string>(
                name: "Address",
                table: "MedicalStores",
                type: "nvarchar(max)",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(300)",
                oldMaxLength: 300);

            migrationBuilder.AddColumn<int>(
                name: "Id",
                table: "MedicalStores",
                type: "int",
                nullable: false,
                defaultValue: 0)
                .Annotation("SqlServer:Identity", "1, 1");

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAt",
                table: "MedicalStores",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<string>(
                name: "Email",
                table: "MedicalStores",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "LicenseNumber",
                table: "MedicalStores",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "Name",
                table: "MedicalStores",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "PhoneNumber",
                table: "MedicalStores",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAt",
                table: "MedicalStores",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddPrimaryKey(
                name: "PK_MedicalStores",
                table: "MedicalStores",
                column: "Id");

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(5));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(7));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(9));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(10));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(12));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(13));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(14));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(15));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 9,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(16));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 10,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(18));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 11,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(19));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 12,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(20));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 13,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(21));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 14,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(22));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 15,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(23));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 16,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(24));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 17,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(26));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 18,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(27));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 19,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(28));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 20,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(29));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 21,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(30));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 22,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(31));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 23,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(33));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 24,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(34));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 25,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(35));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 26,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(37));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 27,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(38));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 28,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(39));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 29,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(40));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 30,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(41));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 31,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(42));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 32,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(43));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 33,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(73));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 1, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(245));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 2, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(247));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 3, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(248));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 4, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(249));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(250));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 6, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(251));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(252));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 8, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(253));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(254));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(254));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(255));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 12, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(256));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 13, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(257));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 14, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(258));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 15, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(259));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 16, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(260));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 17, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(261));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 18, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(262));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 19, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(263));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 20, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(263));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(264));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(265));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(266));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(267));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(268));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(269));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(270));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(271));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 29, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(271));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(272));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(273));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(274));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(275));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 1, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(276));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 3, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(277));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(278));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(279));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(280));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(281));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 17, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(282));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 18, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(283));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 19, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(285));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 20, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(286));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(287));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(287));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(288));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(289));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(290));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(291));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(293));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(294));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(295));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(296));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(297));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(298));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(299));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(299));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(300));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(301));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(302));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(303));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(304));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(305));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(306));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(306));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(307));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(308));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(309));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(310));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(311));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(312));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(313));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(314));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(316));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 6, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(317));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(317));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 8, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(318));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(319));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(320));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(360));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 12, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(361));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(362));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(363));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(364));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(219));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(221));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(222));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(223));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(224));
        }
    }
}
