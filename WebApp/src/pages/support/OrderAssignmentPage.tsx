import { useEffect, useState } from 'react';
import {
  Box, Typography, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, Paper, Button, Chip, Stack,
  Dialog, DialogTitle, DialogContent, DialogActions, Select, MenuItem,
  FormControl, InputLabel,
} from '@mui/material';
import { observer } from 'mobx-react-lite';
import { useStore } from '../../stores/StoreContext';
import { ordersApi } from '../../api/ordersApi';
import { medicalStoresApi } from '../../api/medicalStoresApi';
import StatusBadge from '../../components/common/StatusBadge';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import EmptyState from '../../components/common/EmptyState';
import { formatDateTime } from '../../utils/formatters';
import type { MedicalStoreDto } from '../../models/User';

const FILTERS = ['All', 'Pending', 'Active', 'Completed', 'Rejected'];

const OrderAssignmentPage = observer(() => {
  const { orderStore } = useStore();
  const [assignDialog, setAssignDialog] = useState<string | null>(null);
  const [chemists, setChemists] = useState<MedicalStoreDto[]>([]);
  const [selectedChemist, setSelectedChemist] = useState('');

  useEffect(() => {
    orderStore.fetchAllOrders();
    loadChemists();
  }, [orderStore]);

  const loadChemists = async () => {
    try {
      const res = await medicalStoresApi.getAll();
      const data = Array.isArray(res.data) ? res.data : res.data?.$values ?? res.data?.data ?? [];
      setChemists(data);
    } catch { /* ignore */ }
  };

  const handleAssign = async () => {
    if (!assignDialog || !selectedChemist) return;
    try {
      await ordersApi.accept(assignDialog); // Placeholder - actual assignment endpoint may differ
      await orderStore.fetchAllOrders();
      setAssignDialog(null);
      setSelectedChemist('');
    } catch { /* ignore */ }
  };

  return (
    <Box>
      <Typography variant="h5" sx={{ fontWeight: 700, mb: 2 }}>Order Assignments</Typography>

      <Stack direction="row" spacing={1} sx={{ mb: 3 }}>
        {FILTERS.map((label, i) => (
          <Chip key={label} label={label}
            variant={orderStore.filterIndex === i ? 'filled' : 'outlined'}
            color={orderStore.filterIndex === i ? 'primary' : 'default'}
            onClick={() => orderStore.setFilter(i)} />
        ))}
      </Stack>

      {orderStore.isLoading ? <LoadingSpinner /> : orderStore.filteredOrders.length === 0 ? <EmptyState message="No orders found" /> : (
        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow sx={{ bgcolor: '#f5f5f5' }}>
                <TableCell sx={{ fontWeight: 600 }}>Order #</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Date</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Status</TableCell>
                <TableCell sx={{ fontWeight: 600 }} align="right">Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {orderStore.filteredOrders.map((order) => (
                <TableRow key={order.orderId} hover>
                  <TableCell>{order.orderNumber || order.orderId.slice(0, 8)}</TableCell>
                  <TableCell>{formatDateTime(order.createdOn)}</TableCell>
                  <TableCell><StatusBadge status={order.status} /></TableCell>
                  <TableCell align="right">
                    {[0, 8].includes(order.status) && (
                      <Button size="small" variant="contained" onClick={() => setAssignDialog(order.orderId)}>
                        Assign to Chemist
                      </Button>
                    )}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      )}

      {/* Assign to Chemist Dialog */}
      <Dialog open={!!assignDialog} onClose={() => setAssignDialog(null)} maxWidth="sm" fullWidth>
        <DialogTitle>Assign Order to Chemist</DialogTitle>
        <DialogContent>
          <FormControl fullWidth sx={{ mt: 1 }}>
            <InputLabel>Select Chemist</InputLabel>
            <Select value={selectedChemist} label="Select Chemist" onChange={(e) => setSelectedChemist(e.target.value)}>
              {chemists.filter((c) => c.isActive).map((c) => (
                <MenuItem key={c.medicalStoreId} value={c.medicalStoreId}>
                  {c.medicalName} — {c.ownerFirstName} {c.ownerLastName}
                </MenuItem>
              ))}
            </Select>
          </FormControl>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setAssignDialog(null)}>Cancel</Button>
          <Button variant="contained" onClick={handleAssign} disabled={!selectedChemist}>Assign</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
});

export default OrderAssignmentPage;
