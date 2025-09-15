using MediatR;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Domain.Interfaces;

namespace MedicineDelivery.Application.Features.RolePermissions.Queries.GetRolePermissions
{
    public class GetRolePermissionsQueryHandler : IRequestHandler<GetRolePermissionsQuery, RolePermissionsListDto>
    {
        private readonly IUnitOfWork _unitOfWork;

        public GetRolePermissionsQueryHandler(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<RolePermissionsListDto> Handle(GetRolePermissionsQuery request, CancellationToken cancellationToken)
        {
            // Get role information
            var role = await _unitOfWork.Roles.GetByIdAsync(request.RoleId);

            if (role == null || !role.IsActive)
            {
                throw new InvalidOperationException("Role not found or inactive.");
            }

            // Get all permissions with their assignment status for this role
            var allPermissions = await _unitOfWork.Permissions.GetAllAsync();
            var activePermissions = allPermissions.Where(p => p.IsActive).ToList();

            var rolePermissions = await _unitOfWork.RolePermissions.GetAllAsync();
            var assignedPermissionIds = rolePermissions
                .Where(rp => rp.RoleId == request.RoleId && rp.IsActive)
                .Select(rp => rp.PermissionId)
                .ToList();

            var permissions = activePermissions.Select(p => new PermissionWithAssignmentDto
            {
                Id = p.Id,
                Name = p.Name,
                Description = p.Description,
                Module = p.Module,
                CreatedAt = p.CreatedAt,
                IsActive = p.IsActive,
                IsAssigned = assignedPermissionIds.Contains(p.Id)
            }).ToList();

            return new RolePermissionsListDto
            {
                RoleId = role.Id,
                RoleName = role.Name,
                Permissions = permissions
            };
        }
    }
}
