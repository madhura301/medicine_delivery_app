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

            RazorpayOnboardingResult onboarding;
            if (string.IsNullOrWhiteSpace(account.RazorpayLinkedAccountId))
            {
                // Fresh onboarding — run the full create sequence.
                onboarding = await _routeClient.CreateLinkedAccountAsync(BuildRequest(store, account), ct);
            }
            else
            {
                // Linked account already exists — just (re)submit bank config.
                onboarding = await _routeClient.UpdateBankConfigurationAsync(
                    account.RazorpayLinkedAccountId,
                    account.RazorpayProductConfigurationId,
                    BuildBank(account),
                    ct);
            }

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

        // ----- helpers -----

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
            BusinessName = store.MedicalName,
            ContactName = $"{store.OwnerFirstName} {store.OwnerLastName}".Trim(),
            Email = store.EmailId,
            Phone = store.MobileNumber,
            Street1 = store.AddressLine1,
            Street2 = store.AddressLine2,
            City = store.City,
            State = store.State,
            PostalCode = store.PostalCode,
            Country = "IN",
            Pan = string.IsNullOrWhiteSpace(store.PAN) ? null : store.PAN,
            Gst = string.IsNullOrWhiteSpace(store.GSTIN) ? null : store.GSTIN,
            Bank = BuildBank(account)
        };

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
