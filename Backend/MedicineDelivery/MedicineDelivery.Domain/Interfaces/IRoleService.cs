using MedicineDelivery.Domain.Entities;

namespace MedicineDelivery.Domain.Interfaces
{
    public interface IRoleService
    {
        Task<bool> HasPermissionAsync(string userId, string permissionName);
        Task<List<Permission>> GetUserPermissionsAsync(string userId);
        Task<List<Role>> GetUserRolesAsync(string userId);
        Task<bool> AssignRoleToUserAsync(string userId, int roleId, string assignedBy);
        Task<bool> RemoveRoleFromUserAsync(string userId, int roleId);
        Task<bool> AddPermissionToRoleAsync(int roleId, int permissionId, string grantedBy);
        Task<bool> RemovePermissionFromRoleAsync(int roleId, int permissionId);
        Task<List<Role>> GetAllRolesAsync();
        Task<Role?> GetRoleByIdAsync(int roleId);
        Task<Role> CreateRoleAsync(string name, string description);
        Task<bool> UpdateRoleAsync(int roleId, string name, string description);
        Task<bool> DeleteRoleAsync(int roleId);
        Task<List<Permission>> GetAllPermissionsAsync();
    }
}
