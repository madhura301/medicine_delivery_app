using MedicineDelivery.Application.DTOs;

namespace MedicineDelivery.Application.Interfaces
{
    public interface IDeliveryService
    {
        Task<DeliveryDto> CreateDeliveryAsync(CreateDeliveryDto createDto, Guid? addedBy = null);
        Task<DeliveryDto?> GetDeliveryByIdAsync(int id);
        Task<IEnumerable<DeliveryDto>> GetAllDeliveriesAsync();
        Task<IEnumerable<DeliveryDto>> GetDeliveriesByMedicalStoreIdAsync(Guid medicalStoreId);
        Task<IEnumerable<DeliveryDto>> GetActiveDeliveriesByMedicalStoreIdAsync(Guid medicalStoreId);
        Task<DeliveryDto> UpdateDeliveryAsync(int id, UpdateDeliveryDto updateDto, Guid? modifiedBy = null);
        Task<bool> DeleteDeliveryAsync(int id);
    }
}

