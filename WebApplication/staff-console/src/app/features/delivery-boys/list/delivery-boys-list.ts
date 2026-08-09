import { HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MatDialog } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatSelectModule } from '@angular/material/select';
import { firstValueFrom } from 'rxjs';
import { CapabilityService } from '../../../core/config/capabilities';
import { describeHttpError } from '../../../core/http/interceptors';
import { DeliveryBoy, MedicalStore, ServiceRegion } from '../../../core/models/api.models';
import { RegionType } from '../../../core/models/enums';
import { ConfirmService } from '../../../core/ui/confirm-dialog';
import { ToastService } from '../../../core/ui/toast.service';
import { DataTable, RowAction, TableColumn } from '../../../shared/ui/data-table';
import { FilterBar } from '../../../shared/ui/filter-bar';
import { PageHeader } from '../../../shared/ui/page-header';
import { ChemistsApiService } from '../../chemists/data/chemists-api.service';
import { RegionsApiService } from '../../regions/data/regions-api.service';
import { AssignRegionData, AssignRegionDialog } from '../../regions/dialogs/assign-region-dialog';
import { DeliveryBoysApiService, deliveryBoyName } from '../data/delivery-boys-api.service';
import { DeliveryBoyFormData, DeliveryBoyFormDialog } from '../dialogs/delivery-boy-form-dialog';

type StatusFilter = 'all' | 'active' | 'inactive';
type RegionFilter = number | 'all' | -1;

@Component({
  selector: 'app-delivery-boys-list',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [FormsModule, MatFormFieldModule, MatSelectModule, PageHeader, FilterBar, DataTable],
  template: `
    <app-page-header
      title="Delivery Boys"
      subtitle="Delivery partners and the region whose pin codes make them eligible for an order."
      [actionLabel]="canManage() ? 'Add delivery partner' : ''"
      (action)="openForm()"
    />

    <app-filter-bar
      [(search)]="search"
      searchLabel="Search name, mobile or licence number"
      (resetFilters)="resetFilters()"
    >
      <mat-form-field appearance="outline" subscriptSizing="dynamic">
        <mat-label>Status</mat-label>
        <mat-select [(ngModel)]="status">
          <mat-option value="all">All</mat-option>
          <mat-option value="active">Active</mat-option>
          <mat-option value="inactive">Inactive</mat-option>
        </mat-select>
      </mat-form-field>

      <mat-form-field appearance="outline" subscriptSizing="dynamic">
        <mat-label>Region</mat-label>
        <mat-select [(ngModel)]="regionFilter">
          <mat-option value="all">All regions</mat-option>
          <mat-option [value]="-1">Unassigned</mat-option>
          @for (region of regions(); track region.id) {
            <mat-option [value]="region.id">{{ region.regionName || region.name }}</mat-option>
          }
        </mat-select>
      </mat-form-field>
    </app-filter-bar>

    <app-data-table
      [rows]="filtered()"
      [columns]="columns()"
      [actions]="actions()"
      [loading]="loading()"
      [error]="error()"
      [forbidden]="forbidden()"
      [trackBy]="trackBy"
      emptyIcon="two_wheeler"
      emptyTitle="No delivery partners yet"
      [emptyMessage]="
        canManage()
          ? 'Add the first partner — creating one also creates their mobile-app login.'
          : 'No delivery partners have been added.'
      "
      [emptyActionLabel]="canManage() ? 'Add delivery partner' : ''"
      (emptyAction)="openForm()"
      (retry)="load()"
    />
  `,
  styles: `
    :host { display: block; }
    mat-form-field { min-width: 160px; }
  `,
})
export class DeliveryBoysList {
  private readonly api = inject(DeliveryBoysApiService);
  private readonly regionsApi = inject(RegionsApiService);
  private readonly chemistsApi = inject(ChemistsApiService);
  private readonly dialog = inject(MatDialog);
  private readonly confirm = inject(ConfirmService);
  private readonly toast = inject(ToastService);
  private readonly capabilities = inject(CapabilityService);

  protected readonly partners = signal<DeliveryBoy[]>([]);
  protected readonly regions = signal<ServiceRegion[]>([]);
  protected readonly stores = signal<MedicalStore[]>([]);
  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);
  protected readonly forbidden = signal(false);

  protected readonly search = signal('');
  protected readonly status = signal<StatusFilter>('all');
  protected readonly regionFilter = signal<RegionFilter>('all');

  protected readonly canManage = computed(() => this.capabilities.can('manageDeliveryBoys'));
  protected readonly trackBy = (row: DeliveryBoy) => row.id;

  private readonly regionNames = computed(() => {
    const map = new Map<number, string>();
    for (const region of this.regions()) {
      map.set(region.id, region.regionName || region.name);
    }
    return map;
  });

  private readonly storeNames = computed(() => {
    const map = new Map<string, string>();
    for (const store of this.stores()) {
      map.set(store.medicalStoreId, store.medicalName);
    }
    return map;
  });

  protected readonly columns = computed<TableColumn<DeliveryBoy>[]>(() => [
    { key: 'name', header: 'Name', primary: true, value: (row) => deliveryBoyName(row) },
    { key: 'mobileNumber', header: 'Mobile', value: (row) => row.mobileNumber || '—' },
    {
      key: 'drivingLicenceNumber',
      header: 'Driving licence',
      value: (row) => row.drivingLicenceNumber || '—',
    },
    {
      key: 'region',
      header: 'Region',
      value: (row) => this.regionLabel(row),
      chip: (row) => ({
        label: this.regionLabel(row),
        tone: row.serviceRegionId ? 'info' : 'warning',
      }),
    },
    { key: 'store', header: 'Medical store', value: (row) => this.storeLabel(row) },
    {
      key: 'isActive',
      header: 'Status',
      value: (row) => (row.isActive ? 'Active' : 'Inactive'),
      chip: (row) => ({
        label: row.isActive ? 'Active' : 'Inactive',
        tone: row.isActive ? 'positive' : 'neutral',
      }),
    },
  ]);

  protected readonly actions = computed<RowAction<DeliveryBoy>[]>(() => {
    if (!this.canManage()) {
      return [];
    }

    return [
      { label: 'Edit', icon: 'edit', run: (row) => void this.openForm(row) },
      { label: 'Assign region', icon: 'map', run: (row) => void this.assignRegion(row) },
      { label: 'Delete', icon: 'delete', danger: true, run: (row) => void this.remove(row) },
    ];
  });

  protected readonly filtered = computed(() => {
    const term = this.search().trim().toLowerCase();
    const status = this.status();
    const region = this.regionFilter();

    return this.partners().filter((partner) => {
      if (status === 'active' && !partner.isActive) {
        return false;
      }
      if (status === 'inactive' && partner.isActive) {
        return false;
      }
      if (region === -1 && partner.serviceRegionId) {
        return false;
      }
      if (typeof region === 'number' && region !== -1 && partner.serviceRegionId !== region) {
        return false;
      }
      if (!term) {
        return true;
      }
      return [deliveryBoyName(partner), partner.mobileNumber, partner.drivingLicenceNumber]
        .join(' ')
        .toLowerCase()
        .includes(term);
    });
  });

  constructor() {
    void this.load();
  }

  private regionLabel(partner: DeliveryBoy): string {
    if (!partner.serviceRegionId) {
      return 'Unassigned';
    }
    return this.regionNames().get(partner.serviceRegionId) ?? `Region ${partner.serviceRegionId}`;
  }

  private storeLabel(partner: DeliveryBoy): string {
    if (!partner.medicalStoreId) {
      return '—';
    }
    return this.storeNames().get(partner.medicalStoreId) ?? '—';
  }

  protected async load(): Promise<void> {
    this.loading.set(true);
    this.error.set(null);
    this.forbidden.set(false);

    try {
      const [partners, regions, stores] = await Promise.all([
        firstValueFrom(this.api.list()),
        firstValueFrom(this.regionsApi.listByType(RegionType.DeliveryBoy)).catch(() => []),
        firstValueFrom(this.chemistsApi.list()).catch(() => []),
      ]);
      this.partners.set((partners ?? []).filter((p) => !p.isDeleted));
      this.regions.set(regions);
      this.stores.set(stores);
    } catch (err) {
      const error = err as HttpErrorResponse;
      this.forbidden.set(error.status === 403);
      this.error.set(describeHttpError(error));
    } finally {
      this.loading.set(false);
    }
  }

  protected resetFilters(): void {
    this.search.set('');
    this.status.set('all');
    this.regionFilter.set('all');
  }

  protected async openForm(deliveryBoy?: DeliveryBoy): Promise<void> {
    if (!this.canManage()) {
      return;
    }

    const ref = this.dialog.open<DeliveryBoyFormDialog, DeliveryBoyFormData, boolean>(
      DeliveryBoyFormDialog,
      { data: { deliveryBoy }, width: '640px', maxWidth: '96vw', autoFocus: 'first-tabbable' },
    );

    if (await firstValueFrom(ref.afterClosed())) {
      await this.load();
    }
  }

  private async assignRegion(partner: DeliveryBoy): Promise<void> {
    const ref = this.dialog.open<AssignRegionDialog, AssignRegionData, boolean>(AssignRegionDialog, {
      data: {
        kind: 'delivery',
        subjectId: partner.id,
        subjectName: deliveryBoyName(partner),
        currentRegionId: partner.serviceRegionId,
      },
      width: '460px',
      maxWidth: '94vw',
    });

    if (await firstValueFrom(ref.afterClosed())) {
      await this.load();
    }
  }

  private async remove(partner: DeliveryBoy): Promise<void> {
    const confirmed = await this.confirm.ask({
      title: 'Delete delivery partner?',
      message: `${deliveryBoyName(partner)} will no longer be able to sign in or be assigned deliveries.`,
      confirmLabel: 'Delete',
      danger: true,
    });

    if (!confirmed) {
      return;
    }

    try {
      await firstValueFrom(this.api.remove(partner.id));
      this.toast.success('Delivery partner deleted.');
      await this.load();
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    }
  }
}
