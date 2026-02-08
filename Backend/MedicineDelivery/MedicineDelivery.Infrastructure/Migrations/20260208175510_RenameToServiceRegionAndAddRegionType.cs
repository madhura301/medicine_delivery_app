using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MedicineDelivery.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class RenameToServiceRegionAndAddRegionType : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_CustomerSupportRegionPinCodes_CustomerSupportRegions_Custom~",
                table: "CustomerSupportRegionPinCodes");

            migrationBuilder.DropForeignKey(
                name: "FK_CustomerSupports_CustomerSupportRegions_CustomerSupportRegi~",
                table: "CustomerSupports");

            migrationBuilder.RenameColumn(
                name: "CustomerSupportRegionId",
                table: "CustomerSupports",
                newName: "ServiceRegionId");

            migrationBuilder.RenameIndex(
                name: "IX_CustomerSupports_CustomerSupportRegionId",
                table: "CustomerSupports",
                newName: "IX_CustomerSupports_ServiceRegionId");

            migrationBuilder.RenameColumn(
                name: "CustomerSupportRegionId",
                table: "CustomerSupportRegionPinCodes",
                newName: "ServiceRegionId");

            migrationBuilder.RenameIndex(
                name: "IX_CustomerSupportRegionPinCodes_CustomerSupportRegionId_PinCo~",
                table: "CustomerSupportRegionPinCodes",
                newName: "IX_CustomerSupportRegionPinCodes_ServiceRegionId_PinCode");

            migrationBuilder.RenameIndex(
                name: "IX_CustomerSupportRegionPinCodes_CustomerSupportRegionId",
                table: "CustomerSupportRegionPinCodes",
                newName: "IX_CustomerSupportRegionPinCodes_ServiceRegionId");

            migrationBuilder.AddColumn<int>(
                name: "ServiceRegionId",
                table: "Deliveries",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "RegionType",
                table: "CustomerSupportRegions",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "IX_Deliveries_ServiceRegionId",
                table: "Deliveries",
                column: "ServiceRegionId");

            migrationBuilder.CreateIndex(
                name: "IX_CustomerSupportRegions_RegionType",
                table: "CustomerSupportRegions",
                column: "RegionType");

            migrationBuilder.AddForeignKey(
                name: "FK_CustomerSupportRegionPinCodes_CustomerSupportRegions_Servic~",
                table: "CustomerSupportRegionPinCodes",
                column: "ServiceRegionId",
                principalTable: "CustomerSupportRegions",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_CustomerSupports_CustomerSupportRegions_ServiceRegionId",
                table: "CustomerSupports",
                column: "ServiceRegionId",
                principalTable: "CustomerSupportRegions",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_Deliveries_CustomerSupportRegions_ServiceRegionId",
                table: "Deliveries",
                column: "ServiceRegionId",
                principalTable: "CustomerSupportRegions",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_CustomerSupportRegionPinCodes_CustomerSupportRegions_Servic~",
                table: "CustomerSupportRegionPinCodes");

            migrationBuilder.DropForeignKey(
                name: "FK_CustomerSupports_CustomerSupportRegions_ServiceRegionId",
                table: "CustomerSupports");

            migrationBuilder.DropForeignKey(
                name: "FK_Deliveries_CustomerSupportRegions_ServiceRegionId",
                table: "Deliveries");

            migrationBuilder.DropIndex(
                name: "IX_Deliveries_ServiceRegionId",
                table: "Deliveries");

            migrationBuilder.DropIndex(
                name: "IX_CustomerSupportRegions_RegionType",
                table: "CustomerSupportRegions");

            migrationBuilder.DropColumn(
                name: "ServiceRegionId",
                table: "Deliveries");

            migrationBuilder.DropColumn(
                name: "RegionType",
                table: "CustomerSupportRegions");

            migrationBuilder.RenameColumn(
                name: "ServiceRegionId",
                table: "CustomerSupports",
                newName: "CustomerSupportRegionId");

            migrationBuilder.RenameIndex(
                name: "IX_CustomerSupports_ServiceRegionId",
                table: "CustomerSupports",
                newName: "IX_CustomerSupports_CustomerSupportRegionId");

            migrationBuilder.RenameColumn(
                name: "ServiceRegionId",
                table: "CustomerSupportRegionPinCodes",
                newName: "CustomerSupportRegionId");

            migrationBuilder.RenameIndex(
                name: "IX_CustomerSupportRegionPinCodes_ServiceRegionId_PinCode",
                table: "CustomerSupportRegionPinCodes",
                newName: "IX_CustomerSupportRegionPinCodes_CustomerSupportRegionId_PinCo~");

            migrationBuilder.RenameIndex(
                name: "IX_CustomerSupportRegionPinCodes_ServiceRegionId",
                table: "CustomerSupportRegionPinCodes",
                newName: "IX_CustomerSupportRegionPinCodes_CustomerSupportRegionId");

            migrationBuilder.AddForeignKey(
                name: "FK_CustomerSupportRegionPinCodes_CustomerSupportRegions_Custom~",
                table: "CustomerSupportRegionPinCodes",
                column: "CustomerSupportRegionId",
                principalTable: "CustomerSupportRegions",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_CustomerSupports_CustomerSupportRegions_CustomerSupportRegi~",
                table: "CustomerSupports",
                column: "CustomerSupportRegionId",
                principalTable: "CustomerSupportRegions",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }
    }
}
