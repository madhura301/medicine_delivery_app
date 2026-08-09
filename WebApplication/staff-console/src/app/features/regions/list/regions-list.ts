import { HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, computed, effect, inject, input, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatDialog } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { firstValueFrom } from 'rxjs';
import { CapabilityService } from '../../../core/config/capabilities';
import { describeHttpError } from '../../../core/http/interceptors';
import { CustomerSupport, DeliveryBoy, ServiceRegion } from '../../../core/models/api.models';
import { RegionType } from '../../../core/models/enums';
import { ConfirmService } from '../../../core/ui/confirm-dialog';
import { ToastService } from '../../../core/ui/toast.service';
import { DataTable, RowAction, TableColumn } from '../../../shared/ui/data-table';
import { FilterBar } from '../../../shared/ui/filter-bar';
import { PageHeader } from '../../../shared/ui/page-header';
import { CustomerSupportApiService } from '../../customer-support/data/customer-support-api.service';
import { DeliveryBoysApiService } from '../../delivery-boys/data/delivery-boys-api.service';
import { RegionsApiService } from '../data/regions-api.service';
import { ManageAssignmentsData, ManageAssignmentsDialog } from '../dialogs/manage-assignments-dialog';
import { RegionFormData, RegionFormDialog } from '../dialogs/region-form-dialog';

/**
 * One component, routed twice — `/regions/support` and `/regions/delivery` differ only by the
 * `regionType` supplied in the route data.
 */
@Component({
  selector: 'app-regions-list',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    FormsModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatIconModule,
    PageHeader,
    FilterBar,
    DataTable,
  ],
  template: `
    <app-page-header
      [title]="isSupport() ? 'Support Regions' : 'Delivery Regions'"
      [subtitle]="subtitle()"
      [actionLabel]="canManage() ? 'Add region' : ''"
      (action)="openForm()"
    />

    <div class="lookup">
      <mat-form-field appearance="outline" subscriptSizing="dynamic">
        <mat-label>Which region serves a pin code?</mat-label>
        <mat-icon matPrefix>pin_drop</mat-icon>
        <input
          matInput
          [(ngModel)]="lookupPin"
          inputmode="numeric"
          maxlength="6"
          placeholder="411001"
          (keyup.enter)="lookup()"
        />
      </mat-form-field>
      <button matButton="filled" [disabled]="lookupBusy()" (click)="lookup()">Look up</button>

      @if (lookupResult(); as result) {
        <p class="result" [class.miss]="result.miss">
          <mat-icon>{{ result.miss ? 'warning' : 'check_circle' }}</mat-icon>
          <span>{{ result.message }}</span>
        </p>
      }
    </div>

    <app-filter-bar
      [(search)]="search"
      searchLabel="Search name, city or pin code"
      [showReset]="false"
    />

    <app-data-table
      [rows]="filtered()"
      [columns]="columns()"
      [actions]="actions()"
      [loading]="loading()"
      [error]="error()"
      [forbidden]="forbidden()"
      [trackBy]="trackBy"
      emptyIcon="map"
      [emptyTitle]="isSupport() ? 'No support regions yet' : 'No delivery regions yet'"
      [emptyMessage]="emptyMessage()"
      [emptyActionLabel]="canManage() ? 'Add region' : ''"
      (emptyAction)="openForm()"
      (retry)="load()"
    />
  `,
  styles: `
    :host { display: block; }

    .lookup {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      gap: 12px;
      margin-bottom: 20px;
      padding: 14px 16px;
      border: 1px solid var(--mat-sys-outline-variant);
      border-radius: 12px;
      background: var(--mat-sys-surface-container-low);
    }
    .lookup mat-form-field { min-width: 260px; }

    .result {
      display: flex;
      align-items: center;
      gap: 8px;
      margin: 0;
      font: var(--mat-sys-body-medium);
      color: var(--mat-sys-primary);
    }
    .result.miss { color: var(--mat-sys-error); }

    @media (max-width: 599px) {
      .lookup { flex-direction: column; align-items: stretch; }
      .lookup mat-form-field { min-width: 0; }
    }
  `,
})
export class RegionsList {
  /** Supplied by the route's `data`, so the same component serves both region menus. */
  readonly regionType = input.required<RegionType>();

  private readonly api = inject(RegionsApiService);
  private readonly supportApi = inject(CustomerSupportApiService);
  private readonly deliveryApi = inject(DeliveryBoysApiService);
  private readonly dialog = inject(MatDialog);
  private readonly confirm = inject(ConfirmService);
  private readonly toast = inject(ToastService);
  private readonly capabilities = inject(CapabilityService);

  protected readonly regions = signal<ServiceRegion[]>([]);
  protected readonly agents = signal<CustomerSupport[]>([]);
  protected readonly partners = signal<DeliveryBoy[]>([]);
  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);
  protected readonly forbidden = signal(false);

  protected readonly search = signal('');
  protected lookupPin = '';
  protected readonly lookupBusy = signal(false);
  protected readonly lookupResult = signal<{ message: string; miss: boolean } | null>(null);

  protected readonly isSupport = computed(() => this.regionType() === RegionType.CustomerSupport);
  protected readonly canManage = computed(() => this.capabilities.can('manageRegions'));
  protected readonly trackBy = (row: ServiceRegion) => row.id;

  protected readonly subtitle = computed(() =>
    this.isSupport()
      ? 'Pin codes here decide which support agent picks up an order a chemist rejected.'
      : 'Pin codes here decide which delivery partners are eligible for an order.',
  );

  protected readonly emptyMessage = computed(() =>
    this.isSupport()
      ? 'Without a support region, rejected orders escalate straight to a manager.'
      : 'Without a delivery region, no partner is eligible to deliver an order.',
  );

  /** How many active people sit in each region — drives the count column and the delete guard. */
  private readonly staffCounts = computed(() => {
    const counts = new Map<number, number>();
    const rows: { serviceRegionId: number | null }[] = this.isSupport()
      ? this.agents()
      : this.partners();

    for (const row of rows) {
      if (row.serviceRegionId) {
        counts.set(row.serviceRegionId, (counts.get(row.serviceRegionId) ?? 0) + 1);
      }
    }
    return counts;
  });

  protected readonly columns = computed<TableColumn<ServiceRegion>[]>(() => [
    { key: 'regionName', header: 'Region', primary: true, value: (row) => row.regionName || row.name },
    { key: 'name', header: 'Name', value: (row) => row.name || '—' },
    { key: 'city', header: 'City', value: (row) => row.city || '—' },
    {
      key: 'pinCodes',
      header: 'Pin codes',
      value: (row) => this.describePins(row),
      sortValue: (row) => row.pinCodes?.length ?? 0,
    },
    {
      key: 'staff',
      header: this.isSupport() ? 'Agents' : 'Partners',
      value: (row) => String(this.staffCounts().get(row.id) ?? 0),
      sortValue: (row) => this.staffCounts().get(row.id) ?? 0,
      chip: (row) => {
        const count = this.staffCounts().get(row.id) ?? 0;
        return { label: String(count), tone: count ? 'info' : 'warning' };
      },
    },
  ]);

  protected readonly actions = computed<RowAction<ServiceRegion>[]>(() => {
    if (!this.canManage()) {
      return [];
    }

    return [
      { label: 'Edit', icon: 'edit', run: (row) => void this.openForm(row) },
      {
        label: this.isSupport() ? 'Manage agents' : 'Manage partners',
        icon: 'group',
        run: (row) => void this.manageAssignments(row),
      },
      { label: 'Delete', icon: 'delete', danger: true, run: (row) => void this.remove(row) },
    ];
  });

  protected readonly filtered = computed(() => {
    const term = this.search().trim().toLowerCase();
    if (!term) {
      return this.regions();
    }

    return this.regions().filter((region) =>
      [region.name, region.regionName, region.city, ...(region.pinCodes ?? [])]
        .join(' ')
        .toLowerCase()
        .includes(term),
    );
  });

  constructor() {
    effect(() => {
      // Re-reads when the route switches between the support and delivery variants.
      this.regionType();
      void this.load();
    });
  }

  private describePins(region: ServiceRegion): string {
    const pins = region.pinCodes ?? [];
    if (!pins.length) {
      return 'None';
    }
    return pins.length <= 3 ? pins.join(', ') : `${pins.slice(0, 3).join(', ')} +${pins.length - 3}`;
  }

  protected async load(): Promise<void> {
    this.loading.set(true);
    this.error.set(null);
    this.forbidden.set(false);
    this.lookupResult.set(null);

    try {
      this.regions.set(await firstValueFrom(this.api.listByType(this.regionType())));

      // Staff counts are advisory; a 403 here must not break the region list.
      if (this.isSupport()) {
        this.agents.set((await firstValueFrom(this.supportApi.list()).catch(() => [])).filter((a) => !a.isDeleted));
      } else {
        this.partners.set(
          (await firstValueFrom(this.deliveryApi.list()).catch(() => [])).filter((p) => !p.isDeleted),
        );
      }
    } catch (err) {
      const error = err as HttpErrorResponse;
      this.forbidden.set(error.status === 403);
      this.error.set(describeHttpError(error));
    } finally {
      this.loading.set(false);
    }
  }

  protected async lookup(): Promise<void> {
    const pin = this.lookupPin.trim();

    if (!/^\d{6}$/.test(pin)) {
      this.lookupResult.set({ message: 'Enter a 6-digit pin code.', miss: true });
      return;
    }

    this.lookupBusy.set(true);

    try {
      const region = await firstValueFrom(this.api.byPinCode(pin));

      if (!region) {
        this.lookupResult.set({ message: this.missMessage(pin), miss: true });
        return;
      }

      // by-pincode searches every region, so a hit of the other type is still a miss here.
      if (region.regionType !== this.regionType()) {
        this.lookupResult.set({ message: this.missMessage(pin), miss: true });
        return;
      }

      this.lookupResult.set({
        message: `${pin} is served by ${region.regionName || region.name} (${region.city}).`,
        miss: false,
      });
    } catch {
      this.lookupResult.set({ message: this.missMessage(pin), miss: true });
    } finally {
      this.lookupBusy.set(false);
    }
  }

  private missMessage(pin: string): string {
    return this.isSupport()
      ? `No support region covers ${pin} — rejected orders there escalate straight to a manager.`
      : `No delivery region covers ${pin} — no partner is eligible for orders there.`;
  }

  protected async openForm(region?: ServiceRegion): Promise<void> {
    if (!this.canManage()) {
      return;
    }

    const ref = this.dialog.open<RegionFormDialog, RegionFormData, boolean>(RegionFormDialog, {
      data: { region, regionType: this.regionType() },
      width: '640px',
      maxWidth: '96vw',
      autoFocus: 'first-tabbable',
    });

    if (await firstValueFrom(ref.afterClosed())) {
      await this.load();
    }
  }

  private async manageAssignments(region: ServiceRegion): Promise<void> {
    const ref = this.dialog.open<ManageAssignmentsDialog, ManageAssignmentsData, boolean>(
      ManageAssignmentsDialog,
      { data: { region }, width: '860px', maxWidth: '96vw' },
    );

    if (await firstValueFrom(ref.afterClosed())) {
      await this.load();
    }
  }

  /**
   * The API deletes a region outright without checking who is attached, orphaning them silently.
   * Refuse the delete here while anyone is still assigned.
   */
  private async remove(region: ServiceRegion): Promise<void> {
    const staff = this.staffCounts().get(region.id) ?? 0;

    if (staff > 0) {
      const who = this.isSupport() ? 'support agent' : 'delivery partner';
      await this.confirm.ask({
        title: 'Cannot delete this region',
        message:
          `${region.regionName || region.name} still has ${staff} ${who}${staff === 1 ? '' : 's'} assigned. ` +
          `Move them to another region first — deleting would leave them without one.`,
        confirmLabel: 'OK',
        cancelLabel: 'Close',
      });
      return;
    }

    const pins = region.pinCodes?.length ?? 0;
    const consequence = this.isSupport()
      ? 'Orders rejected in those pin codes will escalate straight to a manager.'
      : 'No delivery partner will be eligible for orders in those pin codes.';

    const confirmed = await this.confirm.ask({
      title: 'Delete region?',
      message:
        `${region.regionName || region.name} and its ${pins} pin code${pins === 1 ? '' : 's'} will be ` +
        `deleted permanently. ${consequence}`,
      confirmLabel: 'Delete',
      danger: true,
    });

    if (!confirmed) {
      return;
    }

    try {
      await firstValueFrom(this.api.remove(region.id));
      this.toast.success('Region deleted.');
      await this.load();
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    }
  }
}
