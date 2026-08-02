import { DatePipe } from '@angular/common';
import { HttpErrorResponse } from '@angular/common/http';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  effect,
  inject,
  input,
  signal,
} from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatDialog } from '@angular/material/dialog';
import { MatIconModule } from '@angular/material/icon';
import { MatMenuModule } from '@angular/material/menu';
import { Router } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { CapabilityService } from '../../../core/config/capabilities';
import { describeHttpError } from '../../../core/http/interceptors';
import { Customer, CustomerAddress } from '../../../core/models/api.models';
import { ConfirmService } from '../../../core/ui/confirm-dialog';
import { ToastService } from '../../../core/ui/toast.service';
import { PageHeader } from '../../../shared/ui/page-header';
import { ErrorState, LoadingState } from '../../../shared/ui/state-panels';
import { StatusChip } from '../../../shared/ui/status-chip';
import { CustomersApiService, customerFullName, formatAddress } from '../data/customers-api.service';
import { AddressFormData, AddressFormDialog } from '../dialogs/address-form-dialog';
import { CustomerFormData, CustomerFormDialog } from '../dialogs/customer-form-dialog';

@Component({
  selector: 'app-customer-detail',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    DatePipe,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatMenuModule,
    PageHeader,
    LoadingState,
    ErrorState,
    StatusChip,
  ],
  template: `
    @if (loading()) {
      <app-loading-state message="Loading customer…" />
    } @else if (error()) {
      <app-error-state [message]="error()!" [forbidden]="forbidden()" (retry)="load()" />
    } @else if (customer(); as row) {
      <app-page-header [title]="name()" [subtitle]="'Customer ' + (row.customerNumber || '—')">
        <div headerActions>
          <button matButton (click)="back()">
            <mat-icon>arrow_back</mat-icon>
            Back
          </button>
          @if (canManage()) {
            <button matButton (click)="edit()">
              <mat-icon>edit</mat-icon>
              Edit
            </button>
            <button matButton (click)="addAddress()">
              <mat-icon>add_location_alt</mat-icon>
              Add address
            </button>
            <button matButton (click)="remove()">
              <mat-icon>delete</mat-icon>
              Delete
            </button>
          }
        </div>
      </app-page-header>

      <div class="cards">
        <mat-card appearance="outlined">
          <mat-card-header><mat-card-title>Profile</mat-card-title></mat-card-header>
          <mat-card-content>
            <dl>
              <dt>Status</dt>
              <dd>
                <app-status-chip
                  [label]="row.isActive ? 'Active' : 'Inactive'"
                  [tone]="row.isActive ? 'positive' : 'neutral'"
                />
              </dd>
              <dt>Mobile</dt>
              <dd>{{ row.mobileNumber || '—' }}</dd>
              <dt>Alternative mobile</dt>
              <dd>{{ row.alternativeMobileNumber || '—' }}</dd>
              <dt>Email</dt>
              <dd>{{ row.emailId || '—' }}</dd>
              <dt>Date of birth</dt>
              <dd>{{ dateOfBirth() }}</dd>
              <dt>Gender</dt>
              <dd>{{ row.gender || '—' }}</dd>
              <dt>Registered</dt>
              <dd>{{ row.createdOn | date: 'mediumDate' }}</dd>
            </dl>
          </mat-card-content>
        </mat-card>

        <mat-card appearance="outlined" class="addresses">
          <mat-card-header>
            <mat-card-title>Addresses ({{ addresses().length }})</mat-card-title>
          </mat-card-header>
          <mat-card-content>
            @if (!addresses().length) {
              <p class="hint">No addresses on file. Orders cannot be delivered without one.</p>
            } @else {
              <ul>
                @for (address of addresses(); track address.id) {
                  <li>
                    <div class="address-text">
                      <span>{{ format(address) }}</span>
                      @if (address.isDefault) {
                        <app-status-chip label="Default" tone="info" />
                      }
                    </div>

                    @if (canManage()) {
                      <button matIconButton [matMenuTriggerFor]="addressMenu" aria-label="Address actions">
                        <mat-icon>more_vert</mat-icon>
                      </button>
                      <mat-menu #addressMenu="matMenu">
                        <button mat-menu-item (click)="editAddress(address)">
                          <mat-icon>edit</mat-icon>
                          <span>Edit</span>
                        </button>
                        @if (!address.isDefault) {
                          <button mat-menu-item (click)="makeDefault(address)">
                            <mat-icon>star</mat-icon>
                            <span>Set as default</span>
                          </button>
                        }
                        <button mat-menu-item (click)="removeAddress(address)">
                          <mat-icon>delete</mat-icon>
                          <span>Delete</span>
                        </button>
                      </mat-menu>
                    }
                  </li>
                }
              </ul>
            }
          </mat-card-content>
        </mat-card>
      </div>
    }
  `,
  styles: `
    :host { display: block; }
    .cards {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
      gap: 16px;
      align-items: start;
    }
    dl { display: grid; grid-template-columns: auto 1fr; gap: 10px 20px; margin: 0; }
    dt { color: var(--mat-sys-on-surface-variant); font: var(--mat-sys-body-small); }
    dd { margin: 0; font: var(--mat-sys-body-medium); text-align: right; word-break: break-word; }

    ul { list-style: none; margin: 0; padding: 0; display: grid; gap: 8px; }
    li {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
      padding: 10px 12px;
      border: 1px solid var(--mat-sys-outline-variant);
      border-radius: 10px;
    }
    .address-text {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      gap: 8px;
      font: var(--mat-sys-body-medium);
    }
    .hint { margin: 0; color: var(--mat-sys-on-surface-variant); font: var(--mat-sys-body-small); }
    [headerActions] { display: flex; gap: 8px; flex-wrap: wrap; }
  `,
})
export class CustomerDetail {
  readonly id = input.required<string>();

  private readonly api = inject(CustomersApiService);
  private readonly dialog = inject(MatDialog);
  private readonly confirm = inject(ConfirmService);
  private readonly toast = inject(ToastService);
  private readonly router = inject(Router);
  private readonly capabilities = inject(CapabilityService);

  protected readonly customer = signal<Customer | null>(null);
  protected readonly addresses = signal<CustomerAddress[]>([]);
  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);
  protected readonly forbidden = signal(false);

  protected readonly canManage = computed(() => this.capabilities.can('manageCustomers'));
  protected readonly format = formatAddress;

  protected readonly name = computed(() => {
    const row = this.customer();
    return row ? customerFullName(row) : '';
  });

  protected readonly dateOfBirth = computed(() => {
    const value = this.customer()?.dateOfBirth;
    if (!value) {
      return '—';
    }
    const date = new Date(value);
    // The API cannot store "unknown", so unset dates come back as the epoch.
    return date.getUTCFullYear() <= 1970 ? '—' : date.toLocaleDateString();
  });

  constructor() {
    effect(() => {
      const id = this.id();
      void this.load(id);
    });
  }

  protected async load(id = this.id()): Promise<void> {
    this.loading.set(true);
    this.error.set(null);
    this.forbidden.set(false);

    try {
      const customer = await firstValueFrom(this.api.get(id));
      this.customer.set(customer);

      // The customer payload may already embed addresses; fall back to the dedicated endpoint.
      const embedded = customer.addresses;
      this.addresses.set(
        embedded?.length ? embedded : ((await firstValueFrom(this.api.addresses(id))) ?? []),
      );
    } catch (err) {
      const error = err as HttpErrorResponse;
      this.forbidden.set(error.status === 403);
      this.error.set(describeHttpError(error));
    } finally {
      this.loading.set(false);
    }
  }

  protected back(): void {
    void this.router.navigate(['/customers']);
  }

  protected async edit(): Promise<void> {
    const customer = this.customer();
    if (!customer) {
      return;
    }

    const ref = this.dialog.open<CustomerFormDialog, CustomerFormData, boolean>(CustomerFormDialog, {
      data: { customer },
      width: '640px',
      maxWidth: '96vw',
    });

    if (await firstValueFrom(ref.afterClosed())) {
      await this.load();
    }
  }

  protected async addAddress(): Promise<void> {
    await this.openAddressDialog();
  }

  protected async editAddress(address: CustomerAddress): Promise<void> {
    await this.openAddressDialog(address);
  }

  private async openAddressDialog(address?: CustomerAddress): Promise<void> {
    const ref = this.dialog.open<AddressFormDialog, AddressFormData, boolean>(AddressFormDialog, {
      data: { customerId: this.id(), address },
      width: '620px',
      maxWidth: '96vw',
    });

    if (await firstValueFrom(ref.afterClosed())) {
      await this.load();
    }
  }

  protected async makeDefault(address: CustomerAddress): Promise<void> {
    try {
      await firstValueFrom(this.api.setDefaultAddress(this.id(), address.id));
      this.toast.success('Default address updated.');
      await this.load();
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    }
  }

  protected async removeAddress(address: CustomerAddress): Promise<void> {
    const confirmed = await this.confirm.ask({
      title: 'Delete address?',
      message: formatAddress(address),
      confirmLabel: 'Delete',
      danger: true,
    });

    if (!confirmed) {
      return;
    }

    try {
      await firstValueFrom(this.api.removeAddress(address.id));
      this.toast.success('Address deleted.');
      await this.load();
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    }
  }

  protected async remove(): Promise<void> {
    const customer = this.customer();
    if (!customer) {
      return;
    }

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
      this.back();
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    }
  }
}
