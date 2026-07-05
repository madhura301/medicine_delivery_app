using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MedicineDelivery.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class RemoveBusinessTypeFromMedicalStore : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "BusinessType",
                table: "MedicalStores");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "BusinessType",
                table: "MedicalStores",
                type: "integer",
                nullable: false,
                defaultValue: 0);
        }
    }
}
