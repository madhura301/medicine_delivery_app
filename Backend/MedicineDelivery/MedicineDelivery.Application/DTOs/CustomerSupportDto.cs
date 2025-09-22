namespace MedicineDelivery.Application.DTOs
{
    public class CustomerSupportRegistrationDto
    {
        public string CustomerSupportFirstName { get; set; } = string.Empty;
        public string CustomerSupportLastName { get; set; } = string.Empty;
        public string CustomerSupportMiddleName { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public string City { get; set; } = string.Empty;
        public string State { get; set; } = string.Empty;
        public string MobileNumber { get; set; } = string.Empty;
        public string EmailId { get; set; } = string.Empty;
        public string AlternativeMobileNumber { get; set; } = string.Empty;
        
        // Employee information
        public string EmployeeId { get; set; } = string.Empty;
    }

    public class CustomerSupportResponseDto
    {
        public Guid CustomerSupportId { get; set; }
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
        public string CustomerSupportPhoto { get; set; } = string.Empty;
        
        public bool IsActive { get; set; }
        public bool IsDeleted { get; set; }
        public DateTime CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public string? UserId { get; set; }
        public string Password { get; set; } = string.Empty;
    }

    public class CustomerSupportDto
    {
        public Guid CustomerSupportId { get; set; }
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
        public string CustomerSupportPhoto { get; set; } = string.Empty;
        
        public bool IsActive { get; set; }
        public bool IsDeleted { get; set; }
        public DateTime CreatedOn { get; set; }
        public Guid? CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public Guid? UpdatedBy { get; set; }
        public string? UserId { get; set; }
    }
}
