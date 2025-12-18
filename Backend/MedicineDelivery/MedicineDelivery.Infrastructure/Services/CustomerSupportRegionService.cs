using AutoMapper;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Domain.Interfaces;

namespace MedicineDelivery.Infrastructure.Services
{
    public class CustomerSupportRegionService : ICustomerSupportRegionService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public CustomerSupportRegionService(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        public async Task<CustomerSupportRegionDto> CreateCustomerSupportRegionAsync(CreateCustomerSupportRegionDto createDto)
        {
            ArgumentNullException.ThrowIfNull(createDto);

            if (string.IsNullOrWhiteSpace(createDto.Name))
            {
                throw new ArgumentException("Name is required.", nameof(createDto.Name));
            }

            if (string.IsNullOrWhiteSpace(createDto.City))
            {
                throw new ArgumentException("City is required.", nameof(createDto.City));
            }

            if (string.IsNullOrWhiteSpace(createDto.RegionName))
            {
                throw new ArgumentException("RegionName is required.", nameof(createDto.RegionName));
            }

            var region = new CustomerSupportRegion
            {
                Name = createDto.Name.Trim(),
                City = createDto.City.Trim(),
                RegionName = createDto.RegionName.Trim()
            };

            await _unitOfWork.CustomerSupportRegions.AddAsync(region);
            await _unitOfWork.SaveChangesAsync();

            // Add pin codes if provided
            if (createDto.PinCodes != null && createDto.PinCodes.Any())
            {
                foreach (var pinCode in createDto.PinCodes.Distinct())
                {
                    if (!string.IsNullOrWhiteSpace(pinCode))
                    {
                        var regionPinCode = new CustomerSupportRegionPinCode
                        {
                            CustomerSupportRegionId = region.Id,
                            PinCode = pinCode.Trim()
                        };
                        await _unitOfWork.CustomerSupportRegionPinCodes.AddAsync(regionPinCode);
                    }
                }
                await _unitOfWork.SaveChangesAsync();
            }

            return await GetCustomerSupportRegionByIdAsync(region.Id) ?? 
                throw new InvalidOperationException("Failed to retrieve created region.");
        }

        public async Task<CustomerSupportRegionDto?> GetCustomerSupportRegionByIdAsync(int id)
        {
            var region = await _unitOfWork.CustomerSupportRegions.GetByIdAsync(id);
            if (region == null)
            {
                return null;
            }

            var regionDto = _mapper.Map<CustomerSupportRegionDto>(region);
            
            // Load pin codes
            var pinCodes = await _unitOfWork.CustomerSupportRegionPinCodes.FindAsync(
                p => p.CustomerSupportRegionId == id);
            regionDto.PinCodes = pinCodes.Select(p => p.PinCode).ToList();

            return regionDto;
        }

        public async Task<IEnumerable<CustomerSupportRegionDto>> GetAllCustomerSupportRegionsAsync()
        {
            var regions = await _unitOfWork.CustomerSupportRegions.GetAllAsync();
            var regionDtos = new List<CustomerSupportRegionDto>();

            foreach (var region in regions)
            {
                var regionDto = _mapper.Map<CustomerSupportRegionDto>(region);
                
                // Load pin codes for each region
                var pinCodes = await _unitOfWork.CustomerSupportRegionPinCodes.FindAsync(
                    p => p.CustomerSupportRegionId == region.Id);
                regionDto.PinCodes = pinCodes.Select(p => p.PinCode).ToList();

                regionDtos.Add(regionDto);
            }

            return regionDtos;
        }

        public async Task<CustomerSupportRegionDto> UpdateCustomerSupportRegionAsync(int id, UpdateCustomerSupportRegionDto updateDto)
        {
            ArgumentNullException.ThrowIfNull(updateDto);

            var region = await _unitOfWork.CustomerSupportRegions.GetByIdAsync(id);
            if (region == null)
            {
                throw new KeyNotFoundException($"Customer support region with ID '{id}' not found.");
            }

            // Update basic properties
            if (!string.IsNullOrWhiteSpace(updateDto.Name))
                region.Name = updateDto.Name.Trim();

            if (!string.IsNullOrWhiteSpace(updateDto.City))
                region.City = updateDto.City.Trim();

            if (!string.IsNullOrWhiteSpace(updateDto.RegionName))
                region.RegionName = updateDto.RegionName.Trim();

            _unitOfWork.CustomerSupportRegions.Update(region);

            // Update pin codes if provided
            if (updateDto.PinCodes != null)
            {
                // Remove existing pin codes
                var existingPinCodes = await _unitOfWork.CustomerSupportRegionPinCodes.FindAsync(
                    p => p.CustomerSupportRegionId == id);
                
                foreach (var existingPinCode in existingPinCodes)
                {
                    _unitOfWork.CustomerSupportRegionPinCodes.Remove(existingPinCode);
                }

                // Add new pin codes
                foreach (var pinCode in updateDto.PinCodes.Distinct())
                {
                    if (!string.IsNullOrWhiteSpace(pinCode))
                    {
                        var regionPinCode = new CustomerSupportRegionPinCode
                        {
                            CustomerSupportRegionId = id,
                            PinCode = pinCode.Trim()
                        };
                        await _unitOfWork.CustomerSupportRegionPinCodes.AddAsync(regionPinCode);
                    }
                }
            }

            await _unitOfWork.SaveChangesAsync();

            return await GetCustomerSupportRegionByIdAsync(id) ?? 
                throw new InvalidOperationException("Failed to retrieve updated region.");
        }

        public async Task<bool> DeleteCustomerSupportRegionAsync(int id)
        {
            var region = await _unitOfWork.CustomerSupportRegions.GetByIdAsync(id);
            if (region == null)
            {
                return false;
            }

            // Remove all associated pin codes (cascade delete will handle this, but we'll do it explicitly)
            var pinCodes = await _unitOfWork.CustomerSupportRegionPinCodes.FindAsync(
                p => p.CustomerSupportRegionId == id);
            
            foreach (var pinCode in pinCodes)
            {
                _unitOfWork.CustomerSupportRegionPinCodes.Remove(pinCode);
            }

            _unitOfWork.CustomerSupportRegions.Remove(region);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }

        public async Task<bool> AddPinCodeToRegionAsync(AddPinCodeToRegionDto addDto)
        {
            ArgumentNullException.ThrowIfNull(addDto);

            if (string.IsNullOrWhiteSpace(addDto.PinCode))
            {
                throw new ArgumentException("PinCode is required.", nameof(addDto.PinCode));
            }

            // Validate region exists
            var region = await _unitOfWork.CustomerSupportRegions.GetByIdAsync(addDto.CustomerSupportRegionId);
            if (region == null)
            {
                throw new KeyNotFoundException($"Customer support region with ID '{addDto.CustomerSupportRegionId}' not found.");
            }

            // Check if pin code already exists for this region
            var existingPinCode = await _unitOfWork.CustomerSupportRegionPinCodes.FirstOrDefaultAsync(
                p => p.CustomerSupportRegionId == addDto.CustomerSupportRegionId && 
                     p.PinCode == addDto.PinCode.Trim());
            
            if (existingPinCode != null)
            {
                throw new InvalidOperationException($"Pin code '{addDto.PinCode}' already exists for this region.");
            }

            var regionPinCode = new CustomerSupportRegionPinCode
            {
                CustomerSupportRegionId = addDto.CustomerSupportRegionId,
                PinCode = addDto.PinCode.Trim()
            };

            await _unitOfWork.CustomerSupportRegionPinCodes.AddAsync(regionPinCode);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }

        public async Task<bool> RemovePinCodeFromRegionAsync(RemovePinCodeFromRegionDto removeDto)
        {
            ArgumentNullException.ThrowIfNull(removeDto);

            if (string.IsNullOrWhiteSpace(removeDto.PinCode))
            {
                throw new ArgumentException("PinCode is required.", nameof(removeDto.PinCode));
            }

            var regionPinCode = await _unitOfWork.CustomerSupportRegionPinCodes.FirstOrDefaultAsync(
                p => p.CustomerSupportRegionId == removeDto.CustomerSupportRegionId && 
                     p.PinCode == removeDto.PinCode.Trim());
            
            if (regionPinCode == null)
            {
                return false;
            }

            _unitOfWork.CustomerSupportRegionPinCodes.Remove(regionPinCode);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }

        public async Task<IEnumerable<string>> GetPinCodesByRegionIdAsync(int regionId)
        {
            var pinCodes = await _unitOfWork.CustomerSupportRegionPinCodes.FindAsync(
                p => p.CustomerSupportRegionId == regionId);
            
            return pinCodes.Select(p => p.PinCode).ToList();
        }

        public async Task<CustomerSupportRegionDto?> GetRegionByPinCodeAsync(string pinCode)
        {
            if (string.IsNullOrWhiteSpace(pinCode))
            {
                throw new ArgumentException("PinCode is required.", nameof(pinCode));
            }

            var regionPinCode = await _unitOfWork.CustomerSupportRegionPinCodes.FirstOrDefaultAsync(
                p => p.PinCode == pinCode.Trim());
            
            if (regionPinCode == null)
            {
                return null;
            }

            return await GetCustomerSupportRegionByIdAsync(regionPinCode.CustomerSupportRegionId);
        }
    }
}

