import { useState } from 'react';
import { Box, TextField, Button, Typography, Alert, Link } from '@mui/material';
import { Link as RouterLink } from 'react-router-dom';
import { authApi } from '../../api/authApi';

export default function ForgotPasswordPage() {
  const [mobile, setMobile] = useState('');
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      await authApi.forgotPassword(mobile);
      setSuccess(true);
    } catch {
      setError('Failed to send reset link. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Box component="form" onSubmit={handleSubmit}>
      <Typography variant="h5" sx={{ fontWeight: 700, mb: 1 }}>Forgot Password</Typography>
      <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
        Enter your mobile number to receive a reset OTP.
      </Typography>

      {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}
      {success && <Alert severity="success" sx={{ mb: 2 }}>OTP sent! Check your mobile.</Alert>}

      <TextField
        label="Mobile Number"
        value={mobile}
        onChange={(e) => setMobile(e.target.value)}
        fullWidth required sx={{ mb: 3 }}
      />

      <Button type="submit" variant="contained" fullWidth disabled={loading} sx={{ mb: 2 }}>
        {loading ? 'Sending...' : 'Send Reset OTP'}
      </Button>

      <Box sx={{ textAlign: 'center' }}>
        <Link component={RouterLink} to="/login" variant="body2" underline="hover">
          Back to Login
        </Link>
      </Box>
    </Box>
  );
}
