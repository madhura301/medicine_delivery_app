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

        /// <summary>
        /// Permanently removes a medical store (and its cascading payout/activation
        /// records and login account) — refuses if the store has any order history.
        /// Intended for cleaning up test/junk chemist registrations only.
        /// </summary>
        Task<MedicalStoreHardDeleteResult> HardDeleteMedicalStoreAsync(Guid id);

        Task<bool> CheckChemistAvailabilityAsync(Guid customerId, CancellationToken cancellationToken = default);
    }

    public class MedicalStoreRegistrationResult
    {
        public bool Success { get; set; }
        public MedicalStoreResponseDto? MedicalStore { get; set; }
        public List<string> Errors { get; set; } = new();
    }

    public class MedicalStoreHardDeleteResult
    {
        public bool Success { get; set; }
        public bool NotFound { get; set; }
        /// <summary>True when refused because the store has real order history.</summary>
        public bool HasOrderHistory { get; set; }
        public string? Error { get; set; }

        public static MedicalStoreHardDeleteResult Ok() => new() { Success = true };
        public static MedicalStoreHardDeleteResult NotFoundResult() => new() { Success = false, NotFound = true };
        public static MedicalStoreHardDeleteResult BlockedByHistory() => new()
        {
            Success = false,
            HasOrderHistory = true,
            Error = "This chemist has order history and cannot be hard-deleted. Use the regular delete (deactivate) instead."
        };
    }
}
