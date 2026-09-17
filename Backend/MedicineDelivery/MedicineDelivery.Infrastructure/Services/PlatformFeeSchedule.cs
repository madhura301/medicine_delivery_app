using System.Globalization;

namespace MedicineDelivery.Infrastructure.Services
{
    /// <summary>
    /// A parsed and validated platform fee table. Immutable.
    ///
    /// Validation is deliberately strict — bounds must be written in ascending order, not merely
    /// sortable — because this decides what every chemist is paid. A typo such as <c>150:15</c> for
    /// <c>1500:15</c> should stop the API from starting, not quietly change the fees.
    /// </summary>
    public sealed class PlatformFeeSchedule
    {
        private const string AboveTopMarker = "*";

        private PlatformFeeSchedule(int freeWindowDays, IReadOnlyList<PlatformFeeSlab> slabs, decimal aboveTopSlabFee)
        {
            FreeWindowDays = freeWindowDays;
            Slabs = slabs;
            AboveTopSlabFee = aboveTopSlabFee;
        }

        public int FreeWindowDays { get; }

        /// <summary>Ascending by <see cref="PlatformFeeSlab.UpToInclusive"/>.</summary>
        public IReadOnlyList<PlatformFeeSlab> Slabs { get; }

        /// <summary>Charged on any bill above the highest slab bound.</summary>
        public decimal AboveTopSlabFee { get; }

        public decimal FeeFor(decimal billAmount)
        {
            foreach (var slab in Slabs)
            {
                if (billAmount <= slab.UpToInclusive)
                {
                    return slab.Fee;
                }
            }
            return AboveTopSlabFee;
        }

        /// <summary>A one-line summary for logs, e.g. "free for 30 days; up to ₹200 → ₹5, …, above → ₹100".</summary>
        public override string ToString()
        {
            var bands = Slabs.Select(s => $"up to ₹{s.UpToInclusive.ToString(CultureInfo.InvariantCulture)} → ₹{s.Fee.ToString(CultureInfo.InvariantCulture)}");
            var free = FreeWindowDays > 0 ? $"free for {FreeWindowDays} days after activation" : "no free period";
            return $"{free}; {string.Join(", ", bands)}, above → ₹{AboveTopSlabFee.ToString(CultureInfo.InvariantCulture)}";
        }

        /// <summary>Builds the schedule, throwing with a specific message if the settings are invalid.</summary>
        public static PlatformFeeSchedule From(PlatformFeeOptions options)
        {
            if (!TryCreate(options, out var schedule, out var error))
            {
                throw new InvalidOperationException(error);
            }
            return schedule!;
        }

        public static bool TryCreate(PlatformFeeOptions options, out PlatformFeeSchedule? schedule, out string error)
        {
            schedule = null;
            error = string.Empty;

            if (options.FreeWindowDays < 0)
            {
                error = $"PlatformFee:FreeWindowDays must be 0 or more (0 turns the free period off). Got {options.FreeWindowDays}.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(options.Slabs))
            {
                error = $"PlatformFee:Slabs is empty. Expected something like \"{PlatformFeeOptions.DefaultSlabs}\".";
                return false;
            }

            var slabs = new List<PlatformFeeSlab>();
            decimal? aboveTop = null;
            var entries = options.Slabs.Split(',', StringSplitOptions.TrimEntries);

            // Checked up front so two "*" entries report that, not "must come last" for the first one.
            if (entries.Count(e => e.Split(':', StringSplitOptions.TrimEntries)[0] == AboveTopMarker) > 1)
            {
                error = "PlatformFee:Slabs has more than one \"*\" entry. Only one fee can apply above the last bound.";
                return false;
            }

            for (var i = 0; i < entries.Length; i++)
            {
                var entry = entries[i];
                var position = i + 1;
                var parts = entry.Split(':', StringSplitOptions.TrimEntries);

                if (parts.Length != 2 || parts[0].Length == 0 || parts[1].Length == 0)
                {
                    error = $"PlatformFee:Slabs entry {position} \"{entry}\" must look like \"upTo:fee\", e.g. \"500:10\", or \"*:fee\" for bills above the last bound.";
                    return false;
                }

                if (!TryParseAmount(parts[1], out var fee) || fee < 0)
                {
                    error = $"PlatformFee:Slabs entry {position} \"{entry}\" has an invalid fee \"{parts[1]}\". Use a number of rupees, 0 or more.";
                    return false;
                }

                if (parts[0] == AboveTopMarker)
                {
                    if (aboveTop.HasValue)
                    {
                        error = $"PlatformFee:Slabs has more than one \"*\" entry. Only one fee can apply above the last bound.";
                        return false;
                    }
                    if (position != entries.Length)
                    {
                        error = $"PlatformFee:Slabs \"*\" entry must come last, after every upper bound. It is entry {position} of {entries.Length}.";
                        return false;
                    }
                    aboveTop = fee;
                    continue;
                }

                if (!TryParseAmount(parts[0], out var upTo) || upTo <= 0)
                {
                    error = $"PlatformFee:Slabs entry {position} \"{entry}\" has an invalid upper bound \"{parts[0]}\". Use a number of rupees greater than 0.";
                    return false;
                }

                if (slabs.Count > 0 && upTo <= slabs[^1].UpToInclusive)
                {
                    error = $"PlatformFee:Slabs upper bounds must be in ascending order. Entry {position} (₹{parts[0]}) is not above the one before it (₹{slabs[^1].UpToInclusive.ToString(CultureInfo.InvariantCulture)}).";
                    return false;
                }

                slabs.Add(new PlatformFeeSlab(upTo, fee));
            }

            if (slabs.Count == 0)
            {
                error = "PlatformFee:Slabs needs at least one \"upTo:fee\" band before the \"*:fee\" entry.";
                return false;
            }

            if (!aboveTop.HasValue)
            {
                error = $"PlatformFee:Slabs must end with \"*:fee\" — the fee for bills above ₹{slabs[^1].UpToInclusive.ToString(CultureInfo.InvariantCulture)}.";
                return false;
            }

            schedule = new PlatformFeeSchedule(options.FreeWindowDays, slabs, aboveTop.Value);
            return true;
        }

        private static bool TryParseAmount(string text, out decimal value) =>
            decimal.TryParse(text, NumberStyles.AllowDecimalPoint, CultureInfo.InvariantCulture, out value);
    }

    /// <summary>One fee band: bills up to and including <paramref name="UpToInclusive"/> rupees pay <paramref name="Fee"/>.</summary>
    public readonly record struct PlatformFeeSlab(decimal UpToInclusive, decimal Fee);
}
