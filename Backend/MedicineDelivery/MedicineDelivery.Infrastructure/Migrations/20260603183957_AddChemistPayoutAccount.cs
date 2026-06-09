using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace MedicineDelivery.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddChemistPayoutAccount : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "ChemistPayoutAccounts",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    MedicalStoreId = table.Column<Guid>(type: "uuid", nullable: false),
                    RazorpayLinkedAccountId = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    RazorpayStakeholderId = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    RazorpayProductConfigurationId = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    BankAccountNumber = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    BankIfscCode = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    BankAccountHolderName = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: true),
                    OnboardingStatus = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    OnboardingError = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true),
                    ActivatedOn = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedOn = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedOn = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ChemistPayoutAccounts", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ChemistPayoutAccounts_MedicalStores_MedicalStoreId",
                        column: x => x.MedicalStoreId,
                        principalTable: "MedicalStores",
                        principalColumn: "MedicalStoreId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ChemistPayoutAccounts_MedicalStoreId",
                table: "ChemistPayoutAccounts",
                column: "MedicalStoreId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ChemistPayoutAccounts_RazorpayLinkedAccountId",
                table: "ChemistPayoutAccounts",
                column: "RazorpayLinkedAccountId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ChemistPayoutAccounts");
        }
    }
}
