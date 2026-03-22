import { makeAutoObservable, runInAction } from 'mobx';
import { ordersApi } from '../api/ordersApi';
import { customersApi } from '../api/customersApi';
import { medicalStoresApi } from '../api/medicalStoresApi';
import { addressesApi } from '../api/addressesApi';
import { type OrderModel, normalizeOrder } from '../models/Order';
import type { CustomerDto, MedicalStoreDto } from '../models/User';

export class OrderStore {
  orders: OrderModel[] = [];
  currentOrder: OrderModel | null = null;
  currentCustomer: CustomerDto | null = null;
  currentChemist: MedicalStoreDto | null = null;
  currentAddress: Record<string, unknown> | null = null;
  filterIndex = 0;
  isLoading = false;
  error = '';

  constructor() {
    makeAutoObservable(this);
  }

  get filteredOrders(): OrderModel[] {
    if (this.filterIndex === 0) return this.orders;
    const statusMap: Record<number, number[]> = {
      1: [0, 1, 8],       // Pending
      2: [3, 4, 5, 6],    // Active
      3: [7],              // Completed
      4: [2],              // Rejected
    };
    const statuses = statusMap[this.filterIndex] ?? [];
    return this.orders.filter((o) => statuses.includes(o.status));
  }

  setFilter(index: number) {
    this.filterIndex = index;
  }

  async fetchAllOrders() {
    this.isLoading = true;
    try {
      const res = await ordersApi.getAll();
      const data = Array.isArray(res.data) ? res.data : res.data?.data ?? res.data?.$values ?? [];
      runInAction(() => {
        this.orders = data.map((o: Record<string, unknown>) => normalizeOrder(o));
        this.isLoading = false;
      });
    } catch {
      runInAction(() => { this.error = 'Failed to load orders'; this.isLoading = false; });
    }
  }

  async fetchOrderById(id: string) {
    this.isLoading = true;
    this.currentCustomer = null;
    this.currentChemist = null;
    this.currentAddress = null;
    try {
      const res = await ordersApi.getById(id);
      const raw = res.data?.data ?? res.data;
      const order = normalizeOrder(raw);
      runInAction(() => { this.currentOrder = order; this.isLoading = false; });
      // Load related data
      if (order.customerId) this.fetchCustomer(order.customerId);
      if (order.medicalStoreId) this.fetchChemist(order.medicalStoreId);
    } catch {
      runInAction(() => { this.error = 'Failed to load order'; this.isLoading = false; });
    }
  }

  async fetchCustomer(id: string) {
    try {
      const res = await customersApi.getById(id);
      runInAction(() => { this.currentCustomer = res.data?.data ?? res.data; });
    } catch { /* ignore */ }
  }

  async fetchChemist(id: string) {
    try {
      const res = await medicalStoresApi.getById(id);
      runInAction(() => { this.currentChemist = res.data?.data ?? res.data; });
    } catch { /* ignore */ }
  }

  async fetchAddress(id: string) {
    try {
      const res = await addressesApi.getById(id);
      runInAction(() => { this.currentAddress = res.data?.data ?? res.data; });
    } catch { /* ignore */ }
  }
}
