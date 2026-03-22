import { makeAutoObservable, runInAction } from 'mobx';
import { ordersApi } from '../api/ordersApi';
import { customersApi } from '../api/customersApi';
import { type OrderModel, normalizeOrder } from '../models/Order';
import type { CustomerDto } from '../models/User';

export class ChemistStore {
  orders: OrderModel[] = [];
  customerCache: Map<string, CustomerDto> = new Map();
  isLoading = false;
  error = '';

  constructor() {
    makeAutoObservable(this);
  }

  get pendingOrders(): OrderModel[] {
    return this.orders.filter((o) => o.status === 1); // AssignedToChemist
  }

  get acceptedOrders(): OrderModel[] {
    return this.orders.filter((o) => [3, 4, 5, 6].includes(o.status));
  }

  get completedOrders(): OrderModel[] {
    return this.orders.filter((o) => o.status === 7);
  }

  get rejectedOrders(): OrderModel[] {
    return this.orders.filter((o) => o.status === 2);
  }

  get orderCounts() {
    return {
      pending: this.pendingOrders.length,
      accepted: this.acceptedOrders.length,
      completed: this.completedOrders.length,
      rejected: this.rejectedOrders.length,
      total: this.orders.length,
    };
  }

  async fetchMyOrders(storeId: string) {
    this.isLoading = true;
    try {
      const res = await ordersApi.getByMedicalStore(storeId);
      const data = Array.isArray(res.data) ? res.data : res.data?.$values ?? res.data?.data ?? [];
      runInAction(() => {
        this.orders = data.map((o: Record<string, unknown>) => normalizeOrder(o));
        this.isLoading = false;
      });
      // Pre-fetch customers
      const customerIds = [...new Set(this.orders.map((o) => o.customerId).filter(Boolean))];
      customerIds.forEach((id) => this.fetchCustomer(id));
    } catch {
      runInAction(() => { this.error = 'Failed to load orders'; this.isLoading = false; });
    }
  }

  async fetchCustomer(id: string) {
    if (this.customerCache.has(id)) return;
    try {
      const res = await customersApi.getById(id);
      const customer = res.data?.data ?? res.data;
      runInAction(() => { this.customerCache.set(id, customer); });
    } catch { /* ignore */ }
  }

  async acceptOrder(orderId: string) {
    try {
      await ordersApi.accept(orderId);
      runInAction(() => {
        const order = this.orders.find((o) => o.orderId === orderId);
        if (order) order.status = 3;
      });
      return true;
    } catch { return false; }
  }

  async rejectOrder(orderId: string, reason: string) {
    try {
      await ordersApi.reject(orderId, reason);
      runInAction(() => {
        const order = this.orders.find((o) => o.orderId === orderId);
        if (order) {
          order.status = 2;
          order.rejectionReason = reason;
        }
      });
      return true;
    } catch { return false; }
  }

  async uploadBill(orderId: string, file: File, amount: number) {
    try {
      await ordersApi.uploadBill(orderId, file, amount);
      runInAction(() => {
        const order = this.orders.find((o) => o.orderId === orderId);
        if (order) {
          order.status = 4;
          order.totalAmount = amount;
        }
      });
      return true;
    } catch { return false; }
  }
}
