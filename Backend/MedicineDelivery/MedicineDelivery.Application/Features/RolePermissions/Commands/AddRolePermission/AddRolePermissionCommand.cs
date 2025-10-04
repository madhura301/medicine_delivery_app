using MediatR;
using MedicineDelivery.Application.DTOs;

namespace MedicineDelivery.Application.Features.RolePermissions.Commands.AddRolePermission
{
    public class AddRolePermissionCommand : IRequest<RolePermissionResponseDto>
    {
        public string RoleId { get; set; } = string.Empty;
        public int PermissionId { get; set; }
        public bool IsActive { get; set; } = true;
        public string? GrantedBy { get; set; }
    }
}
