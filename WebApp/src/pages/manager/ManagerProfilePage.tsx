import { useEffect, useState } from 'react';
import { Box, Typography, Paper, Grid, Chip } from '@mui/material';
import { observer } from 'mobx-react-lite';
import { useStore } from '../../stores/StoreContext';
import { managersApi } from '../../api/managersApi';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import type { ManagerDto } from '../../models/User';

const ManagerProfilePage = observer(() => {
  const { authStore } = useStore();
  const [profile, setProfile] = useState<ManagerDto | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const load = async () => {
      try {
        const res = await managersApi.getAll();
        const managers = Array.isArray(res.data) ? res.data : res.data?.$values ?? res.data?.data ?? [];
        const mine = managers.find((m: ManagerDto) => m.userId === authStore.userId);
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
      <Typography variant="h5" sx={{ fontWeight: 700, mb: 3 }}>Manager Profile</Typography>
      <Paper sx={{ p: 3 }}>
        <Grid container spacing={2}>
          <Grid size={{ xs: 12 }}>
            <Typography variant="h6" sx={{ fontWeight: 600 }}>{profile.managerFirstName} {profile.managerLastName}</Typography>
            <Chip label={profile.isActive ? 'Active' : 'Inactive'} size="small" color={profile.isActive ? 'success' : 'default'} sx={{ mt: 0.5 }} />
          </Grid>
          <Grid size={{ xs: 12, sm: 6 }}><InfoField label="Employee ID" value={profile.employeeId ?? '—'} /></Grid>
          <Grid size={{ xs: 12, sm: 6 }}><InfoField label="Mobile" value={profile.mobileNumber} /></Grid>
          <Grid size={{ xs: 12, sm: 6 }}><InfoField label="Email" value={profile.emailId ?? '—'} /></Grid>
          <Grid size={{ xs: 12, sm: 6 }}><InfoField label="City" value={profile.city ?? '—'} /></Grid>
        </Grid>
      </Paper>
    </Box>
  );
});

function InfoField({ label, value }: { label: string; value: string }) {
  return (
    <Box>
      <Typography variant="caption" color="text.secondary">{label}</Typography>
      <Typography variant="body2" sx={{ fontWeight: 500 }}>{value}</Typography>
    </Box>
  );
}

export default ManagerProfilePage;
