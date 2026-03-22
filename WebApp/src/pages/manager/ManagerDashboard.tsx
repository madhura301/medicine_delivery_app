import { useEffect, useState } from 'react';
import { Box, Grid, Typography } from '@mui/material';
import {
  Receipt as ReceiptIcon,
  HourglassEmpty as PendingIcon,
  LocalShipping as DeliveryIcon,
  CheckCircle as CompletedIcon,
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import { observer } from 'mobx-react-lite';
import { useStore } from '../../stores/StoreContext';
import StatCard from '../../components/common/StatCard';
import LoadingSpinner from '../../components/common/LoadingSpinner';

const ManagerDashboard = observer(() => {
  const { authStore, orderStore } = useStore();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    orderStore.fetchAllOrders().then(() => setLoading(false));
  }, [orderStore]);

  if (loading) return <LoadingSpinner message="Loading dashboard..." />;

  const orders = orderStore.orders;
  const pending = orders.filter((o) => [0, 1, 8].includes(o.status)).length;
  const inDelivery = orders.filter((o) => o.status === 6).length;
  const today = new Date().toDateString();
  const completedToday = orders.filter((o) => o.status === 7 && o.completedOn && new Date(o.completedOn).toDateString() === today).length;

  return (
    <Box>
      <Typography variant="h5" sx={{ fontWeight: 700, mb: 0.5 }}>
        Welcome back, {authStore.firstName}!
      </Typography>
      <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
        {new Date().toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
      </Typography>

      <Grid container spacing={3} sx={{ mb: 4 }}>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatCard title="Total Orders" value={orders.length} icon={<ReceiptIcon sx={{ fontSize: 28 }} />} color="#1976D2"
            onClick={() => navigate('/manager/orders')} />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatCard title="Pending Orders" value={pending} icon={<PendingIcon sx={{ fontSize: 28 }} />} color="#FF9800" />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatCard title="In Delivery" value={inDelivery} icon={<DeliveryIcon sx={{ fontSize: 28 }} />} color="#9C27B0" />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatCard title="Completed Today" value={completedToday} icon={<CompletedIcon sx={{ fontSize: 28 }} />} color="#4CAF50" />
        </Grid>
      </Grid>

      <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>Quick Actions</Typography>
      <Grid container spacing={2}>
        {[
          { label: 'View All Orders', path: '/manager/orders', color: '#1976D2' },
          { label: 'Delivery Boys', path: '/manager/delivery-boys', color: '#9C27B0' },
        ].map((action) => (
          <Grid size={{ xs: 12, sm: 6, md: 4 }} key={action.path}>
            <Box
              onClick={() => navigate(action.path)}
              sx={{
                p: 3, borderRadius: 2, textAlign: 'center', cursor: 'pointer',
                bgcolor: `${action.color}10`, border: `1px solid ${action.color}30`,
                '&:hover': { bgcolor: `${action.color}20` }, transition: 'all 0.2s',
              }}
            >
              <Typography sx={{ fontWeight: 600, color: action.color }}>{action.label}</Typography>
            </Box>
          </Grid>
        ))}
      </Grid>
    </Box>
  );
});

export default ManagerDashboard;
