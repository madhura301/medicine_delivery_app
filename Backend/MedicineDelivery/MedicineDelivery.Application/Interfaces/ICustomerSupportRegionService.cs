using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Domain.Enums;

namespace MedicineDelivery.Application.Interfaces
{
    public interface IServiceRegionService
    {
        Task<ServiceRegionDto> CreateServiceRegionAsync(CreateServiceRegionDto createDto);
        Task<ServiceRegionDto?> GetServiceRegionByIdAsync(int id);
        Task<IEnumerable<ServiceRegionDto>> GetAllServiceRegionsAsync();
        Task<IEnumerable<ServiceRegionDto>> GetAllServiceRegionsByTypeAsync(RegionType regionType);
        Task<ServiceRegionDto> UpdateServiceRegionAsync(int id, UpdateServiceRegionDto updateDto);
        Task<bool> DeleteServiceRegionAsync(int id);
        Task<bool> AddPinCodeToRegionAsync(AddPinCodeToRegionDto addDto);
        Task<bool> RemovePinCodeFromRegionAsync(RemovePinCodeFromRegionDto removeDto);
        Task<IEnumerable<string>> GetPinCodesByRegionIdAsync(int regionId);
        Task<ServiceRegionDto?> GetRegionByPinCodeAsync(string pinCode);
        Task<bool> AssignRegionToCustomerSupportAsync(AssignCustomerSupportRegionDto assignDto);
        Task<bool> AssignRegionToCustomerSupportsAsync(AssignCustomerSupportRegionBulkDto assignDto);
        Task<bool> AssignRegionToDeliveryAsync(AssignDeliveryRegionDto assignDto);
        Task<bool> AssignRegionToDeliveriesAsync(AssignDeliveryRegionBulkDto assignDto);
    }
}
