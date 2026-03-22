import { useEffect } from 'react';
import {
  Box, Typography, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, Paper, Chip,
} from '@mui/material';
import { observer } from 'mobx-react-lite';
import { useStore } from '../../stores/StoreContext';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import EmptyState from '../../components/common/EmptyState';
import { formatDateTime } from '../../utils/formatters';

const ConsentLogsPage = observer(() => {
  const { consentStore } = useStore();

  useEffect(() => {
    consentStore.loadLogs();
  }, [consentStore]);

  return (
    <Box>
      <Typography variant="h5" sx={{ fontWeight: 700, mb: 3 }}>Consent Logs</Typography>

      {consentStore.isLoading ? <LoadingSpinner /> : consentStore.logs.length === 0 ? <EmptyState message="No consent logs found" /> : (
        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow sx={{ bgcolor: '#f5f5f5' }}>
                <TableCell sx={{ fontWeight: 600 }}>User ID</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>User Type</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Action</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>IP Address</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Device</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Date</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {consentStore.logs.map((log) => (
                <TableRow key={log.consentLogId} hover>
                  <TableCell sx={{ fontFamily: 'monospace', fontSize: 12 }}>{log.userId?.slice(0, 12)}...</TableCell>
                  <TableCell>{log.userType ?? '—'}</TableCell>
                  <TableCell>
                    <Chip
                      label={log.action === 1 ? 'Accepted' : 'Rejected'}
                      size="small"
                      color={log.action === 1 ? 'success' : 'error'}
                    />
                  </TableCell>
                  <TableCell>{log.ipAddress ?? '—'}</TableCell>
                  <TableCell sx={{ maxWidth: 200, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                    {log.deviceInfo ?? log.userAgent ?? '—'}
                  </TableCell>
                  <TableCell>{formatDateTime(log.createdOn)}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      )}
    </Box>
  );
});

export default ConsentLogsPage;
