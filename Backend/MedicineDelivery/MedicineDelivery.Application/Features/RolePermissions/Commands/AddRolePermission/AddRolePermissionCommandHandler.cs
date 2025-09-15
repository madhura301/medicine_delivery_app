using MediatR;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Domain.Interfaces;
using MedicineDelivery.Domain.Entities;

namespace MedicineDelivery.Application.Features.RolePermissions.Commands.AddRolePermission
{
    public class AddRolePermissionCommandHandler : IRequestHandler<AddRolePermissionCommand, RolePermissionResponseDto>
    {
        private readonly IUnitOfWork _unitOfWork;

        public AddRolePermissionCommandHandler(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<RolePermissionResponseDto> Handle(AddRolePermissionCommand request, CancellationToken cancellationToken)
        {
            // Validate role exists
            var role = await _unitOfWork.Roles.GetByIdAsync(request.RoleId);
            
            if (role == null || !role.IsActive)
            {
                throw new InvalidOperationException("Role not found or inactive.");
            }

            // Validate permission exists
            var permission = await _unitOfWork.Permissions.GetByIdAsync(request.PermissionId);
            
            if (permission == null || !permission.IsActive)
            {
                throw new InvalidOperationException("Permission not found or inactive.");
            }

            // Check if role-permission already exists
            var existingRolePermissions = await _unitOfWork.RolePermissions.GetAllAsync();
            var existingRolePermission = existingRolePermissions
                .FirstOrDefault(rp => rp.RoleId == request.RoleId && rp.PermissionId == request.PermissionId);

            if (existingRolePermission != null)
            {
                if (existingRolePermission.IsActive)
                {
                    throw new InvalidOperationException("Role already has this permission.");
                }
                else
                {
                    // Reactivate existing role-permission
                    existingRolePermission.IsActive = true;
                    existingRolePermission.GrantedAt = DateTime.UtcNow;
                    existingRolePermission.GrantedBy = request.GrantedBy;
                    _unitOfWork.RolePermissions.Update(existingRolePermission);
                }
            }
            else
            {
                // Create new role-permission
                var rolePermission = new RolePermission
                {
                    RoleId = request.RoleId,
                    PermissionId = request.PermissionId,
                    IsActive = request.IsActive,
                    GrantedAt = DateTime.UtcNow,
                    GrantedBy = request.GrantedBy
                };

                await _unitOfWork.RolePermissions.AddAsync(rolePermission);
            }

            await _unitOfWork.SaveChangesAsync();

            return new RolePermissionResponseDto
            {
                RoleId = request.RoleId,
                RoleName = role.Name,
                PermissionId = request.PermissionId,
                PermissionName = permission.Name,
                Module = permission.Module,
                IsActive = request.IsActive,
                GrantedAt = DateTime.UtcNow,
                GrantedBy = request.GrantedBy
            };
        }
    }
}
