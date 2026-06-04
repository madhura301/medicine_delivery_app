using System;
using System.Threading;
using System.Threading.Tasks;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace MedicineDelivery.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class PolicyDocumentsController : ControllerBase
    {
        private readonly IPolicyDocumentService _policyDocumentService;
        private readonly ILogger<PolicyDocumentsController> _logger;

        public PolicyDocumentsController(IPolicyDocumentService policyDocumentService, ILogger<PolicyDocumentsController> logger)
        {
            _policyDocumentService = policyDocumentService;
            _logger = logger;
        }

        /// <summary>
        /// Upload a policy/legal document (Terms &amp; Conditions, Privacy Policy, Refund Policy, etc.).
        /// Stored under Files/PolicyDocuments in blob storage. Re-uploading a file with the same name
        /// overwrites the existing document.
        /// </summary>
        [HttpPost("upload")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> UploadDocument([FromForm] UploadPolicyDocumentDto uploadDto, CancellationToken cancellationToken)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var result = await _policyDocumentService.UploadDocumentAsync(uploadDto.File, cancellationToken);
                return Ok(result);
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning("UploadDocument: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in UploadDocument");
                return StatusCode(500, new { error = "An error occurred while uploading the document." });
            }
        }

        /// <summary>
        /// Download a policy/legal document by its file name. Publicly accessible so documents can be
        /// shown before sign-in.
        /// </summary>
        /// <param name="fileName">The stored file name, e.g. Terms_and_Conditions.pdf</param>
        [HttpGet("download/{fileName}")]
        [AllowAnonymous]
        public async Task<IActionResult> DownloadDocument(string fileName, CancellationToken cancellationToken)
        {
            try
            {
                var file = await _policyDocumentService.DownloadDocumentAsync(fileName, cancellationToken);
                if (file == null)
                {
                    return NotFound(new { error = "Document not found." });
                }

                return File(file.Content, file.ContentType, file.FileName);
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning("DownloadDocument: {Message}", ex.Message);
                return BadRequest(new { error = ex.Message });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499, new { error = "Request was cancelled." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in DownloadDocument for {FileName}", fileName);
                return StatusCode(500, new { error = "An error occurred while downloading the document." });
            }
        }
    }
}
