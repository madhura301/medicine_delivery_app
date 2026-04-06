import { useEffect } from 'react';
import { Box, Typography, Paper, Grid, Button, Alert } from '@mui/material';
import { ArrowBack as BackIcon, Download as DownloadIcon } from '@mui/icons-material';
import { useParams, useNavigate } from 'react-router-dom';
import { observer } from 'mobx-react-lite';
import { useStore } from '../../stores/StoreContext';
import StatusBadge from '../../components/common/StatusBadge';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import AssignmentHistoryTimeline from '../../components/orders/AssignmentHistoryTimeline';
import { formatDateTime, formatCurrency } from '../../utils/formatters';
import { getOrderInputFileApiPath, getOrderBillApiPath, downloadPrescriptionImage, downloadBillFile } from '../../utils/docUrl';
import AuthImage from '../../components/common/AuthImage';

const ChemistOrderDetailPage = observer(() => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { orderStore } = useStore();

  useEffect(() => {
    if (id) orderStore.fetchOrderById(id);
  }, [id, orderStore]);

  const order = orderStore.currentOrder;

  if (orderStore.isLoading) return <LoadingSpinner message="Loading order..." />;
  if (!order) return <Alert severity="error">Order not found</Alert>;

  const hasPrescription = !!(order.prescriptionFileUrl || order.orderInputFileLocation);
  const prescriptionApiPath = getOrderInputFileApiPath(order.orderId);
  const hasBill = !!order.billFileUrl;
  const billApiPath = getOrderBillApiPath(order.orderId);

  return (
    <Box>
      <Button startIcon={<BackIcon />} onClick={() => navigate(-1)} sx={{ mb: 2 }}>Back</Button>

      <Paper sx={{ p: 3, mb: 3 }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Typography variant="h6" sx={{ fontWeight: 700 }}>
            Order #{order.orderNumber || order.orderId.slice(0, 8)}
          </Typography>
          <StatusBadge status={order.status} />
        </Box>
        <Typography variant="body2" color="text.secondary">{formatDateTime(order.createdOn)}</Typography>
        {order.totalAmount != null && (
          <Typography variant="h6" sx={{ mt: 1, color: '#2E7D32' }}>{formatCurrency(order.totalAmount)}</Typography>
        )}
      </Paper>

      <Grid container spacing={3}>
        {orderStore.currentCustomer && (
          <Grid size={{ xs: 12, md: 6 }}>
            <Paper sx={{ p: 3 }}>
              <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>Customer</Typography>
              <Typography variant="body2">{orderStore.currentCustomer.customerFirstName} {orderStore.currentCustomer.customerLastName}</Typography>
              <Typography variant="body2" color="text.secondary">{orderStore.currentCustomer.mobileNumber}</Typography>
              <Typography variant="body2" color="text.secondary">{orderStore.currentCustomer.emailId}</Typography>
            </Paper>
          </Grid>
        )}

        {hasPrescription && (
          <Grid size={{ xs: 12, md: 6 }}>
            <Paper sx={{ p: 3 }}>
              <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>Prescription</Typography>
              <AuthImage src={prescriptionApiPath} alt="Prescription"
                sx={{ maxWidth: '100%', maxHeight: 300, borderRadius: 2 }} />
              <Box sx={{ textAlign: 'center', mt: 1 }}>
                <Button startIcon={<DownloadIcon />} size="small"
                  onClick={() => downloadPrescriptionImage(order.orderId, order.prescriptionFileUrl || order.orderInputFileLocation)}>
                  Download
                </Button>
              </Box>
            </Paper>
          </Grid>
        )}

        {hasBill && (
          <Grid size={{ xs: 12, md: 6 }}>
            <Paper sx={{ p: 3 }}>
              <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>Bill</Typography>
              <AuthImage src={billApiPath} alt="Bill"
                sx={{ maxWidth: '100%', maxHeight: 300, borderRadius: 2 }} />
              <Box sx={{ textAlign: 'center', mt: 1 }}>
                <Button startIcon={<DownloadIcon />} size="small"
                  onClick={() => downloadBillFile(order.orderId, order.billFileUrl)}>
                  Download
                </Button>
              </Box>
            </Paper>
          </Grid>
        )}

        {order.rejectionReason && (
          <Grid size={{ xs: 12 }}>
            <Alert severity="error">Rejection Reason: {order.rejectionReason}</Alert>
          </Grid>
        )}

        <Grid size={{ xs: 12 }}>
          <Paper sx={{ p: 3 }}>
            <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>Assignment History</Typography>
            <AssignmentHistoryTimeline history={order.assignmentHistory} />
          </Paper>
        </Grid>
      </Grid>
    </Box>
  );
});

export default ChemistOrderDetailPage;
