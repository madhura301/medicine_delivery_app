using Microsoft.EntityFrameworkCore;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Domain.Interfaces;
using MedicineDelivery.Infrastructure.Data;

namespace MedicineDelivery.Infrastructure.Services
{
    public class RoleService : IRoleService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ApplicationDbContext _context;

        public RoleService(IUnitOfWork unitOfWork, ApplicationDbContext context)
        {
            _unitOfWork = unitOfWork;
            _context = context;
        }

        public async Task<bool> HasPermissionAsync(string userId, string permissionName)
        {
            // Check if user has any role that contains the specified permission
            return await _context.UserRoles
                .Include(ur => ur.Role)
                .ThenInclude(r => r.RolePermissions)
                .ThenInclude(rp => rp.Permission)
                .AnyAsync(ur => ur.UserId == userId && 
                               ur.IsActive && 
                               ur.Role.IsActive &&
                               ur.Role.RolePermissions.Any(rp => 
                                   rp.IsActive && 
                                   rp.Permission.IsActive && 
                                   rp.Permission.Name == permissionName));
        }

        public async Task<List<Permission>> GetUserPermissionsAsync(string userId)
        {
            var userRoles = await _context.UserRoles
                .Include(ur => ur.Role)
                .ThenInclude(r => r.RolePermissions)
                .ThenInclude(rp => rp.Permission)
                .Where(ur => ur.UserId == userId && ur.IsActive && ur.Role.IsActive)
                .ToListAsync();

            var permissions = userRoles
                .SelectMany(ur => ur.Role.RolePermissions)
                .Where(rp => rp.IsActive && rp.Permission.IsActive)
                .Select(rp => rp.Permission)
                .Distinct()
                .ToList();

            return permissions;
        }

        public async Task<List<Role>> GetUserRolesAsync(string userId)
        {
            var userRoles = await _context.UserRoles
                .Include(ur => ur.Role)
                .Where(ur => ur.UserId == userId && ur.IsActive && ur.Role.IsActive)
                .Select(ur => ur.Role)
                .ToListAsync();

            return userRoles;
        }

        public async Task<bool> AssignRoleToUserAsync(string userId, int roleId, string assignedBy)
        {
            var existingUserRole = await _unitOfWork.UserRoles
                .FirstOrDefaultAsync(ur => ur.UserId == userId && ur.RoleId == roleId);

            if (existingUserRole != null)
            {
                existingUserRole.IsActive = true;
                existingUserRole.AssignedAt = DateTime.UtcNow;
                existingUserRole.AssignedBy = assignedBy;
            }
            else
            {
                var userRole = new UserRole
                {
                    UserId = userId,
                    RoleId = roleId,
                    AssignedBy = assignedBy,
                    IsActive = true
                };
                await _unitOfWork.UserRoles.AddAsync(userRole);
            }

            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        public async Task<bool> RemoveRoleFromUserAsync(string userId, int roleId)
        {
            var userRole = await _unitOfWork.UserRoles
                .FirstOrDefaultAsync(ur => ur.UserId == userId && ur.RoleId == roleId);

            if (userRole != null)
            {
                userRole.IsActive = false;
                await _unitOfWork.SaveChangesAsync();
                return true;
            }

            return false;
        }

        public async Task<bool> AddPermissionToRoleAsync(int roleId, int permissionId, string grantedBy)
        {
            var existingRolePermission = await _unitOfWork.RolePermissions
                .FirstOrDefaultAsync(rp => rp.RoleId == roleId && rp.PermissionId == permissionId);

            if (existingRolePermission != null)
            {
                existingRolePermission.IsActive = true;
                existingRolePermission.GrantedAt = DateTime.UtcNow;
                existingRolePermission.GrantedBy = grantedBy;
            }
            else
            {
                var rolePermission = new RolePermission
                {
                    RoleId = roleId,
                    PermissionId = permissionId,
                    GrantedBy = grantedBy,
                    IsActive = true
                };
                await _unitOfWork.RolePermissions.AddAsync(rolePermission);
            }

            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        public async Task<bool> RemovePermissionFromRoleAsync(int roleId, int permissionId)
        {
            var rolePermission = await _unitOfWork.RolePermissions
                .FirstOrDefaultAsync(rp => rp.RoleId == roleId && rp.PermissionId == permissionId);

            if (rolePermission != null)
            {
                rolePermission.IsActive = false;
                await _unitOfWork.SaveChangesAsync();
                return true;
            }

            return false;
        }

        public async Task<List<Role>> GetAllRolesAsync()
        {
            return (await _unitOfWork.Roles.GetAllAsync()).ToList();
        }

        public async Task<Role?> GetRoleByIdAsync(int roleId)
        {
            return await _unitOfWork.Roles.GetByIdAsync(roleId);
        }

        public async Task<Role> CreateRoleAsync(string name, string description)
        {
            var role = new Role
            {
                Name = name,
                Description = description,
                IsActive = true
            };

            await _unitOfWork.Roles.AddAsync(role);
            await _unitOfWork.SaveChangesAsync();
            return role;
        }

        public async Task<bool> UpdateRoleAsync(int roleId, string name, string description)
        {
            var role = await _unitOfWork.Roles.GetByIdAsync(roleId);
            if (role == null)
                return false;

            role.Name = name;
            role.Description = description;
            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        public async Task<bool> DeleteRoleAsync(int roleId)
        {
            var role = await _unitOfWork.Roles.GetByIdAsync(roleId);
            if (role == null)
                return false;

            role.IsActive = false;
            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        public async Task<List<Permission>> GetAllPermissionsAsync()
        {
            return (await _unitOfWork.Permissions.GetAllAsync()).ToList();
        }
    }
}
