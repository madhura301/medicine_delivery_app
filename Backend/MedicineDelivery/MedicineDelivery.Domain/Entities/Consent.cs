namespace MedicineDelivery.Domain.Entities
{
    public class Consent
    {
        public Guid ConsentId { get; set; } = Guid.NewGuid();
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string Content { get; set; } = string.Empty;
        public bool IsActive { get; set; } = true;
        public DateTime CreatedOn { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedOn { get; set; }

        // Navigation property
        public ICollection<ConsentLog> ConsentLogs { get; set; } = new List<ConsentLog>();
    }
}