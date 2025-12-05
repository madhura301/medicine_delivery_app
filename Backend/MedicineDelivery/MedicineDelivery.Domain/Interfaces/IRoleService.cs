using MedicineDelivery.Domain.Entities;

namespace MedicineDelivery.Domain.Interfaces
{
    public interface IRoleService
    {
        Task<bool> HasPermissionAsync(string userId, string permissionName);
        Task<List<Permission>> GetUserPermissionsAsync(string userId);
        Task<List<string>> GetUserRolesAsync(string userId);
        Task<bool> AssignRoleToUserAsync(string userId, string roleName, string assignedBy);
        Task<bool> RemoveRoleFromUserAsync(string userId, string roleName);
        Task<bool> AddPermissionToRoleAsync(string roleId, int permissionId, string grantedBy);
        Task<bool> RemovePermissionFromRoleAsync(string roleId, int permissionId);
        // Returns all roles from AspNetRoles with their IDs and names
        Task<List<(string Id, string Name)>> GetAllRolesAsync();
        Task<string?> GetRoleByIdAsync(string roleId);
        Task<List<Permission>> GetAllPermissionsAsync();
    }
}
