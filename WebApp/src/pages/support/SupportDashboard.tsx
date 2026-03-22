import { useEffect, useState } from 'react';
import { Box, Grid, Typography } from '@mui/material';
import {
  Assignment as OrdersIcon,
  HourglassEmpty as PendingIcon,
  CheckCircle as ResolvedIcon,
  TrendingUp as TotalIcon,
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import { observer } from 'mobx-react-lite';
import { useStore } from '../../stores/StoreContext';
import StatCard from '../../components/common/StatCard';
import LoadingSpinner from '../../components/common/LoadingSpinner';

const SupportDashboard = observer(() => {
  const { authStore, orderStore } = useStore();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    orderStore.fetchAllOrders().then(() => setLoading(false));
  }, [orderStore]);

  if (loading) return <LoadingSpinner message="Loading dashboard..." />;

  const orders = orderStore.orders;
  const assignedToSupport = orders.filter((o) => o.status === 8).length;
  const pending = orders.filter((o) => [0, 1].includes(o.status)).length;
  const completed = orders.filter((o) => o.status === 7).length;

  return (
    <Box>
      <Typography variant="h5" sx={{ fontWeight: 700, mb: 0.5 }}>
        Welcome, {authStore.firstName}!
      </Typography>
      <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
        Customer Support Dashboard
      </Typography>

      <Grid container spacing={3} sx={{ mb: 4 }}>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatCard title="Total Orders" value={orders.length} icon={<TotalIcon sx={{ fontSize: 28 }} />} color="#1976D2" />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatCard title="Assigned to Support" value={assignedToSupport} icon={<OrdersIcon sx={{ fontSize: 28 }} />} color="#FF9800"
            onClick={() => navigate('/support/assignments')} />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatCard title="Pending" value={pending} icon={<PendingIcon sx={{ fontSize: 28 }} />} color="#E53E3E" />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatCard title="Completed" value={completed} icon={<ResolvedIcon sx={{ fontSize: 28 }} />} color="#4CAF50" />
        </Grid>
      </Grid>

      <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>Quick Actions</Typography>
      <Grid container spacing={2}>
        <Grid size={{ xs: 12, sm: 6 }}>
          <Box
            onClick={() => navigate('/support/assignments')}
            sx={{
              p: 3, borderRadius: 2, textAlign: 'center', cursor: 'pointer',
              bgcolor: '#FF980010', border: '1px solid #FF980030',
              '&:hover': { bgcolor: '#FF980020' }, transition: 'all 0.2s',
            }}
          >
            <Typography sx={{ fontWeight: 600, color: '#FF9800' }}>Manage Order Assignments</Typography>
          </Box>
        </Grid>
      </Grid>
    </Box>
  );
});

export default SupportDashboard;
