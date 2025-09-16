using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace MedicineDelivery.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddMedicalStoreAndChemistPermissions : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "MedicalStores",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Email = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Address = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    PhoneNumber = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    LicenseNumber = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    UserId = table.Column<string>(type: "nvarchar(450)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MedicalStores", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MedicalStores_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

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

            migrationBuilder.InsertData(
                table: "Permissions",
                columns: new[] { "Id", "CreatedAt", "Description", "IsActive", "Module", "Name" },
                values: new object[,]
                {
                    { 30, new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(41), "Can read chemist information", true, "Chemist", "ChemistRead" },
                    { 31, new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(42), "Can create chemist accounts", true, "Chemist", "ChemistCreate" },
                    { 32, new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(43), "Can update chemist information", true, "Chemist", "ChemistUpdate" },
                    { 33, new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(73), "Can delete chemist accounts", true, "Chemist", "ChemistDelete" }
                });

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

            migrationBuilder.InsertData(
                table: "RolePermissions",
                columns: new[] { "PermissionId", "RoleId", "GrantedAt", "GrantedBy", "IsActive" },
                values: new object[,]
                {
                    { 30, 1, new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(272), null, true },
                    { 31, 1, new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(273), null, true },
                    { 32, 1, new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(274), null, true },
                    { 33, 1, new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(275), null, true },
                    { 30, 2, new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(295), null, true },
                    { 31, 2, new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(296), null, true },
                    { 32, 2, new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(297), null, true },
                    { 33, 2, new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(298), null, true },
                    { 30, 3, new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(308), null, true },
                    { 31, 3, new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(309), null, true },
                    { 32, 3, new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(310), null, true },
                    { 33, 3, new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(311), null, true },
                    { 30, 5, new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(362), null, true },
                    { 32, 5, new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(363), null, true },
                    { 33, 5, new DateTime(2025, 9, 16, 18, 31, 31, 211, DateTimeKind.Utc).AddTicks(364), null, true }
                });

            migrationBuilder.CreateIndex(
                name: "IX_MedicalStores_UserId",
                table: "MedicalStores",
                column: "UserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "MedicalStores");

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 1 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, 1 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 1 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 1 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 2 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, 2 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 2 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 2 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 3 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, 3 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 3 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 3 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, 5 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, 5 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, 5 });

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 30);

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 31);

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 32);

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 33);

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9578));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9582));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9864));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9866));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9867));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9869));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9870));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9871));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 9,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9872));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 10,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9873));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 11,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9875));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 12,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9876));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 13,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9877));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 14,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9878));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 15,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9881));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 16,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9882));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 17,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9883));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 18,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9885));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 19,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9887));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 20,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9888));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 21,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9889));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 22,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9891));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 23,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9892));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 24,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9894));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 25,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9895));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 26,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9901));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 27,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9902));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 28,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9904));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 29,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9905));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 1, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(543));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 2, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(558));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 3, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(561));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 4, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(566));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(567));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 6, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(568));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(569));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 8, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(570));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(571));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(574));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(575));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 12, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(576));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 13, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(577));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 14, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(578));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 15, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(579));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 16, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(581));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 17, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(582));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 18, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(585));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 19, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(586));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 20, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(587));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(588));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(589));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(590));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(591));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(592));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(593));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(594));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(596));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 29, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(597));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 1, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(598));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 3, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(599));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(600));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(603));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(604));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(605));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 17, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(606));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 18, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(607));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 19, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(608));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 20, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(609));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(611));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(612));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(613));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(614));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(615));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(616));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(619));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(620));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(621));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(621));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(622));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(686));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(687));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(688));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(695));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(697));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(700));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(701));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(703));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(704));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(705));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(707));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(708));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 6, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(708));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(712));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 8, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(713));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(719));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(720));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(721));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 12, 5 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(722));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(489));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(495));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(496));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(498));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(499));
        }
    }
}
