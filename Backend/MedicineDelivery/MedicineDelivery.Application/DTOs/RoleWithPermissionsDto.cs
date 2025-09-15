namespace MedicineDelivery.Application.DTOs
{
    public class RoleWithPermissionsDto
    {
        public int Id { get; set; }
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
