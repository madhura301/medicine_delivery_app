using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MedicineDelivery.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddPlatformFeeGstToPaymentSplit : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "PlatformFeeGst",
                table: "PaymentSplits",
                type: "numeric(10,2)",
                nullable: false,
                defaultValue: 0m);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PlatformFeeGst",
                table: "PaymentSplits");
        }
    }
}
