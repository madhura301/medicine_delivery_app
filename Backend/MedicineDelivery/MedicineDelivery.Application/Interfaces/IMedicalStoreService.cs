using MedicineDelivery.Application.DTOs;

namespace MedicineDelivery.Application.Interfaces
{
    public interface IMedicalStoreService
    {
        Task<MedicalStoreRegistrationResult> RegisterMedicalStoreAsync(MedicalStoreRegistrationDto registrationDto);
        Task<MedicalStoreDto?> GetMedicalStoreByIdAsync(Guid id);
        Task<MedicalStoreDto?> GetMedicalStoreByEmailAsync(string email);
        Task<List<MedicalStoreDto>> GetAllMedicalStoresAsync();
        Task<MedicalStoreDto?> UpdateMedicalStoreAsync(Guid id, MedicalStoreRegistrationDto updateDto);

        /// <summary>Activates / deactivates a medical store. Returns false if not found or deleted.</summary>
        Task<bool> SetActiveStatusAsync(Guid id, bool isActive);

        Task<bool> DeleteMedicalStoreAsync(Guid id);
        Task<bool> CheckChemistAvailabilityAsync(Guid customerId, CancellationToken cancellationToken = default);
    }

    public class MedicalStoreRegistrationResult
    {
        public bool Success { get; set; }
        public MedicalStoreResponseDto? MedicalStore { get; set; }
        public List<string> Errors { get; set; } = new();
    }
}
