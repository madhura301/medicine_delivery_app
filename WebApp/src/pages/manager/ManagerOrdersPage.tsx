import { useEffect } from 'react';
import {
  Box, Typography, Chip, Stack, Table, TableBody, TableCell,
  TableContainer, TableHead, TableRow, Paper, IconButton,
} from '@mui/material';
import { Visibility as ViewIcon } from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import { observer } from 'mobx-react-lite';
import { useStore } from '../../stores/StoreContext';
import StatusBadge from '../../components/common/StatusBadge';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import EmptyState from '../../components/common/EmptyState';
import { formatDateTime, formatCurrency } from '../../utils/formatters';

const FILTERS = ['All', 'Pending', 'Active', 'Completed', 'Rejected'];

const ManagerOrdersPage = observer(() => {
  const { orderStore } = useStore();
  const navigate = useNavigate();

  useEffect(() => {
    orderStore.fetchAllOrders();
  }, [orderStore]);

  return (
    <Box>
      <Typography variant="h5" sx={{ fontWeight: 700, mb: 2 }}>All Orders</Typography>

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
                <TableCell sx={{ fontWeight: 600 }}>Amount</TableCell>
                <TableCell sx={{ fontWeight: 600 }} align="right">View</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {orderStore.filteredOrders.map((order) => (
                <TableRow key={order.orderId} hover>
                  <TableCell>{order.orderNumber || order.orderId.slice(0, 8)}</TableCell>
                  <TableCell>{formatDateTime(order.createdOn)}</TableCell>
                  <TableCell><StatusBadge status={order.status} /></TableCell>
                  <TableCell>{formatCurrency(order.totalAmount)}</TableCell>
                  <TableCell align="right">
                    <IconButton size="small" onClick={() => navigate(`/manager/orders/${order.orderId}`)}>
                      <ViewIcon fontSize="small" />
                    </IconButton>
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

export default ManagerOrdersPage;
