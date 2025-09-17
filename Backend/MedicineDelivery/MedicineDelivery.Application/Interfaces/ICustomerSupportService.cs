using MedicineDelivery.Application.DTOs;

namespace MedicineDelivery.Application.Interfaces
{
    public interface ICustomerSupportService
    {
        Task<CustomerSupportRegistrationResult> RegisterCustomerSupportAsync(CustomerSupportRegistrationDto registrationDto);
        Task<CustomerSupportDto?> GetCustomerSupportByIdAsync(Guid id);
        Task<CustomerSupportDto?> GetCustomerSupportByEmailAsync(string email);
        Task<List<CustomerSupportDto>> GetAllCustomerSupportsAsync();
        Task<CustomerSupportDto?> UpdateCustomerSupportAsync(Guid id, CustomerSupportRegistrationDto updateDto);
        Task<bool> DeleteCustomerSupportAsync(Guid id);
    }

    public class CustomerSupportRegistrationResult
    {
        public bool Success { get; set; }
        public CustomerSupportResponseDto? CustomerSupport { get; set; }
        public List<string> Errors { get; set; } = new();
    }
}
