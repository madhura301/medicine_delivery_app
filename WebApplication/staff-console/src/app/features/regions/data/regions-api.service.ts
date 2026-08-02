import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, map } from 'rxjs';
import { environment } from '../../../../environments/environment';
import {
  AssignCustomerSupportRegion,
  AssignCustomerSupportRegionBulk,
  AssignDeliveryRegion,
  AssignDeliveryRegionBulk,
  CreateServiceRegion,
  ServiceRegion,
} from '../../../core/models/api.models';
import { RegionType } from '../../../core/models/enums';

/**
 * Service regions come in two flavours distinguished by RegionType: support regions decide which
 * agent picks up a rejected order, delivery regions decide which delivery partners are eligible.
 * The API stores both in one collection, so callers filter by type.
 */
@Injectable({ providedIn: 'root' })
export class RegionsApiService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiBaseUrl}/ServiceRegions`;

  list(): Observable<ServiceRegion[]> {
    return this.http.get<ServiceRegion[]>(this.base);
  }

  listByType(type: RegionType): Observable<ServiceRegion[]> {
    return this.list().pipe(map((regions) => regions.filter((r) => r.regionType === type)));
  }

  get(id: number): Observable<ServiceRegion> {
    return this.http.get<ServiceRegion>(`${this.base}/${id}`);
  }

  create(payload: CreateServiceRegion): Observable<ServiceRegion> {
    return this.http.post<ServiceRegion>(this.base, payload);
  }

  update(id: number, payload: Partial<CreateServiceRegion>): Observable<ServiceRegion> {
    return this.http.put<ServiceRegion>(`${this.base}/${id}`, payload);
  }

  /** Hard delete — the API removes the region and its pin codes outright. */
  remove(id: number): Observable<unknown> {
    return this.http.delete(`${this.base}/${id}`);
  }

  addPinCode(serviceRegionId: number, pinCode: string): Observable<unknown> {
    return this.http.post(`${this.base}/add-pincode`, { serviceRegionId, pinCode });
  }

  removePinCode(serviceRegionId: number, pinCode: string): Observable<unknown> {
    return this.http.post(`${this.base}/remove-pincode`, { serviceRegionId, pinCode });
  }

  pinCodes(regionId: number): Observable<string[]> {
    return this.http.get<string[]>(`${this.base}/${regionId}/pincodes`);
  }

  byPinCode(pinCode: string): Observable<ServiceRegion | null> {
    return this.http.get<ServiceRegion | null>(`${this.base}/by-pincode/${pinCode}`);
  }

  /** Pass serviceRegionId: null to clear the agent's region. */
  assignCustomerSupport(payload: AssignCustomerSupportRegion): Observable<unknown> {
    return this.http.post(`${this.base}/assign`, payload);
  }

  assignCustomerSupportBulk(payload: AssignCustomerSupportRegionBulk): Observable<unknown> {
    return this.http.post(`${this.base}/assign/bulk`, payload);
  }

  /** Pass serviceRegionId: null to clear the delivery partner's region. */
  assignDelivery(payload: AssignDeliveryRegion): Observable<unknown> {
    return this.http.post(`${this.base}/assign-delivery`, payload);
  }

  assignDeliveryBulk(payload: AssignDeliveryRegionBulk): Observable<unknown> {
    return this.http.post(`${this.base}/assign-delivery/bulk`, payload);
  }
}

/** "Pune West — Pune (3 pin codes)" for dropdowns and table cells. */
export function describeRegion(region: ServiceRegion): string {
  const count = region.pinCodes?.length ?? 0;
  const pins = count === 1 ? '1 pin code' : `${count} pin codes`;
  return `${region.regionName || region.name} — ${region.city} (${pins})`;
}
