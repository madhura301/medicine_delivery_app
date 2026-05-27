import api from './axiosInstance';

export const ordersApi = {
  getAll: () => api.get('/Orders'),

  getById: (id: string) => api.get(`/Orders/${id}`),

  getByCustomer: (customerId: string) => api.get(`/Orders/customer/${customerId}`),

  getByMedicalStore: (storeId: string) => api.get(`/Orders/medicalstore/${storeId}`),

  getMyChemistOrders: () => api.get('/Orders/medical-store/my-orders'),

  accept: (orderId: string) => api.put(`/Orders/${orderId}/accept`),

  reject: (orderId: string, reason: string) =>
    api.put(`/Orders/${orderId}/reject`, { rejectionReason: reason }),

  uploadBill: (orderId: string, file: File, amount: number) => {
    const formData = new FormData();
    formData.append('BillFile', file);
    formData.append('TotalAmount', amount.toString());
    return api.put(`/Orders/${orderId}/upload-bill`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
  },

  assignToDelivery: (orderId: string, deliveryId: string) =>
    api.put(`/Orders/${orderId}/assign-delivery`, { deliveryId }),

  completeDelivery: (orderId: string, otp: string) =>
    api.post(`/Orders/${orderId}/complete-delivery`, { otp }),

  getEligibleDeliveries: (orderId: string) =>
    api.get(`/Orders/${orderId}/eligible-deliveries`),

  getNearbyChemists: (orderNumber: string) =>
    api.get(`/Orders/nearby-chemists/${orderNumber}`),

  assignToMedicalStore: (orderId: number, medicalStoreId: string) =>
    api.put('/Orders/assign', { orderId, medicalStoreId }),
};
