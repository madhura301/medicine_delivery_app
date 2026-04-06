import { useEffect } from 'react';
import { Box, Typography, Paper, Grid, Divider, Button, Alert } from '@mui/material';
import { ArrowBack as BackIcon, Download as DownloadIcon } from '@mui/icons-material';
import { useParams, useNavigate } from 'react-router-dom';
import { observer } from 'mobx-react-lite';
import { useStore } from '../../stores/StoreContext';
import StatusBadge from '../../components/common/StatusBadge';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import AssignmentHistoryTimeline from '../../components/orders/AssignmentHistoryTimeline';
import { formatDateTime, formatCurrency } from '../../utils/formatters';
import { OrderInputTypeLabel, OrderTypeLabel } from '../../models/OrderEnums';
import { getOrderInputFileApiPath, getOrderBillApiPath, downloadPrescriptionImage, downloadBillFile } from '../../utils/docUrl';
import AuthImage from '../../components/common/AuthImage';

const OrderDetailsPage = observer(() => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { orderStore } = useStore();

  useEffect(() => {
    if (id) orderStore.fetchOrderById(id);
  }, [id, orderStore]);

  const order = orderStore.currentOrder;

  if (orderStore.isLoading) return <LoadingSpinner message="Loading order details..." />;
  if (!order) return <Alert severity="error">Order not found</Alert>;

  const hasPrescription = !!(order.prescriptionFileUrl || order.orderInputFileLocation);
  const prescriptionApiPath = getOrderInputFileApiPath(order.orderId);
  const hasBill = !!order.billFileUrl;
  const billApiPath = getOrderBillApiPath(order.orderId);

  return (
    <Box>
      <Button startIcon={<BackIcon />} onClick={() => navigate(-1)} sx={{ mb: 2 }}>
        Back
      </Button>

      {/* Status Banner */}
      <Paper sx={{ p: 3, mb: 3, bgcolor: '#f8f9fa' }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Box>
            <Typography variant="h6" sx={{ fontWeight: 700 }}>
              Order #{order.orderNumber || order.orderId.slice(0, 8)}
            </Typography>
            <Typography variant="body2" color="text.secondary">
              {formatDateTime(order.createdOn)}
            </Typography>
          </Box>
          <StatusBadge status={order.status} />
        </Box>
      </Paper>

      <Grid container spacing={3}>
        {/* Order Info */}
        <Grid size={{ xs: 12, md: 6 }}>
          <Paper sx={{ p: 3 }}>
            <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>Order Information</Typography>
            <InfoRow label="Order Type" value={OrderTypeLabel[order.orderType] ?? 'N/A'} />
            <InfoRow label="Input Type" value={OrderInputTypeLabel[order.orderInputType] ?? 'N/A'} />
            <InfoRow label="Amount" value={formatCurrency(order.totalAmount)} />
            {order.completedOn && <InfoRow label="Completed" value={formatDateTime(order.completedOn)} />}
            {order.rejectionReason && (
              <Alert severity="error" sx={{ mt: 2 }}>
                Rejection Reason: {order.rejectionReason}
              </Alert>
            )}
          </Paper>
        </Grid>

        {/* Customer Info */}
        <Grid size={{ xs: 12, md: 6 }}>
          <Paper sx={{ p: 3 }}>
            <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>Customer Details</Typography>
            {orderStore.currentCustomer ? (
              <>
                <InfoRow label="Name" value={`${orderStore.currentCustomer.customerFirstName} ${orderStore.currentCustomer.customerLastName}`} />
                <InfoRow label="Mobile" value={orderStore.currentCustomer.mobileNumber} />
                <InfoRow label="Email" value={orderStore.currentCustomer.emailId ?? '—'} />
              </>
            ) : (
              <Typography variant="body2" color="text.secondary">Loading customer info...</Typography>
            )}
          </Paper>
        </Grid>

        {/* Chemist Info */}
        {orderStore.currentChemist && (
          <Grid size={{ xs: 12, md: 6 }}>
            <Paper sx={{ p: 3 }}>
              <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>Chemist Details</Typography>
              <InfoRow label="Store Name" value={orderStore.currentChemist.medicalName} />
              <InfoRow label="Owner" value={`${orderStore.currentChemist.ownerFirstName} ${orderStore.currentChemist.ownerLastName}`} />
              <InfoRow label="Mobile" value={orderStore.currentChemist.mobileNumber} />
              <InfoRow label="City" value={orderStore.currentChemist.city ?? '—'} />
            </Paper>
          </Grid>
        )}

        {/* Shipping Address */}
        {order.shippingAddressLine1 && (
          <Grid size={{ xs: 12, md: 6 }}>
            <Paper sx={{ p: 3 }}>
              <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>Delivery Address</Typography>
              <Typography variant="body2">{order.shippingAddressLine1}</Typography>
              {order.shippingAddressLine2 && <Typography variant="body2">{order.shippingAddressLine2}</Typography>}
              <Typography variant="body2">{order.shippingCity} - {order.shippingPincode}</Typography>
            </Paper>
          </Grid>
        )}

        {/* Prescription */}
        {hasPrescription && (
          <Grid size={{ xs: 12, md: 6 }}>
            <Paper sx={{ p: 3 }}>
              <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>Prescription</Typography>
              <AuthImage
                src={prescriptionApiPath}
                alt="Prescription"
                sx={{ maxWidth: '100%', maxHeight: 300, borderRadius: 2 }}
              />
              <Box sx={{ textAlign: 'center', mt: 1 }}>
                <Button startIcon={<DownloadIcon />} size="small"
                  onClick={() => downloadPrescriptionImage(order.orderId, order.prescriptionFileUrl || order.orderInputFileLocation)}>
                  Download
                </Button>
              </Box>
            </Paper>
          </Grid>
        )}

        {/* Bill */}
        {hasBill && (
          <Grid size={{ xs: 12, md: 6 }}>
            <Paper sx={{ p: 3 }}>
              <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>Bill</Typography>
              <AuthImage
                src={billApiPath}
                alt="Bill"
                sx={{ maxWidth: '100%', maxHeight: 300, borderRadius: 2 }}
              />
              <Box sx={{ textAlign: 'center', mt: 1 }}>
                <Button startIcon={<DownloadIcon />} size="small"
                  onClick={() => downloadBillFile(order.orderId, order.billFileUrl)}>
                  Download
                </Button>
              </Box>
            </Paper>
          </Grid>
        )}

        {/* Assignment History */}
        <Grid size={{ xs: 12 }}>
          <Paper sx={{ p: 3 }}>
            <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>Assignment History</Typography>
            <Divider sx={{ mb: 2 }} />
            <AssignmentHistoryTimeline history={order.assignmentHistory} />
          </Paper>
        </Grid>
      </Grid>
    </Box>
  );
});

function InfoRow({ label, value }: { label: string; value: string }) {
  return (
    <Box sx={{ display: 'flex', justifyContent: 'space-between', py: 0.75 }}>
      <Typography variant="body2" color="text.secondary">{label}</Typography>
      <Typography variant="body2" sx={{ fontWeight: 500 }}>{value}</Typography>
    </Box>
  );
}

export default OrderDetailsPage;
