using System.ComponentModel.DataAnnotations;

namespace MedicineDelivery.Application.DTOs
{
    public class AddRolePermissionDto
    {
        [Required]
        public string RoleId { get; set; } = string.Empty;

        [Required]
        [Range(1, int.MaxValue, ErrorMessage = "PermissionId must be a positive number")]
        public int PermissionId { get; set; }

        public bool IsActive { get; set; } = true;
    }

    public class RemoveRolePermissionDto
    {
        [Required]
        public string RoleId { get; set; } = string.Empty;

        [Required]
        [Range(1, int.MaxValue, ErrorMessage = "PermissionId must be a positive number")]
        public int PermissionId { get; set; }
    }

    public class RolePermissionResponseDto
    {
        public string RoleId { get; set; } = string.Empty;
        public string RoleName { get; set; } = string.Empty;
        public int PermissionId { get; set; }
        public string PermissionName { get; set; } = string.Empty;
        public string Module { get; set; } = string.Empty;
        public bool IsActive { get; set; }
        public DateTime GrantedAt { get; set; }
        public string? GrantedBy { get; set; }
    }

    public class RolePermissionsListDto
    {
        public string RoleId { get; set; } = string.Empty;
        public string RoleName { get; set; } = string.Empty;
        public List<PermissionWithAssignmentDto> Permissions { get; set; } = new();
    }

    public class PermissionWithAssignmentDto : PermissionDto
    {
        public DateTime? GrantedAt { get; set; }
        public bool IsAssigned { get; set; }
    }
}
