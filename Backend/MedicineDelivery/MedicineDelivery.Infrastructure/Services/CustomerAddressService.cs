using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Domain.Interfaces;
using AutoMapper;
using Microsoft.Extensions.Logging;

namespace MedicineDelivery.Infrastructure.Services
{
    public class CustomerAddressService : ICustomerAddressService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly ILogger<CustomerAddressService> _logger;

        public CustomerAddressService(IUnitOfWork unitOfWork, IMapper mapper, ILogger<CustomerAddressService> logger)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _logger = logger;
        }

        public async Task<CustomerAddressDto?> GetCustomerAddressByIdAsync(Guid id)
        {
            var customerAddress = await _unitOfWork.CustomerAddresses.FirstOrDefaultAsync(ca => ca.Id == id && ca.IsActive);
            return customerAddress != null ? _mapper.Map<CustomerAddressDto>(customerAddress) : null;
        }

        public async Task<List<CustomerAddressDto>> GetCustomerAddressesByCustomerIdAsync(Guid customerId)
        {
            var customerAddresses = await _unitOfWork.CustomerAddresses.FindAsync(ca => ca.CustomerId == customerId && ca.IsActive);
            return _mapper.Map<List<CustomerAddressDto>>(customerAddresses);
        }

        public async Task<CustomerAddressDto?> GetDefaultCustomerAddressAsync(Guid customerId)
        {
            var defaultAddress = await _unitOfWork.CustomerAddresses.FirstOrDefaultAsync(ca => 
                ca.CustomerId == customerId && ca.IsDefault && ca.IsActive);
            return defaultAddress != null ? _mapper.Map<CustomerAddressDto>(defaultAddress) : null;
        }

        public async Task<CustomerAddressDto> CreateCustomerAddressAsync(CreateCustomerAddressDto createDto)
        {
            _logger.LogInformation("Creating customer address for customer {CustomerId}, IsDefault: {IsDefault}", createDto.CustomerId, createDto.IsDefault);

            // If this is set as default, unset other default addresses for this customer
            if (createDto.IsDefault)
            {
                var existingDefaultAddresses = await _unitOfWork.CustomerAddresses.FindAsync(ca => 
                    ca.CustomerId == createDto.CustomerId && ca.IsDefault && ca.IsActive);
                
                foreach (var address in existingDefaultAddresses)
                {
                    address.IsDefault = false;
                    address.UpdatedOn = DateTime.UtcNow;
                    _unitOfWork.CustomerAddresses.Update(address);
                }
            }

            var customerAddress = new CustomerAddress
            {
                Id = Guid.NewGuid(),
                CustomerId = createDto.CustomerId,
                Address = createDto.Address,
                AddressLine1 = createDto.AddressLine1,
                AddressLine2 = createDto.AddressLine2,
                AddressLine3 = createDto.AddressLine3,
                City = createDto.City,
                State = createDto.State,
                PostalCode = createDto.PostalCode,
                Latitude = createDto.Latitude,
                Longitude = createDto.Longitude,
                IsDefault = createDto.IsDefault,
                IsActive = true,
                CreatedOn = DateTime.UtcNow
            };

            await _unitOfWork.CustomerAddresses.AddAsync(customerAddress);
            await _unitOfWork.SaveChangesAsync();

            _logger.LogInformation("Customer address {AddressId} created successfully for customer {CustomerId}", customerAddress.Id, createDto.CustomerId);
            return _mapper.Map<CustomerAddressDto>(customerAddress);
        }

        public async Task<CustomerAddressDto?> UpdateCustomerAddressAsync(Guid id, UpdateCustomerAddressDto updateDto)
        {
            _logger.LogInformation("Updating customer address {AddressId}", id);

            var customerAddress = await _unitOfWork.CustomerAddresses.FirstOrDefaultAsync(ca => ca.Id == id && ca.IsActive);
            if (customerAddress == null)
            {
                _logger.LogWarning("UpdateCustomerAddressAsync: Address {AddressId} not found or inactive", id);
                return null;
            }

            // If this is being set as default, unset other default addresses for this customer
            if (updateDto.IsDefault == true && !customerAddress.IsDefault)
            {
                var existingDefaultAddresses = await _unitOfWork.CustomerAddresses.FindAsync(ca => 
                    ca.CustomerId == customerAddress.CustomerId && ca.IsDefault && ca.IsActive && ca.Id != id);
                
                foreach (var address in existingDefaultAddresses)
                {
                    address.IsDefault = false;
                    address.UpdatedOn = DateTime.UtcNow;
                    _unitOfWork.CustomerAddresses.Update(address);
                }
            }

            // Only update properties that were explicitly provided (non-null)
            if (updateDto.Address != null)
                customerAddress.Address = updateDto.Address;
            if (updateDto.AddressLine1 != null)
                customerAddress.AddressLine1 = updateDto.AddressLine1;
            if (updateDto.AddressLine2 != null)
                customerAddress.AddressLine2 = updateDto.AddressLine2;
            if (updateDto.AddressLine3 != null)
                customerAddress.AddressLine3 = updateDto.AddressLine3;
            if (updateDto.City != null)
                customerAddress.City = updateDto.City;
            if (updateDto.State != null)
                customerAddress.State = updateDto.State;
            if (updateDto.PostalCode != null)
                customerAddress.PostalCode = updateDto.PostalCode;
            if (updateDto.Latitude != null)
                customerAddress.Latitude = updateDto.Latitude;
            if (updateDto.Longitude != null)
                customerAddress.Longitude = updateDto.Longitude;
            if (updateDto.IsDefault.HasValue)
                customerAddress.IsDefault = updateDto.IsDefault.Value;
            if (updateDto.IsActive.HasValue)
                customerAddress.IsActive = updateDto.IsActive.Value;
            customerAddress.UpdatedOn = DateTime.UtcNow;

            _unitOfWork.CustomerAddresses.Update(customerAddress);
            await _unitOfWork.SaveChangesAsync();

            _logger.LogInformation("Customer address {AddressId} updated successfully", id);
            return _mapper.Map<CustomerAddressDto>(customerAddress);
        }

        public async Task<bool> DeleteCustomerAddressAsync(Guid id)
        {
            _logger.LogInformation("Deleting customer address {AddressId} (soft delete)", id);

            var customerAddress = await _unitOfWork.CustomerAddresses.FirstOrDefaultAsync(ca => ca.Id == id && ca.IsActive);
            if (customerAddress == null)
            {
                _logger.LogWarning("DeleteCustomerAddressAsync: Address {AddressId} not found or already inactive", id);
                return false;
            }

            customerAddress.IsActive = false;
            customerAddress.UpdatedOn = DateTime.UtcNow;

            _unitOfWork.CustomerAddresses.Update(customerAddress);
            await _unitOfWork.SaveChangesAsync();

            _logger.LogInformation("Customer address {AddressId} soft-deleted successfully", id);
            return true;
        }

        public async Task<bool> SetDefaultAddressAsync(Guid customerId, Guid addressId)
        {
            _logger.LogInformation("Setting default address {AddressId} for customer {CustomerId}", addressId, customerId);

            // First, unset all default addresses for this customer
            var existingDefaultAddresses = await _unitOfWork.CustomerAddresses.FindAsync(ca => 
                ca.CustomerId == customerId && ca.IsDefault && ca.IsActive);
            
            foreach (var address in existingDefaultAddresses)
            {
                address.IsDefault = false;
                address.UpdatedOn = DateTime.UtcNow;
                _unitOfWork.CustomerAddresses.Update(address);
            }

            // Then set the specified address as default
            var targetAddress = await _unitOfWork.CustomerAddresses.FirstOrDefaultAsync(ca => 
                ca.Id == addressId && ca.CustomerId == customerId && ca.IsActive);
            
            if (targetAddress == null)
            {
                _logger.LogWarning("SetDefaultAddressAsync: Address {AddressId} not found for customer {CustomerId}", addressId, customerId);
                return false;
            }

            targetAddress.IsDefault = true;
            targetAddress.UpdatedOn = DateTime.UtcNow;
            _unitOfWork.CustomerAddresses.Update(targetAddress);

            await _unitOfWork.SaveChangesAsync();
            _logger.LogInformation("Default address set to {AddressId} for customer {CustomerId}", addressId, customerId);
            return true;
        }
    }
}
