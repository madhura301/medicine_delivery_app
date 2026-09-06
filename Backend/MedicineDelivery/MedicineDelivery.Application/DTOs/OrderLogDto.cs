using System;
using System.Collections.Generic;
using MedicineDelivery.Domain.Enums;

namespace MedicineDelivery.Application.DTOs
{
    /// <summary>
    /// A refused order attempt, as shown in the staff console's "Order Log" list. Carries everything
    /// the list needs; <see cref="OrderLogDto.Details"/> is only populated on the detail endpoint.
    /// </summary>
    public class OrderLogListItemDto
    {
        public long OrderLogId { get; set; }
        public Guid? CustomerId { get; set; }
        public string? CustomerName { get; set; }
        public string? CustomerMobileNumber { get; set; }
        public string? DeliveryAddress { get; set; }
        public string? PostalCode { get; set; }
        public decimal? Latitude { get; set; }
        public decimal? Longitude { get; set; }
        public OrderLogReason Reason { get; set; }
        public string ReasonName => Reason.ToString();
        public string ReasonSummary { get; set; } = string.Empty;
        public bool ChemistUnavailable { get; set; }
        public bool CustomerSupportUnavailable { get; set; }
        public bool DeliveryBoyUnavailable { get; set; }
        public DateTime CreatedOn { get; set; }
    }

    /// <summary>A single refused attempt with its full free-text diagnostic block.</summary>
    public class OrderLogDto : OrderLogListItemDto
    {
        public Guid? CustomerAddressId { get; set; }

        /// <summary>Free-text record of everything known about the attempt.</summary>
        public string? Details { get; set; }
    }

    /// <summary>Filters accepted by the order-log list endpoint. All are optional and combine with AND.</summary>
    public class OrderLogQueryDto
    {
        /// <summary>Free-text match against customer name, mobile number, address and reason summary.</summary>
        public string? Search { get; set; }

        public string? PostalCode { get; set; }

        public OrderLogReason? Reason { get; set; }

        /// <summary>Inclusive lower bound on <see cref="OrderLogListItemDto.CreatedOn"/> (UTC).</summary>
        public DateTime? FromDate { get; set; }

        /// <summary>Inclusive upper bound on <see cref="OrderLogListItemDto.CreatedOn"/> (UTC).</summary>
        public DateTime? ToDate { get; set; }

        public int Page { get; set; } = 1;

        public int PageSize { get; set; } = 50;
    }

    public class PagedResultDto<T>
    {
        public IReadOnlyList<T> Items { get; set; } = Array.Empty<T>();
        public int TotalCount { get; set; }
        public int Page { get; set; }
        public int PageSize { get; set; }
    }
}
