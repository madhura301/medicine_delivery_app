using AutoMapper;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Domain.Enums;
using MedicineDelivery.Domain.Interfaces;
using Microsoft.Extensions.Logging;

namespace MedicineDelivery.Infrastructure.Services
{
    public class ServiceRegionService : IServiceRegionService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly ILogger<ServiceRegionService> _logger;

        public ServiceRegionService(IUnitOfWork unitOfWork, IMapper mapper, ILogger<ServiceRegionService> logger)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _logger = logger;
        }

        public async Task<ServiceRegionDto> CreateServiceRegionAsync(CreateServiceRegionDto createDto)
        {
            ArgumentNullException.ThrowIfNull(createDto);
            _logger.LogInformation("Creating service region with name {Name}, city {City}, region {RegionName}", createDto.Name, createDto.City, createDto.RegionName);

            if (string.IsNullOrWhiteSpace(createDto.Name))
            {
                _logger.LogWarning("CreateServiceRegionAsync failed: Name is required");
                throw new ArgumentException("Name is required.", nameof(createDto.Name));
            }

            if (string.IsNullOrWhiteSpace(createDto.City))
            {
                _logger.LogWarning("CreateServiceRegionAsync failed: City is required");
                throw new ArgumentException("City is required.", nameof(createDto.City));
            }

            if (string.IsNullOrWhiteSpace(createDto.RegionName))
            {
                _logger.LogWarning("CreateServiceRegionAsync failed: RegionName is required");
                throw new ArgumentException("RegionName is required.", nameof(createDto.RegionName));
            }

            var region = new ServiceRegion
            {
                Name = createDto.Name.Trim(),
                City = createDto.City.Trim(),
                RegionName = createDto.RegionName.Trim(),
                RegionType = createDto.RegionType
            };

            await _unitOfWork.ServiceRegions.AddAsync(region);
            await _unitOfWork.SaveChangesAsync();

            // Add pin codes if provided
            if (createDto.PinCodes != null && createDto.PinCodes.Any())
            {
                foreach (var pinCode in createDto.PinCodes.Distinct())
                {
                    if (!string.IsNullOrWhiteSpace(pinCode))
                    {
                        await EnsurePinCodeUniquePerRegionTypeAsync(pinCode.Trim(), createDto.RegionType, region.Id);
                        var regionPinCode = new ServiceRegionPinCode
                        {
                            ServiceRegionId = region.Id,
                            PinCode = pinCode.Trim()
                        };
                        await _unitOfWork.ServiceRegionPinCodes.AddAsync(regionPinCode);
                    }
                }
                await _unitOfWork.SaveChangesAsync();
            }

            var result = await GetServiceRegionByIdAsync(region.Id) ?? 
                throw new InvalidOperationException("Failed to retrieve created region.");

            _logger.LogInformation("Service region created successfully with ID {RegionId}", region.Id);
            return result;
        }

        public async Task<ServiceRegionDto?> GetServiceRegionByIdAsync(int id)
        {
            var region = await _unitOfWork.ServiceRegions.GetByIdAsync(id);
            if (region == null)
            {
                return null;
            }

            var regionDto = _mapper.Map<ServiceRegionDto>(region);
            
            // Load pin codes
            var pinCodes = await _unitOfWork.ServiceRegionPinCodes.FindAsync(
                p => p.ServiceRegionId == id);
            regionDto.PinCodes = pinCodes.Select(p => p.PinCode).ToList();

            return regionDto;
        }

        public async Task<IEnumerable<ServiceRegionDto>> GetAllServiceRegionsAsync()
        {
            var regions = await _unitOfWork.ServiceRegions.GetAllAsync();
            var regionDtos = new List<ServiceRegionDto>();

            foreach (var region in regions)
            {
                var regionDto = _mapper.Map<ServiceRegionDto>(region);
                
                // Load pin codes for each region
                var pinCodes = await _unitOfWork.ServiceRegionPinCodes.FindAsync(
                    p => p.ServiceRegionId == region.Id);
                regionDto.PinCodes = pinCodes.Select(p => p.PinCode).ToList();

                regionDtos.Add(regionDto);
            }

            return regionDtos;
        }

        public async Task<IEnumerable<ServiceRegionDto>> GetAllServiceRegionsByTypeAsync(RegionType regionType)
        {
            var regions = await _unitOfWork.ServiceRegions.FindAsync(r => r.RegionType == regionType);
            var regionDtos = new List<ServiceRegionDto>();

            foreach (var region in regions)
            {
                var regionDto = _mapper.Map<ServiceRegionDto>(region);
                
                // Load pin codes for each region
                var pinCodes = await _unitOfWork.ServiceRegionPinCodes.FindAsync(
                    p => p.ServiceRegionId == region.Id);
                regionDto.PinCodes = pinCodes.Select(p => p.PinCode).ToList();

                regionDtos.Add(regionDto);
            }

            return regionDtos;
        }

        public async Task<ServiceRegionDto> UpdateServiceRegionAsync(int id, UpdateServiceRegionDto updateDto)
        {
            ArgumentNullException.ThrowIfNull(updateDto);
            _logger.LogInformation("Updating service region {RegionId}", id);

            var region = await _unitOfWork.ServiceRegions.GetByIdAsync(id);
            if (region == null)
            {
                _logger.LogWarning("UpdateServiceRegionAsync failed: Service region {RegionId} not found", id);
                throw new KeyNotFoundException($"Service region with ID '{id}' not found.");
            }

            // Update basic properties
            if (!string.IsNullOrWhiteSpace(updateDto.Name))
                region.Name = updateDto.Name.Trim();

            if (!string.IsNullOrWhiteSpace(updateDto.City))
                region.City = updateDto.City.Trim();

            if (!string.IsNullOrWhiteSpace(updateDto.RegionName))
                region.RegionName = updateDto.RegionName.Trim();

            if (updateDto.RegionType.HasValue)
                region.RegionType = updateDto.RegionType.Value;

            _unitOfWork.ServiceRegions.Update(region);

            // Update pin codes if provided
            if (updateDto.PinCodes != null)
            {
                // Remove existing pin codes
                var existingPinCodes = await _unitOfWork.ServiceRegionPinCodes.FindAsync(
                    p => p.ServiceRegionId == id);
                
                foreach (var existingPinCode in existingPinCodes)
                {
                    _unitOfWork.ServiceRegionPinCodes.Remove(existingPinCode);
                }

                // Add new pin codes
                foreach (var pinCode in updateDto.PinCodes.Distinct())
                {
                    if (!string.IsNullOrWhiteSpace(pinCode))
                    {
                        await EnsurePinCodeUniquePerRegionTypeAsync(pinCode.Trim(), region.RegionType, id);
                        var regionPinCode = new ServiceRegionPinCode
                        {
                            ServiceRegionId = id,
                            PinCode = pinCode.Trim()
                        };
                        await _unitOfWork.ServiceRegionPinCodes.AddAsync(regionPinCode);
                    }
                }
            }

            await _unitOfWork.SaveChangesAsync();

            return await GetServiceRegionByIdAsync(id) ?? 
                throw new InvalidOperationException("Failed to retrieve updated region.");
        }

        public async Task<bool> DeleteServiceRegionAsync(int id)
        {
            _logger.LogInformation("Deleting service region {RegionId}", id);

            var region = await _unitOfWork.ServiceRegions.GetByIdAsync(id);
            if (region == null)
            {
                _logger.LogWarning("DeleteServiceRegionAsync: Service region {RegionId} not found", id);
                return false;
            }

            // Remove all associated pin codes (cascade delete will handle this, but we'll do it explicitly)
            var pinCodes = await _unitOfWork.ServiceRegionPinCodes.FindAsync(
                p => p.ServiceRegionId == id);
            
            foreach (var pinCode in pinCodes)
            {
                _unitOfWork.ServiceRegionPinCodes.Remove(pinCode);
            }

            _unitOfWork.ServiceRegions.Remove(region);
            await _unitOfWork.SaveChangesAsync();

            _logger.LogInformation("Service region {RegionId} deleted successfully along with {PinCodeCount} pin codes", id, pinCodes.Count());
            return true;
        }

        public async Task<bool> AddPinCodeToRegionAsync(AddPinCodeToRegionDto addDto)
        {
            ArgumentNullException.ThrowIfNull(addDto);
            _logger.LogInformation("Adding pin code {PinCode} to service region {RegionId}", addDto.PinCode, addDto.ServiceRegionId);

            if (string.IsNullOrWhiteSpace(addDto.PinCode))
            {
                _logger.LogWarning("AddPinCodeToRegionAsync failed: PinCode is required");
                throw new ArgumentException("PinCode is required.", nameof(addDto.PinCode));
            }

            // Validate region exists
            var region = await _unitOfWork.ServiceRegions.GetByIdAsync(addDto.ServiceRegionId);
            if (region == null)
            {
                _logger.LogWarning("AddPinCodeToRegionAsync failed: Service region {RegionId} not found", addDto.ServiceRegionId);
                throw new KeyNotFoundException($"Service region with ID '{addDto.ServiceRegionId}' not found.");
            }

            // Check if pin code already exists for this region
            var existingPinCode = await _unitOfWork.ServiceRegionPinCodes.FirstOrDefaultAsync(
                p => p.ServiceRegionId == addDto.ServiceRegionId && 
                     p.PinCode == addDto.PinCode.Trim());
            
            if (existingPinCode != null)
            {
                _logger.LogWarning("AddPinCodeToRegionAsync failed: Pin code {PinCode} already exists for region {RegionId}", addDto.PinCode, addDto.ServiceRegionId);
                throw new InvalidOperationException($"Pin code '{addDto.PinCode}' already exists for this region.");
            }

            await EnsurePinCodeUniquePerRegionTypeAsync(addDto.PinCode.Trim(), region.RegionType, addDto.ServiceRegionId);

            var regionPinCode = new ServiceRegionPinCode
            {
                ServiceRegionId = addDto.ServiceRegionId,
                PinCode = addDto.PinCode.Trim()
            };

            await _unitOfWork.ServiceRegionPinCodes.AddAsync(regionPinCode);
            await _unitOfWork.SaveChangesAsync();

            _logger.LogInformation("Pin code {PinCode} added successfully to service region {RegionId}", addDto.PinCode, addDto.ServiceRegionId);
            return true;
        }

        public async Task<bool> RemovePinCodeFromRegionAsync(RemovePinCodeFromRegionDto removeDto)
        {
            ArgumentNullException.ThrowIfNull(removeDto);

            if (string.IsNullOrWhiteSpace(removeDto.PinCode))
            {
                throw new ArgumentException("PinCode is required.", nameof(removeDto.PinCode));
            }

            var regionPinCode = await _unitOfWork.ServiceRegionPinCodes.FirstOrDefaultAsync(
                p => p.ServiceRegionId == removeDto.ServiceRegionId && 
                     p.PinCode == removeDto.PinCode.Trim());
            
            if (regionPinCode == null)
            {
                return false;
            }

            _unitOfWork.ServiceRegionPinCodes.Remove(regionPinCode);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }

        public async Task<IEnumerable<string>> GetPinCodesByRegionIdAsync(int regionId)
        {
            var pinCodes = await _unitOfWork.ServiceRegionPinCodes.FindAsync(
                p => p.ServiceRegionId == regionId);
            
            return pinCodes.Select(p => p.PinCode).ToList();
        }

        public async Task<ServiceRegionDto?> GetRegionByPinCodeAsync(string pinCode)
        {
            if (string.IsNullOrWhiteSpace(pinCode))
            {
                throw new ArgumentException("PinCode is required.", nameof(pinCode));
            }

            var regionPinCode = await _unitOfWork.ServiceRegionPinCodes.FirstOrDefaultAsync(
                p => p.PinCode == pinCode.Trim());
            
            if (regionPinCode == null)
            {
                return null;
            }

            return await GetServiceRegionByIdAsync(regionPinCode.ServiceRegionId);
        }

        public async Task<bool> AssignRegionToCustomerSupportAsync(AssignCustomerSupportRegionDto assignDto)
        {
            ArgumentNullException.ThrowIfNull(assignDto);
            _logger.LogInformation("Assigning service region {RegionId} to customer support {CustomerSupportId}", assignDto.ServiceRegionId, assignDto.CustomerSupportId);

            // Validate region exists
            var region = await _unitOfWork.ServiceRegions.GetByIdAsync(assignDto.ServiceRegionId);
            if (region == null)
            {
                _logger.LogWarning("AssignRegionToCustomerSupportAsync failed: Service region {RegionId} not found", assignDto.ServiceRegionId);
                throw new KeyNotFoundException($"Service region with ID '{assignDto.ServiceRegionId}' not found.");
            }

            // Validate customer support exists
            var customerSupport = await _unitOfWork.CustomerSupports.FirstOrDefaultAsync(cs => cs.CustomerSupportId == assignDto.CustomerSupportId);
            if (customerSupport == null)
            {
                _logger.LogWarning("AssignRegionToCustomerSupportAsync failed: Customer support {CustomerSupportId} not found", assignDto.CustomerSupportId);
                throw new KeyNotFoundException($"Customer support with ID '{assignDto.CustomerSupportId}' not found.");
            }

            customerSupport.ServiceRegionId = assignDto.ServiceRegionId;
            _unitOfWork.CustomerSupports.Update(customerSupport);
            await _unitOfWork.SaveChangesAsync();

            _logger.LogInformation("Service region {RegionId} assigned to customer support {CustomerSupportId}", assignDto.ServiceRegionId, assignDto.CustomerSupportId);
            return true;
        }

        public async Task<bool> AssignRegionToCustomerSupportsAsync(AssignCustomerSupportRegionBulkDto assignDto)
        {
            ArgumentNullException.ThrowIfNull(assignDto);

            if (assignDto.CustomerSupportIds == null || !assignDto.CustomerSupportIds.Any())
            {
                throw new ArgumentException("At least one CustomerSupportId is required.", nameof(assignDto.CustomerSupportIds));
            }

            // Validate region exists
            var region = await _unitOfWork.ServiceRegions.GetByIdAsync(assignDto.ServiceRegionId);
            if (region == null)
            {
                throw new KeyNotFoundException($"Service region with ID '{assignDto.ServiceRegionId}' not found.");
            }

            var distinctIds = assignDto.CustomerSupportIds.Where(id => id != Guid.Empty).Distinct().ToList();
            if (!distinctIds.Any())
            {
                throw new ArgumentException("At least one valid CustomerSupportId is required.", nameof(assignDto.CustomerSupportIds));
            }

            var customerSupports = await _unitOfWork.CustomerSupports.FindAsync(cs => distinctIds.Contains(cs.CustomerSupportId));
            var customerSupportList = customerSupports.ToList();

            var foundIds = customerSupportList.Select(cs => cs.CustomerSupportId).ToHashSet();
            var missingIds = distinctIds.Where(id => !foundIds.Contains(id)).ToList();
            if (missingIds.Any())
            {
                throw new KeyNotFoundException($"Customer support IDs not found: {string.Join(", ", missingIds)}");
            }

            foreach (var cs in customerSupportList)
            {
                cs.ServiceRegionId = assignDto.ServiceRegionId;
            }

            _unitOfWork.CustomerSupports.UpdateRange(customerSupportList);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }

        public async Task<bool> AssignRegionToDeliveryAsync(AssignDeliveryRegionDto assignDto)
        {
            ArgumentNullException.ThrowIfNull(assignDto);
            _logger.LogInformation("Assigning service region {RegionId} to delivery {DeliveryId}", assignDto.ServiceRegionId, assignDto.DeliveryId);

            // Validate region exists
            var region = await _unitOfWork.ServiceRegions.GetByIdAsync(assignDto.ServiceRegionId);
            if (region == null)
            {
                _logger.LogWarning("AssignRegionToDeliveryAsync failed: Service region {RegionId} not found", assignDto.ServiceRegionId);
                throw new KeyNotFoundException($"Service region with ID '{assignDto.ServiceRegionId}' not found.");
            }

            // Validate delivery exists
            var delivery = await _unitOfWork.Deliveries.GetByIdAsync(assignDto.DeliveryId);
            if (delivery == null || delivery.IsDeleted)
            {
                _logger.LogWarning("AssignRegionToDeliveryAsync failed: Delivery {DeliveryId} not found or deleted", assignDto.DeliveryId);
                throw new KeyNotFoundException($"Delivery with ID '{assignDto.DeliveryId}' not found.");
            }

            delivery.ServiceRegionId = assignDto.ServiceRegionId;
            _unitOfWork.Deliveries.Update(delivery);
            await _unitOfWork.SaveChangesAsync();

            _logger.LogInformation("Service region {RegionId} assigned to delivery {DeliveryId}", assignDto.ServiceRegionId, assignDto.DeliveryId);
            return true;
        }

        public async Task<bool> AssignRegionToDeliveriesAsync(AssignDeliveryRegionBulkDto assignDto)
        {
            ArgumentNullException.ThrowIfNull(assignDto);

            if (assignDto.DeliveryIds == null || !assignDto.DeliveryIds.Any())
            {
                throw new ArgumentException("At least one DeliveryId is required.", nameof(assignDto.DeliveryIds));
            }

            // Validate region exists
            var region = await _unitOfWork.ServiceRegions.GetByIdAsync(assignDto.ServiceRegionId);
            if (region == null)
            {
                throw new KeyNotFoundException($"Service region with ID '{assignDto.ServiceRegionId}' not found.");
            }

            var distinctIds = assignDto.DeliveryIds.Where(id => id > 0).Distinct().ToList();
            if (!distinctIds.Any())
            {
                throw new ArgumentException("At least one valid DeliveryId is required.", nameof(assignDto.DeliveryIds));
            }

            var deliveries = await _unitOfWork.Deliveries.FindAsync(d => distinctIds.Contains(d.Id) && !d.IsDeleted);
            var deliveryList = deliveries.ToList();

            var foundIds = deliveryList.Select(d => d.Id).ToHashSet();
            var missingIds = distinctIds.Where(id => !foundIds.Contains(id)).ToList();
            if (missingIds.Any())
            {
                throw new KeyNotFoundException($"Delivery IDs not found: {string.Join(", ", missingIds)}");
            }

            foreach (var delivery in deliveryList)
            {
                delivery.ServiceRegionId = assignDto.ServiceRegionId;
            }

            _unitOfWork.Deliveries.UpdateRange(deliveryList);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }

        /// <summary>
        /// Ensures the pin code is not already assigned to another region of the same type.
        /// Throws <see cref="InvalidOperationException"/> if it is.
        /// </summary>
        private async Task EnsurePinCodeUniquePerRegionTypeAsync(string pinCode, RegionType regionType, int? excludeRegionId)
        {
            var trimmed = pinCode.Trim();
            var existingRows = await _unitOfWork.ServiceRegionPinCodes.FindAsync(p => p.PinCode == trimmed);
            var regionIds = existingRows.Select(p => p.ServiceRegionId).Distinct().ToList();
            if (regionIds.Count == 0)
                return;

            var otherRegionIds = excludeRegionId.HasValue
                ? regionIds.Where(id => id != excludeRegionId.Value).ToList()
                : regionIds;
            if (otherRegionIds.Count == 0)
                return;

            var regionsOfSameType = await _unitOfWork.ServiceRegions.FindAsync(sr =>
                otherRegionIds.Contains(sr.Id) && sr.RegionType == regionType);
            if (regionsOfSameType.Any())
            {
                var regionTypeName = regionType == RegionType.DeliveryBoy ? "Delivery" : "CustomerSupport";
                _logger.LogWarning("EnsurePinCodeUniquePerRegionTypeAsync: Pin code {PinCode} already assigned to another {RegionType} region", trimmed, regionTypeName);
                throw new InvalidOperationException($"Pin code '{trimmed}' is already assigned to another {regionTypeName} region.");
            }
        }
    }
}
