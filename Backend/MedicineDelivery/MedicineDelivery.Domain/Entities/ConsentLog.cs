using MedicineDelivery.Domain.Enums;

namespace MedicineDelivery.Domain.Entities
{
    public class ConsentLog
    {
        public Guid ConsentLogId { get; set; } = Guid.NewGuid();
        public Guid ConsentId { get; set; }
        public string UserId { get; set; } = string.Empty;
        public UserType UserType { get; set; }
        public Guid? RespectiveId { get; set; }
        public ConsentAction Action { get; set; }
        public string UserAgent { get; set; } = string.Empty;
        public string IpAddress { get; set; } = string.Empty;
        public string? DeviceInfo { get; set; }
        public DateTime CreatedOn { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public Consent? Consent { get; set; }
        public ApplicationUser? User { get; set; }
    }
}