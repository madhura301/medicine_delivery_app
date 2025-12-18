namespace MedicineDelivery.Domain.Entities
{
    public class CustomerSupport
    {
        public Guid CustomerSupportId { get; set; } = Guid.NewGuid();
        public string CustomerSupportFirstName { get; set; } = string.Empty;
        public string CustomerSupportLastName { get; set; } = string.Empty;
        public string CustomerSupportMiddleName { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public string City { get; set; } = string.Empty;
        public string State { get; set; } = string.Empty;
        public string MobileNumber { get; set; } = string.Empty;
        public string EmailId { get; set; } = string.Empty;
        public string AlternativeMobileNumber { get; set; } = string.Empty;
        
        // Employee and photo information
        public string EmployeeId { get; set; } = string.Empty;
        public string CustomerSupportPhoto { get; set; } = string.Empty; // File name of the photo
        
        public bool IsActive { get; set; } = true;
        public bool IsDeleted { get; set; } = false;
        public DateTime CreatedOn { get; set; } = DateTime.UtcNow;
        public Guid? CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public string? UserId { get; set; } // Reference to the associated user account
        public int? CustomerSupportRegionId { get; set; }

        // Navigation properties
        public CustomerSupportRegion? CustomerSupportRegion { get; set; }
    }
}
