using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MedicineDelivery.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class ClearRolePermissionsData : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Clear all RolePermissions data to avoid type conversion issues
            migrationBuilder.Sql("DELETE FROM \"RolePermissions\"");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // This migration only clears data, so we can't restore it
            // The data will need to be re-seeded after the schema changes
        }
    }
}
