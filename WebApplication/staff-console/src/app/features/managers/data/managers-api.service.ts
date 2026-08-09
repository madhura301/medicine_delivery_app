import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../../environments/environment';
import { Manager, ManagerRegistration, ManagerUpdate } from '../../../core/models/api.models';

@Injectable({ providedIn: 'root' })
export class ManagersApiService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiBaseUrl}/Managers`;

  list(): Observable<Manager[]> {
    return this.http.get<Manager[]>(this.base);
  }

  get(id: string): Observable<Manager> {
    return this.http.get<Manager>(`${this.base}/${id}`);
  }

  create(payload: ManagerRegistration): Observable<Manager> {
    return this.http.post<Manager>(`${this.base}/register`, payload);
  }

  update(id: string, payload: ManagerUpdate): Observable<Manager> {
    return this.http.put<Manager>(`${this.base}/${id}`, payload);
  }

  /** Soft delete — the row stays in the database with IsDeleted set. */
  remove(id: string): Observable<unknown> {
    return this.http.delete(`${this.base}/${id}`);
  }

  uploadPhoto(id: string, file: File): Observable<unknown> {
    const form = new FormData();
    form.append('file', file, file.name);
    return this.http.post(`${this.base}/${id}/photo`, form);
  }
}
