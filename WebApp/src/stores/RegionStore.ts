import { makeAutoObservable, runInAction } from 'mobx';
import { regionsApi } from '../api/regionsApi';
import type { ServiceRegion, CreateRegionDto } from '../models/Region';

export class RegionStore {
  regions: ServiceRegion[] = [];
  isLoading = false;
  error = '';
  searchQuery = '';
  cityFilter = '';
  regionTypeFilter: number | null = null;

  constructor() {
    makeAutoObservable(this);
  }

  setSearch(q: string) { this.searchQuery = q; }
  setCityFilter(city: string) { this.cityFilter = city; }
  setRegionTypeFilter(type: number | null) { this.regionTypeFilter = type; }

  get filteredRegions(): ServiceRegion[] {
    let result = this.regions;
    if (this.searchQuery) {
      const q = this.searchQuery.toLowerCase();
      result = result.filter((r) =>
        r.name.toLowerCase().includes(q) || r.city.toLowerCase().includes(q),
      );
    }
    if (this.cityFilter) {
      result = result.filter((r) => r.city === this.cityFilter);
    }
    if (this.regionTypeFilter !== null) {
      result = result.filter((r) => r.regionType === this.regionTypeFilter);
    }
    return result;
  }

  get cities(): string[] {
    return [...new Set(this.regions.map((r) => r.city).filter(Boolean))];
  }

  private normalizeArray(data: unknown): ServiceRegion[] {
    if (Array.isArray(data)) return data;
    if (data && typeof data === 'object') {
      const obj = data as Record<string, unknown>;
      if (Array.isArray(obj.$values)) return obj.$values as ServiceRegion[];
      if (Array.isArray(obj.data)) return obj.data as ServiceRegion[];
    }
    return [];
  }

  async loadRegions() {
    this.isLoading = true;
    try {
      const res = await regionsApi.getAll();
      runInAction(() => {
        this.regions = this.normalizeArray(res.data);
        this.isLoading = false;
      });
    } catch {
      runInAction(() => { this.error = 'Failed to load regions'; this.isLoading = false; });
    }
  }

  async createRegion(data: CreateRegionDto) {
    try {
      await regionsApi.create(data);
      await this.loadRegions();
      return true;
    } catch { return false; }
  }

  async deleteRegion(id: string) {
    try {
      await regionsApi.delete(id);
      runInAction(() => { this.regions = this.regions.filter((r) => r.serviceRegionId !== id); });
      return true;
    } catch { return false; }
  }

  async addPinCode(regionId: string, pinCode: string) {
    try {
      await regionsApi.addPinCode(regionId, pinCode);
      await this.loadRegions();
      return true;
    } catch { return false; }
  }

  async removePinCode(regionId: string, pinCodeId: string) {
    try {
      await regionsApi.removePinCode(regionId, pinCodeId);
      await this.loadRegions();
      return true;
    } catch { return false; }
  }
}
