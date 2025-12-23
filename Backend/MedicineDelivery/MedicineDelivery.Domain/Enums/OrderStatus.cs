namespace MedicineDelivery.Domain.Enums
{
    public enum OrderStatus
    {
        PendingPayment = 0,
        AssignedToChemist = 1,
        RejectedByChemist = 2,
        AcceptedByChemist = 3,
        BillUploaded = 4,
        Paid = 5,
        OutForDelivery = 6,
        Completed = 7,
        AssignedToCustomerSupport = 8
    }
}

