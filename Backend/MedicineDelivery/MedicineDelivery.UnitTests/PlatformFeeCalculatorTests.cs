using MedicineDelivery.Infrastructure.Services;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;
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

    /// <summary>With no arguments this is the default configuration — the fees that were hard-coded before.</summary>
    private static PlatformFeeCalculator NewCalculator(int? freeWindowDays = null, string? slabs = null) =>
        new(
            Options.Create(new PlatformFeeOptions
            {
                FreeWindowDays = freeWindowDays ?? PlatformFeeOptions.DefaultFreeWindowDays,
                Slabs = slabs ?? PlatformFeeOptions.DefaultSlabs,
            }),
            NullLogger<PlatformFeeCalculator>.Instance);

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

    /* ── configurable free window ─────────────────────────────────────────── */

    private static readonly DateTime AsOf = new(2026, 9, 20, 12, 0, 0, DateTimeKind.Utc);

    [Theory]
    // free-window days, days since activation, expected fee on a ₹1,000 bill
    [InlineData(30, 29, 0)]   // default: inside
    [InlineData(30, 31, 15)]  // default: just outside
    [InlineData(45, 40, 0)]   // lengthened: still free at day 40
    [InlineData(10, 11, 15)]  // shortened: charging from day 11
    [InlineData(0, 0, 15)]    // 0 turns the free period off entirely
    public void Free_window_length_comes_from_configuration(int freeWindowDays, int daysSinceActivation, decimal expectedFee)
    {
        var activatedOn = AsOf.AddDays(-daysSinceActivation);
        var fee = NewCalculator(freeWindowDays: freeWindowDays).CalculateFee(1000m, activatedOn, AsOf);
        Assert.Equal(expectedFee, fee);
    }

    [Fact]
    public void A_store_with_no_activation_date_is_never_in_the_free_window()
    {
        Assert.Equal(15m, NewCalculator(freeWindowDays: 365).CalculateFee(1000m, storeActivatedOn: null, AsOf));
    }

    /* ── configurable slabs ───────────────────────────────────────────────── */

    [Theory]
    [InlineData(100, 2)]
    [InlineData(100.01, 7)]
    [InlineData(999, 7)]
    [InlineData(1000.50, 12)]
    [InlineData(1000000, 12)]
    public void Slabs_come_from_configuration(decimal bill, decimal expectedFee)
    {
        var calculator = NewCalculator(slabs: "100:2, 1000:7, *:12");
        Assert.Equal(expectedFee, calculator.CalculateFee(bill, ActivatedLongAgo));
    }

    [Fact]
    public void Slabs_tolerate_whitespace_and_decimal_amounts()
    {
        var calculator = NewCalculator(slabs: " 250.50 : 4.5 ,  * : 9.25 ");
        Assert.Equal(4.5m, calculator.CalculateFee(250.50m, ActivatedLongAgo));
        Assert.Equal(9.25m, calculator.CalculateFee(250.51m, ActivatedLongAgo));
    }

    [Fact]
    public void Default_configuration_matches_the_fees_that_were_hard_coded()
    {
        var schedule = PlatformFeeSchedule.From(new PlatformFeeOptions());

        Assert.Equal(30, schedule.FreeWindowDays);
        Assert.Equal(
            new[] { new PlatformFeeSlab(200, 5), new PlatformFeeSlab(500, 10), new PlatformFeeSlab(1500, 15), new PlatformFeeSlab(3000, 20), new PlatformFeeSlab(5000, 50) },
            schedule.Slabs);
        Assert.Equal(100m, schedule.AboveTopSlabFee);
    }

    /* ── validation: a bad fee table must never load ──────────────────────── */

    [Theory]
    [InlineData("500:10,200:5,*:100", "ascending")]          // out of order
    [InlineData("200:5,200:10,*:100", "ascending")]          // duplicate bound
    [InlineData("200:5,500:10", "must end with")]            // no above-top fee
    [InlineData("*:100", "at least one")]                    // no bands
    [InlineData("200:5,*:50,500:10", "must come last")]      // * in the middle
    [InlineData("200:5,*:50,*:60", "more than one")]         // two * entries
    [InlineData("200-5,*:100", "must look like")]            // wrong separator
    [InlineData("200:,*:100", "must look like")]             // missing fee
    [InlineData("200:-5,*:100", "invalid fee")]              // negative fee
    [InlineData("0:5,*:100", "invalid upper bound")]         // zero bound
    [InlineData("abc:5,*:100", "invalid upper bound")]       // not a number
    [InlineData("₹200:5,*:100", "invalid upper bound")]      // currency symbol
    [InlineData("", "is empty")]
    public void Invalid_slab_tables_are_rejected_with_a_specific_reason(string slabs, string expectedMessagePart)
    {
        var ok = PlatformFeeSchedule.TryCreate(new PlatformFeeOptions { Slabs = slabs }, out var schedule, out var error);

        Assert.False(ok);
        Assert.Null(schedule);
        Assert.Contains(expectedMessagePart, error);
    }

    [Fact]
    public void A_negative_free_window_is_rejected()
    {
        var ok = PlatformFeeSchedule.TryCreate(new PlatformFeeOptions { FreeWindowDays = -1 }, out _, out var error);

        Assert.False(ok);
        Assert.Contains("FreeWindowDays", error);
    }

    [Fact]
    public void The_calculator_refuses_to_start_with_an_invalid_fee_table()
    {
        var ex = Assert.Throws<InvalidOperationException>(() => NewCalculator(slabs: "500:10,200:5,*:100"));
        Assert.Contains("ascending", ex.Message);
    }

    [Fact]
    public void The_startup_validator_reports_the_same_problem()
    {
        var result = new PlatformFeeOptionsValidator().Validate(null, new PlatformFeeOptions { Slabs = "200:5" });

        Assert.True(result.Failed);
        Assert.Contains("must end with", result.FailureMessage);
    }
}
