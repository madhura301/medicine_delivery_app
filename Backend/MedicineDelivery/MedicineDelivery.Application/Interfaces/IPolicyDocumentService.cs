using System.Threading;
using System.Threading.Tasks;
using MedicineDelivery.Application.DTOs;
using Microsoft.AspNetCore.Http;

namespace MedicineDelivery.Application.Interfaces
{
    public interface IPolicyDocumentService
    {
        /// <summary>
        /// Stores a policy/legal document under the policy documents folder.
        /// Re-uploading a file with the same name overwrites the existing document.
        /// </summary>
        Task<PolicyDocumentDto> UploadDocumentAsync(IFormFile file, CancellationToken cancellationToken = default);

        /// <summary>
        /// Opens a stored policy document by its file name. Returns null if it does not exist.
        /// </summary>
        Task<PolicyDocumentFileDto?> DownloadDocumentAsync(string fileName, CancellationToken cancellationToken = default);
    }
}
