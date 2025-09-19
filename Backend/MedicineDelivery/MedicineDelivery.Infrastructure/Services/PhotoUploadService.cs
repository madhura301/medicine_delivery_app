using MedicineDelivery.Application.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using System.Security.Cryptography;

namespace MedicineDelivery.Infrastructure.Services
{
    public class PhotoUploadService : IPhotoUploadService
    {
        private readonly IHostEnvironment _environment;
        private readonly IConfiguration _configuration;
        private readonly string[] _allowedExtensions = { ".jpg", ".jpeg", ".png", ".gif", ".bmp" };
        private readonly long _maxFileSizeInBytes = 5 * 1024 * 1024; // 5MB

        public PhotoUploadService(IHostEnvironment environment, IConfiguration configuration)
        {
            _environment = environment;
            _configuration = configuration;
        }

        public async Task<string> UploadPhotoAsync(IFormFile photo, string entityType, Guid entityId)
        {
            if (photo == null || photo.Length == 0)
                throw new ArgumentException("No photo file provided");

            if (!IsValidPhotoFile(photo))
                throw new ArgumentException("Invalid photo file format or size");

            // Create upload directory if it doesn't exist
            var uploadPath = Path.Combine(_environment.ContentRootPath, "wwwroot", "uploads", entityType.ToLower());
            if (!Directory.Exists(uploadPath))
                Directory.CreateDirectory(uploadPath);

            // Generate unique filename
            var fileExtension = Path.GetExtension(photo.FileName).ToLowerInvariant();
            var uniqueFileName = GenerateUniqueFileName(entityId, fileExtension);

            var filePath = Path.Combine(uploadPath, uniqueFileName);

            // Save the file
            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await photo.CopyToAsync(stream);
            }

            return uniqueFileName;
        }

        public async Task<bool> DeletePhotoAsync(string fileName, string entityType)
        {
            if (string.IsNullOrEmpty(fileName))
                return false;

            var filePath = Path.Combine(_environment.ContentRootPath, "wwwroot", "uploads", entityType.ToLower(), fileName);
            
            if (File.Exists(filePath))
            {
                try
                {
                    File.Delete(filePath);
                    return true;
                }
                catch
                {
                    return false;
                }
            }

            return false;
        }

        public string GetPhotoUrl(string fileName, string entityType)
        {
            if (string.IsNullOrEmpty(fileName))
                return string.Empty;

            var baseUrl = _configuration["BaseUrl"] ?? "http://localhost:5000";
            return $"{baseUrl}/uploads/{entityType.ToLower()}/{fileName}";
        }

        public bool IsValidPhotoFile(IFormFile file)
        {
            if (file == null || file.Length == 0)
                return false;

            // Check file size
            if (file.Length > _maxFileSizeInBytes)
                return false;

            // Check file extension
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
            // Generate a unique filename using entity ID and timestamp
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
