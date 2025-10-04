namespace MedicineDelivery.Domain.Entities
{
    public class RolePermission
    {
        public string RoleId { get; set; } = string.Empty;
        public int PermissionId { get; set; }
        public DateTime GrantedAt { get; set; } = DateTime.UtcNow;
        public string? GrantedBy { get; set; }
        public bool IsActive { get; set; } = true;

        // Navigation properties
        public Permission Permission { get; set; } = null!;
    }
}
