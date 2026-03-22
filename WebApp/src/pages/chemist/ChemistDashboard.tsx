import { useEffect } from 'react';
import { Box, Grid, Typography } from '@mui/material';
import {
  HourglassEmpty as PendingIcon,
  CheckCircle as AcceptedIcon,
  Done as CompletedIcon,
  Cancel as RejectedIcon,
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import { observer } from 'mobx-react-lite';
import { useStore } from '../../stores/StoreContext';
import StatCard from '../../components/common/StatCard';
import LoadingSpinner from '../../components/common/LoadingSpinner';

const ChemistDashboard = observer(() => {
  const { authStore, chemistStore } = useStore();
  const navigate = useNavigate();

  useEffect(() => {
    // The medicalStoreId comes from the userId - we use a lookup approach
    // For chemist, the backend /Orders/medical-store/my-orders uses JWT userId
    if (authStore.userId) {
      chemistStore.fetchMyOrders(authStore.userId);
    }
  }, [authStore.userId, chemistStore]);

  if (chemistStore.isLoading) return <LoadingSpinner message="Loading dashboard..." />;

  const counts = chemistStore.orderCounts;

  return (
    <Box>
      <Typography variant="h5" sx={{ fontWeight: 700, mb: 0.5 }}>
        Welcome, {authStore.firstName}!
      </Typography>
      <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
        Manage your pharmacy orders.
      </Typography>

      <Grid container spacing={3} sx={{ mb: 4 }}>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatCard title="Pending" value={counts.pending} icon={<PendingIcon sx={{ fontSize: 28 }} />} color="#FF9800"
            onClick={() => navigate('/chemist/orders')} />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatCard title="Accepted" value={counts.accepted} icon={<AcceptedIcon sx={{ fontSize: 28 }} />} color="#4CAF50" />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatCard title="Completed" value={counts.completed} icon={<CompletedIcon sx={{ fontSize: 28 }} />} color="#1976D2" />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatCard title="Rejected" value={counts.rejected} icon={<RejectedIcon sx={{ fontSize: 28 }} />} color="#E53E3E" />
        </Grid>
      </Grid>

      {/* Recent pending orders */}
      <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>Recent Pending Orders</Typography>
      {chemistStore.pendingOrders.length === 0 ? (
        <Typography variant="body2" color="text.secondary">No pending orders.</Typography>
      ) : (
        <Grid container spacing={2}>
          {chemistStore.pendingOrders.slice(0, 5).map((order) => {
            const customer = chemistStore.customerCache.get(order.customerId);
            return (
              <Grid size={{ xs: 12, md: 6 }} key={order.orderId}>
                <Box
                  sx={{ p: 2, border: '1px solid #e0e0e0', borderRadius: 2, cursor: 'pointer', '&:hover': { bgcolor: '#f5f5f5' } }}
                  onClick={() => navigate(`/chemist/orders/${order.orderId}`)}
                >
                  <Typography variant="body2" sx={{ fontWeight: 600 }}>
                    #{order.orderNumber || order.orderId.slice(0, 8)}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Customer: {customer ? `${customer.customerFirstName} ${customer.customerLastName}` : 'Loading...'}
                  </Typography>
                </Box>
              </Grid>
            );
          })}
        </Grid>
      )}
    </Box>
  );
});

export default ChemistDashboard;
