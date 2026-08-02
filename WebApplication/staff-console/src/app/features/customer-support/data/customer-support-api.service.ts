import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../../environments/environment';
import {
  CustomerSupport,
  CustomerSupportRegistration,
  CustomerSupportUpdate,
} from '../../../core/models/api.models';

@Injectable({ providedIn: 'root' })
export class CustomerSupportApiService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiBaseUrl}/CustomerSupports`;

  list(): Observable<CustomerSupport[]> {
    return this.http.get<CustomerSupport[]>(this.base);
  }

  get(id: string): Observable<CustomerSupport> {
    return this.http.get<CustomerSupport>(`${this.base}/${id}`);
  }

  create(payload: CustomerSupportRegistration): Observable<CustomerSupport> {
    return this.http.post<CustomerSupport>(`${this.base}/register`, payload);
  }

  update(id: string, payload: CustomerSupportUpdate): Observable<CustomerSupport> {
    return this.http.put<CustomerSupport>(`${this.base}/${id}`, payload);
  }

  /** Soft delete. */
  remove(id: string): Observable<unknown> {
    return this.http.delete(`${this.base}/${id}`);
  }

  uploadPhoto(id: string, file: File): Observable<unknown> {
    const form = new FormData();
    form.append('file', file, file.name);
    return this.http.post(`${this.base}/${id}/photo`, form);
  }
}

export function agentFullName(agent: CustomerSupport): string {
  return [
    agent.customerSupportFirstName,
    agent.customerSupportMiddleName,
    agent.customerSupportLastName,
  ]
    .filter(Boolean)
    .join(' ')
    .trim();
}
