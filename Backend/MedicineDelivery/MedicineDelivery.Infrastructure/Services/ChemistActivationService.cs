using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Domain.Enums;
using MedicineDelivery.Domain.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace MedicineDelivery.Infrastructure.Services
{
    /// <summary>
    /// Collects the chemist's one-time activation/onboarding fee via a Razorpay Payment Link
    /// and activates the store (stamps <c>MedicalStore.ActivatedOn</c>) when the link is paid.
    /// </summary>
    public class ChemistActivationService : IChemistActivationService
    {
        private const decimal DefaultActivationFee = 14999m;
        private const decimal DefaultGstPercent = 18m;

        private readonly IUnitOfWork _unitOfWork;
        private readonly IRazorpayPaymentLinkClient _paymentLinkClient;
        private readonly IConfiguration _configuration;
        private readonly ILogger<ChemistActivationService> _logger;

        public ChemistActivationService(
            IUnitOfWork unitOfWork,
            IRazorpayPaymentLinkClient paymentLinkClient,
            IConfiguration configuration,
            ILogger<ChemistActivationService> logger)
        {
            _unitOfWork = unitOfWork;
            _paymentLinkClient = paymentLinkClient;
            _configuration = configuration;
            _logger = logger;
        }

        public async Task<ChemistActivationResult> CreateActivationLinkAsync(Guid medicalStoreId, CancellationToken ct = default)
        {
            ct.ThrowIfCancellationRequested();

            var store = await _unitOfWork.MedicalStores.FirstOrDefaultAsync(s => s.MedicalStoreId == medicalStoreId);
            if (store == null)
                return ChemistActivationResult.Fail($"Medical store {medicalStoreId} not found.");

            if (store.ActivatedOn != null)
                return ChemistActivationResult.Fail("This chemist is already activated.");

            // Reuse an existing unpaid link if one is already pending (idempotent).
            var existing = await GetLatestAsync(medicalStoreId);
            if (existing is { Status: ChemistActivationStatus.Created, RazorpayPaymentLinkId: not null })
            {
                _logger.LogInformation("Returning existing pending activation link for store {StoreId}", medicalStoreId);
                return ChemistActivationResult.Ok(ToDto(existing, store));
            }

            var fee = GetDecimal("RazorpaySettings:ActivationFee", DefaultActivationFee);
            var gstPercent = GetDecimal("RazorpaySettings:ActivationGstPercent", DefaultGstPercent);
            var gst = Math.Round(fee * gstPercent / 100m, 2);
            var total = fee + gst;
            var currency = _configuration["RazorpaySettings:Currency"] ?? "INR";

            var record = new ChemistActivationPayment
            {
                MedicalStoreId = medicalStoreId,
                Amount = fee,
                Gst = gst,
                Status = ChemistActivationStatus.Created,
                CreatedOn = DateTime.UtcNow
            };

            var linkResult = await _paymentLinkClient.CreatePaymentLinkAsync(new PaymentLinkRequest
            {
                AmountInPaise = (int)(total * 100),
                Currency = currency,
                Description = "Pharmaish Platform Onboarding Fee",
                CustomerName = $"{store.OwnerFirstName} {store.OwnerLastName}".Trim(),
                CustomerEmail = store.EmailId,
                CustomerContact = store.MobileNumber,
                ReferenceNote = medicalStoreId.ToString()
            }, ct);

            if (!linkResult.Success)
            {
                _logger.LogWarning("Failed to create activation payment link for store {StoreId}: {Error}",
                    medicalStoreId, linkResult.Error);
                return ChemistActivationResult.Fail(linkResult.Error ?? "Failed to create activation payment link.");
            }

            record.RazorpayPaymentLinkId = linkResult.PaymentLinkId;

            await _unitOfWork.ChemistActivationPayments.AddAsync(record);
            await _unitOfWork.SaveChangesAsync();

            _logger.LogInformation("Activation link created for store {StoreId}. PaymentLinkId={LinkId}",
                medicalStoreId, linkResult.PaymentLinkId);

            var dto = ToDto(record, store);
            dto.PaymentLinkUrl = linkResult.ShortUrl;
            return ChemistActivationResult.Ok(dto);
        }

        public async Task<ChemistActivationResult> GetActivationStatusAsync(Guid medicalStoreId, CancellationToken ct = default)
        {
            ct.ThrowIfCancellationRequested();

            var store = await _unitOfWork.MedicalStores.FirstOrDefaultAsync(s => s.MedicalStoreId == medicalStoreId);
            if (store == null)
                return ChemistActivationResult.Fail($"Medical store {medicalStoreId} not found.");

            var latest = await GetLatestAsync(medicalStoreId);
            if (latest == null)
                return ChemistActivationResult.Fail("No activation payment found for this chemist.");

            return ChemistActivationResult.Ok(ToDto(latest, store));
        }

        public async Task<bool> MarkPaidFromWebhookAsync(string paymentLinkId, string? paymentId, CancellationToken ct = default)
        {
            ct.ThrowIfCancellationRequested();

            if (string.IsNullOrWhiteSpace(paymentLinkId))
                return false;

            var record = await _unitOfWork.ChemistActivationPayments
                .FirstOrDefaultAsync(a => a.RazorpayPaymentLinkId == paymentLinkId);

            if (record == null)
            {
                _logger.LogWarning("Activation webhook: no record for PaymentLinkId={LinkId}", paymentLinkId);
                return false;
            }

            if (record.Status == ChemistActivationStatus.Paid)
            {
                // Idempotent: already processed.
                return true;
            }

            record.Status = ChemistActivationStatus.Paid;
            record.RazorpayPaymentId = paymentId;
            record.PaidOn = DateTime.UtcNow;
            _unitOfWork.ChemistActivationPayments.Update(record);

            var store = await _unitOfWork.MedicalStores.FirstOrDefaultAsync(s => s.MedicalStoreId == record.MedicalStoreId);
            if (store != null && store.ActivatedOn == null)
            {
                store.ActivatedOn = DateTime.UtcNow;
                store.UpdatedOn = DateTime.UtcNow;
                _unitOfWork.MedicalStores.Update(store);
            }

            await _unitOfWork.SaveChangesAsync();

            _logger.LogInformation("Activation marked paid for store {StoreId} via PaymentLinkId={LinkId}",
                record.MedicalStoreId, paymentLinkId);
            return true;
        }

        // ----- helpers -----

        private async Task<ChemistActivationPayment?> GetLatestAsync(Guid medicalStoreId)
        {
            var all = await _unitOfWork.ChemistActivationPayments.FindAsync(a => a.MedicalStoreId == medicalStoreId);
            return all.OrderByDescending(a => a.CreatedOn).FirstOrDefault();
        }

        private decimal GetDecimal(string key, decimal fallback)
        {
            var raw = _configuration[key];
            return decimal.TryParse(raw, out var value) ? value : fallback;
        }

        private static ChemistActivationDto ToDto(ChemistActivationPayment a, MedicalStore store) => new()
        {
            MedicalStoreId = a.MedicalStoreId,
            Amount = a.Amount,
            Gst = a.Gst,
            GatewayCharges = a.GatewayCharges,
            Total = a.Total,
            Status = a.Status,
            PaymentLinkId = a.RazorpayPaymentLinkId,
            IsActivated = store.ActivatedOn != null,
            CreatedOn = a.CreatedOn,
            PaidOn = a.PaidOn
        };
    }
}
