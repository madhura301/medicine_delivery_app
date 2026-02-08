namespace MedicineDelivery.Domain.Exceptions
{
    public class PaymentIncompleteException : Exception
    {
        public int OrderId { get; }
        public decimal TotalAmount { get; }
        public decimal PaidAmount { get; }
        public decimal RemainingAmount => TotalAmount - PaidAmount;

        public PaymentIncompleteException(int orderId, decimal totalAmount, decimal paidAmount)
            : base($"Cannot complete order {orderId}. Payment incomplete. " +
                   $"Total: {totalAmount:C}, Paid: {paidAmount:C}, Remaining: {totalAmount - paidAmount:C}")
        {
            OrderId = orderId;
            TotalAmount = totalAmount;
            PaidAmount = paidAmount;
        }
    }
}
