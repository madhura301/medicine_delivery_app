using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Domain.Enums;
using MedicineDelivery.Domain.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Hosting;

namespace MedicineDelivery.Infrastructure.Services
{
    public class OrderService : IOrderService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly IHostEnvironment _hostEnvironment;
        private static readonly string[] AllowedImageExtensions = { ".jpg", ".jpeg", ".png", ".gif", ".bmp" };
        private static readonly string[] AllowedVoiceExtensions = { ".mp3", ".wav", ".m4a", ".aac", ".ogg" };

        public OrderService(IUnitOfWork unitOfWork, IMapper mapper, IHostEnvironment hostEnvironment)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _hostEnvironment = hostEnvironment;
        }

        public async Task<OrderDto> CreateOrderAsync(CreateOrderDto createDto, CancellationToken cancellationToken = default)
        {
            ArgumentNullException.ThrowIfNull(createDto);

            cancellationToken.ThrowIfCancellationRequested();

            if (createDto.CustomerId == Guid.Empty)
            {
                throw new ArgumentException("CustomerId is required.", nameof(createDto.CustomerId));
            }

            if (createDto.CustomerAddressId == Guid.Empty)
            {
                throw new ArgumentException("CustomerAddressId is required.", nameof(createDto.CustomerAddressId));
            }

            if (!Enum.IsDefined(typeof(OrderType), createDto.OrderType))
            {
                throw new ArgumentException("Invalid order type provided.", nameof(createDto.OrderType));
            }

            if (!Enum.IsDefined(typeof(OrderInputType), createDto.OrderInputType))
            {
                throw new ArgumentException("Invalid order input type provided.", nameof(createDto.OrderInputType));
            }

            // Ensure the customer exists and is active
            var customer = await _unitOfWork.Customers.FirstOrDefaultAsync(c => c.CustomerId == createDto.CustomerId && c.IsActive);
            if (customer == null)
            {
                throw new KeyNotFoundException("Customer not found or inactive.");
            }

            // Ensure the address exists for the customer
            var address = await _unitOfWork.CustomerAddresses.FirstOrDefaultAsync(ca =>
                ca.Id == createDto.CustomerAddressId &&
                ca.CustomerId == createDto.CustomerId &&
                ca.IsActive);

            if (address == null)
            {
                throw new KeyNotFoundException("Customer address not found or inactive.");
            }

            // Validate input data based on the order input type
            switch (createDto.OrderInputType)
            {
                case OrderInputType.Text when string.IsNullOrWhiteSpace(createDto.OrderInputText):
                    throw new ArgumentException("Order input text is required when order input type is text.", nameof(createDto.OrderInputText));
                case OrderInputType.Image when createDto.OrderInputFile == null || createDto.OrderInputFile.Length == 0:
                    throw new ArgumentException("An image file is required when order input type is image.", nameof(createDto.OrderInputFile));
                case OrderInputType.Voice when createDto.OrderInputFile == null || createDto.OrderInputFile.Length == 0:
                    throw new ArgumentException("A voice file is required when order input type is voice.", nameof(createDto.OrderInputFile));
            }

            var order = new Order
            {
                CustomerId = createDto.CustomerId,
                CustomerAddressId = createDto.CustomerAddressId,
                OrderType = createDto.OrderType,
                OrderInputType = createDto.OrderInputType,
                OrderInputText = createDto.OrderInputType == OrderInputType.Text
                    ? string.IsNullOrWhiteSpace(createDto.OrderInputText) ? null : createDto.OrderInputText.Trim()
                    : null,
                AssignedByType = AssignedByType.System,
                OrderStatus = OrderStatus.PendingPayment,
                CreatedOn = DateTime.UtcNow,
                UpdatedOn = null
            };

            if (createDto.OrderInputType is OrderInputType.Image or OrderInputType.Voice)
            {
                if (createDto.OrderInputFile == null || createDto.OrderInputFile.Length == 0)
                {
                    throw new ArgumentException("An order input file is required for image or voice orders.", nameof(createDto.OrderInputFile));
                }

                ValidateOrderInputFile(createDto.OrderInputType, createDto.OrderInputFile);
                order.OrderInputFileLocation = await SaveOrderInputFileAsync(createDto.OrderInputFile, createDto.OrderInputType, cancellationToken);
            }
            else
            {
                order.OrderInputFileLocation = null;
            }

            await _unitOfWork.Orders.AddAsync(order);
            await _unitOfWork.SaveChangesAsync();

            return _mapper.Map<OrderDto>(order);
        }

        public async Task<OrderDto?> GetOrderByIdAsync(int orderId, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId);
            if (order == null)
            {
                return null;
            }

            return _mapper.Map<OrderDto>(order);
        }

        public async Task<IEnumerable<OrderDto>> GetOrdersByCustomerIdAsync(Guid customerId, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            if (customerId == Guid.Empty)
            {
                throw new ArgumentException("CustomerId is required.", nameof(customerId));
            }

            var orders = await _unitOfWork.Orders.FindAsync(o => o.CustomerId == customerId);
            return _mapper.Map<IEnumerable<OrderDto>>(orders);
        }

        public async Task<IEnumerable<OrderDto>> GetActiveOrdersByMedicalStoreIdAsync(Guid medicalStoreId, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            if (medicalStoreId == Guid.Empty)
            {
                throw new ArgumentException("MedicalStoreId is required.", nameof(medicalStoreId));
            }

            var orders = await _unitOfWork.Orders.FindAsync(o => 
                o.MedicalStoreId == medicalStoreId && 
                o.OrderStatus != OrderStatus.Completed);
            
            return _mapper.Map<IEnumerable<OrderDto>>(orders);
        }

        public async Task<OrderDto> AcceptOrderByChemistAsync(int orderId, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId);
            if (order == null)
            {
                throw new KeyNotFoundException("Order not found.");
            }

            if (order.OrderStatus != OrderStatus.AssignedToChemist)
            {
                throw new InvalidOperationException($"Order can only be accepted when its status is {OrderStatus.AssignedToChemist}. Current status is {order.OrderStatus}.");
            }

            order.OrderStatus = OrderStatus.AcceptedByChemist;
            order.UpdatedOn = DateTime.UtcNow;

            _unitOfWork.Orders.Update(order);
            await _unitOfWork.SaveChangesAsync();

            return _mapper.Map<OrderDto>(order);
        }

        private void ValidateOrderInputFile(OrderInputType inputType, IFormFile file)
        {
            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            if (string.IsNullOrEmpty(extension))
            {
                throw new ArgumentException("The uploaded file must have an extension.", nameof(file));
            }

            var allowedExtensions = inputType == OrderInputType.Image
                ? AllowedImageExtensions
                : AllowedVoiceExtensions;

            if (!allowedExtensions.Contains(extension))
            {
                throw new ArgumentException($"File type '{extension}' is not supported for {inputType} orders.", nameof(file));
            }
        }

        private async Task<string> SaveOrderInputFileAsync(IFormFile file, OrderInputType inputType, CancellationToken cancellationToken)
        {
            var folderName = inputType switch
            {
                OrderInputType.Image => "Images",
                OrderInputType.Voice => "Voice",
                _ => throw new InvalidOperationException("Unsupported order input type for file upload.")
            };

            var basePath = Path.Combine(_hostEnvironment.ContentRootPath, "Files", "Orders", folderName);
            Directory.CreateDirectory(basePath);

            var fileExtension = Path.GetExtension(file.FileName);
            var uniqueFileName = $"{Guid.NewGuid():N}{fileExtension}";
            var filePath = Path.Combine(basePath, uniqueFileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream, cancellationToken);
            }

            return Path.Combine("Files", "Orders", folderName, uniqueFileName).Replace("\\", "/");
        }
    }
}


