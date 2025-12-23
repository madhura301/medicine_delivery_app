using MedicineDelivery.Application.DTOs;

namespace MedicineDelivery.Application.Interfaces
{
    public interface ICustomerSupportRegionService
    {
        Task<CustomerSupportRegionDto> CreateCustomerSupportRegionAsync(CreateCustomerSupportRegionDto createDto);
        Task<CustomerSupportRegionDto?> GetCustomerSupportRegionByIdAsync(int id);
        Task<IEnumerable<CustomerSupportRegionDto>> GetAllCustomerSupportRegionsAsync();
        Task<CustomerSupportRegionDto> UpdateCustomerSupportRegionAsync(int id, UpdateCustomerSupportRegionDto updateDto);
        Task<bool> DeleteCustomerSupportRegionAsync(int id);
        Task<bool> AddPinCodeToRegionAsync(AddPinCodeToRegionDto addDto);
        Task<bool> RemovePinCodeFromRegionAsync(RemovePinCodeFromRegionDto removeDto);
        Task<IEnumerable<string>> GetPinCodesByRegionIdAsync(int regionId);
        Task<CustomerSupportRegionDto?> GetRegionByPinCodeAsync(string pinCode);
        Task<bool> AssignRegionToCustomerSupportAsync(AssignCustomerSupportRegionDto assignDto);
        Task<bool> AssignRegionToCustomerSupportsAsync(AssignCustomerSupportRegionBulkDto assignDto);
    }
}

