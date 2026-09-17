import { HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatDialog } from '@angular/material/dialog';
import { MatIconModule } from '@angular/material/icon';
import { MatMenuModule } from '@angular/material/menu';
import { firstValueFrom } from 'rxjs';
import { describeHttpError } from '../../../core/http/interceptors';
import { CustomerAddress } from '../../../core/models/api.models';
import { ConfirmService } from '../../../core/ui/confirm-dialog';
import { ToastService } from '../../../core/ui/toast.service';
import { CustomersApiService, formatAddress } from '../../customers/data/customers-api.service';
import { AddressFormData, AddressFormDialog } from '../../customers/dialogs/address-form-dialog';
import { PortalStore } from '../data/portal.store';

@Component({
  selector: 'app-portal-addresses',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [MatButtonModule, MatIconModule, MatMenuModule],
  template: `
    <header class="head">
      <div>
        <h1>Addresses</h1>
        <p>Where we deliver. Pinning the exact location on the map helps us match you with the nearest chemist.</p>
      </div>
      <button matButton="filled" class="pt-round" (click)="edit()"><mat-icon>add</mat-icon>Add address</button>
    </header>

    @if (store.addresses().length) {
      <ul class="grid">
        @for (a of store.addresses(); track a.id) {
          <li class="card" [class.default]="a.isDefault">
            <div class="top">
              <span class="pin"><mat-icon>{{ a.isDefault ? 'home' : 'location_on' }}</mat-icon></span>
              @if (a.isDefault) { <span class="tag">Default</span> }
              <button class="more" [matMenuTriggerFor]="menu" [attr.aria-label]="'Options for ' + formatAddress(a)">
                <mat-icon>more_vert</mat-icon>
              </button>
              <mat-menu #menu="matMenu" xPosition="before" class="portal-theme">
                <button mat-menu-item (click)="edit(a)"><mat-icon>edit</mat-icon>Edit</button>
                @if (!a.isDefault) {
                  <button mat-menu-item (click)="makeDefault(a)"><mat-icon>home</mat-icon>Make default</button>
                }
                <button mat-menu-item (click)="remove(a)"><mat-icon>delete</mat-icon>Delete</button>
              </mat-menu>
            </div>
            <p class="line">{{ formatAddress(a) }}</p>
            <p class="geo" [class.missing]="a.latitude === null">
              <mat-icon>{{ a.latitude !== null ? 'my_location' : 'location_disabled' }}</mat-icon>
              {{ a.latitude !== null ? 'Location pinned on map' : 'Not pinned — add the map location for faster matching' }}
            </p>
            @if (a.latitude === null) {
              <button matButton class="pt-round fix" (click)="edit(a)">Pin location</button>
            }
          </li>
        }
      </ul>
    } @else if (!store.loading()) {
      <div class="empty">
        <span class="empty-icon"><mat-icon>add_location_alt</mat-icon></span>
        <h2>No addresses yet</h2>
        <p>Add where you'd like your medicines delivered. You'll need one before placing an order.</p>
        <button matButton="filled" class="pt-cta" (click)="edit()">Add your first address</button>
      </div>
    }
  `,
  styles: `
    :host { display: flex; flex-direction: column; gap: 22px; }
    .head { display: flex; justify-content: space-between; align-items: flex-end; gap: 16px; flex-wrap: wrap; }
    h1 { margin: 0; font-size: clamp(1.7rem, 3vw, 2.2rem); font-weight: 800; letter-spacing: -0.025em; color: var(--pt-navy-deep); }
    .head p { margin: 4px 0 0; color: var(--pt-muted); max-width: 60ch; }

    .grid { list-style: none; margin: 0; padding: 0; display: grid; grid-template-columns: repeat(auto-fill, minmax(290px, 1fr)); gap: 16px; }
    .card { background: var(--pt-card); border: 1px solid var(--pt-line); border-radius: var(--pt-radius); padding: 18px 18px 16px; display: flex; flex-direction: column; gap: 10px; }
    .card.default { border: 2px solid var(--pt-navy); }
    .top { display: flex; align-items: center; gap: 10px; }
    .pin { width: 40px; height: 40px; border-radius: 12px; display: grid; place-items: center; background: var(--pt-navy-soft); color: var(--pt-navy); }
    .card.default .pin { background: var(--pt-navy); color: #fff; }
    .tag { font-size: 0.72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; color: var(--pt-orange-deep); background: var(--pt-orange-soft); padding: 3px 8px; border-radius: 6px; }
    .more { margin-left: auto; background: none; border: 0; cursor: pointer; color: var(--pt-muted); width: 36px; height: 36px; border-radius: 50%; display: grid; place-items: center; }
    .more:hover { background: var(--pt-ground); }
    .more:focus-visible { outline: 3px solid color-mix(in srgb, var(--pt-navy) 40%, transparent); }
    .line { margin: 0; line-height: 1.55; }
    .geo { margin: 0; display: flex; align-items: center; gap: 6px; font-size: 0.84rem; color: var(--pt-good); }
    .geo mat-icon { font-size: 16px; width: 16px; height: 16px; }
    .geo.missing { color: var(--pt-orange-deep); }
    .fix { align-self: flex-start; }

    .empty { display: flex; flex-direction: column; align-items: center; text-align: center; gap: 8px; padding: 56px 20px; background: var(--pt-card); border: 1px solid var(--pt-line); border-radius: var(--pt-radius); }
    .empty-icon { width: 64px; height: 64px; border-radius: 50%; background: var(--pt-orange-soft); color: var(--pt-orange-deep); display: grid; place-items: center; margin-bottom: 6px; }
    .empty h2 { margin: 0; font-size: 1.2rem; font-weight: 700; }
    .empty p { margin: 0 0 10px; color: var(--pt-muted); max-width: 44ch; }
  `,
})
export class PortalAddresses {
  protected readonly store = inject(PortalStore);
  private readonly api = inject(CustomersApiService);
  private readonly dialog = inject(MatDialog);
  private readonly confirm = inject(ConfirmService);
  private readonly toast = inject(ToastService);
  protected readonly formatAddress = formatAddress;
  protected readonly busy = signal(false);

  protected async edit(address?: CustomerAddress): Promise<void> {
    const customerId = this.store.customerId();
    if (!customerId) return;
    const ref = this.dialog.open<AddressFormDialog, AddressFormData, boolean>(AddressFormDialog, {
      data: { customerId, address },
      width: '640px',
      maxWidth: '96vw',
      panelClass: 'portal-theme',
    });
    if (await firstValueFrom(ref.afterClosed())) {
      await this.store.refreshAddresses();
    }
  }

  protected async makeDefault(address: CustomerAddress): Promise<void> {
    const customerId = this.store.customerId();
    if (!customerId) return;
    try {
      await firstValueFrom(this.api.setDefaultAddress(customerId, address.id));
      await this.store.refreshAddresses();
      this.toast.success('Default address updated.');
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    }
  }

  protected async remove(address: CustomerAddress): Promise<void> {
    const ok = await this.confirm.ask({
      title: 'Delete this address?',
      message: formatAddress(address),
      confirmLabel: 'Delete',
    });
    if (!ok) return;
    try {
      await firstValueFrom(this.api.removeAddress(address.id));
      await this.store.refreshAddresses();
      this.toast.success('Address deleted.');
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    }
  }
}
