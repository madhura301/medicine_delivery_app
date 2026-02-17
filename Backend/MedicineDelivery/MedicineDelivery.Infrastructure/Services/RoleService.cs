using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Domain.Interfaces;
using MedicineDelivery.Infrastructure.Data;

namespace MedicineDelivery.Infrastructure.Services
{
    public class RoleService : IRoleService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ApplicationDbContext _context;
        private readonly UserManager<Domain.Entities.ApplicationUser> _userManager;
        private readonly ILogger<RoleService> _logger;

        public RoleService(IUnitOfWork unitOfWork, ApplicationDbContext context, UserManager<Domain.Entities.ApplicationUser> userManager, ILogger<RoleService> logger)
        {
            _unitOfWork = unitOfWork;
            _context = context;
            _userManager = userManager;
            _logger = logger;
        }

        public async Task<bool> HasPermissionAsync(string userId, string permissionName)
        {
            // Get user's Identity roles
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null)
            {
                _logger.LogWarning("HasPermissionAsync: User {UserId} not found when checking permission {PermissionName}", userId, permissionName);
                return false;
            }

            // Get user's role names
            var userRoleNames = await _userManager.GetRolesAsync(user);
            
            // Get the role IDs for these role names from AspNetRoles
            var userRoleIds = await _context.Roles
                .Where(r => r.Name != null && userRoleNames.Contains(r.Name))
                .Select(r => r.Id)
                .ToListAsync();

            // Check if any of the user's roles have the specified permission
            return await _context.RolePermissions
                .Include(rp => rp.Permission)
                .AnyAsync(rp => userRoleIds.Contains(rp.RoleId) && 
                               rp.IsActive && 
                               rp.Permission.IsActive && 
                               rp.Permission.Name == permissionName);
        }

        public async Task<List<Permission>> GetUserPermissionsAsync(string userId)
        {
            // Get user's Identity roles
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null)
            {
                _logger.LogWarning("GetUserPermissionsAsync: User {UserId} not found. Returning empty permissions list", userId);
                return new List<Permission>();
            }

            // Get user's role names
            var userRoleNames = await _userManager.GetRolesAsync(user);
            
            // Get the role IDs for these role names from AspNetRoles
            var userRoleIds = await _context.Roles
                .Where(r => r.Name != null && userRoleNames.Contains(r.Name))
                .Select(r => r.Id)
                .ToListAsync();
            
            // Get permissions for all user roles
            var permissions = await _context.RolePermissions
                .Include(rp => rp.Permission)
                .Where(rp => userRoleIds.Contains(rp.RoleId) && rp.IsActive && rp.Permission.IsActive)
                .Select(rp => rp.Permission)
                .Distinct()
                .ToListAsync();

            return permissions;
        }

        public async Task<List<string>> GetUserRolesAsync(string userId)
        {
            // Get user's Identity roles
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null) return new List<string>();

            var userRoles = await _userManager.GetRolesAsync(user);
            return userRoles.ToList();
        }

        public async Task<bool> AssignRoleToUserAsync(string userId, string roleName, string assignedBy)
        {
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null)
            {
                _logger.LogWarning("AssignRoleToUserAsync: User {UserId} not found when assigning role {RoleName}", userId, roleName);
                return false;
            }

            var result = await _userManager.AddToRoleAsync(user, roleName);
            if (!result.Succeeded)
            {
                _logger.LogWarning("AssignRoleToUserAsync: Failed to assign role {RoleName} to user {UserId}. Errors: {Errors}", roleName, userId, string.Join(", ", result.Errors.Select(e => e.Description)));
            }
            return result.Succeeded;
        }

        public async Task<bool> RemoveRoleFromUserAsync(string userId, string roleName)
        {
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null) return false;

            var result = await _userManager.RemoveFromRoleAsync(user, roleName);
            return result.Succeeded;
        }

        public async Task<bool> AddPermissionToRoleAsync(string roleId, int permissionId, string grantedBy)
        {
            var existingRolePermission = await _unitOfWork.RolePermissions
                .FirstOrDefaultAsync(rp => rp.RoleId == roleId && rp.PermissionId == permissionId);

            if (existingRolePermission != null)
            {
                _logger.LogInformation("Reactivating existing permission {PermissionId} for role {RoleId} by {GrantedBy}", permissionId, roleId, grantedBy);
                existingRolePermission.IsActive = true;
                existingRolePermission.GrantedAt = DateTime.UtcNow;
                existingRolePermission.GrantedBy = grantedBy;
            }
            else
            {
                _logger.LogInformation("Adding new permission {PermissionId} to role {RoleId} by {GrantedBy}", permissionId, roleId, grantedBy);
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

        public async Task<bool> RemovePermissionFromRoleAsync(string roleId, int permissionId)
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

        public async Task<List<(string Id, string Name)>> GetAllRolesAsync()
        {
            var roles = await _context.Roles
                .Select(r => new { r.Id, r.Name })
                .ToListAsync();

            return roles
                .Select(r => (r.Id, r.Name ?? string.Empty))
                .ToList();
        }

        public async Task<string?> GetRoleByIdAsync(string roleId)
        {
            var role = await _context.Roles.FindAsync(roleId);
            return role?.Name;
        }

        public async Task<List<Permission>> GetAllPermissionsAsync()
        {
            return (await _unitOfWork.Permissions.GetAllAsync()).ToList();
        }
    }
}
