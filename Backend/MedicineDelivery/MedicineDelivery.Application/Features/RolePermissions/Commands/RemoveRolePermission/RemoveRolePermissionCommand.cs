using MediatR;

namespace MedicineDelivery.Application.Features.RolePermissions.Commands.RemoveRolePermission
{
    public class RemoveRolePermissionCommand : IRequest<bool>
    {
        public int RoleId { get; set; }
        public int PermissionId { get; set; }
    }
}
