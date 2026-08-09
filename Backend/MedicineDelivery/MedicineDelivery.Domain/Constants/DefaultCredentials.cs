namespace MedicineDelivery.Domain.Constants
{
    /// <summary>
    /// Default credentials applied to staff accounts created by an administrator.
    /// </summary>
    public static class DefaultCredentials
    {
        /// <summary>
        /// Initial password assigned to Manager, Customer Support and Delivery Boy
        /// accounts when they are created. It is returned to the creating user so it
        /// can be handed to the staff member, who is expected to change it on first
        /// login. Chemists are not covered — they still get a generated password.
        /// </summary>
        public const string StaffPassword = "Pass@123";
    }
}
