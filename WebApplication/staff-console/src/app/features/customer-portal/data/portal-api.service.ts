import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../../environments/environment';
import {
  Customer,
  CustomerRegistration,
  Order,
  Payment,
  RazorpayOrderResponse,
} from '../../../core/models/api.models';
import { OrderInputType, OrderType } from '../../../core/models/enums';
import { CustomerWrite } from '../../customers/data/customers-api.service';

export interface PlaceOrderRequest {
  customerId: string;
  customerAddressId: string;
  orderType: OrderType;
  orderInputType: OrderInputType;
  text?: string;
  file?: File;
}

/**
 * Everything the customer portal calls. The same endpoints the mobile app uses — the API scopes
 * each one to the signed-in customer, so nothing here can reach another customer's data.
 */
@Injectable({ providedIn: 'root' })
export class PortalApiService {
  private readonly http = inject(HttpClient);
  private readonly api = environment.apiBaseUrl;

  myProfile(): Observable<Customer> {
    return this.http.get<Customer>(`${this.api}/Customers/my-profile`);
  }

  updateProfile(customerId: string, payload: CustomerWrite & { isActive: boolean }): Observable<Customer> {
    return this.http.put<Customer>(`${this.api}/Customers/${customerId}`, payload);
  }

  /** Anonymous. Answers 201 on success and 400 `{ errors: [...] }` for duplicates and bad input. */
  register(payload: CustomerRegistration): Observable<unknown> {
    return this.http.post(`${this.api}/Customers/register`, payload);
  }

  myOrders(customerId: string): Observable<Order[]> {
    return this.http.get<Order[]>(`${this.api}/Orders/customer/${customerId}`);
  }

  /** Includes the delivery OTP once the order is paid — the API adds it for the owner only. */
  order(orderId: number): Observable<Order> {
    return this.http.get<Order>(`${this.api}/Orders/${orderId}`);
  }

  /**
   * Multipart, like the mobile app. A refused order comes back as 400
   * `{ error, postalCode, missingRoles }` — see `describePlaceOrderError`.
   */
  placeOrder(request: PlaceOrderRequest): Observable<Order> {
    const form = new FormData();
    form.append('CustomerId', request.customerId);
    form.append('CustomerAddressId', request.customerAddressId);
    form.append('OrderType', String(request.orderType));
    form.append('OrderInputType', String(request.orderInputType));
    if (request.text) {
      form.append('OrderInputText', request.text);
    }
    if (request.file) {
      form.append('OrderInputFile', request.file, request.file.name);
    }
    return this.http.post<Order>(`${this.api}/Orders`, form);
  }

  payments(orderId: number): Observable<Payment[]> {
    return this.http.get<Payment[]>(`${this.api}/Payments/order/${orderId}`);
  }

  createPaymentOrder(body: {
    orderId: number;
    amount: number;
    billAmount: number;
    convenienceFee: number;
  }): Observable<RazorpayOrderResponse> {
    return this.http.post<RazorpayOrderResponse>(`${this.api}/Razorpay/create-order`, body);
  }

  verifyPayment(body: {
    orderId: number;
    razorpayOrderId: string;
    razorpayPaymentId: string;
    razorpaySignature: string;
  }): Observable<unknown> {
    return this.http.post(`${this.api}/Razorpay/verify-payment`, body);
  }
}
