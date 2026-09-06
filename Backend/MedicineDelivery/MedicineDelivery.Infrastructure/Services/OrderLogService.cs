using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace MedicineDelivery.Infrastructure.Services
{
    /// <inheritdoc cref="IOrderLogService"/>
    public class OrderLogService : IOrderLogService
    {
        private const int MaxPageSize = 200;

        private readonly ApplicationDbContext _context;
        private readonly ILogger<OrderLogService> _logger;

        public OrderLogService(ApplicationDbContext context, ILogger<OrderLogService> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<PagedResultDto<OrderLogListItemDto>> GetOrderLogsAsync(OrderLogQueryDto query, CancellationToken cancellationToken = default)
        {
            ArgumentNullException.ThrowIfNull(query);

            var page = query.Page < 1 ? 1 : query.Page;
            var pageSize = query.PageSize < 1 ? 50 : Math.Min(query.PageSize, MaxPageSize);

            var logs = _context.OrderLogs.AsNoTracking().AsQueryable();

            if (!string.IsNullOrWhiteSpace(query.PostalCode))
            {
                var postalCode = query.PostalCode.Trim();
                logs = logs.Where(l => l.PostalCode == postalCode);
            }

            if (query.Reason.HasValue)
                logs = logs.Where(l => l.Reason == query.Reason.Value);

            if (query.FromDate.HasValue)
            {
                var from = DateTime.SpecifyKind(query.FromDate.Value, DateTimeKind.Utc);
                logs = logs.Where(l => l.CreatedOn >= from);
            }

            if (query.ToDate.HasValue)
            {
                var to = DateTime.SpecifyKind(query.ToDate.Value, DateTimeKind.Utc);
                logs = logs.Where(l => l.CreatedOn <= to);
            }

            if (!string.IsNullOrWhiteSpace(query.Search))
            {
                // ILIKE via EF.Functions.Like on a lowered column keeps this provider-agnostic.
                var term = $"%{query.Search.Trim().ToLower()}%";
                logs = logs.Where(l =>
                    (l.CustomerName != null && EF.Functions.Like(l.CustomerName.ToLower(), term)) ||
                    (l.CustomerMobileNumber != null && EF.Functions.Like(l.CustomerMobileNumber.ToLower(), term)) ||
                    (l.DeliveryAddress != null && EF.Functions.Like(l.DeliveryAddress.ToLower(), term)) ||
                    (l.PostalCode != null && EF.Functions.Like(l.PostalCode.ToLower(), term)) ||
                    EF.Functions.Like(l.ReasonSummary.ToLower(), term));
            }

            var totalCount = await logs.CountAsync(cancellationToken);

            var items = await logs
                .OrderByDescending(l => l.CreatedOn)
                .ThenByDescending(l => l.OrderLogId)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(l => new OrderLogListItemDto
                {
                    OrderLogId = l.OrderLogId,
                    CustomerId = l.CustomerId,
                    CustomerName = l.CustomerName,
                    CustomerMobileNumber = l.CustomerMobileNumber,
                    DeliveryAddress = l.DeliveryAddress,
                    PostalCode = l.PostalCode,
                    Latitude = l.Latitude,
                    Longitude = l.Longitude,
                    Reason = l.Reason,
                    ReasonSummary = l.ReasonSummary,
                    ChemistUnavailable = l.ChemistUnavailable,
                    CustomerSupportUnavailable = l.CustomerSupportUnavailable,
                    DeliveryBoyUnavailable = l.DeliveryBoyUnavailable,
                    CreatedOn = l.CreatedOn
                })
                .ToListAsync(cancellationToken);

            _logger.LogInformation("GetOrderLogsAsync: returned {Count} of {TotalCount} order log(s) (page {Page}, size {PageSize}).",
                items.Count, totalCount, page, pageSize);

            return new PagedResultDto<OrderLogListItemDto>
            {
                Items = items,
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize
            };
        }

        public async Task<OrderLogDto?> GetOrderLogByIdAsync(long orderLogId, CancellationToken cancellationToken = default)
        {
            var log = await _context.OrderLogs.AsNoTracking()
                .FirstOrDefaultAsync(l => l.OrderLogId == orderLogId, cancellationToken);

            if (log == null)
            {
                _logger.LogWarning("GetOrderLogByIdAsync: OrderLog {OrderLogId} not found.", orderLogId);
                return null;
            }

            return new OrderLogDto
            {
                OrderLogId = log.OrderLogId,
                CustomerId = log.CustomerId,
                CustomerName = log.CustomerName,
                CustomerMobileNumber = log.CustomerMobileNumber,
                CustomerAddressId = log.CustomerAddressId,
                DeliveryAddress = log.DeliveryAddress,
                PostalCode = log.PostalCode,
                Latitude = log.Latitude,
                Longitude = log.Longitude,
                Reason = log.Reason,
                ReasonSummary = log.ReasonSummary,
                ChemistUnavailable = log.ChemistUnavailable,
                CustomerSupportUnavailable = log.CustomerSupportUnavailable,
                DeliveryBoyUnavailable = log.DeliveryBoyUnavailable,
                Details = log.Details,
                CreatedOn = log.CreatedOn
            };
        }
    }
}
