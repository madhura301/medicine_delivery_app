namespace MedicineDelivery.Application.DTOs
{
    public class CustomerDto
    {
        public Guid CustomerId { get; set; }
        public string CustomerFirstName { get; set; } = string.Empty;
        public string CustomerLastName { get; set; } = string.Empty;
        public string? CustomerMiddleName { get; set; }
        public string MobileNumber { get; set; } = string.Empty;
        public string? AlternativeMobileNumber { get; set; }
        public string? EmailId { get; set; }
        public string? Address { get; set; }
        public string? City { get; set; }
        public string? State { get; set; }
        public string? PostalCode { get; set; }
        public DateTime DateOfBirth { get; set; }
        public string? Gender { get; set; }
        public string? CustomerPhoto { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedOn { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public string? UserId { get; set; }
    }

    public class CustomerRegistrationDto
    {
        public string CustomerFirstName { get; set; } = string.Empty;
        public string CustomerLastName { get; set; } = string.Empty;
        public string? CustomerMiddleName { get; set; }
        public string MobileNumber { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string? AlternativeMobileNumber { get; set; }
        public string? EmailId { get; set; }
        public string? Address { get; set; }
        public string? City { get; set; }
        public string? State { get; set; }
        public string? PostalCode { get; set; }
        public DateTime DateOfBirth { get; set; }
        public string? Gender { get; set; }
    }

    public class CreateCustomerDto
    {
        public string CustomerFirstName { get; set; } = string.Empty;
        public string CustomerLastName { get; set; } = string.Empty;
        public string? CustomerMiddleName { get; set; }
        public string MobileNumber { get; set; } = string.Empty;
        public string? AlternativeMobileNumber { get; set; }
        public string? EmailId { get; set; }
        public string? Address { get; set; }
        public string? City { get; set; }
        public string? State { get; set; }
        public string? PostalCode { get; set; }
        public DateTime DateOfBirth { get; set; }
        public string? Gender { get; set; }
        public string? CustomerPhoto { get; set; }
        public string? UserId { get; set; }
    }

    public class UpdateCustomerDto
    {
        public string CustomerFirstName { get; set; } = string.Empty;
        public string CustomerLastName { get; set; } = string.Empty;
        public string? CustomerMiddleName { get; set; }
        public string MobileNumber { get; set; } = string.Empty;
        public string? AlternativeMobileNumber { get; set; }
        public string? EmailId { get; set; }
        public string? Address { get; set; }
        public string? City { get; set; }
        public string? State { get; set; }
        public string? PostalCode { get; set; }
        public DateTime DateOfBirth { get; set; }
        public string? Gender { get; set; }
        public string? CustomerPhoto { get; set; }
        public bool IsActive { get; set; }
    }
}
