using MedicineDelivery.Application.Common;
using MedicineDelivery.Domain.Enums;
using Xunit;

namespace MedicineDelivery.UnitTests;

/// <summary>
/// Who may see a customer's phone number: only the store handling the order, and only while the
/// order is still in progress.
/// </summary>
public class CustomerContactRulesTests
{
    private static readonly Guid HandlingStore = Guid.NewGuid();
    private static readonly Guid OtherStore = Guid.NewGuid();

    [Theory]
    [InlineData(OrderStatus.AssignedToChemist)]
    [InlineData(OrderStatus.AcceptedByChemist)]
    [InlineData(OrderStatus.BillUploaded)]
    [InlineData(OrderStatus.Paid)]
    [InlineData(OrderStatus.OutForDelivery)]
    public void Handling_store_sees_contact_while_order_is_in_progress(OrderStatus status)
    {
        Assert.True(CustomerContactRules.StoreMaySeeCustomerContact(HandlingStore, status, HandlingStore));
    }

    [Theory]
    [InlineData(OrderStatus.PendingPayment)]
    [InlineData(OrderStatus.RejectedByChemist)]
    [InlineData(OrderStatus.AssignedToCustomerSupport)]
    [InlineData(OrderStatus.AssignedToManager)]
    [InlineData(OrderStatus.Completed)]
    [InlineData(OrderStatus.Cancelled)]
    public void Handling_store_loses_contact_once_order_is_rejected_escalated_finished_or_cancelled(OrderStatus status)
    {
        Assert.False(CustomerContactRules.StoreMaySeeCustomerContact(HandlingStore, status, HandlingStore));
    }

    [Fact]
    public void Another_store_never_sees_contact()
    {
        Assert.False(CustomerContactRules.StoreMaySeeCustomerContact(HandlingStore, OrderStatus.AcceptedByChemist, OtherStore));
    }

    [Fact]
    public void Order_without_a_store_shows_no_contact()
    {
        Assert.False(CustomerContactRules.StoreMaySeeCustomerContact(null, OrderStatus.AssignedToChemist, HandlingStore));
    }

    [Fact]
    public void Every_status_is_either_a_contact_stage_or_deliberately_excluded()
    {
        // Guards against a new OrderStatus silently getting (or missing) contact access.
        var excluded = new[]
        {
            OrderStatus.PendingPayment, OrderStatus.RejectedByChemist, OrderStatus.AssignedToCustomerSupport,
            OrderStatus.AssignedToManager, OrderStatus.Completed, OrderStatus.Cancelled,
        };
        foreach (var status in Enum.GetValues<OrderStatus>())
        {
            Assert.True(CustomerContactRules.ContactStages.Contains(status) ^ excluded.Contains(status),
                $"{status} must be in exactly one of ContactStages or the excluded list.");
        }
    }
}
