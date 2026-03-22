import api from './axiosInstance';

export const addressesApi = {
  getById: (id: string) => api.get(`/CustomerAddresses/${id}`),
  getByCustomer: (customerId: string) => api.get(`/CustomerAddresses/customer/${customerId}`),
};
