using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace MedicineDelivery.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddOrderLog : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "OrderLogs",
                columns: table => new
                {
                    OrderLogId = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    CustomerId = table.Column<Guid>(type: "uuid", nullable: true),
                    CustomerName = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    CustomerMobileNumber = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    CustomerAddressId = table.Column<Guid>(type: "uuid", nullable: true),
                    DeliveryAddress = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true),
                    PostalCode = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    Latitude = table.Column<decimal>(type: "numeric(18,6)", nullable: true),
                    Longitude = table.Column<decimal>(type: "numeric(18,6)", nullable: true),
                    Reason = table.Column<int>(type: "integer", nullable: false),
                    ReasonSummary = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    ChemistUnavailable = table.Column<bool>(type: "boolean", nullable: false),
                    CustomerSupportUnavailable = table.Column<bool>(type: "boolean", nullable: false),
                    DeliveryBoyUnavailable = table.Column<bool>(type: "boolean", nullable: false),
                    Details = table.Column<string>(type: "text", nullable: true),
                    CreatedOn = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "now() at time zone 'utc'")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_OrderLogs", x => x.OrderLogId);
                });

            migrationBuilder.CreateIndex(
                name: "IX_OrderLogs_CreatedOn",
                table: "OrderLogs",
                column: "CreatedOn");

            migrationBuilder.CreateIndex(
                name: "IX_OrderLogs_CustomerId",
                table: "OrderLogs",
                column: "CustomerId");

            migrationBuilder.CreateIndex(
                name: "IX_OrderLogs_PostalCode",
                table: "OrderLogs",
                column: "PostalCode");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "OrderLogs");
        }
    }
}
