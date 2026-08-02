import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../../environments/environment';
import {
  DeliveryBoy,
  MedicalStoreBasic,
  Order,
  Payment,
} from '../../../core/models/api.models';

@Injectable({ providedIn: 'root' })
export class OrdersApiService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiBaseUrl}/Orders`;

  /** Requires ListAllOrders — Admin and Manager only. Returns every order, unpaginated. */
  listAll(): Observable<Order[]> {
    return this.http.get<Order[]>(this.base);
  }

  get(orderId: number): Observable<Order> {
    return this.http.get<Order>(`${this.base}/${orderId}`);
  }

  /** Every order this support agent has ever handled. */
  byCustomerSupport(customerSupportId: string): Observable<Order[]> {
    return this.http.get<Order[]>(`${this.base}/customersupport/${customerSupportId}`);
  }

  /** Only the ones awaiting this agent's action. */
  awaitingCustomerSupport(customerSupportId: string): Observable<Order[]> {
    return this.http.get<Order[]>(
      `${this.base}/customersupport/${customerSupportId}/assignedtocustomersupport`,
    );
  }

  byManager(managerId: string): Observable<Order[]> {
    return this.http.get<Order[]>(`${this.base}/manager/${managerId}`);
  }

  awaitingManager(managerId: string): Observable<Order[]> {
    return this.http.get<Order[]>(`${this.base}/manager/${managerId}/assignedtomanager`);
  }

  /** Moves the order to a different chemist; it returns to the AssignedToChemist state. */
  reassign(orderId: number, medicalStoreId: string): Observable<Order> {
    return this.http.put<Order>(`${this.base}/${orderId}/reassign`, { orderId, medicalStoreId });
  }

  cancel(orderId: number, cancellationReason: string): Observable<Order> {
    return this.http.put<Order>(`${this.base}/${orderId}/cancel`, { cancellationReason });
  }

  assignDelivery(orderId: number, deliveryId: number): Observable<Order> {
    return this.http.put<Order>(`${this.base}/${orderId}/assign-delivery`, { deliveryId });
  }

  /** Chemists whose pin code matches the order's delivery address. */
  candidatesByPinCode(orderId: number): Observable<MedicalStoreBasic[]> {
    return this.http.get<MedicalStoreBasic[]>(`${this.base}/${orderId}/medical-stores-by-pincode`);
  }

  candidatesByCity(orderId: number): Observable<MedicalStoreBasic[]> {
    return this.http.get<MedicalStoreBasic[]>(`${this.base}/${orderId}/medical-stores-by-city`);
  }

  /** Partners whose delivery region covers the order's pin code. */
  eligibleDeliveryBoys(orderId: number): Observable<DeliveryBoy[]> {
    return this.http.get<DeliveryBoy[]>(`${this.base}/${orderId}/eligible-delivery-boys`);
  }

  payments(orderId: number): Observable<Payment[]> {
    return this.http.get<Payment[]>(`${environment.apiBaseUrl}/Payments/order/${orderId}`);
  }

  downloadInputFile(orderId: number): Observable<Blob> {
    return this.http.get(`${this.base}/${orderId}/download-input-file`, { responseType: 'blob' });
  }

  downloadBill(orderId: number): Observable<Blob> {
    return this.http.get(`${this.base}/${orderId}/download-bill`, { responseType: 'blob' });
  }
}
