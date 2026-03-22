import api from './axiosInstance';

export const customerSupportsApi = {
  getAll: () => api.get('/CustomerSupports'),
  getById: (id: string) => api.get(`/CustomerSupports/${id}`),
  update: (id: string, data: Record<string, unknown>) => api.put(`/CustomerSupports/${id}`, data),
  delete: (id: string) => api.delete(`/CustomerSupports/${id}`),
};
