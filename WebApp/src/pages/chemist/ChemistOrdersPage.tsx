import { useEffect, useState } from 'react';
import {
  Box, Typography, Tabs, Tab, Table, TableBody, TableCell,
  TableContainer, TableHead, TableRow, Paper, Button,
  Dialog, DialogTitle, DialogContent, DialogActions, TextField,
} from '@mui/material';
import { useNavigate } from 'react-router-dom';
import { observer } from 'mobx-react-lite';
import { useStore } from '../../stores/StoreContext';
import StatusBadge from '../../components/common/StatusBadge';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import EmptyState from '../../components/common/EmptyState';
import { formatDateTime } from '../../utils/formatters';

const TABS = ['Pending', 'Accepted', 'Completed', 'Rejected'];

const ChemistOrdersPage = observer(() => {
  const { authStore, chemistStore } = useStore();
  const navigate = useNavigate();
  const [tab, setTab] = useState(0);
  const [rejectDialog, setRejectDialog] = useState<string | null>(null);
  const [rejectReason, setRejectReason] = useState('');
  const [billDialog, setBillDialog] = useState<string | null>(null);
  const [billFile, setBillFile] = useState<File | null>(null);
  const [billAmount, setBillAmount] = useState('');

  useEffect(() => {
    if (authStore.userId) chemistStore.fetchMyOrders(authStore.userId);
  }, [authStore.userId, chemistStore]);

  const getOrders = () => {
    switch (tab) {
      case 0: return chemistStore.pendingOrders;
      case 1: return chemistStore.acceptedOrders;
      case 2: return chemistStore.completedOrders;
      case 3: return chemistStore.rejectedOrders;
      default: return [];
    }
  };

  const handleAccept = async (orderId: string) => {
    await chemistStore.acceptOrder(orderId);
  };

  const handleReject = async () => {
    if (!rejectDialog) return;
    await chemistStore.rejectOrder(rejectDialog, rejectReason);
    setRejectDialog(null); setRejectReason('');
  };

  const handleUploadBill = async () => {
    if (!billDialog || !billFile || !billAmount) return;
    await chemistStore.uploadBill(billDialog, billFile, parseFloat(billAmount));
    setBillDialog(null); setBillFile(null); setBillAmount('');
  };

  const orders = getOrders();

  return (
    <Box>
      <Typography variant="h5" sx={{ fontWeight: 700, mb: 2 }}>My Orders</Typography>

      <Tabs value={tab} onChange={(_, v) => setTab(v)} sx={{ mb: 3 }}>
        {TABS.map((label) => <Tab key={label} label={label} />)}
      </Tabs>

      {chemistStore.isLoading ? <LoadingSpinner /> : orders.length === 0 ? <EmptyState message={`No ${TABS[tab].toLowerCase()} orders`} /> : (
        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow sx={{ bgcolor: '#f5f5f5' }}>
                <TableCell sx={{ fontWeight: 600 }}>Order #</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Customer</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Date</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Status</TableCell>
                <TableCell sx={{ fontWeight: 600 }} align="right">Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {orders.map((order) => {
                const customer = chemistStore.customerCache.get(order.customerId);
                return (
                  <TableRow key={order.orderId} hover>
                    <TableCell
                      sx={{ cursor: 'pointer', color: '#1976D2', fontWeight: 500 }}
                      onClick={() => navigate(`/chemist/orders/${order.orderId}`)}
                    >
                      {order.orderNumber || order.orderId.slice(0, 8)}
                    </TableCell>
                    <TableCell>{customer ? `${customer.customerFirstName} ${customer.customerLastName}` : '...'}</TableCell>
                    <TableCell>{formatDateTime(order.createdOn)}</TableCell>
                    <TableCell><StatusBadge status={order.status} /></TableCell>
                    <TableCell align="right">
                      {tab === 0 && (
                        <Box sx={{ display: 'flex', gap: 1, justifyContent: 'flex-end' }}>
                          <Button size="small" variant="contained" color="success" onClick={() => handleAccept(order.orderId)}>Accept</Button>
                          <Button size="small" variant="outlined" color="error" onClick={() => setRejectDialog(order.orderId)}>Reject</Button>
                        </Box>
                      )}
                      {tab === 1 && order.status === 3 && (
                        <Button size="small" variant="contained" onClick={() => setBillDialog(order.orderId)}>Upload Bill</Button>
                      )}
                    </TableCell>
                  </TableRow>
                );
              })}
            </TableBody>
          </Table>
        </TableContainer>
      )}

      {/* Reject Dialog */}
      <Dialog open={!!rejectDialog} onClose={() => setRejectDialog(null)} maxWidth="sm" fullWidth>
        <DialogTitle>Reject Order</DialogTitle>
        <DialogContent>
          <TextField
            label="Reason for rejection"
            value={rejectReason}
            onChange={(e) => setRejectReason(e.target.value)}
            fullWidth multiline rows={3} sx={{ mt: 1 }}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setRejectDialog(null)}>Cancel</Button>
          <Button variant="contained" color="error" onClick={handleReject} disabled={!rejectReason}>Reject</Button>
        </DialogActions>
      </Dialog>

      {/* Upload Bill Dialog */}
      <Dialog open={!!billDialog} onClose={() => setBillDialog(null)} maxWidth="sm" fullWidth>
        <DialogTitle>Upload Bill</DialogTitle>
        <DialogContent>
          <TextField
            label="Total Amount (₹)"
            type="number"
            value={billAmount}
            onChange={(e) => setBillAmount(e.target.value)}
            fullWidth sx={{ mt: 1, mb: 2 }}
          />
          <Button variant="outlined" component="label">
            Choose Bill File
            <input type="file" hidden accept="image/*,.pdf" onChange={(e) => setBillFile(e.target.files?.[0] ?? null)} />
          </Button>
          {billFile && <Typography variant="body2" sx={{ mt: 1 }}>{billFile.name}</Typography>}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setBillDialog(null)}>Cancel</Button>
          <Button variant="contained" onClick={handleUploadBill} disabled={!billFile || !billAmount}>Upload</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
});

export default ChemistOrdersPage;
