using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace MedicineDelivery.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddAllCustomerPermissions : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 42, 1 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 44, 1 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 45, 1 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 42, 2 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 44, 2 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 45, 2 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 42, 3 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 44, 3 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 45, 3 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 43, 4 });

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1069));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1070));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1072));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1073));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1074));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1076));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1077));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1078));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 9,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1079));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 10,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1081));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 11,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1082));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 12,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1083));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 13,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1084));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 14,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1085));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 15,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1086));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 16,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1087));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 17,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1089));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 18,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1090));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 19,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1091));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 20,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1092));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 21,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1093));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 22,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1094));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 23,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1096));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 24,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1097));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 25,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1099));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 26,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1100));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 27,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1103));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 28,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1104));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 29,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1105));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 30,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1106));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 31,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1107));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 32,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1108));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 33,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1109));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 34,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1110));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 35,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1112));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 36,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1113));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 37,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1114));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 38,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1115));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 39,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1116));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 40,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1117));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 41,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1119));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 42,
                columns: new[] { "CreatedAt", "Description" },
                values: new object[] { new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1120), "Can read own customer information" });

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 43,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1121));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 44,
                columns: new[] { "CreatedAt", "Description" },
                values: new object[] { new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1122), "Can update own customer information" });

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 45,
                columns: new[] { "CreatedAt", "Description" },
                values: new object[] { new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1123), "Can delete own customer account" });

            migrationBuilder.InsertData(
                table: "Permissions",
                columns: new[] { "Id", "CreatedAt", "Description", "IsActive", "Module", "Name" },
                values: new object[,]
                {
                    { 46, new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1125), "Can read all customer information", true, "Customer", "AllCustomerRead" },
                    { 47, new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1126), "Can update any customer information", true, "Customer", "AllCustomerUpdate" },
                    { 48, new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1127), "Can delete any customer account", true, "Customer", "AllCustomerDelete" }
                });

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 1, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1357));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 2, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1359));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 3, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1360));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 4, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1362));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1362));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 6, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1364));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1365));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 8, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1366));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1367));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1367));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1368));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 12, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1369));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 13, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1370));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 14, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1371));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 15, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1372));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 16, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1373));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 17, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1374));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 18, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1375));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 19, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1376));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 20, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1377));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1377));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1378));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1379));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1380));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1381));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1382));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1383));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1383));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 29, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1384));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1386));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1387));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1388));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1388));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1389));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 35, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1390));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1391));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1392));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 38, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1393));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 39, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1394));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 40, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1395));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 41, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1395));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 43, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1399));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 1, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1400));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 3, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1401));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1402));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1402));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1403));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1404));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 17, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1406));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 18, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1406));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 19, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1407));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 20, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1408));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1409));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1410));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1411));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1412));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1413));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1414));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1414));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1415));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1416));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1417));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1418));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1419));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1420));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 35, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1421));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1422));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1423));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 38, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1423));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 40, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1424));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 41, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1425));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 43, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1430));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1430));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1431));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1432));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1433));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1434));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1435));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1436));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1437));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1438));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1438));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1460));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1461));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1462));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1463));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1464));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1464));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1465));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1466));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 43, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1470));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1471));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1475));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1476));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 42, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1478));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 44, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1479));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 45, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1480));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1481));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 6, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1482));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1482));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 8, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1483));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1484));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1485));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1486));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 12, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1487));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1488));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1488));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1489));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1328));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1330));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1331));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1333));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1334));

            migrationBuilder.InsertData(
                table: "RolePermissions",
                columns: new[] { "PermissionId", "RoleId", "GrantedAt", "GrantedBy", "IsActive" },
                values: new object[,]
                {
                    { 46, 1, new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1396), null, true },
                    { 47, 1, new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1397), null, true },
                    { 48, 1, new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1398), null, true },
                    { 46, 2, new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1426), null, true },
                    { 47, 2, new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1427), null, true },
                    { 48, 2, new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1428), null, true },
                    { 46, 3, new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1467), null, true },
                    { 47, 3, new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1468), null, true },
                    { 48, 3, new DateTime(2025, 9, 20, 11, 25, 47, 313, DateTimeKind.Utc).AddTicks(1469), null, true }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 46, 1 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 47, 1 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 48, 1 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 46, 2 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 47, 2 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 48, 2 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 46, 3 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 47, 3 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 48, 3 });

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 46);

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 47);

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 48);

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1462));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1463));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1465));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1466));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1469));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1470));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1471));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1474));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 9,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1476));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 10,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1477));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 11,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1478));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 12,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1479));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 13,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1480));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 14,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1481));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 15,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1483));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 16,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1484));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 17,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1485));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 18,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1486));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 19,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1487));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 20,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1488));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 21,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1489));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 22,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1491));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 23,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1521));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 24,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1523));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 25,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1524));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 26,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1525));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 27,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1526));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 28,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1527));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 29,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1529));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 30,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1530));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 31,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1531));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 32,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1532));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 33,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1533));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 34,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1534));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 35,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1535));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 36,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1537));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 37,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1538));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 38,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1539));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 39,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1540));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 40,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1541));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 41,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1543));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 42,
                columns: new[] { "CreatedAt", "Description" },
                values: new object[] { new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1544), "Can read customer information" });

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 43,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1546));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 44,
                columns: new[] { "CreatedAt", "Description" },
                values: new object[] { new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1547), "Can update customer information" });

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 45,
                columns: new[] { "CreatedAt", "Description" },
                values: new object[] { new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1548), "Can delete customer accounts" });

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 1, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1834));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 2, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1836));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 3, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1837));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 4, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1838));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1839));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 6, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1840));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1841));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 8, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1842));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1842));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1843));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1844));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 12, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1845));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 13, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1846));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 14, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1847));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 15, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1848));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 16, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1849));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 17, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1850));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 18, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1851));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 19, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1851));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 20, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1852));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1853));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1854));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1855));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1856));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1857));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1858));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1858));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1859));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 29, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1860));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1861));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1862));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1863));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1864));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1865));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 35, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1866));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1867));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1868));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 38, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1869));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 39, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1870));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 40, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1870));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 41, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1871));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 43, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1897));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 1, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1900));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 3, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1901));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1902));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1903));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1903));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1904));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 17, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1905));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 18, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1906));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 19, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1907));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 20, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1908));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1909));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1909));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1911));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1912));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1913));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1915));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1915));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1916));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1917));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1918));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1919));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1919));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1920));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 35, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1921));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1922));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1923));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 38, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1924));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 40, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1925));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 41, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1925));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 43, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1927));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1930));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1931));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1931));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1933));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1934));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1935));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1936));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1937));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1937));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1938));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1939));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1940));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1941));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1943));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1944));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1944));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1945));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1946));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 43, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1948));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1950));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1951));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1952));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 42, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1953));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 44, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1955));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 45, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1956));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1957));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 6, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1958));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1958));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 8, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1959));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1960));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1963));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1963));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 12, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1964));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1965));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1966));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1969));

            migrationBuilder.InsertData(
                table: "RolePermissions",
                columns: new[] { "PermissionId", "RoleId", "GrantedAt", "GrantedBy", "IsActive" },
                values: new object[,]
                {
                    { 42, 1, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1872), null, true },
                    { 44, 1, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1898), null, true },
                    { 45, 1, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1899), null, true },
                    { 42, 2, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1926), null, true },
                    { 44, 2, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1928), null, true },
                    { 45, 2, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1929), null, true },
                    { 42, 3, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1947), null, true },
                    { 44, 3, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1949), null, true },
                    { 45, 3, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1950), null, true },
                    { 43, 4, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1954), null, true }
                });

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1802));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1807));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1809));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1810));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1812));
        }
    }
}
