import { useState } from 'react';
import { Box, TextField, Button, Typography, Alert, Link } from '@mui/material';
import { Link as RouterLink, useNavigate } from 'react-router-dom';
import { authApi } from '../../api/authApi';

export default function ResetPasswordPage() {
  const navigate = useNavigate();
  const [mobile, setMobile] = useState('');
  const [otp, setOtp] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (newPassword !== confirmPassword) { setError('Passwords do not match'); return; }
    setLoading(true); setError('');
    try {
      await authApi.resetPassword({ mobileNumber: mobile, otp, newPassword });
      navigate('/login');
    } catch {
      setError('Reset failed. Check your OTP and try again.');
    } finally { setLoading(false); }
  };

  return (
    <Box component="form" onSubmit={handleSubmit}>
      <Typography variant="h5" sx={{ fontWeight: 700, mb: 3 }}>Reset Password</Typography>
      {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}
      <TextField label="Mobile Number" value={mobile} onChange={(e) => setMobile(e.target.value)} fullWidth required sx={{ mb: 2 }} />
      <TextField label="OTP" value={otp} onChange={(e) => setOtp(e.target.value)} fullWidth required sx={{ mb: 2 }} />
      <TextField label="New Password" type="password" value={newPassword} onChange={(e) => setNewPassword(e.target.value)} fullWidth required sx={{ mb: 2 }} />
      <TextField label="Confirm Password" type="password" value={confirmPassword} onChange={(e) => setConfirmPassword(e.target.value)} fullWidth required sx={{ mb: 3 }} />
      <Button type="submit" variant="contained" fullWidth disabled={loading}>{loading ? 'Resetting...' : 'Reset Password'}</Button>
      <Box sx={{ textAlign: 'center', mt: 2 }}>
        <Link component={RouterLink} to="/login" variant="body2" underline="hover">Back to Login</Link>
      </Box>
    </Box>
  );
}
