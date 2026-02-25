using MedicineDelivery.Application.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using System.Security.Cryptography;

namespace MedicineDelivery.Infrastructure.Services
{
    public class PhotoUploadService : IPhotoUploadService
    {
        private readonly IFileStorageService _fileStorageService;
        private readonly ILogger<PhotoUploadService> _logger;
        private readonly string[] _allowedExtensions = { ".jpg", ".jpeg", ".png", ".gif", ".bmp" };
        private readonly long _maxFileSizeInBytes = 5 * 1024 * 1024; // 5MB

        public PhotoUploadService(IFileStorageService fileStorageService, ILogger<PhotoUploadService> logger)
        {
            _fileStorageService = fileStorageService;
            _logger = logger;
        }

        public async Task<string> UploadPhotoAsync(IFormFile photo, string entityType, Guid entityId)
        {
            if (photo == null || photo.Length == 0)
            {
                _logger.LogWarning("Upload attempted with no photo file for entity {EntityType}/{EntityId}", entityType, entityId);
                throw new ArgumentException("No photo file provided");
            }

            if (!IsValidPhotoFile(photo))
            {
                _logger.LogWarning("Upload attempted with invalid photo file for entity {EntityType}/{EntityId}. FileName: {FileName}, Size: {FileSize}", entityType, entityId, photo.FileName, photo.Length);
                throw new ArgumentException("Invalid photo file format or size");
            }

            var fileExtension = Path.GetExtension(photo.FileName).ToLowerInvariant();
            var uniqueFileName = GenerateUniqueFileName(entityId, fileExtension);
            var relativePath = Path.Combine("wwwroot", "uploads", entityType.ToLower(), uniqueFileName).Replace("\\", "/");

            using var stream = photo.OpenReadStream();
            await _fileStorageService.UploadAsync(stream, relativePath);

            return uniqueFileName;
        }

        public async Task<bool> DeletePhotoAsync(string fileName, string entityType)
        {
            if (string.IsNullOrEmpty(fileName))
                return false;

            var relativePath = Path.Combine("wwwroot", "uploads", entityType.ToLower(), fileName).Replace("\\", "/");
            return await _fileStorageService.DeleteAsync(relativePath);
        }

        public string GetPhotoUrl(string fileName, string entityType)
        {
            if (string.IsNullOrEmpty(fileName))
                return string.Empty;

            var relativePath = Path.Combine("uploads", entityType.ToLower(), fileName).Replace("\\", "/");
            return _fileStorageService.GetPublicUrl(relativePath);
        }

        public bool IsValidPhotoFile(IFormFile file)
        {
            if (file == null || file.Length == 0)
                return false;

            if (file.Length > _maxFileSizeInBytes)
                return false;

            var fileExtension = Path.GetExtension(file.FileName).ToLowerInvariant();
            return _allowedExtensions.Contains(fileExtension);
        }

        public long GetMaxFileSizeInBytes()
        {
            return _maxFileSizeInBytes;
        }

        public string[] GetAllowedExtensions()
        {
            return _allowedExtensions;
        }

        private string GenerateUniqueFileName(Guid entityId, string fileExtension)
        {
            var timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
            var randomBytes = new byte[4];
            using (var rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(randomBytes);
            }
            var randomString = Convert.ToHexString(randomBytes).ToLowerInvariant();

            return $"{entityId}_{timestamp}_{randomString}{fileExtension}";
        }
    }
}
