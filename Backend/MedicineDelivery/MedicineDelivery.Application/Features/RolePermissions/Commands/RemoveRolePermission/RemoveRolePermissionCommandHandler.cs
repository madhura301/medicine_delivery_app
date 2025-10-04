using MediatR;
using MedicineDelivery.Domain.Interfaces;

namespace MedicineDelivery.Application.Features.RolePermissions.Commands.RemoveRolePermission
{
    public class RemoveRolePermissionCommandHandler : IRequestHandler<RemoveRolePermissionCommand, bool>
    {
        private readonly IRoleService _roleService;

        public RemoveRolePermissionCommandHandler(IRoleService roleService)
        {
            _roleService = roleService;
        }

        public async Task<bool> Handle(RemoveRolePermissionCommand request, CancellationToken cancellationToken)
        {
            // Remove permission from role using RoleService
            var success = await _roleService.RemovePermissionFromRoleAsync(request.RoleId, request.PermissionId);
            
            if (!success)
            {
                throw new InvalidOperationException("Failed to remove permission from role.");
            }

            return true;
        }
    }
}
