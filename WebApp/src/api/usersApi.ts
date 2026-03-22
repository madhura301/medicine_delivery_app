import api from './axiosInstance';
import type { CreateUserWithRoleDto } from '../models/User';

export const usersApi = {
  create: (data: CreateUserWithRoleDto) => api.post('/Users', data),
  getAll: () => api.get('/Users'),
};
