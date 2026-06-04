using System.ComponentModel.DataAnnotations;
using System.IO;
using Microsoft.AspNetCore.Http;

namespace MedicineDelivery.Application.DTOs
{
    /// <summary>
    /// Request payload for uploading a policy/legal document.
    /// </summary>
    public class UploadPolicyDocumentDto
    {
        [Required]
        public IFormFile File { get; set; } = null!;
    }

    /// <summary>
    /// Metadata returned after a policy document has been stored.
    /// </summary>
    public class PolicyDocumentDto
    {
        public string FileName { get; set; } = string.Empty;
        public string FilePath { get; set; } = string.Empty;
        public string DownloadUrl { get; set; } = string.Empty;
        public long FileSizeBytes { get; set; }
        public string ContentType { get; set; } = string.Empty;
    }

    /// <summary>
    /// Carries the file content for a download. Not serialized — used to stream a file back to the caller.
    /// </summary>
    public class PolicyDocumentFileDto
    {
        public Stream Content { get; set; } = Stream.Null;
        public string FileName { get; set; } = string.Empty;
        public string ContentType { get; set; } = string.Empty;
    }
}
