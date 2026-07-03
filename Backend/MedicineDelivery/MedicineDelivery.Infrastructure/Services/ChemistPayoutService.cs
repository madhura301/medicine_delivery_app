using System.Text.RegularExpressions;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Domain.Enums;
using MedicineDelivery.Domain.Interfaces;
using Microsoft.Extensions.Logging;

namespace MedicineDelivery.Infrastructure.Services
{
    /// <summary>
    /// Orchestrates chemist (medical store) onboarding as a Razorpay Route linked account
    /// and persists the resulting payout configuration / status.
    /// </summary>
    public class ChemistPayoutService : IChemistPayoutService
    {
        private static readonly Regex IfscRegex = new("^[A-Z]{4}0[A-Z0-9]{6}$", RegexOptions.Compiled);

        private readonly IUnitOfWork _unitOfWork;
        private readonly IRazorpayRouteClient _routeClient;
        private readonly ILogger<ChemistPayoutService> _logger;

        public ChemistPayoutService(
            IUnitOfWork unitOfWork,
            IRazorpayRouteClient routeClient,
            ILogger<ChemistPayoutService> logger)
        {
            _unitOfWork = unitOfWork;
            _routeClient = routeClient;
            _logger = logger;
        }

        public async Task<ChemistPayoutResult> OnboardAsync(Guid medicalStoreId, OnboardChemistPayoutDto request, CancellationToken ct = default)
        {
            ct.ThrowIfCancellationRequested();

            var validationErrors = ValidateBank(request.BankAccountNumber, request.BankIfscCode, request.BankAccountHolderName);
            if (validationErrors.Count > 0)
                return ChemistPayoutResult.Fail(validationErrors.ToArray());

            var store = await _unitOfWork.MedicalStores.FirstOrDefaultAsync(s => s.MedicalStoreId == medicalStoreId);
            if (store == null)
                return ChemistPayoutResult.Fail($"Medical store {medicalStoreId} not found.");

            var account = await _unitOfWork.ChemistPayoutAccounts.FirstOrDefaultAsync(a => a.MedicalStoreId == medicalStoreId);
            var isNew = account == null;

            if (account != null && account.OnboardingStatus == ChemistPayoutStatus.Active)
                return ChemistPayoutResult.Fail("This chemist already has an active payout account.");

            account ??= new ChemistPayoutAccount
            {
                MedicalStoreId = medicalStoreId,
                CreatedOn = DateTime.UtcNow
            };

            account.BankAccountNumber = request.BankAccountNumber.Trim();
            account.BankIfscCode = request.BankIfscCode.Trim().ToUpperInvariant();
            account.BankAccountHolderName = request.BankAccountHolderName.Trim();

            // Resumable: passes any ids from a previous (partial) attempt so completed
            // steps are skipped and a failure (e.g. stakeholder) can be retried.
            _logger.LogInformation(
                "Onboarding store {StoreId}: ExistingLinkedAccountId={Acc}, ExistingStakeholderId={Sth}, " +
                "ExistingProductConfigurationId={Prod}, StorePAN={Pan}, StoreGST={Gst}",
                medicalStoreId, account.RazorpayLinkedAccountId ?? "(none)", account.RazorpayStakeholderId ?? "(none)",
                account.RazorpayProductConfigurationId ?? "(none)", store.PAN, store.GSTIN ?? "(none)");

            var onboarding = await _routeClient.CreateLinkedAccountAsync(BuildRequest(store, account), ct);

            ApplyOnboardingResult(account, onboarding);

            await PersistAsync(account, isNew);

            if (!onboarding.Success)
            {
                _logger.LogWarning("Chemist payout onboarding incomplete for store {StoreId}. Step={Step}, Error={Error}",
                    medicalStoreId, onboarding.FailedStep, onboarding.Error);
                return ChemistPayoutResult.Fail(onboarding.Error ?? "Razorpay onboarding failed.");
            }

            _logger.LogInformation("Chemist payout onboarding processed for store {StoreId}. LinkedAccount={AccountId}, Status={Status}",
                medicalStoreId, account.RazorpayLinkedAccountId, account.OnboardingStatus);

            return ChemistPayoutResult.Ok(ToDto(account));
        }

        public async Task<ChemistPayoutResult> GetStatusAsync(Guid medicalStoreId, CancellationToken ct = default)
        {
            ct.ThrowIfCancellationRequested();

            var account = await _unitOfWork.ChemistPayoutAccounts.FirstOrDefaultAsync(a => a.MedicalStoreId == medicalStoreId);
            if (account == null)
                return ChemistPayoutResult.Fail($"No payout account found for medical store {medicalStoreId}.");

            return ChemistPayoutResult.Ok(ToDto(account));
        }

        public async Task<ChemistPayoutResult> UpdateBankDetailsAsync(Guid medicalStoreId, UpdateChemistBankDto request, CancellationToken ct = default)
        {
            ct.ThrowIfCancellationRequested();

            var validationErrors = ValidateBank(request.BankAccountNumber, request.BankIfscCode, request.BankAccountHolderName);
            if (validationErrors.Count > 0)
                return ChemistPayoutResult.Fail(validationErrors.ToArray());

            var account = await _unitOfWork.ChemistPayoutAccounts.FirstOrDefaultAsync(a => a.MedicalStoreId == medicalStoreId);
            if (account == null)
                return ChemistPayoutResult.Fail($"No payout account found for medical store {medicalStoreId}. Onboard the chemist first.");

            account.BankAccountNumber = request.BankAccountNumber.Trim();
            account.BankIfscCode = request.BankIfscCode.Trim().ToUpperInvariant();
            account.BankAccountHolderName = request.BankAccountHolderName.Trim();

            if (string.IsNullOrWhiteSpace(account.RazorpayLinkedAccountId))
            {
                // No linked account yet — nothing to update at Razorpay; just persist locally.
                account.UpdatedOn = DateTime.UtcNow;
                _unitOfWork.ChemistPayoutAccounts.Update(account);
                await _unitOfWork.SaveChangesAsync();
                return ChemistPayoutResult.Ok(ToDto(account));
            }

            var onboarding = await _routeClient.UpdateBankConfigurationAsync(
                account.RazorpayLinkedAccountId,
                account.RazorpayProductConfigurationId,
                BuildBank(account),
                ct);

            ApplyOnboardingResult(account, onboarding);
            _unitOfWork.ChemistPayoutAccounts.Update(account);
            await _unitOfWork.SaveChangesAsync();

            if (!onboarding.Success)
                return ChemistPayoutResult.Fail(onboarding.Error ?? "Razorpay bank update failed.");

            return ChemistPayoutResult.Ok(ToDto(account));
        }

        public async Task<ChemistPayoutRefreshResultDto> RefreshPendingStatusesAsync(CancellationToken ct = default)
        {
            ct.ThrowIfCancellationRequested();

            // Pull every account still awaiting activation that has a linked account to query.
            var pending = await _unitOfWork.ChemistPayoutAccounts.FindAsync(a =>
                a.OnboardingStatus == ChemistPayoutStatus.Pending ||
                a.OnboardingStatus == ChemistPayoutStatus.NeedsClarification);

            var candidates = pending
                .Where(a => !string.IsNullOrWhiteSpace(a.RazorpayLinkedAccountId))
                .ToList();

            var result = new ChemistPayoutRefreshResultDto { Checked = candidates.Count };

            foreach (var account in candidates)
            {
                ct.ThrowIfCancellationRequested();

                var previous = account.OnboardingStatus;
                var item = new ChemistPayoutRefreshItemDto
                {
                    MedicalStoreId = account.MedicalStoreId,
                    RazorpayLinkedAccountId = account.RazorpayLinkedAccountId,
                    PreviousStatus = previous.ToString(),
                    NewStatus = previous.ToString()
                };

                var statusResult = await _routeClient.GetAccountStatusAsync(account.RazorpayLinkedAccountId!, ct);
                item.RazorpayRawStatus = statusResult.RawStatus;

                if (!statusResult.Success)
                {
                    item.Error = statusResult.Error;
                    result.Items.Add(item);
                    continue;
                }

                var newStatus = MapState(statusResult.State);
                item.NewStatus = newStatus.ToString();

                if (newStatus != previous)
                {
                    account.OnboardingStatus = newStatus;
                    if (newStatus == ChemistPayoutStatus.Active)
                    {
                        account.OnboardingError = null;
                        account.ActivatedOn ??= DateTime.UtcNow;
                    }
                    account.UpdatedOn = DateTime.UtcNow;
                    _unitOfWork.ChemistPayoutAccounts.Update(account);

                    item.Changed = true;
                    result.Updated++;
                    if (newStatus == ChemistPayoutStatus.Active) result.Activated++;
                }

                result.Items.Add(item);
            }

            if (result.Updated > 0)
                await _unitOfWork.SaveChangesAsync();

            _logger.LogInformation(
                "Chemist payout refresh: checked={Checked}, updated={Updated}, activated={Activated}",
                result.Checked, result.Updated, result.Activated);

            return result;
        }

        public async Task<ChemistPayoutResult> RefreshStatusAsync(Guid chemistId, CancellationToken ct = default)
        {
            ct.ThrowIfCancellationRequested();

            // Resolve the store by its id, or by the logged-in chemist's UserId.
            var idText = chemistId.ToString();
            var store = await _unitOfWork.MedicalStores.FirstOrDefaultAsync(s =>
                s.MedicalStoreId == chemistId || s.UserId == idText);
            if (store == null)
                return ChemistPayoutResult.Fail($"No chemist found for id {chemistId}.");

            var account = await _unitOfWork.ChemistPayoutAccounts
                .FirstOrDefaultAsync(a => a.MedicalStoreId == store.MedicalStoreId);
            if (account == null)
                return ChemistPayoutResult.Fail("This chemist has no payout account yet. Complete onboarding first.");

            // Need to remove code
            if(account.OnboardingStatus == ChemistPayoutStatus.Active)
                return ChemistPayoutResult.Ok(ToDto(account));


            // Nothing to pull from Razorpay until a linked account exists.
            if (string.IsNullOrWhiteSpace(account.RazorpayLinkedAccountId))
                return ChemistPayoutResult.Ok(ToDto(account));

            var statusResult = await _routeClient.GetAccountStatusAsync(account.RazorpayLinkedAccountId!, ct);
            if (!statusResult.Success)
            {
                _logger.LogWarning("Refresh status: Razorpay lookup failed for store {StoreId}: {Error}",
                    store.MedicalStoreId, statusResult.Error);
                // Return the current (unchanged) status rather than failing the button.
                return ChemistPayoutResult.Ok(ToDto(account));
            }

            var newStatus = MapState(statusResult.State);
            if (newStatus != account.OnboardingStatus)
            {
                var previous = account.OnboardingStatus;
                account.OnboardingStatus = newStatus;
                if (newStatus == ChemistPayoutStatus.Active)
                {
                    account.OnboardingError = null;
                    account.ActivatedOn ??= DateTime.UtcNow;
                }
                account.UpdatedOn = DateTime.UtcNow;
                _unitOfWork.ChemistPayoutAccounts.Update(account);
                await _unitOfWork.SaveChangesAsync();

                _logger.LogInformation("Refresh status: store {StoreId} {Old} -> {New} (razorpay={Raw})",
                    store.MedicalStoreId, previous, newStatus, statusResult.RawStatus);
            }

            return ChemistPayoutResult.Ok(ToDto(account));
        }

        // ----- helpers -----

        private static ChemistPayoutStatus MapState(RazorpayActivationState state) => state switch
        {
            RazorpayActivationState.Activated => ChemistPayoutStatus.Active,
            RazorpayActivationState.Rejected => ChemistPayoutStatus.Rejected,
            RazorpayActivationState.Suspended => ChemistPayoutStatus.Suspended,
            RazorpayActivationState.NeedsClarification => ChemistPayoutStatus.NeedsClarification,
            _ => ChemistPayoutStatus.Pending
        };

        private async Task PersistAsync(ChemistPayoutAccount account, bool isNew)
        {
            if (isNew)
                await _unitOfWork.ChemistPayoutAccounts.AddAsync(account);
            else
                _unitOfWork.ChemistPayoutAccounts.Update(account);

            await _unitOfWork.SaveChangesAsync();
        }

        private static void ApplyOnboardingResult(ChemistPayoutAccount account, RazorpayOnboardingResult onboarding)
        {
            if (!string.IsNullOrWhiteSpace(onboarding.LinkedAccountId))
                account.RazorpayLinkedAccountId = onboarding.LinkedAccountId;
            if (!string.IsNullOrWhiteSpace(onboarding.StakeholderId))
                account.RazorpayStakeholderId = onboarding.StakeholderId;
            if (!string.IsNullOrWhiteSpace(onboarding.ProductConfigurationId))
                account.RazorpayProductConfigurationId = onboarding.ProductConfigurationId;

            account.OnboardingError = onboarding.Success ? null : onboarding.Error;
            account.OnboardingStatus = MapStatus(onboarding);

            if (account.OnboardingStatus == ChemistPayoutStatus.Active && account.ActivatedOn == null)
                account.ActivatedOn = DateTime.UtcNow;

            account.UpdatedOn = DateTime.UtcNow;
        }

        private static ChemistPayoutStatus MapStatus(RazorpayOnboardingResult onboarding)
        {
            // A failed call before/at linked-account creation leaves us not-started/pending.
            if (!onboarding.Success && string.IsNullOrWhiteSpace(onboarding.LinkedAccountId))
                return ChemistPayoutStatus.NotStarted;

            return onboarding.State switch
            {
                RazorpayActivationState.Activated => ChemistPayoutStatus.Active,
                RazorpayActivationState.Rejected => ChemistPayoutStatus.Rejected,
                RazorpayActivationState.Suspended => ChemistPayoutStatus.Suspended,
                RazorpayActivationState.NeedsClarification => ChemistPayoutStatus.NeedsClarification,
                _ => ChemistPayoutStatus.Pending
            };
        }

        private static RazorpayOnboardingRequest BuildRequest(MedicalStore store, ChemistPayoutAccount account) => new()
        {
            BusinessName = Clean(store.MedicalName),
            ContactName = $"{Clean(store.OwnerFirstName)} {Clean(store.OwnerLastName)}".Trim(),
            Email = Clean(store.EmailId),
            Phone = Clean(store.MobileNumber),
            Street1 = Clean(store.AddressLine1),
            Street2 = Clean(store.AddressLine2),
            City = Clean(store.City),
            State = Clean(store.State),
            PostalCode = Clean(store.PostalCode),
            Country = "IN",
            // PAN/GST must be uppercase and whitespace-free or Razorpay rejects them.
            Pan = string.IsNullOrWhiteSpace(store.PAN) ? null : store.PAN.Trim().ToUpperInvariant(),
            Gst = string.IsNullOrWhiteSpace(store.GSTIN) ? null : store.GSTIN.Trim().ToUpperInvariant(),
            Bank = BuildBank(account),
            ExistingLinkedAccountId = account.RazorpayLinkedAccountId,
            ExistingStakeholderId = account.RazorpayStakeholderId,
            ExistingProductConfigurationId = account.RazorpayProductConfigurationId
        };

        /// <summary>Trims whitespace from a value sent to Razorpay (null-safe).</summary>
        private static string Clean(string? value) => (value ?? string.Empty).Trim();

        private static RazorpayBankDetails BuildBank(ChemistPayoutAccount account) => new()
        {
            AccountNumber = account.BankAccountNumber ?? string.Empty,
            IfscCode = account.BankIfscCode ?? string.Empty,
            BeneficiaryName = account.BankAccountHolderName ?? string.Empty
        };

        private static List<string> ValidateBank(string accountNumber, string ifsc, string holder)
        {
            var errors = new List<string>();

            if (string.IsNullOrWhiteSpace(accountNumber) || accountNumber.Trim().Length < 6)
                errors.Add("A valid bank account number is required.");

            if (string.IsNullOrWhiteSpace(ifsc) || !IfscRegex.IsMatch(ifsc.Trim().ToUpperInvariant()))
                errors.Add("A valid IFSC code is required (e.g. HDFC0001234).");

            if (string.IsNullOrWhiteSpace(holder))
                errors.Add("Account holder name is required.");

            return errors;
        }

        private static ChemistPayoutStatusDto ToDto(ChemistPayoutAccount a) => new()
        {
            MedicalStoreId = a.MedicalStoreId,
            RazorpayLinkedAccountId = a.RazorpayLinkedAccountId,
            OnboardingStatus = a.OnboardingStatus,
            OnboardingError = a.OnboardingError,
            BankAccountNumberMasked = MaskAccount(a.BankAccountNumber),
            BankIfscCode = a.BankIfscCode,
            BankAccountHolderName = a.BankAccountHolderName,
            ActivatedOn = a.ActivatedOn,
            CreatedOn = a.CreatedOn,
            UpdatedOn = a.UpdatedOn
        };

        private static string? MaskAccount(string? accountNumber)
        {
            if (string.IsNullOrWhiteSpace(accountNumber)) return null;
            var trimmed = accountNumber.Trim();
            if (trimmed.Length <= 4) return new string('X', trimmed.Length);
            return new string('X', trimmed.Length - 4) + trimmed[^4..];
        }
    }
}
