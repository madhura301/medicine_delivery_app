import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { ThemeProvider } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { SnackbarProvider } from 'notistack';
import theme from './theme/muiTheme';
import { StoreContext } from './stores/StoreContext';
import { rootStore } from './stores/RootStore';

// Layouts
import AuthLayout from './layouts/AuthLayout';
import DashboardLayout from './layouts/DashboardLayout';
import RoleGuard from './routes/RoleGuard';

// Auth pages
import LoginPage from './pages/auth/LoginPage';
import ForgotPasswordPage from './pages/auth/ForgotPasswordPage';
import ResetPasswordPage from './pages/auth/ResetPasswordPage';
import ChangePasswordPage from './pages/auth/ChangePasswordPage';

// Admin pages
import AdminDashboard from './pages/admin/AdminDashboard';
import UserManagement from './pages/admin/UserManagement';
import CreateUserPage from './pages/admin/CreateUserPage';
import AllOrdersPage from './pages/admin/AllOrdersPage';
import OrderDetailsPage from './pages/admin/OrderDetailsPage';
import ServiceRegionsPage from './pages/admin/ServiceRegionsPage';
import ConsentLogsPage from './pages/admin/ConsentLogsPage';

// Chemist pages
import ChemistDashboard from './pages/chemist/ChemistDashboard';
import ChemistOrdersPage from './pages/chemist/ChemistOrdersPage';
import ChemistOrderDetailPage from './pages/chemist/ChemistOrderDetailPage';
import ChemistProfilePage from './pages/chemist/ChemistProfilePage';

// Manager pages
import ManagerDashboard from './pages/manager/ManagerDashboard';
import ManagerOrdersPage from './pages/manager/ManagerOrdersPage';
import ManagerOrderDetailPage from './pages/manager/ManagerOrderDetailPage';
import DeliveryBoysPage from './pages/manager/DeliveryBoysPage';
import ManagerProfilePage from './pages/manager/ManagerProfilePage';

// Support pages
import SupportDashboard from './pages/support/SupportDashboard';
import OrderAssignmentPage from './pages/support/OrderAssignmentPage';
import SupportProfilePage from './pages/support/SupportProfilePage';

function App() {
  return (
    <StoreContext.Provider value={rootStore}>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        <SnackbarProvider maxSnack={3} anchorOrigin={{ vertical: 'top', horizontal: 'right' }}>
          <BrowserRouter>
            <Routes>
              {/* Auth routes */}
              <Route element={<AuthLayout />}>
                <Route path="/login" element={<LoginPage />} />
                <Route path="/forgot-password" element={<ForgotPasswordPage />} />
                <Route path="/reset-password" element={<ResetPasswordPage />} />
              </Route>

              {/* Admin routes */}
              <Route element={<RoleGuard allowedRoles={['Admin']}><DashboardLayout /></RoleGuard>}>
                <Route path="/admin/dashboard" element={<AdminDashboard />} />
                <Route path="/admin/users" element={<UserManagement />} />
                <Route path="/admin/users/create" element={<CreateUserPage />} />
                <Route path="/admin/orders" element={<AllOrdersPage />} />
                <Route path="/admin/orders/:id" element={<OrderDetailsPage />} />
                <Route path="/admin/regions" element={<ServiceRegionsPage />} />
                <Route path="/admin/consent-logs" element={<ConsentLogsPage />} />
                <Route path="/admin/change-password" element={<ChangePasswordPage />} />
              </Route>

              {/* Chemist routes */}
              <Route element={<RoleGuard allowedRoles={['Chemist']}><DashboardLayout /></RoleGuard>}>
                <Route path="/chemist/dashboard" element={<ChemistDashboard />} />
                <Route path="/chemist/orders" element={<ChemistOrdersPage />} />
                <Route path="/chemist/orders/:id" element={<ChemistOrderDetailPage />} />
                <Route path="/chemist/profile" element={<ChemistProfilePage />} />
                <Route path="/chemist/change-password" element={<ChangePasswordPage />} />
              </Route>

              {/* Manager routes */}
              <Route element={<RoleGuard allowedRoles={['Manager']}><DashboardLayout /></RoleGuard>}>
                <Route path="/manager/dashboard" element={<ManagerDashboard />} />
                <Route path="/manager/orders" element={<ManagerOrdersPage />} />
                <Route path="/manager/orders/:id" element={<ManagerOrderDetailPage />} />
                <Route path="/manager/delivery-boys" element={<DeliveryBoysPage />} />
                <Route path="/manager/profile" element={<ManagerProfilePage />} />
                <Route path="/manager/change-password" element={<ChangePasswordPage />} />
              </Route>

              {/* Customer Support routes */}
              <Route element={<RoleGuard allowedRoles={['CustomerSupport']}><DashboardLayout /></RoleGuard>}>
                <Route path="/support/dashboard" element={<SupportDashboard />} />
                <Route path="/support/assignments" element={<OrderAssignmentPage />} />
                <Route path="/support/profile" element={<SupportProfilePage />} />
                <Route path="/support/change-password" element={<ChangePasswordPage />} />
              </Route>

              {/* Default redirect */}
              <Route path="/" element={<Navigate to="/login" replace />} />
              <Route path="*" element={<Navigate to="/login" replace />} />
            </Routes>
          </BrowserRouter>
        </SnackbarProvider>
      </ThemeProvider>
    </StoreContext.Provider>
  );
}

export default App;
