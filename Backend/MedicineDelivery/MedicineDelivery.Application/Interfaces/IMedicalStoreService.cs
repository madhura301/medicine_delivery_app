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
        Task<bool> DeleteMedicalStoreAsync(Guid id);
    }

    public class MedicalStoreRegistrationResult
    {
        public bool Success { get; set; }
        public MedicalStoreResponseDto? MedicalStore { get; set; }
        public List<string> Errors { get; set; } = new();
    }
}
