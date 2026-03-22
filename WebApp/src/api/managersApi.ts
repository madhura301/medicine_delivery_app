import api from './axiosInstance';

export const managersApi = {
  getAll: () => api.get('/Managers'),
  getById: (id: string) => api.get(`/Managers/${id}`),
  update: (id: string, data: Record<string, unknown>) => api.put(`/Managers/${id}`, data),
  delete: (id: string) => api.delete(`/Managers/${id}`),
};
