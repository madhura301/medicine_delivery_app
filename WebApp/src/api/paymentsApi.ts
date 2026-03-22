import api from './axiosInstance';

export const paymentsApi = {
  getByOrder: (orderId: string) => api.get(`/Payments/order/${orderId}`),
  record: (data: Record<string, unknown>) => api.post('/Payments', data),
};
