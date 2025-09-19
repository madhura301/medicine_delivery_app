using Microsoft.AspNetCore.Http;

namespace MedicineDelivery.Application.Interfaces
{
    public interface IPhotoUploadService
    {
        Task<string> UploadPhotoAsync(IFormFile photo, string entityType, Guid entityId);
        Task<bool> DeletePhotoAsync(string fileName, string entityType);
        string GetPhotoUrl(string fileName, string entityType);
        bool IsValidPhotoFile(IFormFile file);
        long GetMaxFileSizeInBytes();
        string[] GetAllowedExtensions();
    }
}
