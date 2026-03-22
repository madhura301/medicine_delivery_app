import {
  Drawer,
  List,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Toolbar,
  Box,
  Typography,
  Divider,
  Avatar,
} from '@mui/material';
import {
  Dashboard as DashboardIcon,
  People as PeopleIcon,
  ShoppingCart as OrdersIcon,
  Map as RegionsIcon,
  Description as ConsentsIcon,
  LocalPharmacy as ChemistIcon,
  Inventory as ManagerOrdersIcon,
  LocalShipping as DeliveryBoysIcon,
  Assignment as SupportIcon,
  Person as ProfileIcon,
  Lock as PasswordIcon,
  Logout as LogoutIcon,
} from '@mui/icons-material';
import { useNavigate, useLocation } from 'react-router-dom';
import { observer } from 'mobx-react-lite';
import { useStore } from '../stores/StoreContext';

const DRAWER_WIDTH = 260;

interface MenuItem {
  label: string;
  path: string;
  icon: React.ReactNode;
}

function getMenuItems(role: string): MenuItem[] {
  switch (role) {
    case 'Admin':
      return [
        { label: 'Dashboard', path: '/admin/dashboard', icon: <DashboardIcon /> },
        { label: 'User Management', path: '/admin/users', icon: <PeopleIcon /> },
        { label: 'All Orders', path: '/admin/orders', icon: <OrdersIcon /> },
        { label: 'Service Regions', path: '/admin/regions', icon: <RegionsIcon /> },
        { label: 'Consent Logs', path: '/admin/consent-logs', icon: <ConsentsIcon /> },
      ];
    case 'Chemist':
      return [
        { label: 'Dashboard', path: '/chemist/dashboard', icon: <DashboardIcon /> },
        { label: 'Orders', path: '/chemist/orders', icon: <OrdersIcon /> },
        { label: 'Profile', path: '/chemist/profile', icon: <ProfileIcon /> },
      ];
    case 'Manager':
      return [
        { label: 'Dashboard', path: '/manager/dashboard', icon: <DashboardIcon /> },
        { label: 'All Orders', path: '/manager/orders', icon: <ManagerOrdersIcon /> },
        { label: 'Delivery Boys', path: '/manager/delivery-boys', icon: <DeliveryBoysIcon /> },
        { label: 'Profile', path: '/manager/profile', icon: <ProfileIcon /> },
      ];
    case 'CustomerSupport':
      return [
        { label: 'Dashboard', path: '/support/dashboard', icon: <DashboardIcon /> },
        { label: 'Order Assignments', path: '/support/assignments', icon: <SupportIcon /> },
        { label: 'Profile', path: '/support/profile', icon: <ProfileIcon /> },
      ];
    default:
      return [];
  }
}

const Sidebar = observer(({ open }: { open: boolean }) => {
  const { authStore } = useStore();
  const navigate = useNavigate();
  const location = useLocation();

  const menuItems = getMenuItems(authStore.role ?? '');

  const bottomItems: MenuItem[] = [
    { label: 'Change Password', path: `/${authStore.role?.toLowerCase() === 'customersupport' ? 'support' : authStore.role?.toLowerCase()}/change-password`, icon: <PasswordIcon /> },
  ];

  const handleLogout = () => {
    authStore.logout();
    navigate('/login');
  };

  return (
    <Drawer
      variant="persistent"
      open={open}
      sx={{
        width: open ? DRAWER_WIDTH : 0,
        flexShrink: 0,
        '& .MuiDrawer-paper': {
          width: DRAWER_WIDTH,
          boxSizing: 'border-box',
          background: 'linear-gradient(180deg, #1a1a2e 0%, #16213e 100%)',
          color: '#fff',
        },
      }}
    >
      <Toolbar>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5, py: 1 }}>
          <ChemistIcon sx={{ color: '#4CAF50', fontSize: 32 }} />
          <Typography variant="h6" sx={{ fontWeight: 700, color: '#fff' }}>
            Pharmaish
          </Typography>
        </Box>
      </Toolbar>
      <Divider sx={{ borderColor: 'rgba(255,255,255,0.1)' }} />

      {/* User info */}
      <Box sx={{ px: 2, py: 2, display: 'flex', alignItems: 'center', gap: 1.5 }}>
        <Avatar sx={{ bgcolor: '#4CAF50', width: 36, height: 36 }}>
          {authStore.firstName?.[0]?.toUpperCase() ?? 'U'}
        </Avatar>
        <Box>
          <Typography variant="body2" sx={{ fontWeight: 600, color: '#fff' }}>
            {authStore.fullName || 'User'}
          </Typography>
          <Typography variant="caption" sx={{ color: 'rgba(255,255,255,0.6)' }}>
            {authStore.role}
          </Typography>
        </Box>
      </Box>
      <Divider sx={{ borderColor: 'rgba(255,255,255,0.1)' }} />

      {/* Menu items */}
      <List sx={{ flex: 1, px: 1 }}>
        {menuItems.map((item) => (
          <ListItemButton
            key={item.path}
            selected={location.pathname === item.path}
            onClick={() => navigate(item.path)}
            sx={{
              borderRadius: 2,
              mb: 0.5,
              '&.Mui-selected': { bgcolor: 'rgba(76,175,80,0.2)', '&:hover': { bgcolor: 'rgba(76,175,80,0.3)' } },
              '&:hover': { bgcolor: 'rgba(255,255,255,0.08)' },
            }}
          >
            <ListItemIcon sx={{ color: location.pathname === item.path ? '#4CAF50' : 'rgba(255,255,255,0.7)', minWidth: 40 }}>
              {item.icon}
            </ListItemIcon>
            <ListItemText primary={item.label} primaryTypographyProps={{ fontSize: 14 }} />
          </ListItemButton>
        ))}
      </List>

      <Divider sx={{ borderColor: 'rgba(255,255,255,0.1)' }} />
      <List sx={{ px: 1 }}>
        {bottomItems.map((item) => (
          <ListItemButton
            key={item.path}
            onClick={() => navigate(item.path)}
            sx={{ borderRadius: 2, mb: 0.5, '&:hover': { bgcolor: 'rgba(255,255,255,0.08)' } }}
          >
            <ListItemIcon sx={{ color: 'rgba(255,255,255,0.7)', minWidth: 40 }}>{item.icon}</ListItemIcon>
            <ListItemText primary={item.label} primaryTypographyProps={{ fontSize: 14 }} />
          </ListItemButton>
        ))}
        <ListItemButton
          onClick={handleLogout}
          sx={{ borderRadius: 2, '&:hover': { bgcolor: 'rgba(229,62,62,0.2)' } }}
        >
          <ListItemIcon sx={{ color: '#E53E3E', minWidth: 40 }}><LogoutIcon /></ListItemIcon>
          <ListItemText primary="Logout" primaryTypographyProps={{ fontSize: 14, color: '#E53E3E' }} />
        </ListItemButton>
      </List>
    </Drawer>
  );
});

export default Sidebar;
export { DRAWER_WIDTH };
