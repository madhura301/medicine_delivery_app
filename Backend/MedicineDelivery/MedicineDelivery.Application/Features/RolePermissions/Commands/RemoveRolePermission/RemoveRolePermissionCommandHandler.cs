using MediatR;
using MedicineDelivery.Domain.Interfaces;

namespace MedicineDelivery.Application.Features.RolePermissions.Commands.RemoveRolePermission
{
    public class RemoveRolePermissionCommandHandler : IRequestHandler<RemoveRolePermissionCommand, bool>
    {
        private readonly IUnitOfWork _unitOfWork;

        public RemoveRolePermissionCommandHandler(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<bool> Handle(RemoveRolePermissionCommand request, CancellationToken cancellationToken)
        {
            // Find the role-permission
            var rolePermissions = await _unitOfWork.RolePermissions.GetAllAsync();
            var rolePermission = rolePermissions
                .FirstOrDefault(rp => rp.RoleId == request.RoleId && rp.PermissionId == request.PermissionId);

            if (rolePermission == null)
            {
                throw new InvalidOperationException("Role-permission not found.");
            }

            if (!rolePermission.IsActive)
            {
                throw new InvalidOperationException("Role-permission is already inactive.");
            }

            // Deactivate the role-permission instead of deleting it
            rolePermission.IsActive = false;
            _unitOfWork.RolePermissions.Update(rolePermission);
            
            await _unitOfWork.SaveChangesAsync();

            return true;
        }
    }
}
