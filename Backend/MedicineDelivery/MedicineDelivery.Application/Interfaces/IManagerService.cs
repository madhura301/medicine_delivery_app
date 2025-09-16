using MedicineDelivery.Application.DTOs;

namespace MedicineDelivery.Application.Interfaces
{
    public interface IManagerService
    {
        Task<ManagerRegistrationResult> RegisterManagerAsync(ManagerRegistrationDto registrationDto);
        Task<ManagerDto?> GetManagerByIdAsync(Guid id);
        Task<ManagerDto?> GetManagerByEmailAsync(string email);
        Task<List<ManagerDto>> GetAllManagersAsync();
        Task<ManagerDto?> UpdateManagerAsync(Guid id, ManagerRegistrationDto updateDto);
        Task<bool> DeleteManagerAsync(Guid id);
    }

    public class ManagerRegistrationResult
    {
        public bool Success { get; set; }
        public ManagerResponseDto? Manager { get; set; }
        public List<string> Errors { get; set; } = new();
    }
}
