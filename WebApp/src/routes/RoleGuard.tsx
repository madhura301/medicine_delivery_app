import { Navigate } from 'react-router-dom';
import { observer } from 'mobx-react-lite';
import { useStore } from '../stores/StoreContext';
import type { UserRole } from '../models/OrderEnums';

interface RoleGuardProps {
  allowedRoles: UserRole[];
  children: React.ReactNode;
}

const RoleGuard = observer(({ allowedRoles, children }: RoleGuardProps) => {
  const { authStore } = useStore();

  if (!authStore.isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  if (!authStore.role || !allowedRoles.includes(authStore.role)) {
    // Redirect to the user's correct dashboard
    return <Navigate to={authStore.dashboardRoute} replace />;
  }

  return <>{children}</>;
});

export default RoleGuard;
