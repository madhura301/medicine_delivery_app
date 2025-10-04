using MediatR;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Domain.Interfaces;
using MedicineDelivery.Domain.Entities;

namespace MedicineDelivery.Application.Features.RolePermissions.Commands.AddRolePermission
{
    public class AddRolePermissionCommandHandler : IRequestHandler<AddRolePermissionCommand, RolePermissionResponseDto>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IRoleService _roleService;

        public AddRolePermissionCommandHandler(IUnitOfWork unitOfWork, IRoleService roleService)
        {
            _unitOfWork = unitOfWork;
            _roleService = roleService;
        }

        public async Task<RolePermissionResponseDto> Handle(AddRolePermissionCommand request, CancellationToken cancellationToken)
        {
            // Validate role exists (using Identity roles)
            var roleName = await _roleService.GetRoleByIdAsync(request.RoleId);
            if (string.IsNullOrEmpty(roleName))
            {
                throw new InvalidOperationException("Role not found or inactive.");
            }

            // Validate permission exists
            var permission = await _unitOfWork.Permissions.GetByIdAsync(request.PermissionId);
            if (permission == null || !permission.IsActive)
            {
                throw new InvalidOperationException("Permission not found or inactive.");
            }

            // Add permission to role using RoleService
            var success = await _roleService.AddPermissionToRoleAsync(request.RoleId, request.PermissionId, request.GrantedBy);
            
            if (!success)
            {
                throw new InvalidOperationException("Failed to add permission to role.");
            }

            return new RolePermissionResponseDto
            {
                RoleId = request.RoleId,
                RoleName = roleName,
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
