namespace MedicineDelivery.Application.DTOs
{
    public class RoleWithPermissionsDto
    {
        // Identity roles use string IDs (stored in AspNetRoles), so keep as string
        public string Id { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public bool IsActive { get; set; }
        public List<PermissionDto> Permissions { get; set; } = new();
    }

    public class RolesWithPermissionsResponseDto
    {
        public List<RoleWithPermissionsDto> Roles { get; set; } = new();
        public int TotalCount { get; set; }
    }
}
