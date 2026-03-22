import { useEffect } from 'react';
import { Box, Typography, Paper, Grid, Button, Alert } from '@mui/material';
import { ArrowBack as BackIcon } from '@mui/icons-material';
import { useParams, useNavigate } from 'react-router-dom';
import { observer } from 'mobx-react-lite';
import { useStore } from '../../stores/StoreContext';
import StatusBadge from '../../components/common/StatusBadge';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import AssignmentHistoryTimeline from '../../components/orders/AssignmentHistoryTimeline';
import { formatDateTime, formatCurrency } from '../../utils/formatters';
import { resolveDocUrl } from '../../utils/docUrl';

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

  const prescriptionUrl = resolveDocUrl(order.prescriptionFileUrl || order.orderInputFileLocation);
  const billUrl = resolveDocUrl(order.billFileUrl);

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

        {prescriptionUrl && (
          <Grid size={{ xs: 12, md: 6 }}>
            <Paper sx={{ p: 3 }}>
              <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>Prescription</Typography>
              <Box component="img" src={prescriptionUrl} alt="Prescription"
                sx={{ maxWidth: '100%', maxHeight: 300, borderRadius: 2, cursor: 'pointer' }}
                onClick={() => window.open(prescriptionUrl, '_blank')} />
            </Paper>
          </Grid>
        )}

        {billUrl && (
          <Grid size={{ xs: 12, md: 6 }}>
            <Paper sx={{ p: 3 }}>
              <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>Bill</Typography>
              <Box component="img" src={billUrl} alt="Bill"
                sx={{ maxWidth: '100%', maxHeight: 300, borderRadius: 2, cursor: 'pointer' }}
                onClick={() => window.open(billUrl, '_blank')} />
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
