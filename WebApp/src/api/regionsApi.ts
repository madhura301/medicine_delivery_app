import api from './axiosInstance';
import type { CreateRegionDto } from '../models/Region';

export const regionsApi = {
  getAll: () => api.get('/CustomerSupportRegions'),
  getById: (id: string) => api.get(`/CustomerSupportRegions/${id}`),
  create: (data: CreateRegionDto) => api.post('/CustomerSupportRegions', data),
  update: (id: string, data: Record<string, unknown>) => api.put(`/CustomerSupportRegions/${id}`, data),
  delete: (id: string) => api.delete(`/CustomerSupportRegions/${id}`),
  addPinCode: (regionId: string, pinCode: string) =>
    api.post(`/CustomerSupportRegions/${regionId}/pincodes`, { pinCode }),
  removePinCode: (regionId: string, pinCodeId: string) =>
    api.delete(`/CustomerSupportRegions/${regionId}/pincodes/${pinCodeId}`),
};
