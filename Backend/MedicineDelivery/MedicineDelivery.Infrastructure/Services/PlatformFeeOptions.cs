namespace MedicineDelivery.Infrastructure.Services
{
    /// <summary>
    /// Platform technology fee settings, bound from the <c>PlatformFee</c> configuration section.
    ///
    /// In Azure, set them as Container App environment variables:
    /// <code>
    /// PlatformFee__FreeWindowDays = 30
    /// PlatformFee__Slabs          = 200:5,500:10,1500:15,3000:20,5000:50,*:100
    /// </code>
    /// Both are read once at startup. Changing an environment variable creates a new revision, which
    /// restarts the API with the new values. An invalid value stops the API from starting, rather than
    /// letting it charge chemists the wrong fee.
    /// </summary>
    public class PlatformFeeOptions
    {
        public const string SectionName = "PlatformFee";

        public const int DefaultFreeWindowDays = 30;

        /// <summary>The fee table in effect before this became configurable.</summary>
        public const string DefaultSlabs = "200:5,500:10,1500:15,3000:20,5000:50,*:100";

        /// <summary>
        /// Days after a store's activation during which no platform fee is charged.
        /// Counted from <c>MedicalStores.ActivatedOn</c>. Set to 0 to turn the free period off.
        /// </summary>
        public int FreeWindowDays { get; set; } = DefaultFreeWindowDays;

        /// <summary>
        /// The fee table as comma-separated <c>upTo:fee</c> pairs in ascending order, in rupees, ending
        /// with <c>*:fee</c> for every bill above the last bound. Bounds are inclusive: <c>200:5</c>
        /// means a bill of up to and including ₹200 pays ₹5.
        /// </summary>
        public string Slabs { get; set; } = DefaultSlabs;
    }
}
