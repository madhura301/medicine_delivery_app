using System.Collections.Generic;

namespace MedicineDelivery.Domain.Exceptions
{
    /// <summary>
    /// Thrown when an order cannot be created because the delivery address's area is not fully
    /// serviceable — i.e. at least one of the required roles (chemist, customer support, delivery
    /// partner) is unavailable for the address's pin code. Surfaced to the client as HTTP 400.
    /// </summary>
    public class ServiceAreaUnavailableException : Exception
    {
        public string PostalCode { get; }

        /// <summary>Human-readable names of the roles that are not available (e.g. "chemist", "delivery partner").</summary>
        public IReadOnlyList<string> MissingRoles { get; }

        public ServiceAreaUnavailableException(string postalCode, IReadOnlyList<string> missingRoles)
            : base(BuildMessage(postalCode, missingRoles))
        {
            PostalCode = postalCode;
            MissingRoles = missingRoles;
        }

        private static string BuildMessage(string postalCode, IReadOnlyList<string> missingRoles)
        {
            var roles = string.Join(", ", missingRoles);
            var pin = string.IsNullOrWhiteSpace(postalCode) ? "this location" : $"pincode {postalCode}";
            return $"We are not serving your delivery area yet. No {roles} available for {pin}.";
        }
    }
}
