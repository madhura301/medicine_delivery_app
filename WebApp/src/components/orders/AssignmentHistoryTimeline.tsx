import { Box, Typography, Paper, Chip } from '@mui/material';
import { Timeline, TimelineItem, TimelineSeparator, TimelineConnector, TimelineContent, TimelineDot } from '@mui/lab';
import type { OrderAssignmentHistory } from '../../models/Order';
import { formatDateTime } from '../../utils/formatters';

const ASSIGN_TO_LABEL: Record<number, string> = { 0: 'Customer', 1: 'Chemist', 2: 'Customer Support', 3: 'Delivery' };
const STATUS_LABEL: Record<number, string> = { 0: 'Assigned', 1: 'Accepted', 2: 'Rejected' };
const STATUS_COLOR: Record<number, 'info' | 'success' | 'error'> = { 0: 'info', 1: 'success', 2: 'error' };

interface Props {
  history: OrderAssignmentHistory[];
}

export default function AssignmentHistoryTimeline({ history }: Props) {
  if (!history.length) {
    return <Typography variant="body2" color="text.secondary">No assignment history available.</Typography>;
  }

  return (
    <Timeline position="alternate" sx={{ px: 0 }}>
      {history.map((item, index) => (
        <TimelineItem key={item.assignmentId || index}>
          <TimelineSeparator>
            <TimelineDot color={STATUS_COLOR[item.status] ?? 'grey'} />
            {index < history.length - 1 && <TimelineConnector />}
          </TimelineSeparator>
          <TimelineContent>
            <Paper elevation={1} sx={{ p: 2 }}>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 0.5 }}>
                <Chip label={STATUS_LABEL[item.status] ?? 'Unknown'} size="small" color={STATUS_COLOR[item.status] ?? 'default'} />
                <Typography variant="caption" color="text.secondary">
                  → {ASSIGN_TO_LABEL[item.assignTo] ?? 'Unknown'}
                </Typography>
              </Box>
              {item.chemistName && (
                <Typography variant="body2">Chemist: {item.chemistName}</Typography>
              )}
              {item.deliveryPersonName && (
                <Typography variant="body2">Delivery: {item.deliveryPersonName}</Typography>
              )}
              {item.rejectNote && (
                <Typography variant="body2" color="error" sx={{ mt: 0.5 }}>
                  Reason: {item.rejectNote}
                </Typography>
              )}
              <Typography variant="caption" color="text.secondary" display="block" sx={{ mt: 0.5 }}>
                {formatDateTime(item.assignedOn)}
              </Typography>
            </Paper>
          </TimelineContent>
        </TimelineItem>
      ))}
    </Timeline>
  );
}
