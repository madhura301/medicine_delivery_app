import { makeAutoObservable, runInAction } from 'mobx';
import { customersApi } from '../api/customersApi';
import { medicalStoresApi } from '../api/medicalStoresApi';
import { customerSupportsApi } from '../api/customerSupportsApi';
import { managersApi } from '../api/managersApi';
import { deliveriesApi } from '../api/deliveriesApi';
import { usersApi } from '../api/usersApi';
import type { CustomerDto, MedicalStoreDto, ManagerDto, CustomerSupportDto, DeliveryDto, CreateUserWithRoleDto } from '../models/User';

export class UserManagementStore {
  customers: CustomerDto[] = [];
  chemists: MedicalStoreDto[] = [];
  supports: CustomerSupportDto[] = [];
  managers: ManagerDto[] = [];
  deliveryBoys: DeliveryDto[] = [];
  selectedTab = 0;
  filterIndex = 0; // 0=All, 1=Active, 2=Inactive, 3=Deleted
  searchQuery = '';
  isLoading = false;
  error = '';

  constructor() {
    makeAutoObservable(this);
  }

  setTab(index: number) { this.selectedTab = index; this.filterIndex = 0; this.searchQuery = ''; }
  setFilter(index: number) { this.filterIndex = index; }
  setSearch(query: string) { this.searchQuery = query; }

  private normalizeArray(data: unknown): unknown[] {
    if (Array.isArray(data)) return data;
    if (data && typeof data === 'object') {
      const obj = data as Record<string, unknown>;
      if (Array.isArray(obj.$values)) return obj.$values;
      if (Array.isArray(obj.data)) return obj.data;
    }
    return [];
  }

  async loadCustomers() {
    this.isLoading = true;
    try {
      const res = await customersApi.getAll();
      runInAction(() => { this.customers = this.normalizeArray(res.data) as CustomerDto[]; this.isLoading = false; });
    } catch { runInAction(() => { this.isLoading = false; }); }
  }

  async loadChemists() {
    this.isLoading = true;
    try {
      const res = await medicalStoresApi.getAll();
      runInAction(() => { this.chemists = this.normalizeArray(res.data) as MedicalStoreDto[]; this.isLoading = false; });
    } catch { runInAction(() => { this.isLoading = false; }); }
  }

  async loadSupports() {
    this.isLoading = true;
    try {
      const res = await customerSupportsApi.getAll();
      runInAction(() => { this.supports = this.normalizeArray(res.data) as CustomerSupportDto[]; this.isLoading = false; });
    } catch { runInAction(() => { this.isLoading = false; }); }
  }

  async loadManagers() {
    this.isLoading = true;
    try {
      const res = await managersApi.getAll();
      runInAction(() => { this.managers = this.normalizeArray(res.data) as ManagerDto[]; this.isLoading = false; });
    } catch { runInAction(() => { this.isLoading = false; }); }
  }

  async loadDeliveryBoys() {
    this.isLoading = true;
    try {
      const res = await deliveriesApi.getAll();
      runInAction(() => { this.deliveryBoys = this.normalizeArray(res.data) as DeliveryDto[]; this.isLoading = false; });
    } catch { runInAction(() => { this.isLoading = false; }); }
  }

  async loadAllUsers() {
    await Promise.all([
      this.loadCustomers(),
      this.loadChemists(),
      this.loadSupports(),
      this.loadManagers(),
      this.loadDeliveryBoys(),
    ]);
  }

  async createUser(data: CreateUserWithRoleDto) {
    this.isLoading = true;
    this.error = '';
    try {
      await usersApi.create(data);
      runInAction(() => { this.isLoading = false; });
      return true;
    } catch (e: unknown) {
      const err = e as { response?: { data?: { message?: string } } };
      runInAction(() => {
        this.error = err.response?.data?.message || 'Failed to create user';
        this.isLoading = false;
      });
      return false;
    }
  }

  async deleteUser(role: string, id: string) {
    try {
      switch (role) {
        case 'Customer': await customersApi.delete(id); break;
        case 'Chemist': await medicalStoresApi.delete(id); break;
        case 'CustomerSupport': await customerSupportsApi.delete(id); break;
        case 'Manager': await managersApi.delete(id); break;
        case 'DeliveryBoy': await deliveriesApi.delete(id); break;
      }
      return true;
    } catch {
      return false;
    }
  }
}
