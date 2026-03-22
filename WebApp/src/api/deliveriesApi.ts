import api from './axiosInstance';

export const deliveriesApi = {
  getAll: () => api.get('/Deliveries'),
  getById: (id: string) => api.get(`/Deliveries/${id}`),
  getByMedicalStore: (storeId: string) => api.get(`/Deliveries/medical-store/${storeId}`),
  update: (id: string, data: Record<string, unknown>) => api.put(`/Deliveries/${id}`, data),
  delete: (id: string) => api.delete(`/Deliveries/${id}`),
};
