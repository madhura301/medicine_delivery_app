import api from './axiosInstance';

export const consentsApi = {
  getActive: () => api.get('/Consents/active'),
  getAll: () => api.get('/Consents'),
  getById: (id: string) => api.get(`/Consents/${id}`),
  getLogs: (consentId?: string) => {
    const url = consentId ? `/Consents/${consentId}/logs` : '/Consents/logs';
    return api.get(url);
  },
  accept: (consentId: string, data: Record<string, unknown>) =>
    api.post(`/Consents/${consentId}/accept`, data),
  reject: (consentId: string, data: Record<string, unknown>) =>
    api.post(`/Consents/${consentId}/reject`, data),
};
