import { useEffect, useState } from 'react';
import {
  Box, Typography, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, Paper, Button, Chip, Stack,
  Dialog, DialogTitle, DialogContent, DialogActions,
  Radio, RadioGroup, FormControlLabel, Alert, CircularProgress,
} from '@mui/material';
import { observer } from 'mobx-react-lite';
import { useStore } from '../../stores/StoreContext';
import { ordersApi } from '../../api/ordersApi';
import { medicalStoresApi } from '../../api/medicalStoresApi';
import StatusBadge from '../../components/common/StatusBadge';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import EmptyState from '../../components/common/EmptyState';
import { formatDateTime } from '../../utils/formatters';
import type { OrderModel } from '../../models/Order';
import {
  ChemistMatchType,
  type NearbyChemistDto,
  type NearbyChemistResponseDto,
} from '../../models/NearbyChemist';

const FILTERS = ['All', 'Pending', 'Active', 'Completed', 'Rejected'];

const OrderAssignmentPage = observer(() => {
  const { orderStore } = useStore();
  const [assignOrder, setAssignOrder] = useState<OrderModel | null>(null);
  const [nearbyChemists, setNearbyChemists] = useState<NearbyChemistDto[]>([]);
  const [selectedChemist, setSelectedChemist] = useState('');
  const [chemistAvailable, setChemistAvailable] = useState<boolean | null>(null);
  const [loadingChemists, setLoadingChemists] = useState(false);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    orderStore.fetchAllOrders();
  }, [orderStore]);

  const openAssignDialog = async (order: OrderModel) => {
    setAssignOrder(order);
    setSelectedChemist('');
    setNearbyChemists([]);
    setChemistAvailable(null);
    setErrorMsg(null);
    setLoadingChemists(true);
    try {
      const calls: Promise<unknown>[] = [];
      if (order.orderNumber) {
        calls.push(ordersApi.getNearbyChemists(order.orderNumber));
      } else {
        calls.push(Promise.resolve(null));
      }
      if (order.customerId) {
        calls.push(medicalStoresApi.checkAvailability(order.customerId));
      } else {
        calls.push(Promise.resolve(null));
      }
      const [nearbyRes, availRes] = await Promise.all(calls);

      if (nearbyRes) {
        const data = (nearbyRes as { data: NearbyChemistResponseDto }).data;
        const list = Array.isArray(data?.chemists)
          ? data.chemists
          : ((data as unknown as { chemists?: { $values?: NearbyChemistDto[] } })?.chemists?.$values ?? []);
        setNearbyChemists(list);
      }
      if (availRes) {
        const availData = (availRes as { data: { isChemistAvailable: boolean } }).data;
        setChemistAvailable(!!availData?.isChemistAvailable);
      }
    } catch {
      setErrorMsg('Failed to load nearby chemists.');
    } finally {
      setLoadingChemists(false);
    }
  };

  const closeDialog = () => {
    setAssignOrder(null);
    setSelectedChemist('');
    setNearbyChemists([]);
    setChemistAvailable(null);
    setErrorMsg(null);
  };

  const handleAssign = async () => {
    if (!assignOrder || !selectedChemist) return;
    const orderIdNum = parseInt(assignOrder.orderId, 10);
    if (Number.isNaN(orderIdNum)) {
      setErrorMsg('Invalid order id.');
      return;
    }
    setSubmitting(true);
    try {
      await ordersApi.assignToMedicalStore(orderIdNum, selectedChemist);
      await orderStore.fetchAllOrders();
      closeDialog();
    } catch {
      setErrorMsg('Failed to reassign order.');
    } finally {
      setSubmitting(false);
    }
  };

  const formatDistance = (c: NearbyChemistDto) => {
    if (c.distanceInKm != null) return `${c.distanceInKm.toFixed(2)} km`;
    if (c.matchType === ChemistMatchType.PostalCode) return 'Same postal code';
    return '—';
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
                      <Button size="small" variant="contained" onClick={() => openAssignDialog(order)}>
                        Reassign
                      </Button>
                    )}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      )}

      {/* Reassign Order Dialog */}
      <Dialog open={!!assignOrder} onClose={closeDialog} maxWidth="md" fullWidth>
        <DialogTitle>
          Reassign Order {assignOrder?.orderNumber ? `— ${assignOrder.orderNumber}` : ''}
        </DialogTitle>
        <DialogContent dividers>
          {chemistAvailable !== null && (
            <Alert severity={chemistAvailable ? 'success' : 'warning'} sx={{ mb: 2 }}>
              {chemistAvailable
                ? 'A chemist is available within 5 KM of the customer address.'
                : 'No chemist is available within 5 KM of the customer address.'}
            </Alert>
          )}

          {errorMsg && <Alert severity="error" sx={{ mb: 2 }}>{errorMsg}</Alert>}

          {loadingChemists ? (
            <Box sx={{ display: 'flex', justifyContent: 'center', py: 4 }}>
              <CircularProgress />
            </Box>
          ) : nearbyChemists.length === 0 ? (
            <EmptyState message="No nearby chemists found for this order." />
          ) : (
            <RadioGroup
              value={selectedChemist}
              onChange={(e) => setSelectedChemist(e.target.value)}
            >
              <TableContainer component={Paper} variant="outlined">
                <Table size="small">
                  <TableHead>
                    <TableRow sx={{ bgcolor: '#fafafa' }}>
                      <TableCell />
                      <TableCell sx={{ fontWeight: 600 }}>Chemist</TableCell>
                      <TableCell sx={{ fontWeight: 600 }}>Address</TableCell>
                      <TableCell sx={{ fontWeight: 600 }}>Mobile</TableCell>
                      <TableCell sx={{ fontWeight: 600 }} align="right">Distance</TableCell>
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {nearbyChemists.map((c) => (
                      <TableRow
                        key={c.medicalStoreId}
                        hover
                        onClick={() => setSelectedChemist(c.medicalStoreId)}
                        sx={{ cursor: 'pointer' }}
                      >
                        <TableCell padding="checkbox">
                          <FormControlLabel
                            value={c.medicalStoreId}
                            control={<Radio />}
                            label=""
                            sx={{ m: 0 }}
                          />
                        </TableCell>
                        <TableCell>{c.medicalName}</TableCell>
                        <TableCell>
                          {[c.addressLine1, c.addressLine2, c.city, c.state, c.postalCode]
                            .filter(Boolean)
                            .join(', ')}
                        </TableCell>
                        <TableCell>{c.mobileNumber}</TableCell>
                        <TableCell align="right">{formatDistance(c)}</TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>
            </RadioGroup>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={closeDialog} disabled={submitting}>Cancel</Button>
          <Button
            variant="contained"
            onClick={handleAssign}
            disabled={!selectedChemist || submitting}
          >
            {submitting ? 'Reassigning...' : 'Reassign'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
});

export default OrderAssignmentPage;
