import { useEffect } from 'react';
import {
  Box, Typography, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, Paper, Chip, Avatar,
} from '@mui/material';
import { LocalShipping as DeliveryIcon } from '@mui/icons-material';
import { observer } from 'mobx-react-lite';
import { useStore } from '../../stores/StoreContext';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import EmptyState from '../../components/common/EmptyState';

const DeliveryBoysPage = observer(() => {
  const { userManagementStore } = useStore();

  useEffect(() => {
    userManagementStore.loadDeliveryBoys();
  }, [userManagementStore]);

  return (
    <Box>
      <Typography variant="h5" sx={{ fontWeight: 700, mb: 3 }}>Delivery Boys</Typography>

      {userManagementStore.isLoading ? <LoadingSpinner /> : userManagementStore.deliveryBoys.length === 0 ? <EmptyState message="No delivery boys found" /> : (
        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow sx={{ bgcolor: '#f5f5f5' }}>
                <TableCell sx={{ fontWeight: 600 }}>Name</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Mobile</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Driving License</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Status</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {userManagementStore.deliveryBoys.map((db) => (
                <TableRow key={db.deliveryId} hover>
                  <TableCell>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
                      <Avatar sx={{ bgcolor: '#00BCD4', width: 32, height: 32 }}>
                        <DeliveryIcon sx={{ fontSize: 18 }} />
                      </Avatar>
                      {db.deliveryFirstName} {db.deliveryLastName}
                    </Box>
                  </TableCell>
                  <TableCell>{db.mobileNumber}</TableCell>
                  <TableCell>{db.drivingLicenseNumber ?? '—'}</TableCell>
                  <TableCell>
                    <Chip label={db.isActive ? 'Active' : 'Inactive'} size="small"
                      color={db.isActive ? 'success' : 'default'} />
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      )}
    </Box>
  );
});

export default DeliveryBoysPage;
