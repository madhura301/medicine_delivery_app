export const ORDER_STATUS_COLORS: Record<number, string> = {
  0: '#FF9800', // Pending Payment - orange
  1: '#1976D2', // Assigned to Chemist - blue
  2: '#E53E3E', // Rejected by Chemist - red
  3: '#4CAF50', // Accepted by Chemist - green
  4: '#9C27B0', // Bill Uploaded - purple
  5: '#2E7D32', // Paid - dark green
  6: '#FF5722', // Out for Delivery - deep orange
  7: '#4CAF50', // Completed - green
  8: '#607D8B', // Assigned to Customer Support - grey-blue
};

export function getStatusColor(status: number): string {
  return ORDER_STATUS_COLORS[status] ?? '#9E9E9E';
}
