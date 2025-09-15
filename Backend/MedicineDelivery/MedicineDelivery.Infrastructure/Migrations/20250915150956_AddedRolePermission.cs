using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace MedicineDelivery.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddedRolePermission : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
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

            migrationBuilder.InsertData(
                table: "Permissions",
                columns: new[] { "Id", "CreatedAt", "Description", "IsActive", "Module", "Name" },
                values: new object[,]
                {
                    { 13, new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9877), "Admin can view all user information", true, "UserManagement", "AdminReadUsers" },
                    { 14, new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9878), "Admin can create users", true, "UserManagement", "AdminCreateUsers" },
                    { 15, new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9881), "Admin can update user information", true, "UserManagement", "AdminUpdateUsers" },
                    { 16, new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9882), "Admin can delete users", true, "UserManagement", "AdminDeleteUsers" },
                    { 17, new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9883), "Manager can view user information", true, "UserManagement", "ManagerReadUsers" },
                    { 18, new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9885), "Manager can create users", true, "UserManagement", "ManagerCreateUsers" },
                    { 19, new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9887), "Manager can update user information", true, "UserManagement", "ManagerUpdateUsers" },
                    { 20, new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9888), "Manager can delete users", true, "UserManagement", "ManagerDeleteUsers" },
                    { 21, new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9889), "CustomerSupport can view user information", true, "UserManagement", "CustomerSupportReadUsers" },
                    { 22, new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9891), "CustomerSupport can create users", true, "UserManagement", "CustomerSupportCreateUsers" },
                    { 23, new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9892), "CustomerSupport can update user information", true, "UserManagement", "CustomerSupportUpdateUsers" },
                    { 24, new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9894), "CustomerSupport can delete users", true, "UserManagement", "CustomerSupportDeleteUsers" },
                    { 25, new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9895), "Chemist can view user information", true, "UserManagement", "ChemistReadUsers" },
                    { 26, new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9901), "Chemist can create users", true, "UserManagement", "ChemistCreateUsers" },
                    { 27, new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9902), "Chemist can update user information", true, "UserManagement", "ChemistUpdateUsers" },
                    { 28, new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9904), "Chemist can delete users", true, "UserManagement", "ChemistDeleteUsers" },
                    { 29, new DateTime(2025, 9, 15, 15, 9, 54, 843, DateTimeKind.Utc).AddTicks(9905), "Can manage role permissions", true, "RoleManagement", "ManageRolePermission" }
                });

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
                columns: new[] { "CreatedAt", "Description", "Name" },
                values: new object[] { new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(496), "Customer support access", "CustomerSupport" });

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(498));

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "CreatedAt", "Description", "IsActive", "Name" },
                values: new object[] { 5, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(499), "Chemist/pharmacist access", true, "Chemist" });

            migrationBuilder.InsertData(
                table: "RolePermissions",
                columns: new[] { "PermissionId", "RoleId", "GrantedAt", "GrantedBy", "IsActive" },
                values: new object[,]
                {
                    { 13, 1, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(577), null, true },
                    { 14, 1, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(578), null, true },
                    { 15, 1, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(579), null, true },
                    { 16, 1, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(581), null, true },
                    { 17, 1, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(582), null, true },
                    { 18, 1, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(585), null, true },
                    { 19, 1, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(586), null, true },
                    { 20, 1, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(587), null, true },
                    { 21, 1, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(588), null, true },
                    { 22, 1, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(589), null, true },
                    { 23, 1, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(590), null, true },
                    { 24, 1, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(591), null, true },
                    { 25, 1, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(592), null, true },
                    { 26, 1, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(593), null, true },
                    { 27, 1, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(594), null, true },
                    { 28, 1, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(596), null, true },
                    { 29, 1, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(597), null, true },
                    { 17, 2, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(606), null, true },
                    { 18, 2, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(607), null, true },
                    { 19, 2, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(608), null, true },
                    { 20, 2, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(609), null, true },
                    { 21, 2, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(611), null, true },
                    { 22, 2, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(612), null, true },
                    { 23, 2, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(613), null, true },
                    { 24, 2, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(614), null, true },
                    { 25, 2, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(615), null, true },
                    { 26, 2, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(616), null, true },
                    { 27, 2, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(619), null, true },
                    { 28, 2, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(620), null, true },
                    { 21, 3, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(686), null, true },
                    { 22, 3, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(687), null, true },
                    { 23, 3, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(688), null, true },
                    { 24, 3, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(695), null, true },
                    { 25, 3, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(697), null, true },
                    { 26, 3, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(700), null, true },
                    { 27, 3, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(701), null, true },
                    { 28, 3, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(703), null, true },
                    { 5, 5, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(708), null, true },
                    { 6, 5, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(708), null, true },
                    { 7, 5, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(712), null, true },
                    { 8, 5, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(713), null, true },
                    { 9, 5, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(719), null, true },
                    { 10, 5, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(720), null, true },
                    { 11, 5, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(721), null, true },
                    { 12, 5, new DateTime(2025, 9, 15, 15, 9, 54, 844, DateTimeKind.Utc).AddTicks(722), null, true }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 13, 1 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 14, 1 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 15, 1 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 16, 1 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 17, 1 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 18, 1 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 19, 1 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 20, 1 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 1 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 1 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 1 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 1 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 1 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 1 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 1 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 1 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 29, 1 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 17, 2 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 18, 2 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 19, 2 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 20, 2 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 2 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 2 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 2 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 2 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 2 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 2 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 2 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 2 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 21, 3 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 22, 3 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 23, 3 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 24, 3 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 25, 3 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 26, 3 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 27, 3 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 28, 3 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 5 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 6, 5 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 5 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 8, 5 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 5 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 5 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 5 });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 12, 5 });

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 16);

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 17);

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 18);

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 19);

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 20);

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 21);

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 22);

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 23);

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 24);

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 25);

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 26);

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 27);

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 28);

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 29);

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7799));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7800));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7802));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7803));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7804));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7805));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7806));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7808));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 9,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7809));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 10,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7810));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 11,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7811));

            migrationBuilder.UpdateData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: 12,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7812));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 1, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7950));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 2, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7952));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 3, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7953));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 4, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7954));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7955));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 6, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7956));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7957));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 8, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7958));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7959));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7960));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7961));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 12, 1 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7962));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 1, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7964));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 3, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7966));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7967));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 7, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7969));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7971));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 11, 2 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7972));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7974));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7975));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 3 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7977));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 5, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7978));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 9, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7980));

            migrationBuilder.UpdateData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionId", "RoleId" },
                keyValues: new object[] { 10, 4 },
                column: "GrantedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7981));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7926));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7928));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CreatedAt", "Description", "Name" },
                values: new object[] { new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7929), "Basic employee access", "Employee" });

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2025, 9, 15, 14, 17, 2, 148, DateTimeKind.Utc).AddTicks(7931));
        }
    }
}
