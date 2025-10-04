namespace MedicineDelivery.Domain.Entities
{
    public class Customer
    {
        public Guid CustomerId { get; set; }
        public string CustomerFirstName { get; set; } = string.Empty;
        public string CustomerLastName { get; set; } = string.Empty;
        public string? CustomerMiddleName { get; set; }
        public string MobileNumber { get; set; } = string.Empty;
        public string? AlternativeMobileNumber { get; set; }
        public string? EmailId { get; set; }
        public DateTime DateOfBirth { get; set; }
        public string? Gender { get; set; }
        public string? CustomerPhoto { get; set; }
        public bool IsActive { get; set; } = true;
        public DateTime CreatedOn { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedOn { get; set; }
        public string? UserId { get; set; } // Foreign key to ApplicationUser
        
        // Navigation properties
        public ICollection<CustomerAddress>? Addresses { get; set; }
    }
}
