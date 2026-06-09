using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace MedicineDelivery.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddChemistActivationPayment : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "ActivatedOn",
                table: "MedicalStores",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "ChemistActivationPayments",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    MedicalStoreId = table.Column<Guid>(type: "uuid", nullable: false),
                    Amount = table.Column<decimal>(type: "numeric(10,2)", nullable: false),
                    Gst = table.Column<decimal>(type: "numeric(10,2)", nullable: false),
                    GatewayCharges = table.Column<decimal>(type: "numeric(10,2)", nullable: true),
                    RazorpayPaymentLinkId = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    RazorpayPaymentId = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    Status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    CreatedOn = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    PaidOn = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ChemistActivationPayments", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ChemistActivationPayments_MedicalStores_MedicalStoreId",
                        column: x => x.MedicalStoreId,
                        principalTable: "MedicalStores",
                        principalColumn: "MedicalStoreId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ChemistActivationPayments_MedicalStoreId",
                table: "ChemistActivationPayments",
                column: "MedicalStoreId");

            migrationBuilder.CreateIndex(
                name: "IX_ChemistActivationPayments_RazorpayPaymentLinkId",
                table: "ChemistActivationPayments",
                column: "RazorpayPaymentLinkId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ChemistActivationPayments");

            migrationBuilder.DropColumn(
                name: "ActivatedOn",
                table: "MedicalStores");
        }
    }
}
