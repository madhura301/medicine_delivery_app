using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace MedicineDelivery.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class OrderAndOrderHistoryTableAdded : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Orders",
                columns: table => new
                {
                    OrderId = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    CustomerId = table.Column<Guid>(type: "uuid", nullable: false),
                    CustomerAddressId = table.Column<Guid>(type: "uuid", nullable: false),
                    MedicalStoreId = table.Column<Guid>(type: "uuid", nullable: true),
                    AssignedByType = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    CustomerSupportId = table.Column<Guid>(type: "uuid", nullable: true),
                    OrderType = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    OrderInputType = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    OrderInputFileLocation = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    OrderInputText = table.Column<string>(type: "text", nullable: true),
                    OrderStatus = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    OTP = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: true),
                    TotalAmount = table.Column<decimal>(type: "numeric(10,2)", nullable: true),
                    CreatedOn = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "now() at time zone 'utc'"),
                    UpdatedOn = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Orders", x => x.OrderId);
                    table.ForeignKey(
                        name: "FK_Orders_CustomerAddresses_CustomerAddressId",
                        column: x => x.CustomerAddressId,
                        principalTable: "CustomerAddresses",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Orders_CustomerSupports_CustomerSupportId",
                        column: x => x.CustomerSupportId,
                        principalTable: "CustomerSupports",
                        principalColumn: "CustomerSupportId",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_Orders_Customers_CustomerId",
                        column: x => x.CustomerId,
                        principalTable: "Customers",
                        principalColumn: "CustomerId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Orders_MedicalStores_MedicalStoreId",
                        column: x => x.MedicalStoreId,
                        principalTable: "MedicalStores",
                        principalColumn: "MedicalStoreId",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "OrderAssignmentHistories",
                columns: table => new
                {
                    AssignmentId = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    OrderId = table.Column<int>(type: "integer", nullable: false),
                    MedicalStoreId = table.Column<Guid>(type: "uuid", nullable: false),
                    AssignedByType = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    AssignedByCustomerSupportId = table.Column<Guid>(type: "uuid", nullable: true),
                    AssignedOn = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "now() at time zone 'utc'"),
                    Status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    RejectNote = table.Column<string>(type: "character varying(250)", maxLength: 250, nullable: true),
                    UpdatedOn = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_OrderAssignmentHistories", x => x.AssignmentId);
                    table.ForeignKey(
                        name: "FK_OrderAssignmentHistories_CustomerSupports_AssignedByCustome~",
                        column: x => x.AssignedByCustomerSupportId,
                        principalTable: "CustomerSupports",
                        principalColumn: "CustomerSupportId",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_OrderAssignmentHistories_MedicalStores_MedicalStoreId",
                        column: x => x.MedicalStoreId,
                        principalTable: "MedicalStores",
                        principalColumn: "MedicalStoreId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_OrderAssignmentHistories_Orders_OrderId",
                        column: x => x.OrderId,
                        principalTable: "Orders",
                        principalColumn: "OrderId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Payments",
                columns: table => new
                {
                    PaymentId = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    OrderId = table.Column<int>(type: "integer", nullable: false),
                    PaymentMode = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    TransactionId = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Amount = table.Column<decimal>(type: "numeric(10,2)", nullable: false),
                    PaymentStatus = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    PaidOn = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "now() at time zone 'utc'")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Payments", x => x.PaymentId);
                    table.ForeignKey(
                        name: "FK_Payments_Orders_OrderId",
                        column: x => x.OrderId,
                        principalTable: "Orders",
                        principalColumn: "OrderId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: "11111111-1111-1111-1111-111111111111",
                column: "ConcurrencyStamp",
                value: "e4a57800-1c37-4be9-b2ed-d52fae6b5118");

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: "22222222-2222-2222-2222-222222222222",
                column: "ConcurrencyStamp",
                value: "739fd549-961c-4937-90e0-840b8639577e");

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: "33333333-3333-3333-3333-333333333333",
                column: "ConcurrencyStamp",
                value: "59159ace-dba1-4e5a-b044-b01bd7c9aadf");

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: "44444444-4444-4444-4444-444444444444",
                column: "ConcurrencyStamp",
                value: "ccf355b2-4153-42a9-b32b-1b74b4520a78");

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: "55555555-5555-5555-5555-555555555555",
                column: "ConcurrencyStamp",
                value: "e033bd17-fbda-4845-887e-8a1a5a7731f6");

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4006));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4009));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4010));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4012));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4013));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4014));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4015));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4017));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 13,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4018));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 14,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4019));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 15,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4020));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 16,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4022));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 17,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4023));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 18,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4024));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 19,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4025));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 20,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4026));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 21,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4027));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 22,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4029));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 23,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4030));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 24,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4031));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 25,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4033));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 26,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4034));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 27,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4035));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 28,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4036));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 29,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4037));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 30,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4039));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 31,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4040));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 32,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4041));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 33,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4042));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 34,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4043));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 35,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4044));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 36,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4046));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 37,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4047));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 38,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4048));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 39,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4049));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 40,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4051));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 41,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4052));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 42,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4054));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 43,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4055));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 44,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4056));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 45,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4061));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 46,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4063));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 47,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4065));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 48,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4067));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 49,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4069));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 50,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4070));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 51,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4071));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 1, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4434));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 2, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4436));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 3, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4437));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 4, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4438));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4439));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 6, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4440));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4441));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 8, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4442));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 13, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4443));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 14, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4444));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 15, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4445));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 16, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4446));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 17, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4446));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 18, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4447));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 19, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4448));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 20, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4449));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4450));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4451));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4452));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4453));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4453));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4454));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4455));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4456));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 29, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4457));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4458));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4459));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4460));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4461));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4462));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 35, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4463));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4464));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4465));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 38, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4467));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 39, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4468));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 40, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4469));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 41, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4470));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 43, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4474));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 46, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4471));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 47, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4472));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 48, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4473));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 49, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4474));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 50, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4475));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 51, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4476));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 1, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4477));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 3, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4478));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4479));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4480));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 17, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4481));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 18, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4482));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 19, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4483));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 20, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4484));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4485));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4485));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4486));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4487));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4488));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4489));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4490));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4491));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4492));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4492));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4493));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4494));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4495));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 35, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4496));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4497));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4498));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 38, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4498));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 40, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4499));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 41, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4500));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 43, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4504));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 46, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4501));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 47, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4502));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 48, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4503));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 49, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4505));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 50, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4505));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 51, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4506));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4507));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4508));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4509));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4510));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4511));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4512));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4513));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4513));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4515));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4516));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4516));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4517));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4518));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4519));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4520));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4521));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 43, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4525));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 46, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4522));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 47, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4523));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 48, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4524));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 49, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4526));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 50, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4526));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 51, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4527));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, "44444444-4444-4444-4444-444444444444" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4528));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 42, "44444444-4444-4444-4444-444444444444" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4529));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 44, "44444444-4444-4444-4444-444444444444" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4530));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 45, "44444444-4444-4444-4444-444444444444" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4531));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, "55555555-5555-5555-5555-555555555555" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4532));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 6, "55555555-5555-5555-5555-555555555555" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4533));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, "55555555-5555-5555-5555-555555555555" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4534));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 8, "55555555-5555-5555-5555-555555555555" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4535));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, "55555555-5555-5555-5555-555555555555" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4535));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, "55555555-5555-5555-5555-555555555555" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4536));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, "55555555-5555-5555-5555-555555555555" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 10, 19, 14, 37, 536, DateTimeKind.Utc).AddTicks(4537));

            migrationBuilder.CreateIndex(
                name: "IX_OrderAssignmentHistories_AssignedByCustomerSupportId",
                table: "OrderAssignmentHistories",
                column: "AssignedByCustomerSupportId");

            migrationBuilder.CreateIndex(
                name: "IX_OrderAssignmentHistories_MedicalStoreId",
                table: "OrderAssignmentHistories",
                column: "MedicalStoreId");

            migrationBuilder.CreateIndex(
                name: "IX_OrderAssignmentHistories_OrderId",
                table: "OrderAssignmentHistories",
                column: "OrderId");

            migrationBuilder.CreateIndex(
                name: "IX_OrderAssignmentHistories_Status",
                table: "OrderAssignmentHistories",
                column: "Status");

            migrationBuilder.CreateIndex(
                name: "IX_Orders_CustomerAddressId",
                table: "Orders",
                column: "CustomerAddressId");

            migrationBuilder.CreateIndex(
                name: "IX_Orders_CustomerId",
                table: "Orders",
                column: "CustomerId");

            migrationBuilder.CreateIndex(
                name: "IX_Orders_CustomerSupportId",
                table: "Orders",
                column: "CustomerSupportId");

            migrationBuilder.CreateIndex(
                name: "IX_Orders_MedicalStoreId",
                table: "Orders",
                column: "MedicalStoreId");

            migrationBuilder.CreateIndex(
                name: "IX_Orders_OrderStatus",
                table: "Orders",
                column: "OrderStatus");

            migrationBuilder.CreateIndex(
                name: "IX_Payments_OrderId",
                table: "Payments",
                column: "OrderId");

            migrationBuilder.CreateIndex(
                name: "IX_Payments_TransactionId",
                table: "Payments",
                column: "TransactionId",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "OrderAssignmentHistories");

            migrationBuilder.DropTable(
                name: "Payments");

            migrationBuilder.DropTable(
                name: "Orders");

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: "11111111-1111-1111-1111-111111111111",
                column: "ConcurrencyStamp",
                value: "325f6e55-a053-4e08-961b-da644d8290f0");

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: "22222222-2222-2222-2222-222222222222",
                column: "ConcurrencyStamp",
                value: "217d0c0f-a0f0-49dd-8646-c9216613e06f");

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: "33333333-3333-3333-3333-333333333333",
                column: "ConcurrencyStamp",
                value: "e6b9487a-8402-43b0-947c-0f3fb1089733");

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: "44444444-4444-4444-4444-444444444444",
                column: "ConcurrencyStamp",
                value: "1321b835-778d-47da-bd4d-1c166d310d8b");

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: "55555555-5555-5555-5555-555555555555",
                column: "ConcurrencyStamp",
                value: "f747fdae-dae5-432f-98eb-ca8c33989819");

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3511));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3514));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3515));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3516));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3517));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3519));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3550));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3552));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 13,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3553));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 14,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3554));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 15,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3555));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 16,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3557));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 17,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3558));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 18,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3559));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 19,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3560));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 20,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3561));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 21,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3562));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 22,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3563));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 23,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3564));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 24,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3566));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 25,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3567));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 26,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3569));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 27,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3570));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 28,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3571));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 29,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3572));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 30,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3573));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 31,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3574));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 32,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3575));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 33,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3577));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 34,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3578));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 35,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3579));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 36,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3580));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 37,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3581));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 38,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3582));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 39,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3583));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 40,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3584));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 41,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3585));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 42,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3586));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 43,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3588));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 44,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3589));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 45,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3590));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 46,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3592));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 47,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3593));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 48,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3594));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 49,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3595));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 50,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3596));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 51,
                column: "CreatedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3597));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 1, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3842));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 2, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3843));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 3, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3844));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 4, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3884));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3885));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 6, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3886));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3887));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 8, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3888));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 13, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3889));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 14, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3889));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 15, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3890));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 16, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3891));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 17, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3892));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 18, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3893));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 19, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3894));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 20, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3895));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3896));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3897));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3897));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3898));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3899));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3900));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3901));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3902));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 29, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3903));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3904));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3904));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3905));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3906));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3907));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 35, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3908));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3909));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3910));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 38, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3910));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 39, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3911));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 40, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3912));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 41, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3913));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 43, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3916));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 46, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3914));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 47, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3914));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 48, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3915));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 49, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3917));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 50, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3918));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 51, "11111111-1111-1111-1111-111111111111" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3919));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 1, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3919));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 3, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3920));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3921));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3922));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 17, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3923));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 18, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3924));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 19, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3925));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 20, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3926));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3927));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3928));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3928));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3929));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3930));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3931));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3932));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3933));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3934));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3934));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3935));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3936));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3937));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 35, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3937));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3938));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3939));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 38, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3940));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 40, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3941));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 41, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3941));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 43, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3945));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 46, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3942));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 47, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3943));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 48, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3944));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 49, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3945));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 50, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3946));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 51, "22222222-2222-2222-2222-222222222222" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3948));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3949));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3950));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3951));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3951));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3952));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3953));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3954));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3954));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3955));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3956));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 31, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3957));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3958));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3958));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 34, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3959));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 36, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3960));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 37, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3961));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 43, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3964));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 46, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3962));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 47, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3962));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 48, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3963));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 49, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3965));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 50, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3965));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 51, "33333333-3333-3333-3333-333333333333" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3966));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, "44444444-4444-4444-4444-444444444444" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3967));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 42, "44444444-4444-4444-4444-444444444444" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3968));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 44, "44444444-4444-4444-4444-444444444444" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3969));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 45, "44444444-4444-4444-4444-444444444444" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3970));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, "55555555-5555-5555-5555-555555555555" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3970));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 6, "55555555-5555-5555-5555-555555555555" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3971));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, "55555555-5555-5555-5555-555555555555" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3972));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 8, "55555555-5555-5555-5555-555555555555" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3973));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 30, "55555555-5555-5555-5555-555555555555" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3973));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 32, "55555555-5555-5555-5555-555555555555" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3974));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 33, "55555555-5555-5555-5555-555555555555" },
                column: "GrantedAt",
                value: new DateTime(2025, 11, 9, 18, 27, 33, 723, DateTimeKind.Utc).AddTicks(3975));
        }
    }
}
