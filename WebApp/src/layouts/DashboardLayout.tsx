import { Box, AppBar, Toolbar, IconButton, Typography } from '@mui/material';
import { Menu as MenuIcon } from '@mui/icons-material';
import { Outlet } from 'react-router-dom';
import { observer } from 'mobx-react-lite';
import { useStore } from '../stores/StoreContext';
import Sidebar, { DRAWER_WIDTH } from './Sidebar';

const DashboardLayout = observer(() => {
  const { uiStore } = useStore();

  return (
    <Box sx={{ display: 'flex', minHeight: '100vh' }}>
      <Sidebar open={uiStore.sidebarOpen} />
      <Box
        sx={{
          flexGrow: 1,
          ml: uiStore.sidebarOpen ? 0 : `-${DRAWER_WIDTH}px`,
          transition: 'margin 0.3s',
          display: 'flex',
          flexDirection: 'column',
        }}
      >
        <AppBar position="sticky" elevation={0} sx={{ bgcolor: '#fff', color: '#000', borderBottom: '1px solid #e0e0e0' }}>
          <Toolbar>
            <IconButton edge="start" onClick={() => uiStore.toggleSidebar()} sx={{ mr: 2 }}>
              <MenuIcon />
            </IconButton>
            <Typography variant="h6" sx={{ fontWeight: 600 }}>
              Pharmaish Admin Portal
            </Typography>
          </Toolbar>
        </AppBar>
        <Box component="main" sx={{ flex: 1, p: 3, bgcolor: '#f5f5f5' }}>
          <Outlet />
        </Box>
      </Box>
    </Box>
  );
});

export default DashboardLayout;
