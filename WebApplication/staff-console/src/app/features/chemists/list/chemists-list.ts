import { HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatSelectModule } from '@angular/material/select';
import { Router } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { CapabilityService } from '../../../core/config/capabilities';
import { describeHttpError } from '../../../core/http/interceptors';
import { MedicalStore } from '../../../core/models/api.models';
import { ConfirmService } from '../../../core/ui/confirm-dialog';
import { ToastService } from '../../../core/ui/toast.service';
import { DataTable, RowAction, TableColumn } from '../../../shared/ui/data-table';
import { FilterBar } from '../../../shared/ui/filter-bar';
import { PageHeader } from '../../../shared/ui/page-header';
import { ChemistsApiService, chemistOwnerName } from '../data/chemists-api.service';

type StatusFilter = 'all' | 'active' | 'inactive';

@Component({
  selector: 'app-chemists-list',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [FormsModule, MatFormFieldModule, MatSelectModule, PageHeader, FilterBar, DataTable],
  template: `
    <app-page-header
      title="Chemists"
      subtitle="Medical stores that fulfil orders. Deactivating a store stops it receiving new assignments."
    />

    <app-filter-bar
      [(search)]="search"
      searchLabel="Search store, owner, mobile or pin code"
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
        <mat-label>City</mat-label>
        <mat-select [(ngModel)]="city">
          <mat-option value="all">All cities</mat-option>
          @for (name of cities(); track name) {
            <mat-option [value]="name">{{ name }}</mat-option>
          }
        </mat-select>
      </mat-form-field>
    </app-filter-bar>

    <app-data-table
      [rows]="filtered()"
      [columns]="columns"
      [actions]="actions()"
      [loading]="loading()"
      [error]="error()"
      [forbidden]="forbidden()"
      [trackBy]="trackBy"
      emptyIcon="local_pharmacy"
      emptyTitle="No chemists yet"
      emptyMessage="Chemists register themselves; once they do they will appear here."
      clickable
      (rowClick)="openDetail($event)"
      (retry)="load()"
    />
  `,
  styles: `
    :host { display: block; }
    mat-form-field { min-width: 160px; }
  `,
})
export class ChemistsList {
  private readonly api = inject(ChemistsApiService);
  private readonly confirm = inject(ConfirmService);
  private readonly toast = inject(ToastService);
  private readonly router = inject(Router);
  private readonly capabilities = inject(CapabilityService);

  protected readonly chemists = signal<MedicalStore[]>([]);
  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);
  protected readonly forbidden = signal(false);

  protected readonly search = signal('');
  protected readonly status = signal<StatusFilter>('all');
  protected readonly city = signal<string>('all');

  protected readonly canManage = computed(() => this.capabilities.can('manageChemists'));
  protected readonly trackBy = (row: MedicalStore) => row.medicalStoreId;

  protected readonly cities = computed(() =>
    [...new Set(this.chemists().map((c) => c.city).filter(Boolean))].sort(),
  );

  protected readonly columns: TableColumn<MedicalStore>[] = [
    { key: 'medicalName', header: 'Store', primary: true, value: (row) => row.medicalName || '—' },
    { key: 'owner', header: 'Owner', value: (row) => chemistOwnerName(row) || '—' },
    { key: 'mobileNumber', header: 'Mobile', value: (row) => row.mobileNumber || '—' },
    { key: 'city', header: 'City', value: (row) => row.city || '—' },
    { key: 'postalCode', header: 'Pin code', value: (row) => row.postalCode || '—' },
    {
      key: 'registrationStatus',
      header: 'Registration',
      value: (row) => (row.registrationStatus ? 'Complete' : 'Incomplete'),
      chip: (row) => ({
        label: row.registrationStatus ? 'Complete' : 'Incomplete',
        tone: row.registrationStatus ? 'positive' : 'warning',
      }),
    },
    {
      key: 'isActive',
      header: 'Status',
      value: (row) => (row.isActive ? 'Active' : 'Inactive'),
      chip: (row) => ({
        label: row.isActive ? 'Active' : 'Inactive',
        tone: row.isActive ? 'positive' : 'neutral',
      }),
    },
  ];

  protected readonly actions = computed<RowAction<MedicalStore>[]>(() => {
    const view: RowAction<MedicalStore> = {
      label: 'View',
      icon: 'visibility',
      run: (row) => this.openDetail(row),
    };

    if (!this.canManage()) {
      return [view];
    }

    return [
      view,
      {
        label: 'Deactivate',
        icon: 'block',
        hidden: (row) => !row.isActive,
        run: (row) => void this.setActive(row, false),
      },
      {
        label: 'Activate',
        icon: 'check_circle',
        hidden: (row) => row.isActive,
        run: (row) => void this.setActive(row, true),
      },
      { label: 'Delete', icon: 'delete', danger: true, run: (row) => void this.remove(row) },
    ];
  });

  protected readonly filtered = computed(() => {
    const term = this.search().trim().toLowerCase();
    const status = this.status();
    const city = this.city();

    return this.chemists().filter((chemist) => {
      if (status === 'active' && !chemist.isActive) {
        return false;
      }
      if (status === 'inactive' && chemist.isActive) {
        return false;
      }
      if (city !== 'all' && chemist.city !== city) {
        return false;
      }
      if (!term) {
        return true;
      }
      return [chemist.medicalName, chemistOwnerName(chemist), chemist.mobileNumber, chemist.postalCode]
        .join(' ')
        .toLowerCase()
        .includes(term);
    });
  });

  constructor() {
    void this.load();
  }

  protected async load(): Promise<void> {
    this.loading.set(true);
    this.error.set(null);
    this.forbidden.set(false);

    try {
      const chemists = await firstValueFrom(this.api.list());
      this.chemists.set((chemists ?? []).filter((c) => !c.isDeleted));
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
    this.city.set('all');
  }

  protected openDetail(chemist: MedicalStore): void {
    void this.router.navigate(['/chemists', chemist.medicalStoreId]);
  }

  private async setActive(chemist: MedicalStore, active: boolean): Promise<void> {
    const confirmed = await this.confirm.ask({
      title: active ? 'Activate chemist?' : 'Deactivate chemist?',
      message: active
        ? `${chemist.medicalName} will start receiving new order assignments again.`
        : `${chemist.medicalName} will stop receiving new order assignments. Orders already with them are unaffected.`,
      confirmLabel: active ? 'Activate' : 'Deactivate',
      danger: !active,
    });

    if (!confirmed) {
      return;
    }

    try {
      await firstValueFrom(
        active ? this.api.activate(chemist.medicalStoreId) : this.api.deactivate(chemist.medicalStoreId),
      );
      this.toast.success(active ? 'Chemist activated.' : 'Chemist deactivated.');
      await this.load();
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    }
  }

  private async remove(chemist: MedicalStore): Promise<void> {
    const confirmed = await this.confirm.ask({
      title: 'Delete chemist?',
      message: `${chemist.medicalName} will be removed from the roster and stop receiving orders.`,
      confirmLabel: 'Delete',
      danger: true,
    });

    if (!confirmed) {
      return;
    }

    try {
      await firstValueFrom(this.api.remove(chemist.medicalStoreId));
      this.toast.success('Chemist deleted.');
      await this.load();
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    }
  }
}
