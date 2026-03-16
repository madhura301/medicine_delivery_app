using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using MedicineDelivery.Application.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace MedicineDelivery.Infrastructure.Services
{
    public class AzureBlobStorageService : IFileStorageService
    {
        private readonly BlobContainerClient _containerClient;
        private readonly ILogger<AzureBlobStorageService> _logger;

        public AzureBlobStorageService(IConfiguration configuration, ILogger<AzureBlobStorageService> logger)
        {
            _logger = logger;

            var connectionString = configuration["AzureBlobStorage:ConnectionString"]
                ?? throw new InvalidOperationException("AzureBlobStorage:ConnectionString is not configured.");
            var containerName = configuration["AzureBlobStorage:ContainerName"]
                ?? throw new InvalidOperationException("AzureBlobStorage:ContainerName is not configured.");

            var serviceClient = new BlobServiceClient(connectionString);
            _containerClient = serviceClient.GetBlobContainerClient(containerName);
            _containerClient.CreateIfNotExists(PublicAccessType.None);
        }

        public async Task<string> UploadAsync(Stream fileStream, string relativePath, CancellationToken cancellationToken = default)
        {
            var blobPath = NormalizePath(relativePath);
            var blobClient = _containerClient.GetBlobClient(blobPath);

            await blobClient.UploadAsync(fileStream, overwrite: true, cancellationToken);
            _logger.LogInformation("File uploaded to blob {BlobPath}", blobPath);

            return relativePath;
        }

        public async Task<Stream?> OpenReadAsync(string relativePath, CancellationToken cancellationToken = default)
        {
            var blobPath = NormalizePath(relativePath);
            var blobClient = _containerClient.GetBlobClient(blobPath);

            if (!await blobClient.ExistsAsync(cancellationToken))
                return null;

            var memoryStream = new MemoryStream();
            await blobClient.DownloadToAsync(memoryStream, cancellationToken);
            memoryStream.Position = 0;
            return memoryStream;
        }

        public async Task<bool> DeleteAsync(string relativePath, CancellationToken cancellationToken = default)
        {
            var blobPath = NormalizePath(relativePath);
            var blobClient = _containerClient.GetBlobClient(blobPath);

            var response = await blobClient.DeleteIfExistsAsync(cancellationToken: cancellationToken);
            if (response.Value)
                _logger.LogInformation("Blob deleted at {BlobPath}", blobPath);

            return response.Value;
        }

        public async Task<bool> ExistsAsync(string relativePath, CancellationToken cancellationToken = default)
        {
            var blobPath = NormalizePath(relativePath);
            var blobClient = _containerClient.GetBlobClient(blobPath);

            var response = await blobClient.ExistsAsync(cancellationToken);
            return response.Value;
        }

        public string GetPublicUrl(string relativePath)
        {
            if (string.IsNullOrEmpty(relativePath))
                return string.Empty;

            var blobPath = NormalizePath(relativePath);
            var blobClient = _containerClient.GetBlobClient(blobPath);
            return blobClient.Uri.ToString();
        }

        private static string NormalizePath(string path)
        {
            return path.Replace("\\", "/").TrimStart('/');
        }
    }
}
