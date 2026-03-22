import { useEffect, useState } from 'react';
import { Box, Typography, Paper, Grid, Chip } from '@mui/material';
import { observer } from 'mobx-react-lite';
import { useStore } from '../../stores/StoreContext';
import { medicalStoresApi } from '../../api/medicalStoresApi';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import type { MedicalStoreDto } from '../../models/User';

const ChemistProfilePage = observer(() => {
  const { authStore } = useStore();
  const [profile, setProfile] = useState<MedicalStoreDto | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const load = async () => {
      try {
        const res = await medicalStoresApi.getAll();
        const stores = Array.isArray(res.data) ? res.data : res.data?.$values ?? res.data?.data ?? [];
        const mine = stores.find((s: MedicalStoreDto) => s.userId === authStore.userId);
        setProfile(mine ?? null);
      } catch { /* ignore */ }
      setLoading(false);
    };
    load();
  }, [authStore.userId]);

  if (loading) return <LoadingSpinner message="Loading profile..." />;
  if (!profile) return <Typography>Profile not found.</Typography>;

  return (
    <Box sx={{ maxWidth: 700, mx: 'auto' }}>
      <Typography variant="h5" sx={{ fontWeight: 700, mb: 3 }}>Pharmacy Profile</Typography>
      <Paper sx={{ p: 3 }}>
        <Grid container spacing={2}>
          <Grid size={{ xs: 12 }}>
            <Typography variant="h6" sx={{ fontWeight: 600 }}>{profile.medicalName}</Typography>
            <Chip label={profile.isActive ? 'Active' : 'Inactive'} size="small" color={profile.isActive ? 'success' : 'default'} sx={{ mt: 0.5 }} />
          </Grid>
          <Grid size={{ xs: 12, sm: 6 }}><InfoField label="Owner" value={`${profile.ownerFirstName} ${profile.ownerLastName}`} /></Grid>
          <Grid size={{ xs: 12, sm: 6 }}><InfoField label="Mobile" value={profile.mobileNumber} /></Grid>
          <Grid size={{ xs: 12, sm: 6 }}><InfoField label="Email" value={profile.emailId ?? '—'} /></Grid>
          <Grid size={{ xs: 12, sm: 6 }}><InfoField label="City" value={profile.city ?? '—'} /></Grid>
          <Grid size={{ xs: 12, sm: 6 }}><InfoField label="DL No" value={profile.dlNo ?? '—'} /></Grid>
          <Grid size={{ xs: 12, sm: 6 }}><InfoField label="GSTIN" value={profile.gstin ?? '—'} /></Grid>
          <Grid size={{ xs: 12, sm: 6 }}><InfoField label="FSSAI" value={profile.fssaiNo ?? '—'} /></Grid>
          <Grid size={{ xs: 12, sm: 6 }}><InfoField label="PAN" value={profile.pan ?? '—'} /></Grid>
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

export default ChemistProfilePage;
