using MedicineDelivery.Application.DTOs;

namespace MedicineDelivery.Application.Interfaces
{
    public interface ICustomerService
    {
        Task<CustomerRegistrationResult> RegisterCustomerAsync(CustomerRegistrationDto registrationDto);
        Task<CustomerDto?> GetCustomerByIdAsync(Guid id);
        Task<CustomerDto?> GetCustomerByMobileNumberAsync(string mobileNumber);
        Task<CustomerDto?> GetCustomerByUserIdAsync(string userId);
        Task<List<CustomerDto>> GetAllCustomersAsync();
        Task<CustomerDto?> UpdateCustomerAsync(Guid id, UpdateCustomerDto updateDto);
        Task<bool> DeleteCustomerAsync(Guid id);
    }

    public class CustomerRegistrationResult
    {
        public bool Success { get; set; }
        public CustomerResponseDto? Customer { get; set; }
        public List<string> Errors { get; set; } = new();
    }

    public class CustomerResponseDto
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
        public string? Password { get; set; }
    }
}
