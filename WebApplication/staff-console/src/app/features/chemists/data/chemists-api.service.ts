import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../../environments/environment';
import {
  ChemistActivation,
  ChemistPayoutAccount,
  ChemistsNearLocation,
  MedicalStore,
  MedicalStoreRegistration,
  MedicalStoreRegistrationResult,
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

  /**
   * Creates the store and its login account in one call.
   *
   * The endpoint is [AllowAnonymous] because the mobile app's self-registration screen uses it too;
   * the console still sends its bearer token like every other call. Registration alone does not make
   * a chemist eligible for orders — payout onboarding and the activation fee are separate steps on
   * the chemist's detail page.
   */
  register(payload: MedicalStoreRegistration): Observable<MedicalStoreRegistrationResult> {
    return this.http.post<MedicalStoreRegistrationResult>(`${this.base}/register`, payload);
  }

  get(id: string): Observable<MedicalStore> {
    return this.http.get<MedicalStore>(`${this.base}/${id}`);
  }

  /**
   * Every chemist within the order-routing radius of a point, marked with whether an order placed
   * there would reach it. Staff only — chemists hold ChemistRead but not AllChemistRead.
   */
  nearby(latitude: number, longitude: number): Observable<ChemistsNearLocation> {
    return this.http.get<ChemistsNearLocation>(`${this.base}/nearby`, {
      params: { latitude, longitude },
    });
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

  /**
   * Pulls the account's current state from Razorpay and writes it to our database.
   * Used by "Sync with database" when a missed webhook has left the two out of step.
   */
  syncPayoutFromRazorpay(storeId: string): Observable<ChemistPayoutAccount> {
    return this.http.post<ChemistPayoutAccount>(`${this.payoutBase}/refresh/${storeId}`, {});
  }

  /**
   * Pulls the activation payment link's state from Razorpay and writes it to our record.
   * This is the repair path for a missed `payment_link.paid` webhook — without it, a chemist who
   * has paid stays un-activated and receives no orders.
   */
  syncActivationFromRazorpay(storeId: string): Observable<ChemistActivation> {
    return this.http.post<ChemistActivation>(`${this.payoutBase}/${storeId}/activation/refresh`, {});
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
