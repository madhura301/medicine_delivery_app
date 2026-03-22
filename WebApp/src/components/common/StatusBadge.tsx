import { Chip } from '@mui/material';
import { OrderStatusLabel } from '../../models/OrderEnums';
import { getStatusColor } from '../../utils/orderColors';

interface StatusBadgeProps {
  status: number;
}

export default function StatusBadge({ status }: StatusBadgeProps) {
  const color = getStatusColor(status);
  const label = OrderStatusLabel[status] ?? 'Unknown';

  return (
    <Chip
      label={label}
      size="small"
      sx={{
        bgcolor: `${color}20`,
        color,
        fontWeight: 600,
        fontSize: 12,
        border: `1px solid ${color}40`,
      }}
    />
  );
}
