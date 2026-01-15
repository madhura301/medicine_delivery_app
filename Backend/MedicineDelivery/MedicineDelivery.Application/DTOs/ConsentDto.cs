using MedicineDelivery.Domain.Enums;

namespace MedicineDelivery.Application.DTOs
{
    public class ConsentDto
    {
        public Guid ConsentId { get; set; }
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string Content { get; set; } = string.Empty;
        public bool IsActive { get; set; }
        public DateTime CreatedOn { get; set; }
        public DateTime? UpdatedOn { get; set; }
    }

    public class CreateConsentDto
    {
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string Content { get; set; } = string.Empty;
        public bool IsActive { get; set; } = true;
    }

    public class UpdateConsentDto
    {
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string Content { get; set; } = string.Empty;
        public bool IsActive { get; set; }
    }

    public class ConsentLogDto
    {
        public Guid ConsentLogId { get; set; }
        public Guid ConsentId { get; set; }
        public string UserId { get; set; } = string.Empty;
        public UserType UserType { get; set; }
        public Guid? RespectiveId { get; set; }
        public ConsentAction Action { get; set; }
        public string UserAgent { get; set; } = string.Empty;
        public string IpAddress { get; set; } = string.Empty;
        public string? DeviceInfo { get; set; }
        public DateTime CreatedOn { get; set; }
        public ConsentDto? Consent { get; set; }
    }

    public class AcceptRejectConsentDto
    {
        public string? DeviceInfo { get; set; }
    }
}