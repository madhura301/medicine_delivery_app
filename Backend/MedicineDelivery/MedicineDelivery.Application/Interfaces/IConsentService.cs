using MedicineDelivery.Application.DTOs;
using Microsoft.AspNetCore.Http;

namespace MedicineDelivery.Application.Interfaces
{
    public interface IConsentService
    {
        Task<ConsentDto?> GetConsentByIdAsync(Guid id);
        Task<List<ConsentDto>> GetAllConsentsAsync();
        Task<List<ConsentDto>> GetActiveConsentsAsync();
        Task<ConsentDto> CreateConsentAsync(CreateConsentDto createDto);
        Task<ConsentDto?> UpdateConsentAsync(Guid id, UpdateConsentDto updateDto);
        Task<bool> DeleteConsentAsync(Guid id);
        Task<ConsentLogDto> AcceptConsentAsync(Guid consentId, string userId, AcceptRejectConsentDto request, HttpContext httpContext);
        Task<ConsentLogDto> RejectConsentAsync(Guid consentId, string userId, AcceptRejectConsentDto request, HttpContext httpContext);
        Task<List<ConsentLogDto>> GetConsentLogsByConsentIdAsync(Guid consentId);
        Task<List<ConsentLogDto>> GetConsentLogsByUserIdAsync(string userId);
    }
}