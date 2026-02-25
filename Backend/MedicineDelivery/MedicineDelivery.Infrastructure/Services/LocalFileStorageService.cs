using MedicineDelivery.Application.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace MedicineDelivery.Infrastructure.Services
{
    public class LocalFileStorageService : IFileStorageService
    {
        private readonly string _rootPath;
        private readonly string _baseUrl;
        private readonly ILogger<LocalFileStorageService> _logger;

        public LocalFileStorageService(IHostEnvironment environment, IConfiguration configuration, ILogger<LocalFileStorageService> logger)
        {
            _rootPath = environment.ContentRootPath;
            _baseUrl = (configuration["BaseUrl"] ?? "http://localhost:5000").TrimEnd('/');
            _logger = logger;
        }

        public async Task<string> UploadAsync(Stream fileStream, string relativePath, CancellationToken cancellationToken = default)
        {
            var fullPath = Path.Combine(_rootPath, relativePath);
            var directory = Path.GetDirectoryName(fullPath);
            if (!string.IsNullOrEmpty(directory))
                Directory.CreateDirectory(directory);

            using var output = new FileStream(fullPath, FileMode.Create, FileAccess.Write, FileShare.None);
            await fileStream.CopyToAsync(output, cancellationToken);

            _logger.LogInformation("File uploaded to local path {FilePath}", fullPath);
            return relativePath;
        }

        public Task<Stream?> OpenReadAsync(string relativePath, CancellationToken cancellationToken = default)
        {
            var fullPath = Path.Combine(_rootPath, relativePath);
            if (!File.Exists(fullPath))
                return Task.FromResult<Stream?>(null);

            Stream stream = new FileStream(fullPath, FileMode.Open, FileAccess.Read, FileShare.Read);
            return Task.FromResult<Stream?>(stream);
        }

        public Task<bool> DeleteAsync(string relativePath, CancellationToken cancellationToken = default)
        {
            var fullPath = Path.Combine(_rootPath, relativePath);
            if (!File.Exists(fullPath))
                return Task.FromResult(false);

            try
            {
                File.Delete(fullPath);
                _logger.LogInformation("File deleted at local path {FilePath}", fullPath);
                return Task.FromResult(true);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to delete file at local path {FilePath}", fullPath);
                return Task.FromResult(false);
            }
        }

        public Task<bool> ExistsAsync(string relativePath, CancellationToken cancellationToken = default)
        {
            var fullPath = Path.Combine(_rootPath, relativePath);
            return Task.FromResult(File.Exists(fullPath));
        }

        public string GetPublicUrl(string relativePath)
        {
            if (string.IsNullOrEmpty(relativePath))
                return string.Empty;

            var normalized = relativePath.Replace("\\", "/").TrimStart('/');
            return $"{_baseUrl}/{normalized}";
        }
    }
}
