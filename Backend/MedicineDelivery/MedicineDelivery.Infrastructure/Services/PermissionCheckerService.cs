using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.Domain.Interfaces;
using Microsoft.AspNetCore.Identity;
using System.Security.Claims;

namespace MedicineDelivery.Infrastructure.Services
{
    public class PermissionCheckerService : IPermissionCheckerService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly UserManager<MedicineDelivery.Infrastructure.Data.ApplicationUser> _userManager;

        public PermissionCheckerService(
            IUnitOfWork unitOfWork,
            UserManager<MedicineDelivery.Infrastructure.Data.ApplicationUser> userManager)
        {
            _unitOfWork = unitOfWork;
            _userManager = userManager;
        }

        public async Task<bool> HasPermissionAsync(string userId, string permissionName)
        {
            try
            {
                // Get all roles and permissions
                var roles = await _unitOfWork.Roles.GetAllAsync();
                var permissions = await _unitOfWork.Permissions.GetAllAsync();
                var rolePermissions = await _unitOfWork.RolePermissions.GetAllAsync();

                // Find the permission by name
                var permission = permissions.FirstOrDefault(p => p.Name == permissionName && p.IsActive);
                if (permission == null) return false;

                // Get user roles from Identity
                var user = await _userManager.FindByIdAsync(userId);
                if (user == null) return false;

                var userRoles = await _userManager.GetRolesAsync(user);
                
                // If no roles from Identity, try to get roles from our domain UserRole table
                if (!userRoles.Any())
                {
                    var domainUserRoles = await _unitOfWork.UserRoles.GetAllAsync();
                    var userDomainRoles = domainUserRoles.Where(ur => ur.UserId == userId && ur.IsActive);
                    
                    // Get role names from role IDs
                    var userRoleIds = userDomainRoles.Select(ur => ur.RoleId).ToList();
                    var userRoleNames = roles.Where(r => userRoleIds.Contains(r.Id) && r.IsActive).Select(r => r.Name).ToList();
                    userRoles = userRoleNames;
                }

                if (!userRoles.Any()) return false;

                // Find roles by name
                var userRoleEntities = roles.Where(r => userRoles.Contains(r.Name) && r.IsActive);

                // Check if any of the user's roles have the specified permission
                return rolePermissions.Any(rp => 
                    userRoleEntities.Any(ur => ur.Id == rp.RoleId) && 
                    rp.PermissionId == permission.Id && 
                    rp.IsActive);
            }
            catch
            {
                return false;
            }
        }

        public async Task<List<string>> GetPermissionsByUserIdAsync(string userId)
        {
            try
            {
                // Get all roles and permissions
                var roles = await _unitOfWork.Roles.GetAllAsync();
                var permissions = await _unitOfWork.Permissions.GetAllAsync();
                var rolePermissions = await _unitOfWork.RolePermissions.GetAllAsync();

                // Get user roles from Identity
                var user = await _userManager.FindByIdAsync(userId);
                if (user == null) return new List<string>();

                var userRoles = await _userManager.GetRolesAsync(user);
                
                // If no roles from Identity, try to get roles from our domain UserRole table
                if (!userRoles.Any())
                {
                    var domainUserRoles = await _unitOfWork.UserRoles.GetAllAsync();
                    var userDomainRoles = domainUserRoles.Where(ur => ur.UserId == userId && ur.IsActive);
                    
                    // Get role names from role IDs
                    var userRoleIds = userDomainRoles.Select(ur => ur.RoleId).ToList();
                    var userRoleNames = roles.Where(r => userRoleIds.Contains(r.Id) && r.IsActive).Select(r => r.Name).ToList();
                    userRoles = userRoleNames;
                }

                if (!userRoles.Any()) return new List<string>();

                // Find roles by name
                var userRoleEntities = roles.Where(r => userRoles.Contains(r.Name) && r.IsActive);

                // Get all role permissions for the user's roles
                var userRolePermissions = rolePermissions.Where(rp => 
                    userRoleEntities.Any(ur => ur.Id == rp.RoleId) && rp.IsActive);

                // Get permission names
                var permissionIds = userRolePermissions.Select(rp => rp.PermissionId).Distinct();
                var userPermissions = permissions.Where(p => permissionIds.Contains(p.Id) && p.IsActive);

                // Return unique permission names
                return userPermissions.Select(p => p.Name).Distinct().ToList();
            }
            catch
            {
                return new List<string>();
            }
        }

        public async Task<bool> HasPermissionAsync(ClaimsPrincipal user, string permissionName)
        {
            try
            {
                var userId = user.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId)) return false;

                return await HasPermissionAsync(userId, permissionName);
            }
            catch
            {
                return false;
            }
        }
    }
}
