using System;
using System.Collections.Generic;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

namespace MedicineDelivery.Infrastructure.Services
{
    public class PolicyDocumentService : IPolicyDocumentService
    {
        private const string DocumentFolder = "PolicyDocuments";

        private static readonly HashSet<string> AllowedExtensions = new(StringComparer.OrdinalIgnoreCase)
        {
            ".pdf", ".doc", ".docx", ".txt"
        };

        private readonly IFileStorageService _fileStorage;
        private readonly ILogger<PolicyDocumentService> _logger;

        public PolicyDocumentService(IFileStorageService fileStorage, ILogger<PolicyDocumentService> logger)
        {
            _fileStorage = fileStorage;
            _logger = logger;
        }

        public async Task<PolicyDocumentDto> UploadDocumentAsync(IFormFile file, CancellationToken cancellationToken = default)
        {
            if (file == null || file.Length == 0)
                throw new ArgumentException("No file was provided for upload.", nameof(file));

            // Strip any directory components a client may have sent in the file name.
            var safeFileName = Path.GetFileName(file.FileName);
            if (string.IsNullOrWhiteSpace(safeFileName))
                throw new ArgumentException("The uploaded file must have a valid name.", nameof(file));

            var extension = Path.GetExtension(safeFileName);
            if (string.IsNullOrEmpty(extension) || !AllowedExtensions.Contains(extension))
                throw new ArgumentException(
                    $"File type '{extension}' is not supported. Allowed types: {string.Join(", ", AllowedExtensions)}.",
                    nameof(file));

            var relativePath = BuildRelativePath(safeFileName);

            using var stream = file.OpenReadStream();
            await _fileStorage.UploadAsync(stream, relativePath, cancellationToken);

            _logger.LogInformation("Policy document uploaded: {FileName}", safeFileName);

            return new PolicyDocumentDto
            {
                FileName = safeFileName,
                FilePath = relativePath,
                DownloadUrl = _fileStorage.GetPublicUrl(relativePath),
                FileSizeBytes = file.Length,
                ContentType = GetContentType(extension)
            };
        }

        public async Task<PolicyDocumentFileDto?> DownloadDocumentAsync(string fileName, CancellationToken cancellationToken = default)
        {
            if (string.IsNullOrWhiteSpace(fileName))
                throw new ArgumentException("A file name must be provided.", nameof(fileName));

            // Guard against path traversal: only a bare file name is allowed (no directory segments).
            var safeFileName = Path.GetFileName(fileName);
            if (!string.Equals(safeFileName, fileName, StringComparison.Ordinal))
                throw new ArgumentException("The file name must not contain path segments.", nameof(fileName));

            var relativePath = BuildRelativePath(safeFileName);
            var stream = await _fileStorage.OpenReadAsync(relativePath, cancellationToken);
            if (stream == null)
                return null;

            return new PolicyDocumentFileDto
            {
                Content = stream,
                FileName = safeFileName,
                ContentType = GetContentType(Path.GetExtension(safeFileName))
            };
        }

        private static string BuildRelativePath(string fileName)
            => Path.Combine("Files", DocumentFolder, fileName).Replace("\\", "/");

        private static string GetContentType(string extension) => extension.ToLowerInvariant() switch
        {
            ".pdf" => "application/pdf",
            ".doc" => "application/msword",
            ".docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            ".txt" => "text/plain",
            _ => "application/octet-stream"
        };
    }
}
