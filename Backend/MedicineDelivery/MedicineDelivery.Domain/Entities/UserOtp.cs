using MedicineDelivery.Domain.Enums;

namespace MedicineDelivery.Domain.Entities
{
    public class UserOtp
    {
        public int Id { get; set; }
        public string PhoneNumber { get; set; } = string.Empty;
        public string OtpCodeHash { get; set; } = string.Empty;
        public OtpPurpose Purpose { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime ExpiresAt { get; set; }
        public bool IsUsed { get; set; }
        public int AttemptCount { get; set; }
    }
}
