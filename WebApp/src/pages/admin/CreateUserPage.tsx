import { useState } from 'react';
import {
  Box, Typography, Paper, TextField, Button, Alert, MenuItem,
  Grid, Card, CardContent, CardActionArea,
} from '@mui/material';
import {
  Person as CustomerIcon, SupportAgent as SupportIcon,
  LocalPharmacy as ChemistIcon, BusinessCenter as ManagerIcon,
  LocalShipping as DeliveryIcon,
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import { observer } from 'mobx-react-lite';
import { useStore } from '../../stores/StoreContext';

const ROLES = [
  { key: 'Customer', label: 'Customer', icon: <CustomerIcon />, color: '#4CAF50' },
  { key: 'CustomerSupport', label: 'Customer Support', icon: <SupportIcon />, color: '#1976D2' },
  { key: 'Chemist', label: 'Chemist / Medical Store', icon: <ChemistIcon />, color: '#9C27B0' },
  { key: 'Manager', label: 'Manager', icon: <ManagerIcon />, color: '#FF9800' },
  { key: 'DeliveryBoy', label: 'Delivery Boy', icon: <DeliveryIcon />, color: '#00BCD4' },
];

const CreateUserPage = observer(() => {
  const { userManagementStore } = useStore();
  const navigate = useNavigate();
  const [selectedRole, setSelectedRole] = useState('');
  const [form, setForm] = useState({
    mobileNumber: '', firstName: '', lastName: '', email: '', password: '',
    // Chemist-specific
    medicalName: '', dlNo: '', gstin: '',
    // Delivery-specific
    drivingLicenseNumber: '',
  });
  const [error, setError] = useState('');
  const [success, setSuccess] = useState(false);

  const updateField = (field: string, value: string) => {
    setForm((prev) => ({ ...prev, [field]: value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(''); setSuccess(false);
    const success = await userManagementStore.createUser({
      mobileNumber: form.mobileNumber,
      firstName: form.firstName,
      lastName: form.lastName,
      email: form.email,
      password: form.password,
      role: selectedRole,
      ...(selectedRole === 'Chemist' ? { medicalName: form.medicalName, dlNo: form.dlNo, gstin: form.gstin } : {}),
      ...(selectedRole === 'DeliveryBoy' ? { drivingLicenseNumber: form.drivingLicenseNumber } : {}),
    });
    if (success) {
      setSuccess(true);
      setTimeout(() => navigate('/admin/users'), 1500);
    } else {
      setError(userManagementStore.error);
    }
  };

  return (
    <Box sx={{ maxWidth: 700, mx: 'auto' }}>
      <Typography variant="h5" sx={{ fontWeight: 700, mb: 3 }}>Create New User</Typography>

      {!selectedRole ? (
        <>
          <Typography variant="body1" sx={{ mb: 2 }}>Select a role:</Typography>
          <Grid container spacing={2}>
            {ROLES.map((role) => (
              <Grid size={{ xs: 12, sm: 6, md: 4 }} key={role.key}>
                <Card>
                  <CardActionArea onClick={() => setSelectedRole(role.key)}>
                    <CardContent sx={{ textAlign: 'center', py: 3 }}>
                      <Box sx={{ color: role.color, mb: 1 }}>{role.icon}</Box>
                      <Typography variant="body1" sx={{ fontWeight: 600 }}>{role.label}</Typography>
                    </CardContent>
                  </CardActionArea>
                </Card>
              </Grid>
            ))}
          </Grid>
        </>
      ) : (
        <Paper sx={{ p: 3 }}>
          {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}
          {success && <Alert severity="success" sx={{ mb: 2 }}>User created successfully!</Alert>}

          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 3 }}>
            <Typography variant="body1">Role:</Typography>
            <MenuItem disabled sx={{ fontWeight: 600 }}>
              {ROLES.find((r) => r.key === selectedRole)?.label}
            </MenuItem>
            <Button size="small" onClick={() => setSelectedRole('')}>Change</Button>
          </Box>

          <Box component="form" onSubmit={handleSubmit}>
            <Grid container spacing={2}>
              <Grid size={{ xs: 12, sm: 6 }}>
                <TextField label="Mobile Number" value={form.mobileNumber} onChange={(e) => updateField('mobileNumber', e.target.value)} fullWidth required />
              </Grid>
              <Grid size={{ xs: 12, sm: 6 }}>
                <TextField label="Email" type="email" value={form.email} onChange={(e) => updateField('email', e.target.value)} fullWidth required />
              </Grid>
              <Grid size={{ xs: 12, sm: 6 }}>
                <TextField label="First Name" value={form.firstName} onChange={(e) => updateField('firstName', e.target.value)} fullWidth required />
              </Grid>
              <Grid size={{ xs: 12, sm: 6 }}>
                <TextField label="Last Name" value={form.lastName} onChange={(e) => updateField('lastName', e.target.value)} fullWidth required />
              </Grid>
              <Grid size={{ xs: 12 }}>
                <TextField label="Password" type="password" value={form.password} onChange={(e) => updateField('password', e.target.value)} fullWidth required />
              </Grid>

              {selectedRole === 'Chemist' && (
                <>
                  <Grid size={{ xs: 12, sm: 6 }}><TextField label="Medical Store Name" value={form.medicalName} onChange={(e) => updateField('medicalName', e.target.value)} fullWidth required /></Grid>
                  <Grid size={{ xs: 12, sm: 6 }}><TextField label="Drug License No" value={form.dlNo} onChange={(e) => updateField('dlNo', e.target.value)} fullWidth /></Grid>
                  <Grid size={{ xs: 12, sm: 6 }}><TextField label="GSTIN" value={form.gstin} onChange={(e) => updateField('gstin', e.target.value)} fullWidth /></Grid>
                </>
              )}

              {selectedRole === 'DeliveryBoy' && (
                <Grid size={{ xs: 12, sm: 6 }}>
                  <TextField label="Driving License Number" value={form.drivingLicenseNumber} onChange={(e) => updateField('drivingLicenseNumber', e.target.value)} fullWidth required />
                </Grid>
              )}
            </Grid>

            <Box sx={{ display: 'flex', gap: 2, mt: 3 }}>
              <Button variant="outlined" onClick={() => navigate('/admin/users')}>Cancel</Button>
              <Button type="submit" variant="contained" disabled={userManagementStore.isLoading}>
                {userManagementStore.isLoading ? 'Creating...' : 'Create User'}
              </Button>
            </Box>
          </Box>
        </Paper>
      )}
    </Box>
  );
});

export default CreateUserPage;
