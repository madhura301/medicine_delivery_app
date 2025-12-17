using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace MedicineDelivery.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddedGroupsAndItsRelatedColumns : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "AssignTo",
                table: "Orders",
                type: "character varying(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<int>(
                name: "DeliveryId",
                table: "Orders",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "OrderBillFileLocation",
                table: "Orders",
                type: "character varying(255)",
                maxLength: 255,
                nullable: true);

            migrationBuilder.AlterColumn<Guid>(
                name: "MedicalStoreId",
                table: "OrderAssignmentHistories",
                type: "uuid",
                nullable: true,
                oldClrType: typeof(Guid),
                oldType: "uuid");

            migrationBuilder.AddColumn<string>(
                name: "AssignTo",
                table: "OrderAssignmentHistories",
                type: "character varying(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<Guid>(
                name: "CustomerId",
                table: "OrderAssignmentHistories",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<int>(
                name: "DeliveryId",
                table: "OrderAssignmentHistories",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "CustomerSupportRegionId",
                table: "CustomerSupports",
                type: "integer",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "CustomerSupportRegions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    City = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    RegionName = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CustomerSupportRegions", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Deliveries",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    FirstName = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    MiddleName = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    LastName = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    DrivingLicenceNumber = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    MobileNumber = table.Column<string>(type: "character varying(15)", maxLength: 15, nullable: true),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    IsDeleted = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    MedicalStoreId = table.Column<Guid>(type: "uuid", nullable: true),
                    AddedOn = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "now() at time zone 'utc'"),
                    ModifiedOn = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    AddedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    ModifiedBy = table.Column<Guid>(type: "uuid", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Deliveries", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Deliveries_MedicalStores_MedicalStoreId",
                        column: x => x.MedicalStoreId,
                        principalTable: "MedicalStores",
                        principalColumn: "MedicalStoreId",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "CustomerSupportRegionPinCodes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    CustomerSupportRegionId = table.Column<int>(type: "integer", nullable: false),
                    PinCode = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CustomerSupportRegionPinCodes", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CustomerSupportRegionPinCodes_CustomerSupportRegions_Custom~",
                        column: x => x.CustomerSupportRegionId,
                        principalTable: "CustomerSupportRegions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Orders_DeliveryId",
                table: "Orders",
                column: "DeliveryId");

            migrationBuilder.CreateIndex(
                name: "IX_OrderAssignmentHistories_CustomerId",
                table: "OrderAssignmentHistories",
                column: "CustomerId");

            migrationBuilder.CreateIndex(
                name: "IX_OrderAssignmentHistories_DeliveryId",
                table: "OrderAssignmentHistories",
                column: "DeliveryId");

            migrationBuilder.CreateIndex(
                name: "IX_CustomerSupports_CustomerSupportRegionId",
                table: "CustomerSupports",
                column: "CustomerSupportRegionId");

            migrationBuilder.CreateIndex(
                name: "IX_CustomerSupportRegionPinCodes_CustomerSupportRegionId",
                table: "CustomerSupportRegionPinCodes",
                column: "CustomerSupportRegionId");

            migrationBuilder.CreateIndex(
                name: "IX_CustomerSupportRegionPinCodes_CustomerSupportRegionId_PinCo~",
                table: "CustomerSupportRegionPinCodes",
                columns: new[] { "CustomerSupportRegionId", "PinCode" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_CustomerSupportRegionPinCodes_PinCode",
                table: "CustomerSupportRegionPinCodes",
                column: "PinCode");

            migrationBuilder.CreateIndex(
                name: "IX_CustomerSupportRegions_City",
                table: "CustomerSupportRegions",
                column: "City");

            migrationBuilder.CreateIndex(
                name: "IX_CustomerSupportRegions_Name",
                table: "CustomerSupportRegions",
                column: "Name");

            migrationBuilder.CreateIndex(
                name: "IX_CustomerSupportRegions_RegionName",
                table: "CustomerSupportRegions",
                column: "RegionName");

            migrationBuilder.CreateIndex(
                name: "IX_Deliveries_IsActive",
                table: "Deliveries",
                column: "IsActive");

            migrationBuilder.CreateIndex(
                name: "IX_Deliveries_IsDeleted",
                table: "Deliveries",
                column: "IsDeleted");

            migrationBuilder.CreateIndex(
                name: "IX_Deliveries_MedicalStoreId",
                table: "Deliveries",
                column: "MedicalStoreId");

            migrationBuilder.AddForeignKey(
                name: "FK_CustomerSupports_CustomerSupportRegions_CustomerSupportRegi~",
                table: "CustomerSupports",
                column: "CustomerSupportRegionId",
                principalTable: "CustomerSupportRegions",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_OrderAssignmentHistories_Customers_CustomerId",
                table: "OrderAssignmentHistories",
                column: "CustomerId",
                principalTable: "Customers",
                principalColumn: "CustomerId",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_OrderAssignmentHistories_Deliveries_DeliveryId",
                table: "OrderAssignmentHistories",
                column: "DeliveryId",
                principalTable: "Deliveries",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_Orders_Deliveries_DeliveryId",
                table: "Orders",
                column: "DeliveryId",
                principalTable: "Deliveries",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_CustomerSupports_CustomerSupportRegions_CustomerSupportRegi~",
                table: "CustomerSupports");

            migrationBuilder.DropForeignKey(
                name: "FK_OrderAssignmentHistories_Customers_CustomerId",
                table: "OrderAssignmentHistories");

            migrationBuilder.DropForeignKey(
                name: "FK_OrderAssignmentHistories_Deliveries_DeliveryId",
                table: "OrderAssignmentHistories");

            migrationBuilder.DropForeignKey(
                name: "FK_Orders_Deliveries_DeliveryId",
                table: "Orders");

            migrationBuilder.DropTable(
                name: "CustomerSupportRegionPinCodes");

            migrationBuilder.DropTable(
                name: "Deliveries");

            migrationBuilder.DropTable(
                name: "CustomerSupportRegions");

            migrationBuilder.DropIndex(
                name: "IX_Orders_DeliveryId",
                table: "Orders");

            migrationBuilder.DropIndex(
                name: "IX_OrderAssignmentHistories_CustomerId",
                table: "OrderAssignmentHistories");

            migrationBuilder.DropIndex(
                name: "IX_OrderAssignmentHistories_DeliveryId",
                table: "OrderAssignmentHistories");

            migrationBuilder.DropIndex(
                name: "IX_CustomerSupports_CustomerSupportRegionId",
                table: "CustomerSupports");

            migrationBuilder.DropColumn(
                name: "AssignTo",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "DeliveryId",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "OrderBillFileLocation",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "AssignTo",
                table: "OrderAssignmentHistories");

            migrationBuilder.DropColumn(
                name: "CustomerId",
                table: "OrderAssignmentHistories");

            migrationBuilder.DropColumn(
                name: "DeliveryId",
                table: "OrderAssignmentHistories");

            migrationBuilder.DropColumn(
                name: "CustomerSupportRegionId",
                table: "CustomerSupports");

            migrationBuilder.AlterColumn<Guid>(
                name: "MedicalStoreId",
                table: "OrderAssignmentHistories",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"),
                oldClrType: typeof(Guid),
                oldType: "uuid",
                oldNullable: true);
        }
    }
}
