import { useEffect, useState } from 'react';
import { Box, Typography, Paper, Grid, Chip } from '@mui/material';
import { observer } from 'mobx-react-lite';
import { useStore } from '../../stores/StoreContext';
import { customerSupportsApi } from '../../api/customerSupportsApi';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import type { CustomerSupportDto } from '../../models/User';

const SupportProfilePage = observer(() => {
  const { authStore } = useStore();
  const [profile, setProfile] = useState<CustomerSupportDto | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const load = async () => {
      try {
        const res = await customerSupportsApi.getAll();
        const data = Array.isArray(res.data) ? res.data : res.data?.$values ?? res.data?.data ?? [];
        const mine = data.find((s: CustomerSupportDto) => s.userId === authStore.userId);
        setProfile(mine ?? null);
      } catch { /* ignore */ }
      setLoading(false);
    };
    load();
  }, [authStore.userId]);

  if (loading) return <LoadingSpinner message="Loading profile..." />;
  if (!profile) return <Typography>Profile not found.</Typography>;

  return (
    <Box sx={{ maxWidth: 600, mx: 'auto' }}>
      <Typography variant="h5" sx={{ fontWeight: 700, mb: 3 }}>Support Profile</Typography>
      <Paper sx={{ p: 3 }}>
        <Grid container spacing={2}>
          <Grid size={{ xs: 12 }}>
            <Typography variant="h6" sx={{ fontWeight: 600 }}>
              {profile.customerSupportFirstName} {profile.customerSupportLastName}
            </Typography>
            <Chip label={profile.isActive ? 'Active' : 'Inactive'} size="small" color={profile.isActive ? 'success' : 'default'} sx={{ mt: 0.5 }} />
          </Grid>
          <Grid size={{ xs: 12, sm: 6 }}>
            <Typography variant="caption" color="text.secondary">Employee ID</Typography>
            <Typography variant="body2" sx={{ fontWeight: 500 }}>{profile.employeeId ?? '—'}</Typography>
          </Grid>
          <Grid size={{ xs: 12, sm: 6 }}>
            <Typography variant="caption" color="text.secondary">Mobile</Typography>
            <Typography variant="body2" sx={{ fontWeight: 500 }}>{profile.mobileNumber}</Typography>
          </Grid>
          <Grid size={{ xs: 12, sm: 6 }}>
            <Typography variant="caption" color="text.secondary">Email</Typography>
            <Typography variant="body2" sx={{ fontWeight: 500 }}>{profile.emailId ?? '—'}</Typography>
          </Grid>
        </Grid>
      </Paper>
    </Box>
  );
});

export default SupportProfilePage;
