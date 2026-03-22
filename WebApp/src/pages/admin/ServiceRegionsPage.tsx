import { useEffect, useState } from 'react';
import {
  Box, Typography, Paper, Button, TextField, Chip, Stack, IconButton,
  Dialog, DialogTitle, DialogContent, DialogActions, Grid, MenuItem, Select,
  FormControl, InputLabel, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow,
} from '@mui/material';
import { Add as AddIcon, Delete as DeleteIcon } from '@mui/icons-material';
import { observer } from 'mobx-react-lite';
import { useStore } from '../../stores/StoreContext';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import EmptyState from '../../components/common/EmptyState';

const ServiceRegionsPage = observer(() => {
  const { regionStore } = useStore();
  const [createOpen, setCreateOpen] = useState(false);
  const [pinCodeDialog, setPinCodeDialog] = useState<string | null>(null);
  const [newRegion, setNewRegion] = useState({ name: '', city: '', regionName: '', regionType: 0 });
  const [newPinCode, setNewPinCode] = useState('');

  useEffect(() => {
    regionStore.loadRegions();
  }, [regionStore]);

  const handleCreateRegion = async () => {
    const success = await regionStore.createRegion(newRegion);
    if (success) {
      setCreateOpen(false);
      setNewRegion({ name: '', city: '', regionName: '', regionType: 0 });
    }
  };

  const handleAddPinCode = async () => {
    if (!pinCodeDialog || !newPinCode) return;
    const success = await regionStore.addPinCode(pinCodeDialog, newPinCode);
    if (success) setNewPinCode('');
  };

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Typography variant="h5" sx={{ fontWeight: 700 }}>Service Regions</Typography>
        <Button variant="contained" startIcon={<AddIcon />} onClick={() => setCreateOpen(true)}>
          Add Region
        </Button>
      </Box>

      <Box sx={{ display: 'flex', gap: 2, mb: 3, flexWrap: 'wrap' }}>
        <TextField
          placeholder="Search regions..."
          size="small"
          value={regionStore.searchQuery}
          onChange={(e) => regionStore.setSearch(e.target.value)}
          sx={{ minWidth: 250 }}
        />
        <Stack direction="row" spacing={1}>
          <Chip label="All Types" variant={regionStore.regionTypeFilter === null ? 'filled' : 'outlined'}
            color={regionStore.regionTypeFilter === null ? 'primary' : 'default'}
            onClick={() => regionStore.setRegionTypeFilter(null)} />
          <Chip label="Customer Support" variant={regionStore.regionTypeFilter === 0 ? 'filled' : 'outlined'}
            color={regionStore.regionTypeFilter === 0 ? 'primary' : 'default'}
            onClick={() => regionStore.setRegionTypeFilter(0)} />
          <Chip label="Delivery Boy" variant={regionStore.regionTypeFilter === 1 ? 'filled' : 'outlined'}
            color={regionStore.regionTypeFilter === 1 ? 'primary' : 'default'}
            onClick={() => regionStore.setRegionTypeFilter(1)} />
        </Stack>
      </Box>

      {regionStore.isLoading ? <LoadingSpinner /> : regionStore.filteredRegions.length === 0 ? <EmptyState message="No regions found" /> : (
        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow sx={{ bgcolor: '#f5f5f5' }}>
                <TableCell sx={{ fontWeight: 600 }}>Name</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>City</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Type</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Pin Codes</TableCell>
                <TableCell sx={{ fontWeight: 600 }} align="right">Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {regionStore.filteredRegions.map((region) => (
                <TableRow key={region.serviceRegionId} hover>
                  <TableCell>{region.name}</TableCell>
                  <TableCell>{region.city}</TableCell>
                  <TableCell>
                    <Chip label={region.regionType === 0 ? 'Customer Support' : 'Delivery'} size="small"
                      color={region.regionType === 0 ? 'info' : 'success'} />
                  </TableCell>
                  <TableCell>
                    <Box sx={{ display: 'flex', gap: 0.5, flexWrap: 'wrap', alignItems: 'center' }}>
                      {region.regionPinCodes?.slice(0, 5).map((pc) => (
                        <Chip key={pc.serviceRegionPinCodeId ?? pc.pinCode} label={pc.pinCode} size="small" variant="outlined" />
                      ))}
                      {(region.regionPinCodes?.length ?? 0) > 5 && (
                        <Chip label={`+${(region.regionPinCodes?.length ?? 0) - 5} more`} size="small" />
                      )}
                      <Button size="small" onClick={() => setPinCodeDialog(region.serviceRegionId)}>
                        Manage
                      </Button>
                    </Box>
                  </TableCell>
                  <TableCell align="right">
                    <IconButton size="small" color="error" onClick={() => regionStore.deleteRegion(region.serviceRegionId)}>
                      <DeleteIcon fontSize="small" />
                    </IconButton>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      )}

      {/* Create Region Dialog */}
      <Dialog open={createOpen} onClose={() => setCreateOpen(false)} maxWidth="sm" fullWidth>
        <DialogTitle>Create Service Region</DialogTitle>
        <DialogContent>
          <Grid container spacing={2} sx={{ mt: 1 }}>
            <Grid size={{ xs: 12 }}><TextField label="Region Name" value={newRegion.name} onChange={(e) => setNewRegion({ ...newRegion, name: e.target.value })} fullWidth required /></Grid>
            <Grid size={{ xs: 12, sm: 6 }}><TextField label="City" value={newRegion.city} onChange={(e) => setNewRegion({ ...newRegion, city: e.target.value })} fullWidth required /></Grid>
            <Grid size={{ xs: 12, sm: 6 }}>
              <FormControl fullWidth>
                <InputLabel>Region Type</InputLabel>
                <Select value={newRegion.regionType} label="Region Type" onChange={(e) => setNewRegion({ ...newRegion, regionType: e.target.value as number })}>
                  <MenuItem value={0}>Customer Support</MenuItem>
                  <MenuItem value={1}>Delivery Boy</MenuItem>
                </Select>
              </FormControl>
            </Grid>
          </Grid>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setCreateOpen(false)}>Cancel</Button>
          <Button variant="contained" onClick={handleCreateRegion}>Create</Button>
        </DialogActions>
      </Dialog>

      {/* Manage PinCodes Dialog */}
      <Dialog open={!!pinCodeDialog} onClose={() => setPinCodeDialog(null)} maxWidth="sm" fullWidth>
        <DialogTitle>Manage Pin Codes</DialogTitle>
        <DialogContent>
          <Box sx={{ display: 'flex', gap: 1, mb: 2, mt: 1 }}>
            <TextField label="New Pin Code" size="small" value={newPinCode} onChange={(e) => setNewPinCode(e.target.value)} />
            <Button variant="contained" onClick={handleAddPinCode} disabled={!newPinCode}>Add</Button>
          </Box>
          <Box sx={{ display: 'flex', gap: 0.5, flexWrap: 'wrap' }}>
            {regionStore.regions.find((r) => r.serviceRegionId === pinCodeDialog)?.regionPinCodes?.map((pc) => (
              <Chip
                key={pc.serviceRegionPinCodeId ?? pc.pinCode}
                label={pc.pinCode}
                onDelete={() => pc.serviceRegionPinCodeId && pinCodeDialog && regionStore.removePinCode(pinCodeDialog, pc.serviceRegionPinCodeId)}
              />
            ))}
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setPinCodeDialog(null)}>Close</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
});

export default ServiceRegionsPage;
