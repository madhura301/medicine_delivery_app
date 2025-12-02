using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Domain.Interfaces;
using AutoMapper;

namespace MedicineDelivery.Infrastructure.Services
{
    public class CustomerAddressService : ICustomerAddressService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public CustomerAddressService(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
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

            return _mapper.Map<CustomerAddressDto>(customerAddress);
        }

        public async Task<CustomerAddressDto?> UpdateCustomerAddressAsync(Guid id, UpdateCustomerAddressDto updateDto)
        {
            var customerAddress = await _unitOfWork.CustomerAddresses.FirstOrDefaultAsync(ca => ca.Id == id && ca.IsActive);
            if (customerAddress == null)
                return null;

            // If this is being set as default, unset other default addresses for this customer
            if (updateDto.IsDefault && !customerAddress.IsDefault)
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

            customerAddress.Address = updateDto.Address;
            customerAddress.AddressLine1 = updateDto.AddressLine1;
            customerAddress.AddressLine2 = updateDto.AddressLine2;
            customerAddress.AddressLine3 = updateDto.AddressLine3;
            customerAddress.City = updateDto.City;
            customerAddress.State = updateDto.State;
            customerAddress.PostalCode = updateDto.PostalCode;
            customerAddress.Latitude = updateDto.Latitude;
            customerAddress.Longitude = updateDto.Longitude;
            customerAddress.IsDefault = updateDto.IsDefault;
            customerAddress.IsActive = updateDto.IsActive;
            customerAddress.UpdatedOn = DateTime.UtcNow;

            _unitOfWork.CustomerAddresses.Update(customerAddress);
            await _unitOfWork.SaveChangesAsync();

            return _mapper.Map<CustomerAddressDto>(customerAddress);
        }

        public async Task<bool> DeleteCustomerAddressAsync(Guid id)
        {
            var customerAddress = await _unitOfWork.CustomerAddresses.FirstOrDefaultAsync(ca => ca.Id == id && ca.IsActive);
            if (customerAddress == null)
                return false;

            customerAddress.IsActive = false;
            customerAddress.UpdatedOn = DateTime.UtcNow;

            _unitOfWork.CustomerAddresses.Update(customerAddress);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }

        public async Task<bool> SetDefaultAddressAsync(Guid customerId, Guid addressId)
        {
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
                return false;

            targetAddress.IsDefault = true;
            targetAddress.UpdatedOn = DateTime.UtcNow;
            _unitOfWork.CustomerAddresses.Update(targetAddress);

            await _unitOfWork.SaveChangesAsync();
            return true;
        }
    }
}
