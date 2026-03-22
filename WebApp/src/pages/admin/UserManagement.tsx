import { useEffect, useState } from 'react';
import {
  Box, Typography, Tabs, Tab, TextField, InputAdornment, Chip,
  Table, TableBody, TableCell, TableContainer, TableHead, TableRow,
  Paper, IconButton, Button, Stack,
} from '@mui/material';
import { Search as SearchIcon, Add as AddIcon, Delete as DeleteIcon } from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import { observer } from 'mobx-react-lite';
import { useStore } from '../../stores/StoreContext';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import EmptyState from '../../components/common/EmptyState';
import ConfirmDialog from '../../components/common/ConfirmDialog';

const TAB_LABELS = ['Customers', 'Cust. Support', 'Chemists', 'Managers', 'Delivery Boys'];
const FILTER_LABELS = ['All', 'Active', 'Inactive', 'Deleted'];

const UserManagement = observer(() => {
  const { userManagementStore } = useStore();
  const navigate = useNavigate();
  const [deleteTarget, setDeleteTarget] = useState<{ role: string; id: string; name: string } | null>(null);

  useEffect(() => {
    userManagementStore.loadAllUsers();
  }, [userManagementStore]);

  const getUsers = () => {
    const tab = userManagementStore.selectedTab;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    let users: any[] = [];
    switch (tab) {
      case 0: users = userManagementStore.customers; break;
      case 1: users = userManagementStore.supports; break;
      case 2: users = userManagementStore.chemists; break;
      case 3: users = userManagementStore.managers; break;
      case 4: users = userManagementStore.deliveryBoys; break;
    }

    // Filter
    let filtered = users;
    if (userManagementStore.filterIndex === 1) filtered = users.filter((u) => u.isActive);
    else if (userManagementStore.filterIndex === 2) filtered = users.filter((u) => !u.isActive && !u.isDeleted);
    else if (userManagementStore.filterIndex === 3) filtered = users.filter((u) => u.isDeleted);

    // Search
    if (userManagementStore.searchQuery) {
      const q = userManagementStore.searchQuery.toLowerCase();
      filtered = filtered.filter((u) => {
        const name = getDisplayName(u).toLowerCase();
        const email = String(u.emailId ?? '').toLowerCase();
        const mobile = String(u.mobileNumber ?? '').toLowerCase();
        return name.includes(q) || email.includes(q) || mobile.includes(q);
      });
    }
    return filtered;
  };

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const getDisplayName = (u: any) => {
    const tab = userManagementStore.selectedTab;
    if (tab === 0) return `${u.customerFirstName ?? ''} ${u.customerLastName ?? ''}`.trim();
    if (tab === 1) return `${u.customerSupportFirstName ?? ''} ${u.customerSupportLastName ?? ''}`.trim();
    if (tab === 2) return String(u.medicalName ?? `${u.ownerFirstName ?? ''} ${u.ownerLastName ?? ''}`.trim());
    if (tab === 3) return `${u.managerFirstName ?? ''} ${u.managerLastName ?? ''}`.trim();
    if (tab === 4) return `${u.deliveryFirstName ?? ''} ${u.deliveryLastName ?? ''}`.trim();
    return 'Unknown';
  };

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const getUserId = (u: any) => {
    return String(u.customerId ?? u.customerSupportId ?? u.medicalStoreId ?? u.managerId ?? u.deliveryId ?? '');
  };

  const getRoleKey = () => {
    return ['Customer', 'CustomerSupport', 'Chemist', 'Manager', 'DeliveryBoy'][userManagementStore.selectedTab];
  };

  const handleDelete = async () => {
    if (!deleteTarget) return;
    const success = await userManagementStore.deleteUser(deleteTarget.role, deleteTarget.id);
    if (success) await userManagementStore.loadAllUsers();
    setDeleteTarget(null);
  };

  const users = getUsers();

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Typography variant="h5" sx={{ fontWeight: 700 }}>User Management</Typography>
        <Button variant="contained" startIcon={<AddIcon />} onClick={() => navigate('/admin/users/create')}>
          Create User
        </Button>
      </Box>

      <Tabs
        value={userManagementStore.selectedTab}
        onChange={(_, v) => userManagementStore.setTab(v)}
        sx={{ mb: 2 }}
      >
        {TAB_LABELS.map((label) => <Tab key={label} label={label} />)}
      </Tabs>

      <Box sx={{ display: 'flex', gap: 2, mb: 2, flexWrap: 'wrap', alignItems: 'center' }}>
        <TextField
          placeholder="Search by name, email, mobile..."
          size="small"
          value={userManagementStore.searchQuery}
          onChange={(e) => userManagementStore.setSearch(e.target.value)}
          InputProps={{ startAdornment: <InputAdornment position="start"><SearchIcon /></InputAdornment> }}
          sx={{ minWidth: 300 }}
        />
        <Stack direction="row" spacing={1}>
          {FILTER_LABELS.map((label, i) => (
            <Chip
              key={label}
              label={label}
              variant={userManagementStore.filterIndex === i ? 'filled' : 'outlined'}
              color={userManagementStore.filterIndex === i ? 'primary' : 'default'}
              onClick={() => userManagementStore.setFilter(i)}
            />
          ))}
        </Stack>
      </Box>

      {userManagementStore.isLoading ? (
        <LoadingSpinner />
      ) : users.length === 0 ? (
        <EmptyState message="No users found" />
      ) : (
        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow sx={{ bgcolor: '#f5f5f5' }}>
                <TableCell sx={{ fontWeight: 600 }}>Name</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Mobile</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Email</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Status</TableCell>
                <TableCell sx={{ fontWeight: 600 }} align="right">Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {users.map((u) => {
                const user = u;
                const id = getUserId(user);
                return (
                  <TableRow key={id} hover>
                    <TableCell>{getDisplayName(user)}</TableCell>
                    <TableCell>{String(user.mobileNumber ?? '—')}</TableCell>
                    <TableCell>{String(user.emailId ?? '—')}</TableCell>
                    <TableCell>
                      <Chip
                        label={user.isDeleted ? 'Deleted' : user.isActive ? 'Active' : 'Inactive'}
                        size="small"
                        color={user.isDeleted ? 'error' : user.isActive ? 'success' : 'default'}
                      />
                    </TableCell>
                    <TableCell align="right">
                      <IconButton
                        size="small"
                        color="error"
                        onClick={() => setDeleteTarget({ role: getRoleKey(), id, name: getDisplayName(user) })}
                      >
                        <DeleteIcon fontSize="small" />
                      </IconButton>
                    </TableCell>
                  </TableRow>
                );
              })}
            </TableBody>
          </Table>
        </TableContainer>
      )}

      <ConfirmDialog
        open={!!deleteTarget}
        title="Delete User"
        message={`Are you sure you want to delete "${deleteTarget?.name}"?`}
        confirmLabel="Delete"
        confirmColor="error"
        onConfirm={handleDelete}
        onCancel={() => setDeleteTarget(null)}
      />
    </Box>
  );
});

export default UserManagement;
