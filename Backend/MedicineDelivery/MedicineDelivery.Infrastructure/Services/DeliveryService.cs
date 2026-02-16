using AutoMapper;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Domain.Interfaces;

namespace MedicineDelivery.Infrastructure.Services
{
    public class DeliveryService : IDeliveryService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly ILogger<DeliveryService> _logger;

        public DeliveryService(IUnitOfWork unitOfWork, IMapper mapper, UserManager<ApplicationUser> userManager, ILogger<DeliveryService> logger)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _userManager = userManager;
            _logger = logger;
        }

        public async Task<DeliveryDto> CreateDeliveryAsync(CreateDeliveryDto createDto, Guid? addedBy = null)
        {
            ArgumentNullException.ThrowIfNull(createDto);
            _logger.LogInformation("Creating delivery for mobile number {MobileNumber}, added by {AddedBy}", createDto.MobileNumber, addedBy);

            if (string.IsNullOrWhiteSpace(createDto.MobileNumber))
            {
                _logger.LogWarning("CreateDeliveryAsync failed: MobileNumber is required");
                throw new ArgumentException("MobileNumber is required to create a delivery boy.");
            }

            if (string.IsNullOrWhiteSpace(createDto.Password))
            {
                _logger.LogWarning("CreateDeliveryAsync failed: Password is required");
                throw new ArgumentException("Password is required to create a delivery boy.");
            }

            // Check if user with this mobile number already exists
            var existingUser = await _userManager.FindByNameAsync(createDto.MobileNumber);
            if (existingUser != null)
            {
                _logger.LogWarning("CreateDeliveryAsync failed: User with mobile number {MobileNumber} already exists", createDto.MobileNumber);
                throw new InvalidOperationException("A user with this mobile number already exists.");
            }

            // Validate MedicalStoreId if provided
            if (createDto.MedicalStoreId.HasValue)
            {
                var medicalStore = await _unitOfWork.MedicalStores.GetByIdAsync(createDto.MedicalStoreId.Value);
                if (medicalStore == null)
                {
                    _logger.LogWarning("CreateDeliveryAsync failed: Medical store {MedicalStoreId} not found", createDto.MedicalStoreId.Value);
                    throw new KeyNotFoundException($"Medical store with ID '{createDto.MedicalStoreId.Value}' not found.");
                }

                if (!medicalStore.IsActive || medicalStore.IsDeleted)
                {
                    _logger.LogWarning("CreateDeliveryAsync failed: Medical store {MedicalStoreId} is inactive or deleted", createDto.MedicalStoreId.Value);
                    throw new InvalidOperationException("Cannot assign delivery to an inactive or deleted medical store.");
                }
            }

            // Validate ServiceRegionId if provided
            if (createDto.ServiceRegionId.HasValue)
            {
                var region = await _unitOfWork.ServiceRegions.GetByIdAsync(createDto.ServiceRegionId.Value);
                if (region == null)
                {
                    _logger.LogWarning("CreateDeliveryAsync failed: Service region {ServiceRegionId} not found", createDto.ServiceRegionId.Value);
                    throw new KeyNotFoundException($"Service region with ID '{createDto.ServiceRegionId.Value}' not found.");
                }
            }

            // Begin transaction for atomicity
            await _unitOfWork.BeginTransactionAsync();
            ApplicationUser? identityUser = null;

            try
            {
                // Create Identity user
                identityUser = new ApplicationUser
                {
                    UserName = createDto.MobileNumber,
                    Email = $"{createDto.MobileNumber}@delivery.local",
                    PhoneNumber = createDto.MobileNumber,
                    FirstName = createDto.FirstName ?? string.Empty,
                    LastName = createDto.LastName ?? string.Empty,
                    EmailConfirmed = true
                };

                var userResult = await _userManager.CreateAsync(identityUser, createDto.Password);
                if (!userResult.Succeeded)
                {
                    await _unitOfWork.RollbackTransactionAsync();
                    var errors = string.Join("; ", userResult.Errors.Select(e => e.Description));
                    _logger.LogWarning("CreateDeliveryAsync failed: Identity user creation failed for {MobileNumber}. Errors: {Errors}", createDto.MobileNumber, errors);
                    throw new InvalidOperationException($"Failed to create identity user: {errors}");
                }

                // Add to DeliveryBoy role
                await _userManager.AddToRoleAsync(identityUser, "DeliveryBoy");

                // Create Delivery entity
                var delivery = new Delivery
                {
                    FirstName = createDto.FirstName,
                    MiddleName = createDto.MiddleName,
                    LastName = createDto.LastName,
                    DrivingLicenceNumber = createDto.DrivingLicenceNumber,
                    MobileNumber = createDto.MobileNumber,
                    MedicalStoreId = createDto.MedicalStoreId,
                    ServiceRegionId = createDto.ServiceRegionId,
                    UserId = identityUser.Id,
                    IsActive = true,
                    IsDeleted = false,
                    AddedOn = DateTime.UtcNow,
                    AddedBy = addedBy
                };

                await _unitOfWork.Deliveries.AddAsync(delivery);
                await _unitOfWork.SaveChangesAsync();
                await _unitOfWork.CommitTransactionAsync();

                _logger.LogInformation("Delivery created successfully with ID {DeliveryId} for mobile number {MobileNumber}", delivery.Id, createDto.MobileNumber);
                return _mapper.Map<DeliveryDto>(delivery);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating delivery for mobile number {MobileNumber}. Rolling back transaction", createDto.MobileNumber);
                await _unitOfWork.RollbackTransactionAsync();
                // Clean up the Identity user if it was created
                if (identityUser != null)
                {
                    var createdUser = await _userManager.FindByIdAsync(identityUser.Id);
                    if (createdUser != null)
                    {
                        await _userManager.DeleteAsync(createdUser);
                    }
                }
                throw;
            }
        }

        public async Task<DeliveryDto?> GetDeliveryByIdAsync(int id)
        {
            var delivery = await _unitOfWork.Deliveries.GetByIdAsync(id);
            if (delivery == null || delivery.IsDeleted)
            {
                return null;
            }

            return _mapper.Map<DeliveryDto>(delivery);
        }

        public async Task<IEnumerable<DeliveryDto>> GetAllDeliveriesAsync()
        {
            var deliveries = await _unitOfWork.Deliveries.FindAsync(d => !d.IsDeleted);
            return _mapper.Map<IEnumerable<DeliveryDto>>(deliveries);
        }

        public async Task<IEnumerable<DeliveryDto>> GetDeliveriesByMedicalStoreIdAsync(Guid medicalStoreId)
        {
            var deliveries = await _unitOfWork.Deliveries.FindAsync(d => 
                d.MedicalStoreId == medicalStoreId && !d.IsDeleted);
            return _mapper.Map<IEnumerable<DeliveryDto>>(deliveries);
        }

        public async Task<IEnumerable<DeliveryDto>> GetActiveDeliveriesByMedicalStoreIdAsync(Guid medicalStoreId)
        {
            var deliveries = await _unitOfWork.Deliveries.FindAsync(d => 
                d.MedicalStoreId == medicalStoreId && 
                d.IsActive && 
                !d.IsDeleted);
            return _mapper.Map<IEnumerable<DeliveryDto>>(deliveries);
        }

        public async Task<DeliveryDto> UpdateDeliveryAsync(int id, UpdateDeliveryDto updateDto, Guid? modifiedBy = null)
        {
            ArgumentNullException.ThrowIfNull(updateDto);
            _logger.LogInformation("Updating delivery {DeliveryId}, modified by {ModifiedBy}", id, modifiedBy);

            var delivery = await _unitOfWork.Deliveries.GetByIdAsync(id);
            if (delivery == null || delivery.IsDeleted)
            {
                _logger.LogWarning("UpdateDeliveryAsync failed: Delivery {DeliveryId} not found or deleted", id);
                throw new KeyNotFoundException($"Delivery with ID '{id}' not found.");
            }

            // Validate MedicalStoreId if provided
            if (updateDto.MedicalStoreId.HasValue)
            {
                var medicalStore = await _unitOfWork.MedicalStores.GetByIdAsync(updateDto.MedicalStoreId.Value);
                if (medicalStore == null)
                {
                    _logger.LogWarning("UpdateDeliveryAsync failed: Medical store {MedicalStoreId} not found", updateDto.MedicalStoreId.Value);
                    throw new KeyNotFoundException($"Medical store with ID '{updateDto.MedicalStoreId.Value}' not found.");
                }

                if (!medicalStore.IsActive || medicalStore.IsDeleted)
                {
                    _logger.LogWarning("UpdateDeliveryAsync failed: Medical store {MedicalStoreId} is inactive or deleted", updateDto.MedicalStoreId.Value);
                    throw new InvalidOperationException("Cannot assign delivery to an inactive or deleted medical store.");
                }
            }

            // Update properties
            if (updateDto.FirstName != null)
                delivery.FirstName = updateDto.FirstName;
            
            if (updateDto.MiddleName != null)
                delivery.MiddleName = updateDto.MiddleName;
            
            if (updateDto.LastName != null)
                delivery.LastName = updateDto.LastName;
            
            if (updateDto.DrivingLicenceNumber != null)
                delivery.DrivingLicenceNumber = updateDto.DrivingLicenceNumber;
            
            if (updateDto.MobileNumber != null)
                delivery.MobileNumber = updateDto.MobileNumber;
            
            if (updateDto.IsActive.HasValue)
                delivery.IsActive = updateDto.IsActive.Value;
            
            if (updateDto.MedicalStoreId.HasValue)
                delivery.MedicalStoreId = updateDto.MedicalStoreId;

            if (updateDto.ServiceRegionId.HasValue)
            {
                var region = await _unitOfWork.ServiceRegions.GetByIdAsync(updateDto.ServiceRegionId.Value);
                if (region == null)
                {
                    _logger.LogWarning("UpdateDeliveryAsync failed: Service region {ServiceRegionId} not found", updateDto.ServiceRegionId.Value);
                    throw new KeyNotFoundException($"Service region with ID '{updateDto.ServiceRegionId.Value}' not found.");
                }
                delivery.ServiceRegionId = updateDto.ServiceRegionId;
            }

            delivery.ModifiedOn = DateTime.UtcNow;
            delivery.ModifiedBy = modifiedBy;

            _unitOfWork.Deliveries.Update(delivery);
            await _unitOfWork.SaveChangesAsync();

            _logger.LogInformation("Delivery {DeliveryId} updated successfully", id);
            return _mapper.Map<DeliveryDto>(delivery);
        }

        public async Task<bool> DeleteDeliveryAsync(int id)
        {
            _logger.LogInformation("Deleting delivery {DeliveryId} (soft delete)", id);

            var delivery = await _unitOfWork.Deliveries.GetByIdAsync(id);
            if (delivery == null || delivery.IsDeleted)
            {
                _logger.LogWarning("DeleteDeliveryAsync: Delivery {DeliveryId} not found or already deleted", id);
                return false;
            }

            // Soft delete
            delivery.IsDeleted = true;
            delivery.IsActive = false;
            delivery.ModifiedOn = DateTime.UtcNow;

            _unitOfWork.Deliveries.Update(delivery);
            await _unitOfWork.SaveChangesAsync();

            _logger.LogInformation("Delivery {DeliveryId} soft-deleted successfully", id);
            return true;
        }
    }
}

