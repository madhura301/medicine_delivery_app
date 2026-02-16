using AutoMapper;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Domain.Enums;
using MedicineDelivery.Domain.Interfaces;
using MedicineDelivery.Infrastructure.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;
using System.Security.Claims;

namespace MedicineDelivery.Infrastructure.Services
{
    public class ConsentService : IConsentService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly IBrowserInfoService _browserInfoService;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly ILogger<ConsentService> _logger;

        public ConsentService(
            IUnitOfWork unitOfWork,
            IMapper mapper,
            IBrowserInfoService browserInfoService,
            UserManager<ApplicationUser> userManager,
            ILogger<ConsentService> logger)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _browserInfoService = browserInfoService;
            _userManager = userManager;
            _logger = logger;
        }

        public async Task<ConsentDto?> GetConsentByIdAsync(Guid id)
        {
            var consent = await _unitOfWork.Consents.GetByIdAsync(id);
            return consent != null ? _mapper.Map<ConsentDto>(consent) : null;
        }

        public async Task<List<ConsentDto>> GetAllConsentsAsync()
        {
            var consents = await _unitOfWork.Consents.GetAllAsync();
            return _mapper.Map<List<ConsentDto>>(consents);
        }

        public async Task<List<ConsentDto>> GetActiveConsentsAsync()
        {
            var consents = await _unitOfWork.Consents.FindAsync(c => c.IsActive);
            return _mapper.Map<List<ConsentDto>>(consents);
        }

        public async Task<ConsentDto> CreateConsentAsync(CreateConsentDto createDto)
        {
            _logger.LogInformation("Creating new consent with title {Title}", createDto.Title);

            var consent = _mapper.Map<Consent>(createDto);
            consent.ConsentId = Guid.NewGuid();
            consent.CreatedOn = DateTime.UtcNow;

            await _unitOfWork.Consents.AddAsync(consent);
            await _unitOfWork.SaveChangesAsync();

            _logger.LogInformation("Consent created successfully with ID {ConsentId}", consent.ConsentId);
            return _mapper.Map<ConsentDto>(consent);
        }

        public async Task<ConsentDto?> UpdateConsentAsync(Guid id, UpdateConsentDto updateDto)
        {
            _logger.LogInformation("Updating consent {ConsentId}", id);

            var consent = await _unitOfWork.Consents.GetByIdAsync(id);
            if (consent == null)
            {
                _logger.LogWarning("UpdateConsentAsync: Consent {ConsentId} not found", id);
                return null;
            }

            consent.Title = updateDto.Title;
            consent.Description = updateDto.Description;
            consent.Content = updateDto.Content;
            consent.IsActive = updateDto.IsActive;
            consent.UpdatedOn = DateTime.UtcNow;

            _unitOfWork.Consents.Update(consent);
            await _unitOfWork.SaveChangesAsync();

            return _mapper.Map<ConsentDto>(consent);
        }

        public async Task<bool> DeleteConsentAsync(Guid id)
        {
            _logger.LogInformation("Deleting consent {ConsentId}", id);

            var consent = await _unitOfWork.Consents.GetByIdAsync(id);
            if (consent == null)
            {
                _logger.LogWarning("DeleteConsentAsync: Consent {ConsentId} not found", id);
                return false;
            }

            _unitOfWork.Consents.Remove(consent);
            await _unitOfWork.SaveChangesAsync();

            _logger.LogInformation("Consent {ConsentId} deleted successfully", id);
            return true;
        }

        public async Task<ConsentLogDto> AcceptConsentAsync(
            Guid consentId,
            string userId,
            AcceptRejectConsentDto request,
            HttpContext httpContext)
        {
            _logger.LogInformation("User {UserId} accepting consent {ConsentId}", userId, consentId);
            return await LogConsentActionAsync(
                consentId,
                userId,
                ConsentAction.Accept,
                request,
                httpContext);
        }

        public async Task<ConsentLogDto> RejectConsentAsync(
            Guid consentId,
            string userId,
            AcceptRejectConsentDto request,
            HttpContext httpContext)
        {
            _logger.LogInformation("User {UserId} rejecting consent {ConsentId}", userId, consentId);
            return await LogConsentActionAsync(
                consentId,
                userId,
                ConsentAction.Reject,
                request,
                httpContext);
        }

        private async Task<ConsentLogDto> LogConsentActionAsync(
            Guid consentId,
            string userId,
            ConsentAction action,
            AcceptRejectConsentDto request,
            HttpContext httpContext)
        {
            // Verify consent exists
            var consent = await _unitOfWork.Consents.GetByIdAsync(consentId);
            if (consent == null)
            {
                _logger.LogWarning("LogConsentActionAsync failed: Consent {ConsentId} not found", consentId);
                throw new KeyNotFoundException($"Consent with ID {consentId} not found.");
            }

            // Get user to determine role
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null)
            {
                _logger.LogWarning("LogConsentActionAsync failed: User {UserId} not found", userId);
                throw new KeyNotFoundException($"User with ID {userId} not found.");
            }

            // Get user roles
            var roles = await _userManager.GetRolesAsync(user);
            var primaryRole = roles.FirstOrDefault() ?? "";

            // Map role to UserType
            var userType = MapRoleToUserType(primaryRole);

            // Get respective entity ID based on user type
            var respectiveId = await GetRespectiveEntityIdAsync(userId, primaryRole, userType);

            // Extract browser information
            var userAgent = _browserInfoService.GetUserAgent(httpContext);
            var ipAddress = _browserInfoService.GetIpAddress(httpContext);
            var deviceInfo = request.DeviceInfo ?? _browserInfoService.GetDeviceInfo(httpContext);

            // Create consent log
            var consentLog = new ConsentLog
            {
                ConsentLogId = Guid.NewGuid(),
                ConsentId = consentId,
                UserId = userId,
                UserType = userType,
                RespectiveId = respectiveId,
                Action = action,
                UserAgent = userAgent,
                IpAddress = ipAddress,
                DeviceInfo = deviceInfo,
                CreatedOn = DateTime.UtcNow
            };

            await _unitOfWork.ConsentLogs.AddAsync(consentLog);
            await _unitOfWork.SaveChangesAsync();

            _logger.LogInformation("Consent action {Action} logged for consent {ConsentId} by user {UserId} (type: {UserType})", action, consentId, userId, userType);

            var logDto = _mapper.Map<ConsentLogDto>(consentLog);
            logDto.Consent = _mapper.Map<ConsentDto>(consent);

            return logDto;
        }

        private UserType MapRoleToUserType(string role)
        {
            return role.ToLower() switch
            {
                "customer" => UserType.Customer,
                "chemist" => UserType.MedicalStore,
                "customersupport" => UserType.CustomerSupport,
                "manager" => UserType.Manager,
                "admin" => UserType.Manager, // Admin mapped to Manager for consent purposes
                _ => UserType.Customer // Default fallback
            };
        }

        private async Task<Guid?> GetRespectiveEntityIdAsync(string userId, string role, UserType userType)
        {
            try
            {
                return userType switch
                {
                    UserType.Customer => await GetCustomerIdAsync(userId),
                    UserType.MedicalStore => await GetMedicalStoreIdAsync(userId),
                    UserType.CustomerSupport => await GetCustomerSupportIdAsync(userId),
                    UserType.Manager => await GetManagerIdAsync(userId),
                    _ => null
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving respective entity ID for user {UserId} with type {UserType}", userId, userType);
                return null; // Return null if entity not found
            }
        }

        private async Task<Guid?> GetCustomerIdAsync(string userId)
        {
            var customer = await _unitOfWork.Customers.FirstOrDefaultAsync(c => c.UserId == userId);
            return customer?.CustomerId;
        }

        private async Task<Guid?> GetMedicalStoreIdAsync(string userId)
        {
            var medicalStore = await _unitOfWork.MedicalStores.FirstOrDefaultAsync(ms => ms.UserId == userId);
            return medicalStore?.MedicalStoreId;
        }

        private async Task<Guid?> GetCustomerSupportIdAsync(string userId)
        {
            var customerSupport = await _unitOfWork.CustomerSupports.FirstOrDefaultAsync(cs => cs.UserId == userId);
            return customerSupport?.CustomerSupportId;
        }

        private async Task<Guid?> GetManagerIdAsync(string userId)
        {
            var manager = await _unitOfWork.Managers.FirstOrDefaultAsync(m => m.UserId == userId);
            return manager?.ManagerId;
        }

        public async Task<List<ConsentLogDto>> GetConsentLogsByConsentIdAsync(Guid consentId)
        {
            var logs = await _unitOfWork.ConsentLogs.FindAsync(cl => cl.ConsentId == consentId);
            var logDtos = _mapper.Map<List<ConsentLogDto>>(logs);

            // Load consent information for each log
            var consent = await _unitOfWork.Consents.GetByIdAsync(consentId);
            if (consent != null)
            {
                var consentDto = _mapper.Map<ConsentDto>(consent);
                foreach (var logDto in logDtos)
                {
                    logDto.Consent = consentDto;
                }
            }

            return logDtos.OrderByDescending(l => l.CreatedOn).ToList();
        }

        public async Task<List<ConsentLogDto>> GetConsentLogsByUserIdAsync(string userId)
        {
            var logs = await _unitOfWork.ConsentLogs.FindAsync(cl => cl.UserId == userId);
            var logDtos = _mapper.Map<List<ConsentLogDto>>(logs);

            // Load consent information for each log
            var consentIds = logDtos.Select(l => l.ConsentId).Distinct().ToList();
            var consents = new Dictionary<Guid, ConsentDto>();

            foreach (var consentId in consentIds)
            {
                var consent = await _unitOfWork.Consents.GetByIdAsync(consentId);
                if (consent != null)
                {
                    consents[consentId] = _mapper.Map<ConsentDto>(consent);
                }
            }

            foreach (var logDto in logDtos)
            {
                if (consents.TryGetValue(logDto.ConsentId, out var consentDto))
                {
                    logDto.Consent = consentDto;
                }
            }

            return logDtos.OrderByDescending(l => l.CreatedOn).ToList();
        }
    }
}