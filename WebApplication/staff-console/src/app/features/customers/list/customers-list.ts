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
import { Customer } from '../../../core/models/api.models';
import { ConfirmService } from '../../../core/ui/confirm-dialog';
import { ToastService } from '../../../core/ui/toast.service';
import { DataTable, RowAction, TableColumn } from '../../../shared/ui/data-table';
import { FilterBar } from '../../../shared/ui/filter-bar';
import { PageHeader } from '../../../shared/ui/page-header';
import { CustomersApiService, customerFullName } from '../data/customers-api.service';
import { CustomerFormData, CustomerFormDialog } from '../dialogs/customer-form-dialog';

type StatusFilter = 'all' | 'active' | 'inactive';

@Component({
  selector: 'app-customers-list',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [FormsModule, MatFormFieldModule, MatSelectModule, PageHeader, FilterBar, DataTable],
  template: `
    <app-page-header
      title="Customers"
      subtitle="People who place orders through the mobile app."
      [actionLabel]="canManage() ? 'Add customer' : ''"
      (action)="openForm()"
    />

    <app-filter-bar
      [(search)]="search"
      searchLabel="Search name, mobile or customer number"
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
      emptyIcon="people"
      emptyTitle="No customers yet"
      emptyMessage="Customers register through the mobile app; they will appear here once they do."
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
export class CustomersList {
  private readonly api = inject(CustomersApiService);
  private readonly dialog = inject(MatDialog);
  private readonly confirm = inject(ConfirmService);
  private readonly toast = inject(ToastService);
  private readonly router = inject(Router);
  private readonly capabilities = inject(CapabilityService);

  protected readonly customers = signal<Customer[]>([]);
  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);
  protected readonly forbidden = signal(false);

  protected readonly search = signal('');
  protected readonly status = signal<StatusFilter>('all');

  protected readonly canManage = computed(() => this.capabilities.can('manageCustomers'));
  protected readonly trackBy = (row: Customer) => row.customerId;

  protected readonly columns: TableColumn<Customer>[] = [
    { key: 'customerNumber', header: 'Customer no.', value: (row) => row.customerNumber || '—' },
    { key: 'name', header: 'Name', primary: true, value: (row) => customerFullName(row) || '—' },
    { key: 'mobileNumber', header: 'Mobile', value: (row) => row.mobileNumber || '—' },
    { key: 'emailId', header: 'Email', value: (row) => row.emailId || '—' },
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

  protected readonly actions = computed<RowAction<Customer>[]>(() => {
    const view: RowAction<Customer> = {
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
      { label: 'Delete', icon: 'delete', danger: true, run: (row) => void this.remove(row) },
    ];
  });

  protected readonly filtered = computed(() => {
    const term = this.search().trim().toLowerCase();
    const status = this.status();

    return this.customers().filter((customer) => {
      if (status === 'active' && !customer.isActive) {
        return false;
      }
      if (status === 'inactive' && customer.isActive) {
        return false;
      }
      if (!term) {
        return true;
      }
      return [customerFullName(customer), customer.mobileNumber, customer.customerNumber, customer.emailId]
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
      this.customers.set((await firstValueFrom(this.api.list())) ?? []);
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

  protected openDetail(customer: Customer): void {
    void this.router.navigate(['/customers', customer.customerId]);
  }

  protected async openForm(customer?: Customer): Promise<void> {
    if (!this.canManage()) {
      return;
    }

    const ref = this.dialog.open<CustomerFormDialog, CustomerFormData, boolean>(CustomerFormDialog, {
      data: { customer },
      width: '640px',
      maxWidth: '96vw',
      autoFocus: 'first-tabbable',
    });

    if (await firstValueFrom(ref.afterClosed())) {
      await this.load();
    }
  }

  private async remove(customer: Customer): Promise<void> {
    const confirmed = await this.confirm.ask({
      title: 'Delete customer?',
      message: `${customerFullName(customer)} will no longer be able to sign in or place orders.`,
      confirmLabel: 'Delete',
      danger: true,
    });

    if (!confirmed) {
      return;
    }

    try {
      await firstValueFrom(this.api.remove(customer.customerId));
      this.toast.success('Customer deleted.');
      await this.load();
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    }
  }
}
