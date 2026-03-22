import { useState } from 'react';
import { Box, TextField, Button, Typography, Alert, Checkbox, FormControlLabel, Link } from '@mui/material';
import { LocalPharmacy as LogoIcon } from '@mui/icons-material';
import { useNavigate, Link as RouterLink } from 'react-router-dom';
import { observer } from 'mobx-react-lite';
import { useStore } from '../../stores/StoreContext';

const LoginPage = observer(() => {
  const { authStore } = useStore();
  const navigate = useNavigate();
  const [mobile, setMobile] = useState('');
  const [password, setPassword] = useState('');
  const [remember, setRemember] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const success = await authStore.login(mobile, password, remember);
    if (success) {
      navigate(authStore.dashboardRoute);
    }
  };

  return (
    <Box component="form" onSubmit={handleSubmit}>
      <Box sx={{ textAlign: 'center', mb: 3 }}>
        <LogoIcon sx={{ fontSize: 48, color: '#4CAF50', mb: 1 }} />
        <Typography variant="h5" sx={{ fontWeight: 700 }}>
          Pharmaish
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Admin Portal - Sign In
        </Typography>
      </Box>

      {authStore.error && (
        <Alert severity="error" sx={{ mb: 2 }}>{authStore.error}</Alert>
      )}

      <TextField
        label="Mobile Number"
        value={mobile}
        onChange={(e) => setMobile(e.target.value)}
        fullWidth
        required
        sx={{ mb: 2 }}
        autoFocus
      />
      <TextField
        label="Password"
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        fullWidth
        required
        sx={{ mb: 2 }}
      />

      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
        <FormControlLabel
          control={<Checkbox checked={remember} onChange={(e) => setRemember(e.target.checked)} size="small" />}
          label={<Typography variant="body2">Remember me</Typography>}
        />
        <Link component={RouterLink} to="/forgot-password" variant="body2" underline="hover">
          Forgot Password?
        </Link>
      </Box>

      <Button
        type="submit"
        variant="contained"
        fullWidth
        size="large"
        disabled={authStore.isLoading}
        sx={{ py: 1.5 }}
      >
        {authStore.isLoading ? 'Signing in...' : 'Sign In'}
      </Button>
    </Box>
  );
});

export default LoginPage;
