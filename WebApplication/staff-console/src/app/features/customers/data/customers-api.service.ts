import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../../environments/environment';
import {
  CreateCustomerAddress,
  Customer,
  CustomerAddress,
  UpdateCustomerAddress,
} from '../../../core/models/api.models';

export interface CustomerWrite {
  customerFirstName: string;
  customerMiddleName: string | null;
  customerLastName: string;
  mobileNumber: string;
  alternativeMobileNumber: string | null;
  emailId: string | null;
  dateOfBirth: string;
  gender: string | null;
}

@Injectable({ providedIn: 'root' })
export class CustomersApiService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiBaseUrl}/Customers`;
  private readonly addressBase = `${environment.apiBaseUrl}/CustomerAddresses`;

  list(): Observable<Customer[]> {
    return this.http.get<Customer[]>(this.base);
  }

  get(id: string): Observable<Customer> {
    return this.http.get<Customer>(`${this.base}/${id}`);
  }

  create(payload: CustomerWrite): Observable<Customer> {
    return this.http.post<Customer>(this.base, payload);
  }

  update(id: string, payload: CustomerWrite & { isActive: boolean }): Observable<Customer> {
    return this.http.put<Customer>(`${this.base}/${id}`, payload);
  }

  remove(id: string): Observable<unknown> {
    return this.http.delete(`${this.base}/${id}`);
  }

  addresses(customerId: string): Observable<CustomerAddress[]> {
    return this.http.get<CustomerAddress[]>(`${this.addressBase}/customer/${customerId}`);
  }

  createAddress(payload: CreateCustomerAddress): Observable<CustomerAddress> {
    return this.http.post<CustomerAddress>(this.addressBase, payload);
  }

  updateAddress(id: string, payload: UpdateCustomerAddress): Observable<CustomerAddress> {
    return this.http.put<CustomerAddress>(`${this.addressBase}/${id}`, payload);
  }

  removeAddress(id: string): Observable<unknown> {
    return this.http.delete(`${this.addressBase}/${id}`);
  }

  setDefaultAddress(customerId: string, addressId: string): Observable<unknown> {
    return this.http.put(`${this.addressBase}/customer/${customerId}/set-default/${addressId}`, {});
  }
}

export function customerFullName(customer: Customer): string {
  return [customer.customerFirstName, customer.customerMiddleName, customer.customerLastName]
    .filter(Boolean)
    .join(' ')
    .trim();
}

/** Addresses arrive either as one free-text line or as structured parts — render whichever exists. */
export function formatAddress(address: CustomerAddress): string {
  const structured = [
    address.addressLine1,
    address.addressLine2,
    address.addressLine3,
    address.city,
    address.state,
    address.postalCode,
  ]
    .filter(Boolean)
    .join(', ');

  return structured || address.address || '—';
}
