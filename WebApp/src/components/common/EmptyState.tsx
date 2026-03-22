import { Box, Typography } from '@mui/material';
import { Inbox as InboxIcon } from '@mui/icons-material';

export default function EmptyState({ message = 'No data found' }: { message?: string }) {
  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', py: 8, color: 'text.secondary' }}>
      <InboxIcon sx={{ fontSize: 64, mb: 2, opacity: 0.5 }} />
      <Typography variant="body1">{message}</Typography>
    </Box>
  );
}
