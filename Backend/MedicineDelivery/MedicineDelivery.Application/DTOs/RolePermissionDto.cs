using System.ComponentModel.DataAnnotations;

namespace MedicineDelivery.Application.DTOs
{
    public class AddRolePermissionDto
    {
        [Required]
        [Range(1, int.MaxValue, ErrorMessage = "RoleId must be a positive number")]
        public int RoleId { get; set; }

        [Required]
        [Range(1, int.MaxValue, ErrorMessage = "PermissionId must be a positive number")]
        public int PermissionId { get; set; }

        public bool IsActive { get; set; } = true;
    }

    public class RemoveRolePermissionDto
    {
        [Required]
        [Range(1, int.MaxValue, ErrorMessage = "RoleId must be a positive number")]
        public int RoleId { get; set; }

        [Required]
        [Range(1, int.MaxValue, ErrorMessage = "PermissionId must be a positive number")]
        public int PermissionId { get; set; }
    }

    public class RolePermissionResponseDto
    {
        public int RoleId { get; set; }
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
        public int RoleId { get; set; }
        public string RoleName { get; set; } = string.Empty;
        public List<PermissionWithAssignmentDto> Permissions { get; set; } = new();
    }

    public class PermissionWithAssignmentDto : PermissionDto
    {
        public DateTime? GrantedAt { get; set; }
        public bool IsAssigned { get; set; }
    }
}
