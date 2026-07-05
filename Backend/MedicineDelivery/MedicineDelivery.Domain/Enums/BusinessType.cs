namespace MedicineDelivery.Domain.Enums
{
    /// <summary>
    /// Legal business type of a chemist (medical store), collected as part of KYC.
    /// Numeric values are fixed to match the reference KYC form's dropdown codes.
    /// </summary>
    public enum BusinessType
    {
        Proprietorship = 1,
        Partnership = 3,
        PrivateLimited = 4,
        PublicLimited = 5,
        LLP = 6,
        NGO = 7,
        Trust = 9,
        Society = 10,
        Individual = 11
    }
}
