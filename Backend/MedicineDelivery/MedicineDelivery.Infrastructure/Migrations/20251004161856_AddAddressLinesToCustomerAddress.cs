using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MedicineDelivery.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddAddressLinesToCustomerAddress : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "AddressLine1",
                table: "CustomerAddresses",
                type: "character varying(300)",
                maxLength: 300,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "AddressLine2",
                table: "CustomerAddresses",
                type: "character varying(300)",
                maxLength: 300,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "AddressLine3",
                table: "CustomerAddresses",
                type: "character varying(300)",
                maxLength: 300,
                nullable: true);

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8167));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8169));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8171));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8172));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8173));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8174));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8176));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8177));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 9,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8178));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 10,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8179));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 11,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8181));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 12,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8182));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 13,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8183));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 14,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8184));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 15,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8185));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 16,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8187));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 17,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8188));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 18,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8189));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 19,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8190));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 20,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8191));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 21,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8192));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 22,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8193));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 23,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8194));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 24,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8196));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 25,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8197));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 26,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8198));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 27,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8199));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 28,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8200));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 29,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8201));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 30,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8203));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 31,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8204));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 32,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8205));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 33,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8207));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 34,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8208));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 35,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8209));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 36,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8210));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 37,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8211));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 38,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8213));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 39,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8214));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 40,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8215));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 41,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8216));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 42,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8217));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 43,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8218));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 44,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8220));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 45,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8221));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 46,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8222));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 47,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8223));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 48,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8224));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 49,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8225));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 50,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8226));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 51,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8227));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 1, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8524));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 2, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8526));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 3, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8527));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 4, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8528));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8529));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 6, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8530));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8532));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 8, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8533));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8534));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8535));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8536));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 12, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8537));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 13, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8538));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 14, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8539));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 15, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8540));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 16, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8540));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 17, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8541));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 18, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8543));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 19, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8544));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 20, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8545));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8546));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8547));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8548));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8549));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8549));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8550));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8552));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8552));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 29, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8553));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8554));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8555));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8556));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8557));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8558));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 35, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8559));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8560));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8560));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 38, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8562));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 39, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8562));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 40, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8563));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 41, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8565));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 43, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8569));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 46, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8566));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 47, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8567));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 48, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8568));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 49, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8570));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 50, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8571));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 51, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8572));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 1, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8574));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 3, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8575));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8576));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8577));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8578));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8579));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 17, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8580));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 18, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8581));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 19, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8582));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 20, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8583));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8583));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8584));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8585));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8586));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8587));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8589));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8589));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8590));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8591));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8592));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8593));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8594));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8595));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 35, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8596));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8597));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8597));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 38, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8598));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 40, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8599));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 41, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8600));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 43, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8604));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 46, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8601));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 47, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8602));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 48, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8603));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 49, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8605));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 50, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8605));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 51, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8606));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8607));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8608));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8610));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8610));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8611));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8612));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8613));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8614));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8615));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8616));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8616));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8617));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8618));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8619));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8620));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8621));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8621));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8622));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 43, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8625));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 46, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8623));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 47, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8624));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 48, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8625));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 49, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8626));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 50, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8627));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 51, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8628));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, "4" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8630));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, "4" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8631));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, "4" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8631));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 42, "4" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8632));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 44, "4" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8633));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 45, "4" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8634));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, "5" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8635));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 6, "5" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8636));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, "5" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8636));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 8, "5" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8637));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, "5" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8638));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, "5" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8639));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, "5" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8640));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 12, "5" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8641));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, "5" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8664));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, "5" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8665));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, "5" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 16, 18, 54, 796, DateTimeKind.Utc).AddTicks(8666));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "AddressLine1",
                table: "CustomerAddresses");

            migrationBuilder.DropColumn(
                name: "AddressLine2",
                table: "CustomerAddresses");

            migrationBuilder.DropColumn(
                name: "AddressLine3",
                table: "CustomerAddresses");

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7161));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7163));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7164));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7167));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7169));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7170));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7171));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7172));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 9,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7174));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 10,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7175));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 11,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7176));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 12,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7178));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 13,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7179));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 14,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7180));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 15,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7182));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 16,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7183));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 17,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7185));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 18,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7186));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 19,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7188));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 20,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7189));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 21,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7190));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 22,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7217));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 23,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7219));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 24,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7220));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 25,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7221));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 26,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7222));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 27,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7224));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 28,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7226));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 29,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7227));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 30,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7228));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 31,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7229));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 32,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7232));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 33,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7234));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 34,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7235));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 35,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7236));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 36,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7237));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 37,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7238));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 38,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7240));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 39,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7241));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 40,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7244));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 41,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7246));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 42,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7248));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 43,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7250));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 44,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7251));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 45,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7252));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 46,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7255));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 47,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7256));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 48,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7257));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 49,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7258));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 50,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7260));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 51,
                column: "CreatedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7261));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 1, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7529));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 2, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7532));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 3, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7533));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 4, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7534));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7535));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 6, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7536));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7537));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 8, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7539));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7540));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7541));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7544));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 12, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7545));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 13, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7546));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 14, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7547));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 15, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7549));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 16, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7550));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 17, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7551));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 18, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7552));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 19, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7554));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 20, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7555));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7556));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7557));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7558));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7559));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7560));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7561));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7562));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7563));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 29, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7564));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7565));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7566));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7567));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7568));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7618));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 35, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7619));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7621));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7622));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 38, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7623));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 39, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7624));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 40, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7625));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 41, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7626));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 43, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7630));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 46, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7627));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 47, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7628));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 48, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7629));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 49, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7631));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 50, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7632));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 51, "1" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7634));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 1, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7635));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 3, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7636));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7637));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7638));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7639));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7640));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 17, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7641));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 18, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7642));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 19, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7643));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 20, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7644));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7645));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7646));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7646));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7647));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7648));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7650));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7651));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7652));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7653));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7654));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7655));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7656));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7658));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 35, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7659));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7660));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7661));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 38, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7662));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 40, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7663));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 41, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7664));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 43, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7668));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 46, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7665));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 47, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7666));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 48, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7667));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 49, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7669));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 50, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7670));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 51, "2" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7671));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7672));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7673));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7675));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7676));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7677));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7678));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7679));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7680));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7681));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7682));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7683));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7684));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7685));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7686));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7687));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7688));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7689));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7690));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 43, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7693));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 46, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7690));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 47, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7691));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 48, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7692));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 49, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7694));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 50, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7695));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 51, "3" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7696));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, "4" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7697));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, "4" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7698));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, "4" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7700));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 42, "4" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7701));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 44, "4" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7702));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 45, "4" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7703));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, "5" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7704));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 6, "5" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7706));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, "5" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7707));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 8, "5" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7707));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, "5" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7708));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, "5" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7709));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, "5" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7710));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 12, "5" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7711));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, "5" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7712));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, "5" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7713));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, "5" },
                column: "GrantedAt",
                value: new DateTime(2025, 10, 4, 15, 46, 33, 385, DateTimeKind.Utc).AddTicks(7714));
        }
    }
}
