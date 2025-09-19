namespace MedicineDelivery.Domain.Entities
{
    public class Manager
    {
        public Guid ManagerId { get; set; } = Guid.NewGuid();
        public string ManagerFirstName { get; set; } = string.Empty;
        public string ManagerLastName { get; set; } = string.Empty;
        public string ManagerMiddleName { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public string City { get; set; } = string.Empty;
        public string State { get; set; } = string.Empty;
        public string MobileNumber { get; set; } = string.Empty;
        public string EmailId { get; set; } = string.Empty;
        public string AlternativeMobileNumber { get; set; } = string.Empty;
        
        // Employee and photo information
        public string EmployeeId { get; set; } = string.Empty;
        public string ManagerPhoto { get; set; } = string.Empty; // File name of the photo
        
        public bool IsActive { get; set; } = true;
        public bool IsDeleted { get; set; } = false;
        public DateTime CreatedOn { get; set; } = DateTime.UtcNow;
        public Guid? CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public string? UserId { get; set; } // Reference to the associated user account

        // Navigation property
        public User? User { get; set; }
    }
}
