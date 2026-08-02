import { HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, computed, inject, signal } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatSelectModule } from '@angular/material/select';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { CapabilityService } from '../../../core/config/capabilities';
import { describeHttpError } from '../../../core/http/interceptors';
import { Manager } from '../../../core/models/api.models';
import { ConfirmService } from '../../../core/ui/confirm-dialog';
import { ToastService } from '../../../core/ui/toast.service';
import { DataTable, RowAction, TableColumn } from '../../../shared/ui/data-table';
import { FilterBar } from '../../../shared/ui/filter-bar';
import { PageHeader } from '../../../shared/ui/page-header';
import { ManagersApiService } from '../data/managers-api.service';
import { ManagerFormDialog, ManagerFormData } from '../dialogs/manager-form-dialog';

type StatusFilter = 'all' | 'active' | 'inactive';

@Component({
  selector: 'app-managers-list',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    FormsModule,
    MatFormFieldModule,
    MatSelectModule,
    PageHeader,
    FilterBar,
    DataTable,
  ],
  template: `
    <app-page-header
      title="Managers"
      subtitle="Staff who handle escalated orders and oversee chemists, support agents and delivery partners."
      [actionLabel]="canManage() ? 'Add manager' : ''"
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
    </app-filter-bar>

    <app-data-table
      [rows]="filtered()"
      [columns]="columns"
      [actions]="actions()"
      [loading]="loading()"
      [error]="error()"
      [forbidden]="forbidden()"
      [trackBy]="trackBy"
      emptyIcon="manage_accounts"
      emptyTitle="No managers yet"
      [emptyMessage]="canManage() ? 'Add the first manager to get started.' : 'No managers have been added.'"
      [emptyActionLabel]="canManage() ? 'Add manager' : ''"
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
export class ManagersList {
  private readonly api = inject(ManagersApiService);
  private readonly dialog = inject(MatDialog);
  private readonly confirm = inject(ConfirmService);
  private readonly toast = inject(ToastService);
  private readonly router = inject(Router);
  private readonly capabilities = inject(CapabilityService);

  protected readonly managers = signal<Manager[]>([]);
  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);
  protected readonly forbidden = signal(false);

  protected readonly search = signal('');
  protected readonly status = signal<StatusFilter>('all');

  protected readonly canManage = computed(() => this.capabilities.can('manageManagers'));

  protected readonly trackBy = (row: Manager) => row.managerId;

  protected readonly columns: TableColumn<Manager>[] = [
    {
      key: 'employeeId',
      header: 'Employee ID',
      value: (row) => row.employeeId || '—',
    },
    {
      key: 'name',
      header: 'Name',
      primary: true,
      value: (row) => fullName(row),
    },
    { key: 'mobileNumber', header: 'Mobile', value: (row) => row.mobileNumber || '—' },
    { key: 'emailId', header: 'Email', value: (row) => row.emailId || '—' },
    { key: 'city', header: 'City', value: (row) => row.city || '—' },
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

  protected readonly actions = computed<RowAction<Manager>[]>(() => {
    const view: RowAction<Manager> = {
      label: 'View',
      icon: 'visibility',
      run: (row) => this.openDetail(row),
    };

    if (!this.canManage()) {
      return [view];
    }

    return [
      view,
      { label: 'Edit', icon: 'edit', run: (row) => this.openForm(row) },
      { label: 'Delete', icon: 'delete', danger: true, run: (row) => void this.remove(row) },
    ];
  });

  protected readonly filtered = computed(() => {
    const term = this.search().trim().toLowerCase();
    const status = this.status();

    return this.managers().filter((manager) => {
      if (status === 'active' && !manager.isActive) {
        return false;
      }
      if (status === 'inactive' && manager.isActive) {
        return false;
      }
      if (!term) {
        return true;
      }
      return [fullName(manager), manager.mobileNumber, manager.emailId, manager.employeeId]
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
      const managers = await firstValueFrom(this.api.list());
      this.managers.set((managers ?? []).filter((m) => !m.isDeleted));
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
  }

  protected openDetail(manager: Manager): void {
    void this.router.navigate(['/managers', manager.managerId]);
  }

  protected async openForm(manager?: Manager): Promise<void> {
    if (!this.canManage()) {
      return;
    }

    const ref = this.dialog.open<ManagerFormDialog, ManagerFormData, boolean>(ManagerFormDialog, {
      data: { manager },
      width: '640px',
      maxWidth: '96vw',
      autoFocus: 'first-tabbable',
    });

    if (await firstValueFrom(ref.afterClosed())) {
      await this.load();
    }
  }

  private async remove(manager: Manager): Promise<void> {
    const confirmed = await this.confirm.ask({
      title: 'Delete manager?',
      message: `${fullName(manager)} will no longer be able to sign in or receive escalated orders.`,
      confirmLabel: 'Delete',
      danger: true,
    });

    if (!confirmed) {
      return;
    }

    try {
      await firstValueFrom(this.api.remove(manager.managerId));
      this.toast.success('Manager deleted.');
      await this.load();
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    }
  }
}

export function fullName(manager: Manager): string {
  return [manager.managerFirstName, manager.managerMiddleName, manager.managerLastName]
    .filter(Boolean)
    .join(' ')
    .trim();
}
