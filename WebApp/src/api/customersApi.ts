import api from './axiosInstance';

export const customersApi = {
  getAll: () => api.get('/Customers'),
  getById: (id: string) => api.get(`/Customers/${id}`),
  getByMobile: (mobile: string) => api.get(`/Customers/by-mobile/${mobile}`),
  update: (id: string, data: Record<string, unknown>) => api.put(`/Customers/${id}`, data),
  delete: (id: string) => api.delete(`/Customers/${id}`),
};
