using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace MedicineDelivery.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddPaymentSplitAndOrderBreakup : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "BillAmount",
                table: "Orders",
                type: "numeric(10,2)",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "ConvenienceFee",
                table: "Orders",
                type: "numeric(10,2)",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "PaymentSplits",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    OrderId = table.Column<int>(type: "integer", nullable: false),
                    RazorpayPaymentId = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    TotalCaptured = table.Column<decimal>(type: "numeric(10,2)", nullable: false),
                    BillAmount = table.Column<decimal>(type: "numeric(10,2)", nullable: false),
                    ConvenienceFee = table.Column<decimal>(type: "numeric(10,2)", nullable: false),
                    PlatformFee = table.Column<decimal>(type: "numeric(10,2)", nullable: false),
                    ChemistAmount = table.Column<decimal>(type: "numeric(10,2)", nullable: false),
                    PharmaishAmount = table.Column<decimal>(type: "numeric(10,2)", nullable: false),
                    RazorpayTransferId = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    ChemistLinkedAccountId = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    TransferStatus = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PaymentSplits", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PaymentSplits_Orders_OrderId",
                        column: x => x.OrderId,
                        principalTable: "Orders",
                        principalColumn: "OrderId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_PaymentSplits_OrderId",
                table: "PaymentSplits",
                column: "OrderId");

            migrationBuilder.CreateIndex(
                name: "IX_PaymentSplits_RazorpayPaymentId",
                table: "PaymentSplits",
                column: "RazorpayPaymentId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PaymentSplits");

            migrationBuilder.DropColumn(
                name: "BillAmount",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "ConvenienceFee",
                table: "Orders");
        }
    }
}
