using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace MedicineDelivery.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddCustomerEntity : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Customers",
                columns: table => new
                {
                    CustomerId = table.Column<Guid>(type: "uniqueidentifier", nullable: false, defaultValueSql: "NEWID()"),
                    CustomerFirstName = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    CustomerLastName = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    CustomerMiddleName = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    MobileNumber = table.Column<string>(type: "nvarchar(15)", maxLength: 15, nullable: false),
                    AlternativeMobileNumber = table.Column<string>(type: "nvarchar(15)", maxLength: 15, nullable: true),
                    EmailId = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    Address = table.Column<string>(type: "nvarchar(300)", maxLength: 300, nullable: true),
                    City = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    State = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    PostalCode = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: true),
                    DateOfBirth = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Gender = table.Column<string>(type: "nvarchar(10)", maxLength: 10, nullable: true),
                    CustomerPhoto = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    CreatedOn = table.Column<DateTime>(type: "datetime2(7)", nullable: false),
                    UpdatedOn = table.Column<DateTime>(type: "datetime2(7)", nullable: true),
                    UserId = table.Column<string>(type: "nvarchar(450)", nullable: true)
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

            migrationBuilder.InsertData(
                table: "Permissions",
                columns: new[] { "Id", "CreatedAt", "Description", "IsActive", "Module", "Name" },
                values: new object[,]
                {
                    { 42, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1544), "Can read customer information", true, "Customer", "CustomerRead" },
                    { 43, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1546), "Can create customer accounts", true, "Customer", "CustomerCreate" },
                    { 44, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1547), "Can update customer information", true, "Customer", "CustomerUpdate" },
                    { 45, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1548), "Can delete customer accounts", true, "Customer", "CustomerDelete" }
                });

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

            migrationBuilder.InsertData(
                table: "RolePermissions",
                columns: new[] { "PermissionId", "RoleId", "GrantedAt", "GrantedBy", "IsActive" },
                values: new object[,]
                {
                    { 42, 1, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1872), null, true },
                    { 43, 1, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1897), null, true },
                    { 44, 1, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1898), null, true },
                    { 45, 1, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1899), null, true },
                    { 42, 2, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1926), null, true },
                    { 43, 2, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1927), null, true },
                    { 44, 2, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1928), null, true },
                    { 45, 2, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1929), null, true },
                    { 42, 3, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1947), null, true },
                    { 43, 3, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1948), null, true },
                    { 44, 3, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1949), null, true },
                    { 45, 3, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1950), null, true },
                    { 42, 4, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1953), null, true },
                    { 43, 4, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1954), null, true },
                    { 44, 4, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1955), null, true },
                    { 45, 4, new DateTime(2025, 9, 20, 10, 35, 12, 754, DateTimeKind.Utc).AddTicks(1956), null, true }
                });

            migrationBuilder.CreateIndex(
                name: "IX_Customers_UserId",
                table: "Customers",
                column: "UserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Customers");

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 42, 1 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 43, 1 });

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
                keyValues: new object[] { 43, 2 });

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
                keyValues: new object[] { 43, 3 });

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
                keyValues: new object[] { 42, 4 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 43, 4 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 44, 4 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 45, 4 });

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 42);

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 43);

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 44);

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 45);

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
    }
}
