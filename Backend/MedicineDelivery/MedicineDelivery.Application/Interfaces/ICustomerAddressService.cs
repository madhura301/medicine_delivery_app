using MedicineDelivery.Application.DTOs;

namespace MedicineDelivery.Application.Interfaces
{
    public interface ICustomerAddressService
    {
        Task<CustomerAddressDto?> GetCustomerAddressByIdAsync(Guid id);
        Task<List<CustomerAddressDto>> GetCustomerAddressesByCustomerIdAsync(Guid customerId);
        Task<CustomerAddressDto?> GetDefaultCustomerAddressAsync(Guid customerId);
        Task<CustomerAddressDto> CreateCustomerAddressAsync(CreateCustomerAddressDto createDto);
        Task<CustomerAddressDto?> UpdateCustomerAddressAsync(Guid id, UpdateCustomerAddressDto updateDto);
        Task<bool> DeleteCustomerAddressAsync(Guid id);
        Task<bool> SetDefaultAddressAsync(Guid customerId, Guid addressId);
    }
}
