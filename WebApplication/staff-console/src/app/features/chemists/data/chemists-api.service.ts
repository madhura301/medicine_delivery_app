import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../../environments/environment';
import {
  ChemistActivation,
  ChemistPayoutAccount,
  MedicalStore,
  MedicalStoreUpdate,
} from '../../../core/models/api.models';

@Injectable({ providedIn: 'root' })
export class ChemistsApiService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiBaseUrl}/MedicalStores`;
  private readonly payoutBase = `${environment.apiBaseUrl}/chemist-payout`;

  list(): Observable<MedicalStore[]> {
    return this.http.get<MedicalStore[]>(this.base);
  }

  get(id: string): Observable<MedicalStore> {
    return this.http.get<MedicalStore>(`${this.base}/${id}`);
  }

  update(id: string, payload: MedicalStoreUpdate): Observable<MedicalStore> {
    return this.http.put<MedicalStore>(`${this.base}/${id}`, payload);
  }

  /** An inactive store stops receiving new order assignments. */
  activate(id: string): Observable<unknown> {
    return this.http.post(`${this.base}/${id}/activate`, {});
  }

  deactivate(id: string): Observable<unknown> {
    return this.http.post(`${this.base}/${id}/deactivate`, {});
  }

  /** Soft delete. */
  remove(id: string): Observable<unknown> {
    return this.http.delete(`${this.base}/${id}`);
  }

  /** Irreversible — Admin only, and gated behind a typed confirmation in the UI. */
  hardDelete(id: string): Observable<unknown> {
    return this.http.delete(`${this.base}/${id}/hard`);
  }

  payoutAccount(storeId: string): Observable<ChemistPayoutAccount> {
    return this.http.get<ChemistPayoutAccount>(`${this.payoutBase}/${storeId}`);
  }

  activation(storeId: string): Observable<ChemistActivation> {
    return this.http.get<ChemistActivation>(`${this.payoutBase}/${storeId}/activation`);
  }
}

export function chemistOwnerName(store: MedicalStore): string {
  return [store.ownerFirstName, store.ownerMiddleName, store.ownerLastName]
    .filter(Boolean)
    .join(' ')
    .trim();
}

export function chemistAddress(store: MedicalStore): string {
  return (
    [store.addressLine1, store.addressLine2, store.city, store.state, store.postalCode]
      .filter(Boolean)
      .join(', ') || '—'
  );
}
