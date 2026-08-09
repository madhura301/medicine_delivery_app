using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MedicineDelivery.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddManagerOrderEscalation : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "ManagerId",
                table: "Orders",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "ManagerId",
                table: "OrderAssignmentHistories",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Orders_ManagerId",
                table: "Orders",
                column: "ManagerId");

            migrationBuilder.CreateIndex(
                name: "IX_OrderAssignmentHistories_ManagerId",
                table: "OrderAssignmentHistories",
                column: "ManagerId");

            migrationBuilder.AddForeignKey(
                name: "FK_OrderAssignmentHistories_Managers_ManagerId",
                table: "OrderAssignmentHistories",
                column: "ManagerId",
                principalTable: "Managers",
                principalColumn: "ManagerId",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_Orders_Managers_ManagerId",
                table: "Orders",
                column: "ManagerId",
                principalTable: "Managers",
                principalColumn: "ManagerId",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_OrderAssignmentHistories_Managers_ManagerId",
                table: "OrderAssignmentHistories");

            migrationBuilder.DropForeignKey(
                name: "FK_Orders_Managers_ManagerId",
                table: "Orders");

            migrationBuilder.DropIndex(
                name: "IX_Orders_ManagerId",
                table: "Orders");

            migrationBuilder.DropIndex(
                name: "IX_OrderAssignmentHistories_ManagerId",
                table: "OrderAssignmentHistories");

            migrationBuilder.DropColumn(
                name: "ManagerId",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "ManagerId",
                table: "OrderAssignmentHistories");
        }
    }
}
