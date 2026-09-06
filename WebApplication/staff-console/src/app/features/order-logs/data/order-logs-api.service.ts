import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../../environments/environment';
import { OrderLog, OrderLogListItem, PagedResult } from '../../../core/models/api.models';
import { OrderLogReason } from '../../../core/models/enums';

export interface OrderLogFilters {
  search?: string;
  postalCode?: string;
  reason?: OrderLogReason | null;
  fromDate?: Date | null;
  toDate?: Date | null;
  page?: number;
  pageSize?: number;
}

@Injectable({ providedIn: 'root' })
export class OrderLogsApiService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiBaseUrl}/OrderLogs`;

  list(filters: OrderLogFilters = {}): Observable<PagedResult<OrderLogListItem>> {
    let params = new HttpParams();

    if (filters.search?.trim()) {
      params = params.set('search', filters.search.trim());
    }
    if (filters.postalCode?.trim()) {
      params = params.set('postalCode', filters.postalCode.trim());
    }
    if (filters.reason !== null && filters.reason !== undefined) {
      params = params.set('reason', filters.reason);
    }
    if (filters.fromDate) {
      params = params.set('fromDate', startOfDayUtc(filters.fromDate).toISOString());
    }
    if (filters.toDate) {
      params = params.set('toDate', endOfDayUtc(filters.toDate).toISOString());
    }

    params = params.set('page', filters.page ?? 1).set('pageSize', filters.pageSize ?? 50);

    return this.http.get<PagedResult<OrderLogListItem>>(this.base, { params });
  }

  get(orderLogId: number): Observable<OrderLog> {
    return this.http.get<OrderLog>(`${this.base}/${orderLogId}`);
  }
}

/**
 * The date pickers hand back a local midnight. The API compares against UTC timestamps, so a
 * "from 3 Sep" filter has to mean 3 Sep 00:00 in the user's own day, not in UTC — otherwise an
 * IST user silently loses the first 5.5 hours of the range.
 */
function startOfDayUtc(date: Date): Date {
  const start = new Date(date);
  start.setHours(0, 0, 0, 0);
  return start;
}

function endOfDayUtc(date: Date): Date {
  const end = new Date(date);
  end.setHours(23, 59, 59, 999);
  return end;
}
