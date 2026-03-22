import { makeAutoObservable, runInAction } from 'mobx';
import { consentsApi } from '../api/consentsApi';
import type { Consent, ConsentLog } from '../models/Consent';

export class ConsentStore {
  consents: Consent[] = [];
  logs: ConsentLog[] = [];
  isLoading = false;

  constructor() {
    makeAutoObservable(this);
  }

  private normalizeArray(data: unknown): unknown[] {
    if (Array.isArray(data)) return data;
    if (data && typeof data === 'object') {
      const obj = data as Record<string, unknown>;
      if (Array.isArray(obj.$values)) return obj.$values;
      if (Array.isArray(obj.data)) return obj.data;
    }
    return [];
  }

  async loadConsents() {
    this.isLoading = true;
    try {
      const res = await consentsApi.getAll();
      runInAction(() => { this.consents = this.normalizeArray(res.data) as Consent[]; this.isLoading = false; });
    } catch {
      runInAction(() => { this.isLoading = false; });
    }
  }

  async loadLogs(consentId?: string) {
    this.isLoading = true;
    try {
      const res = await consentsApi.getLogs(consentId);
      runInAction(() => { this.logs = this.normalizeArray(res.data) as ConsentLog[]; this.isLoading = false; });
    } catch {
      runInAction(() => { this.isLoading = false; });
    }
  }
}
