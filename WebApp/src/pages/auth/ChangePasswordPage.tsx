import { useState } from 'react';
import { Box, TextField, Button, Typography, Alert, Paper } from '@mui/material';
import { observer } from 'mobx-react-lite';
import { useStore } from '../../stores/StoreContext';
import { authApi } from '../../api/authApi';

const ChangePasswordPage = observer(() => {
  const { authStore } = useStore();
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState(false);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (newPassword !== confirmPassword) { setError('Passwords do not match'); return; }
    setLoading(true); setError(''); setSuccess(false);
    try {
      await authApi.changePassword({
        mobileNumber: authStore.mobileNumber,
        currentPassword,
        newPassword,
      });
      setSuccess(true);
      setCurrentPassword(''); setNewPassword(''); setConfirmPassword('');
    } catch {
      setError('Failed to change password. Check your current password.');
    } finally { setLoading(false); }
  };

  return (
    <Box sx={{ maxWidth: 500, mx: 'auto' }}>
      <Typography variant="h5" sx={{ fontWeight: 700, mb: 3 }}>Change Password</Typography>
      <Paper sx={{ p: 3 }}>
        {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}
        {success && <Alert severity="success" sx={{ mb: 2 }}>Password changed successfully!</Alert>}
        <Box component="form" onSubmit={handleSubmit}>
          <TextField label="Current Password" type="password" value={currentPassword} onChange={(e) => setCurrentPassword(e.target.value)} fullWidth required sx={{ mb: 2 }} />
          <TextField label="New Password" type="password" value={newPassword} onChange={(e) => setNewPassword(e.target.value)} fullWidth required sx={{ mb: 2 }} />
          <TextField label="Confirm New Password" type="password" value={confirmPassword} onChange={(e) => setConfirmPassword(e.target.value)} fullWidth required sx={{ mb: 3 }} />
          <Button type="submit" variant="contained" fullWidth disabled={loading}>
            {loading ? 'Updating...' : 'Update Password'}
          </Button>
        </Box>
      </Paper>
    </Box>
  );
});

export default ChangePasswordPage;
