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

            _logger.LogInformation("CreateActivationLinkAsync requested for store {StoreId}", medicalStoreId);

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
            record.PaymentLinkShortUrl = linkResult.ShortUrl;

            await _unitOfWork.ChemistActivationPayments.AddAsync(record);
            await _unitOfWork.SaveChangesAsync();

            _logger.LogInformation("Activation link created for store {StoreId}. PaymentLinkId={LinkId}",
                medicalStoreId, linkResult.PaymentLinkId);

            return ChemistActivationResult.Ok(ToDto(record, store));
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

            // Read the stored status BEFORE reconciling. Comparing Razorpay against the post-refresh
            // value would always match — hiding exactly the drift this is meant to expose.
            var storedStatusOnArrival = latest.Status;
            var live = await ReconcileWithRazorpayAsync(latest, store, ct);

            var dto = ToDto(latest, store);
            ApplyLiveView(dto, storedStatusOnArrival, live);
            return ChemistActivationResult.Ok(dto);
        }

        /// <summary>
        /// "Sync with database": takes Razorpay's word for the payment link and writes it to our
        /// record. This is the repair path for a payment that arrived while the webhook was missing
        /// or misconfigured — otherwise the chemist stays un-activated despite having paid.
        /// </summary>
        public async Task<ChemistActivationResult> RefreshFromRazorpayAsync(Guid medicalStoreId, CancellationToken ct = default)
        {
            ct.ThrowIfCancellationRequested();

            _logger.LogInformation("RefreshFromRazorpayAsync requested for store {StoreId}", medicalStoreId);

            var store = await _unitOfWork.MedicalStores.FirstOrDefaultAsync(s => s.MedicalStoreId == medicalStoreId);
            if (store == null)
                return ChemistActivationResult.Fail($"Medical store {medicalStoreId} not found.");

            var latest = await GetLatestAsync(medicalStoreId);
            if (latest == null)
                return ChemistActivationResult.Fail("No activation payment found for this chemist.");

            var storedStatusOnArrival = latest.Status;
            var live = await ReconcileWithRazorpayAsync(latest, store, ct);

            if (live is { Success: false })
                return ChemistActivationResult.Fail(live.Error ?? "Could not reach Razorpay.");

            var dto = ToDto(latest, store);
            ApplyLiveView(dto, storedStatusOnArrival, live);
            return ChemistActivationResult.Ok(dto);
        }

        /// <summary>
        /// Reads the payment link from Razorpay and brings our record into line with it.
        /// Returns null when there is no link to look up, otherwise the live reading — including a
        /// failed one, in which case the stored status is left exactly as it was.
        /// </summary>
        private async Task<PaymentLinkStatusResult?> ReconcileWithRazorpayAsync(
            ChemistActivationPayment record, MedicalStore store, CancellationToken ct)
        {
            if (string.IsNullOrWhiteSpace(record.RazorpayPaymentLinkId))
                return null;

            var live = await _paymentLinkClient.GetPaymentLinkAsync(record.RazorpayPaymentLinkId, ct);
            if (!live.Success)
                return live;

            var mapped = MapLinkStatus(live.RawStatus);
            if (mapped == null)
                return live;

            var changed = false;

            if (mapped != record.Status)
            {
                _logger.LogInformation(
                    "Activation status drift for store {StoreId}: stored={StoredStatus}, Razorpay={RazorpayStatus} ({RawStatus}). Correcting.",
                    store.MedicalStoreId, record.Status, mapped, live.RawStatus);
                record.Status = mapped.Value;
                changed = true;
            }

            if (mapped == ChemistActivationStatus.Paid)
            {
                // Fill in the payment details Razorpay holds but we may be missing. This happens when
                // a record was marked paid by hand: the status is right, yet PaidOn, the payment id
                // and the store's activation date were never set.
                if (record.PaidOn == null)
                {
                    // Prefer Razorpay's own capture time over "now" — the payment may be days old.
                    record.PaidOn = live.PaidAt ?? DateTime.UtcNow;
                    changed = true;
                }

                if (record.RazorpayPaymentId == null && live.PaymentId != null)
                {
                    record.RazorpayPaymentId = live.PaymentId;
                    changed = true;
                }

                if (store.ActivatedOn == null)
                {
                    // Drives the platform-fee free window and the console's "activated" state, so it
                    // must be stamped here too — the webhook is no longer the only path to Paid.
                    store.ActivatedOn = record.PaidOn;
                    store.UpdatedOn = DateTime.UtcNow;
                    _unitOfWork.MedicalStores.Update(store);
                    changed = true;

                    _logger.LogInformation(
                        "Store {StoreId} activation date backfilled to {ActivatedOn} from Razorpay payment {PaymentId}.",
                        store.MedicalStoreId, store.ActivatedOn, live.PaymentId);
                }
            }

            if (changed)
            {
                _unitOfWork.ChemistActivationPayments.Update(record);
                await _unitOfWork.SaveChangesAsync();
            }

            return live;
        }

        /// <summary>Copies the live reading onto the DTO. These fields are per-request only.</summary>
        private static void ApplyLiveView(ChemistActivationDto dto, ChemistActivationStatus storedStatusOnArrival, PaymentLinkStatusResult? live)
        {
            if (live == null)
            {
                // No payment link exists, so there was nothing to look up.
                dto.RazorpayReachable = false;
                dto.RazorpayCheckedAt = null;
                dto.InSync = null;
                return;
            }

            dto.RazorpayCheckedAt = DateTime.UtcNow;

            if (!live.Success)
            {
                dto.RazorpayReachable = false;
                dto.RazorpayError = live.Error;
                dto.InSync = null;
                return;
            }

            dto.RazorpayReachable = true;
            dto.RazorpayRawStatus = live.RawStatus;
            dto.RazorpayStatus = MapLinkStatus(live.RawStatus);
            dto.RazorpayAmountPaid = live.AmountPaid;
            dto.RazorpayPaymentId = live.PaymentId;
            dto.InSync = dto.RazorpayStatus == null ? null : dto.RazorpayStatus == storedStatusOnArrival;
        }

        /// <summary>
        /// Razorpay payment-link states mapped onto ours. Unknown wording returns null rather than
        /// guessing, so a new Razorpay state never silently marks an activation paid.
        /// </summary>
        private static ChemistActivationStatus? MapLinkStatus(string? rawStatus) => rawStatus?.Trim().ToLowerInvariant() switch
        {
            "paid" => ChemistActivationStatus.Paid,
            "expired" => ChemistActivationStatus.Expired,
            "cancelled" => ChemistActivationStatus.Failed,
            "created" or "partially_paid" => ChemistActivationStatus.Created,
            _ => null
        };

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
            PaymentLinkUrl = a.PaymentLinkShortUrl,
            IsActivated = store.ActivatedOn != null,
            CreatedOn = a.CreatedOn,
            PaidOn = a.PaidOn
        };
    }
}
