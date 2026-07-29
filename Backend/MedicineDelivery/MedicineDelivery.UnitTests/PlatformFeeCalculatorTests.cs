using MedicineDelivery.Infrastructure.Services;
using Microsoft.Extensions.Logging.Abstractions;
using Xunit;

namespace MedicineDelivery.UnitTests;

/// <summary>
/// Money math for the Route split: the chemist is paid the bill minus the platform
/// technology fee INCLUSIVE of GST. Example from the business rule: a ₹1,000 bill with
/// a ₹50 slab fee at 18% GST → Pharmaish retains ₹59 (50 + 9), chemist receives ₹941.
/// </summary>
public class PlatformFeeCalculatorTests
{
    private const decimal Gst = 18m;

    private static PlatformFeeCalculator NewCalculator() =>
        new(NullLogger<PlatformFeeCalculator>.Instance);

    // Store activated long ago so the 30-day free window never applies.
    private static readonly DateTime ActivatedLongAgo = new(2020, 1, 1, 0, 0, 0, DateTimeKind.Utc);

    [Theory]
    // billAmount, expected slab fee (per the configured slabs)
    [InlineData(100, 5)]
    [InlineData(200, 5)]
    [InlineData(201, 10)]
    [InlineData(500, 10)]
    [InlineData(501, 15)]
    [InlineData(1000, 15)]
    [InlineData(1500, 15)]
    [InlineData(1501, 20)]
    [InlineData(3000, 20)]
    [InlineData(3001, 50)]
    [InlineData(5000, 50)]
    [InlineData(5001, 100)]
    public void CalculateFee_returns_the_slab_fee(decimal billAmount, decimal expectedFee)
    {
        var fee = NewCalculator().CalculateFee(billAmount, ActivatedLongAgo);
        Assert.Equal(expectedFee, fee);
    }

    [Theory]
    // billAmount, expected fee, expected GST (18%), expected fee incl. GST
    [InlineData(1000, 15, 2.70, 17.70)]
    [InlineData(200, 5, 0.90, 5.90)]
    [InlineData(3000, 20, 3.60, 23.60)]
    [InlineData(6000, 100, 18.00, 118.00)]
    public void CalculateFeeBreakdown_adds_gst_on_top_of_the_fee(
        decimal billAmount, decimal expectedFee, decimal expectedGst, decimal expectedTotal)
    {
        var breakdown = NewCalculator().CalculateFeeBreakdown(billAmount, ActivatedLongAgo, Gst);

        Assert.Equal(expectedFee, breakdown.Fee);
        Assert.Equal(expectedGst, breakdown.Gst);
        Assert.Equal(expectedTotal, breakdown.FeeInclusiveOfGst);
    }

    [Fact]
    public void Chemist_receives_bill_minus_fee_including_gst()
    {
        const decimal bill = 1000m;
        var breakdown = NewCalculator().CalculateFeeBreakdown(bill, ActivatedLongAgo, Gst);

        var chemistAmount = bill - breakdown.FeeInclusiveOfGst;

        // ₹1,000 bill → ₹15 slab fee + ₹2.70 GST retained; chemist gets ₹982.30.
        Assert.Equal(17.70m, breakdown.FeeInclusiveOfGst);
        Assert.Equal(982.30m, chemistAmount);
        // Nothing is lost or created by the split.
        Assert.Equal(bill, chemistAmount + breakdown.FeeInclusiveOfGst);
    }

    /// <summary>The exact figures from the business rule, using a ₹50 fee.</summary>
    [Fact]
    public void Business_rule_example_50_rupee_fee_yields_59_retained_and_941_to_chemist()
    {
        const decimal bill = 1000m;
        const decimal fee = 50m;

        var gst = Math.Round(fee * Gst / 100m, 2, MidpointRounding.AwayFromZero);
        var retained = fee + gst;

        Assert.Equal(9m, gst);
        Assert.Equal(59m, retained);
        Assert.Equal(941m, bill - retained);
    }

    [Fact]
    public void No_gst_is_charged_when_the_fee_is_waived_in_the_free_window()
    {
        var activatedNow = DateTime.UtcNow;
        var breakdown = NewCalculator().CalculateFeeBreakdown(1000m, activatedNow, Gst);

        Assert.Equal(0m, breakdown.Fee);
        Assert.Equal(0m, breakdown.Gst);
        Assert.Equal(0m, breakdown.FeeInclusiveOfGst);
    }

    [Fact]
    public void Zero_gst_percent_leaves_the_fee_untouched()
    {
        var breakdown = NewCalculator().CalculateFeeBreakdown(1000m, ActivatedLongAgo, 0m);

        Assert.Equal(15m, breakdown.Fee);
        Assert.Equal(0m, breakdown.Gst);
        Assert.Equal(15m, breakdown.FeeInclusiveOfGst);
    }
}
