import { HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MatDialog } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatSelectModule } from '@angular/material/select';
import { Router } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { CapabilityService } from '../../../core/config/capabilities';
import { describeHttpError } from '../../../core/http/interceptors';
import { CustomerSupport, ServiceRegion } from '../../../core/models/api.models';
import { RegionType } from '../../../core/models/enums';
import { ConfirmService } from '../../../core/ui/confirm-dialog';
import { ToastService } from '../../../core/ui/toast.service';
import { DataTable, RowAction, TableColumn } from '../../../shared/ui/data-table';
import { FilterBar } from '../../../shared/ui/filter-bar';
import { PageHeader } from '../../../shared/ui/page-header';
import { RegionsApiService } from '../../regions/data/regions-api.service';
import { AssignRegionData, AssignRegionDialog } from '../../regions/dialogs/assign-region-dialog';
import { CustomerSupportApiService, agentFullName } from '../data/customer-support-api.service';
import {
  CustomerSupportFormData,
  CustomerSupportFormDialog,
} from '../dialogs/customer-support-form-dialog';

type StatusFilter = 'all' | 'active' | 'inactive';
/** -1 means "no region assigned". */
type RegionFilter = number | 'all' | -1;

@Component({
  selector: 'app-customer-support-list',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [FormsModule, MatFormFieldModule, MatSelectModule, PageHeader, FilterBar, DataTable],
  template: `
    <app-page-header
      title="Customer Support"
      subtitle="Agents who pick up orders a chemist has rejected, based on the pin codes their region covers."
      [actionLabel]="canManage() ? 'Add agent' : ''"
      (action)="openForm()"
    />

    <app-filter-bar
      [(search)]="search"
      searchLabel="Search name, mobile, email or employee ID"
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
      emptyIcon="support_agent"
      emptyTitle="No support agents yet"
      [emptyMessage]="
        canManage()
          ? 'Add the first agent, then assign them a support region.'
          : 'No support agents have been added.'
      "
      [emptyActionLabel]="canManage() ? 'Add agent' : ''"
      clickable
      (rowClick)="openDetail($event)"
      (emptyAction)="openForm()"
      (retry)="load()"
    />
  `,
  styles: `
    :host { display: block; }
    mat-form-field { min-width: 160px; }
  `,
})
export class CustomerSupportList {
  private readonly api = inject(CustomerSupportApiService);
  private readonly regionsApi = inject(RegionsApiService);
  private readonly dialog = inject(MatDialog);
  private readonly confirm = inject(ConfirmService);
  private readonly toast = inject(ToastService);
  private readonly router = inject(Router);
  private readonly capabilities = inject(CapabilityService);

  protected readonly agents = signal<CustomerSupport[]>([]);
  protected readonly regions = signal<ServiceRegion[]>([]);
  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);
  protected readonly forbidden = signal(false);

  protected readonly search = signal('');
  protected readonly status = signal<StatusFilter>('all');
  protected readonly regionFilter = signal<RegionFilter>('all');

  protected readonly canManage = computed(() => this.capabilities.can('manageCustomerSupport'));
  protected readonly trackBy = (row: CustomerSupport) => row.customerSupportId;

  private readonly regionNames = computed(() => {
    const map = new Map<number, string>();
    for (const region of this.regions()) {
      map.set(region.id, region.regionName || region.name);
    }
    return map;
  });

  protected readonly columns = computed<TableColumn<CustomerSupport>[]>(() => [
    { key: 'employeeId', header: 'Employee ID', value: (row) => row.employeeId || '—' },
    { key: 'name', header: 'Name', primary: true, value: (row) => agentFullName(row) },
    { key: 'mobileNumber', header: 'Mobile', value: (row) => row.mobileNumber || '—' },
    { key: 'emailId', header: 'Email', value: (row) => row.emailId || '—' },
    {
      key: 'region',
      header: 'Region',
      value: (row) => this.regionLabel(row),
      chip: (row) => ({
        label: this.regionLabel(row),
        tone: row.serviceRegionId ? 'info' : 'warning',
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
  ]);

  protected readonly actions = computed<RowAction<CustomerSupport>[]>(() => {
    const view: RowAction<CustomerSupport> = {
      label: 'View',
      icon: 'visibility',
      run: (row) => this.openDetail(row),
    };

    if (!this.canManage()) {
      return [view];
    }

    return [
      view,
      { label: 'Edit', icon: 'edit', run: (row) => void this.openForm(row) },
      { label: 'Assign region', icon: 'map', run: (row) => void this.assignRegion(row) },
      { label: 'Delete', icon: 'delete', danger: true, run: (row) => void this.remove(row) },
    ];
  });

  protected readonly filtered = computed(() => {
    const term = this.search().trim().toLowerCase();
    const status = this.status();
    const region = this.regionFilter();

    return this.agents().filter((agent) => {
      if (status === 'active' && !agent.isActive) {
        return false;
      }
      if (status === 'inactive' && agent.isActive) {
        return false;
      }
      if (region === -1 && agent.serviceRegionId) {
        return false;
      }
      if (typeof region === 'number' && region !== -1 && agent.serviceRegionId !== region) {
        return false;
      }
      if (!term) {
        return true;
      }
      return [agentFullName(agent), agent.mobileNumber, agent.emailId, agent.employeeId]
        .join(' ')
        .toLowerCase()
        .includes(term);
    });
  });

  constructor() {
    void this.load();
  }

  private regionLabel(agent: CustomerSupport): string {
    if (!agent.serviceRegionId) {
      return 'Unassigned';
    }
    return this.regionNames().get(agent.serviceRegionId) ?? `Region ${agent.serviceRegionId}`;
  }

  protected async load(): Promise<void> {
    this.loading.set(true);
    this.error.set(null);
    this.forbidden.set(false);

    try {
      const [agents, regions] = await Promise.all([
        firstValueFrom(this.api.list()),
        firstValueFrom(this.regionsApi.listByType(RegionType.CustomerSupport)).catch(() => []),
      ]);
      this.agents.set((agents ?? []).filter((a) => !a.isDeleted));
      this.regions.set(regions);
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

  protected openDetail(agent: CustomerSupport): void {
    void this.router.navigate(['/customer-support', agent.customerSupportId]);
  }

  protected async openForm(agent?: CustomerSupport): Promise<void> {
    if (!this.canManage()) {
      return;
    }

    const ref = this.dialog.open<CustomerSupportFormDialog, CustomerSupportFormData, boolean>(
      CustomerSupportFormDialog,
      { data: { agent }, width: '680px', maxWidth: '96vw', autoFocus: 'first-tabbable' },
    );

    if (await firstValueFrom(ref.afterClosed())) {
      await this.load();
    }
  }

  private async assignRegion(agent: CustomerSupport): Promise<void> {
    const ref = this.dialog.open<AssignRegionDialog, AssignRegionData, boolean>(
      AssignRegionDialog,
      {
        data: {
          kind: 'customer-support',
          subjectId: agent.customerSupportId,
          subjectName: agentFullName(agent),
          currentRegionId: agent.serviceRegionId,
        },
        width: '460px',
        maxWidth: '94vw',
      },
    );

    if (await firstValueFrom(ref.afterClosed())) {
      await this.load();
    }
  }

  private async remove(agent: CustomerSupport): Promise<void> {
    const confirmed = await this.confirm.ask({
      title: 'Delete support agent?',
      message: `${agentFullName(agent)} will no longer be able to sign in or receive rejected orders.`,
      confirmLabel: 'Delete',
      danger: true,
    });

    if (!confirmed) {
      return;
    }

    try {
      await firstValueFrom(this.api.remove(agent.customerSupportId));
      this.toast.success('Support agent deleted.');
      await this.load();
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    }
  }
}
