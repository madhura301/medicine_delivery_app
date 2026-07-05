using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MedicineDelivery.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddBusinessNameAndRazorpayBusinessTypeToChemistPayoutAccounts : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "BusinessName",
                table: "ChemistPayoutAccounts",
                type: "character varying(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "RazorpayBusinessType",
                table: "ChemistPayoutAccounts",
                type: "integer",
                nullable: false,
                defaultValue: 4);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "BusinessName",
                table: "ChemistPayoutAccounts");

            migrationBuilder.DropColumn(
                name: "RazorpayBusinessType",
                table: "ChemistPayoutAccounts");
        }
    }
}
