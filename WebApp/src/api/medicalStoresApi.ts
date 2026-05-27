import api from './axiosInstance';

export const medicalStoresApi = {
  getAll: () => api.get('/MedicalStores'),
  getById: (id: string) => api.get(`/MedicalStores/${id}`),
  update: (id: string, data: Record<string, unknown>) => api.put(`/MedicalStores/${id}`, data),
  delete: (id: string) => api.delete(`/MedicalStores/${id}`),
  checkAvailability: (customerId: string) =>
    api.get(`/MedicalStores/check-availability/${customerId}`),
};
