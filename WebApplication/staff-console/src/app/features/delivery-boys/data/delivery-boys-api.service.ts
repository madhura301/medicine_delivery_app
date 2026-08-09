import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../../environments/environment';
import { CreateDeliveryBoy, DeliveryBoy, UpdateDeliveryBoy } from '../../../core/models/api.models';

@Injectable({ providedIn: 'root' })
export class DeliveryBoysApiService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiBaseUrl}/Deliveries`;

  /**
   * Requires the DeliveryRead permission, which CustomerSupport does not hold — the menu hides
   * this feature from them entirely (see docs/FUNCTIONAL_SPEC.md §13.3).
   */
  list(): Observable<DeliveryBoy[]> {
    return this.http.get<DeliveryBoy[]>(this.base);
  }

  get(id: number): Observable<DeliveryBoy> {
    return this.http.get<DeliveryBoy>(`${this.base}/${id}`);
  }

  /** Also creates the partner's mobile-app login (username = mobile number, role DeliveryBoy). */
  create(payload: CreateDeliveryBoy): Observable<DeliveryBoy> {
    return this.http.post<DeliveryBoy>(this.base, payload);
  }

  update(id: number, payload: UpdateDeliveryBoy): Observable<DeliveryBoy> {
    return this.http.put<DeliveryBoy>(`${this.base}/${id}`, payload);
  }

  /** Soft delete. */
  remove(id: number): Observable<unknown> {
    return this.http.delete(`${this.base}/${id}`);
  }
}

export function deliveryBoyName(row: DeliveryBoy): string {
  return [row.firstName, row.middleName, row.lastName].filter(Boolean).join(' ').trim() || '—';
}
