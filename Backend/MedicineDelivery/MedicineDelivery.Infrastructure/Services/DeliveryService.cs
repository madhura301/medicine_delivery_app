using AutoMapper;
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

        public DeliveryService(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        public async Task<DeliveryDto> CreateDeliveryAsync(CreateDeliveryDto createDto, Guid? addedBy = null)
        {
            ArgumentNullException.ThrowIfNull(createDto);

            // Validate MedicalStoreId if provided
            if (createDto.MedicalStoreId.HasValue)
            {
                var medicalStore = await _unitOfWork.MedicalStores.GetByIdAsync(createDto.MedicalStoreId.Value);
                if (medicalStore == null)
                {
                    throw new KeyNotFoundException($"Medical store with ID '{createDto.MedicalStoreId.Value}' not found.");
                }

                if (!medicalStore.IsActive || medicalStore.IsDeleted)
                {
                    throw new InvalidOperationException("Cannot assign delivery to an inactive or deleted medical store.");
                }
            }

            var delivery = new Delivery
            {
                FirstName = createDto.FirstName,
                MiddleName = createDto.MiddleName,
                LastName = createDto.LastName,
                DrivingLicenceNumber = createDto.DrivingLicenceNumber,
                MobileNumber = createDto.MobileNumber,
                MedicalStoreId = createDto.MedicalStoreId,
                IsActive = true,
                IsDeleted = false,
                AddedOn = DateTime.UtcNow,
                AddedBy = addedBy
            };

            await _unitOfWork.Deliveries.AddAsync(delivery);
            await _unitOfWork.SaveChangesAsync();

            return _mapper.Map<DeliveryDto>(delivery);
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

            var delivery = await _unitOfWork.Deliveries.GetByIdAsync(id);
            if (delivery == null || delivery.IsDeleted)
            {
                throw new KeyNotFoundException($"Delivery with ID '{id}' not found.");
            }

            // Validate MedicalStoreId if provided
            if (updateDto.MedicalStoreId.HasValue)
            {
                var medicalStore = await _unitOfWork.MedicalStores.GetByIdAsync(updateDto.MedicalStoreId.Value);
                if (medicalStore == null)
                {
                    throw new KeyNotFoundException($"Medical store with ID '{updateDto.MedicalStoreId.Value}' not found.");
                }

                if (!medicalStore.IsActive || medicalStore.IsDeleted)
                {
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

            delivery.ModifiedOn = DateTime.UtcNow;
            delivery.ModifiedBy = modifiedBy;

            _unitOfWork.Deliveries.Update(delivery);
            await _unitOfWork.SaveChangesAsync();

            return _mapper.Map<DeliveryDto>(delivery);
        }

        public async Task<bool> DeleteDeliveryAsync(int id)
        {
            var delivery = await _unitOfWork.Deliveries.GetByIdAsync(id);
            if (delivery == null || delivery.IsDeleted)
            {
                return false;
            }

            // Soft delete
            delivery.IsDeleted = true;
            delivery.IsActive = false;
            delivery.ModifiedOn = DateTime.UtcNow;

            _unitOfWork.Deliveries.Update(delivery);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }
    }
}

