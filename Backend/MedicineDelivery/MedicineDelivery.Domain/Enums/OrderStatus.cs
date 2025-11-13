namespace MedicineDelivery.Domain.Enums
{
    public enum OrderStatus
    {
        PendingPayment = 0,
        Paid = 1,
        AssignedToChemist = 2,
        RejectedByChemist = 3,
        AcceptedByChemist = 4,
        BillUploaded = 5,
        OutForDelivery = 6,
        Completed = 7
    }
}

