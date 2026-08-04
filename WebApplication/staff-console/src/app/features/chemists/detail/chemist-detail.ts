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
import { Router } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { CapabilityService } from '../../../core/config/capabilities';
import { describeHttpError } from '../../../core/http/interceptors';
import { ChemistActivation, ChemistPayoutAccount, MedicalStore } from '../../../core/models/api.models';
import {
  ChemistPayoutStatus,
  chemistActivationStatusLabel,
  chemistPayoutStatusLabel,
} from '../../../core/models/enums';
import { ConfirmService } from '../../../core/ui/confirm-dialog';
import { ToastService } from '../../../core/ui/toast.service';
import { PageHeader } from '../../../shared/ui/page-header';
import { ErrorState, LoadingState } from '../../../shared/ui/state-panels';
import { LocationMap } from '../../../shared/ui/location-map';
import { StatusChip } from '../../../shared/ui/status-chip';
import { ChemistsApiService, chemistAddress, chemistOwnerName } from '../data/chemists-api.service';
import { ChemistFormData, ChemistFormDialog } from '../dialogs/chemist-form-dialog';

@Component({
  selector: 'app-chemist-detail',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    DatePipe,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    PageHeader,
    LoadingState,
    ErrorState,
    StatusChip,
    LocationMap,
  ],
  template: `
    @if (loading()) {
      <app-loading-state message="Loading chemist…" />
    } @else if (error()) {
      <app-error-state [message]="error()!" [forbidden]="forbidden()" (retry)="load()" />
    } @else if (chemist(); as row) {
      <app-page-header [title]="row.medicalName" [subtitle]="owner()">
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
            @if (row.isActive) {
              <button matButton (click)="setActive(false)">
                <mat-icon>block</mat-icon>
                Deactivate
              </button>
            } @else {
              <button matButton (click)="setActive(true)">
                <mat-icon>check_circle</mat-icon>
                Activate
              </button>
            }
            <button matButton (click)="remove()">
              <mat-icon>delete</mat-icon>
              Delete
            </button>
          }
          @if (canHardDelete()) {
            <button matButton (click)="hardDelete()">
              <mat-icon>delete_forever</mat-icon>
              Delete permanently
            </button>
          }
        </div>
      </app-page-header>

      <div class="cards">
        <mat-card appearance="outlined">
          <mat-card-header><mat-card-title>Store</mat-card-title></mat-card-header>
          <mat-card-content>
            <dl>
              <dt>Status</dt>
              <dd>
                <app-status-chip
                  [label]="row.isActive ? 'Active' : 'Inactive'"
                  [tone]="row.isActive ? 'positive' : 'neutral'"
                />
              </dd>
              <dt>Owner</dt>
              <dd>{{ owner() || '—' }}</dd>
              <dt>Mobile</dt>
              <dd>{{ row.mobileNumber || '—' }}</dd>
              <dt>Alternative mobile</dt>
              <dd>{{ row.alternativeMobileNumber || '—' }}</dd>
              <dt>Email</dt>
              <dd>{{ row.emailId || '—' }}</dd>
            </dl>
          </mat-card-content>
        </mat-card>

        <mat-card appearance="outlined" class="wide">
          <mat-card-header><mat-card-title>Address &amp; location</mat-card-title></mat-card-header>
          <mat-card-content>
            <dl>
              <dt>Address</dt>
              <dd>{{ address() }}</dd>
              <dt>Pin code</dt>
              <dd>{{ row.postalCode || '—' }}</dd>
            </dl>

            <app-location-map
              class="map"
              [latitude]="row.latitude"
              [longitude]="row.longitude"
              [label]="row.medicalName"
              [collapsible]="false"
            />
          </mat-card-content>
        </mat-card>

        <mat-card appearance="outlined">
          <mat-card-header><mat-card-title>Statutory</mat-card-title></mat-card-header>
          <mat-card-content>
            <dl>
              <dt>Registration</dt>
              <dd>
                <app-status-chip
                  [label]="row.registrationStatus ? 'Complete' : 'Incomplete'"
                  [tone]="row.registrationStatus ? 'positive' : 'warning'"
                />
              </dd>
              <dt>GSTIN</dt>
              <dd>{{ row.gstin || '—' }}</dd>
              <dt>PAN</dt>
              <dd>{{ row.pan || '—' }}</dd>
              <dt>FSSAI</dt>
              <dd>{{ row.fssaiNo || '—' }}</dd>
              <dt>Drug licence</dt>
              <dd>{{ row.dlNo || '—' }}</dd>
            </dl>
          </mat-card-content>
        </mat-card>

        <mat-card appearance="outlined">
          <mat-card-header><mat-card-title>Pharmacist</mat-card-title></mat-card-header>
          <mat-card-content>
            <dl>
              <dt>Name</dt>
              <dd>
                {{ (row.pharmacistFirstName + ' ' + row.pharmacistLastName).trim() || '—' }}
              </dd>
              <dt>Registration no.</dt>
              <dd>{{ row.pharmacistRegistrationNumber || '—' }}</dd>
              <dt>Mobile</dt>
              <dd>{{ row.pharmacistMobileNumber || '—' }}</dd>
            </dl>
          </mat-card-content>
        </mat-card>

        <mat-card appearance="outlined">
          <mat-card-header><mat-card-title>Payouts &amp; activation</mat-card-title></mat-card-header>
          <mat-card-content>
            <dl>
              <dt>Payout account</dt>
              <dd>
                @if (payout(); as account) {
                  <app-status-chip [label]="payoutLabel()" [tone]="payoutTone()" />
                } @else {
                  Not onboarded
                }
              </dd>
              <dt>Activation fee</dt>
              <dd>{{ activationLabel() }}</dd>
            </dl>
            <p class="hint">
              A store needs an active payout account and a paid activation fee before the system
              will route orders to it.
            </p>
          </mat-card-content>
        </mat-card>

        <mat-card appearance="outlined">
          <mat-card-header><mat-card-title>Record</mat-card-title></mat-card-header>
          <mat-card-content>
            <dl>
              <dt>Created</dt>
              <dd>{{ row.createdOn | date: 'medium' }}</dd>
              <dt>Last updated</dt>
              <dd>{{ row.updatedOn ? (row.updatedOn | date: 'medium') : '—' }}</dd>
              <dt>Login</dt>
              <dd>{{ row.userId ? 'Linked' : 'No linked account' }}</dd>
            </dl>
          </mat-card-content>
        </mat-card>
      </div>
    }
  `,
  styles: `
    :host { display: block; }
    .cards {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
      gap: 16px;
    }
    dl { display: grid; grid-template-columns: auto 1fr; gap: 10px 20px; margin: 0; }
    dt { color: var(--mat-sys-on-surface-variant); font: var(--mat-sys-body-small); }
    dd { margin: 0; font: var(--mat-sys-body-medium); text-align: right; word-break: break-word; }
    .hint {
      margin: 12px 0 0;
      color: var(--mat-sys-on-surface-variant);
      font: var(--mat-sys-body-small);
    }
    .wide { grid-column: 1 / -1; }
    .map { display: block; margin-top: 16px; --map-height: 300px; }
    [headerActions] { display: flex; gap: 8px; flex-wrap: wrap; }
  `,
})
export class ChemistDetail {
  readonly id = input.required<string>();

  private readonly api = inject(ChemistsApiService);
  private readonly dialog = inject(MatDialog);
  private readonly confirm = inject(ConfirmService);
  private readonly toast = inject(ToastService);
  private readonly router = inject(Router);
  private readonly capabilities = inject(CapabilityService);

  protected readonly chemist = signal<MedicalStore | null>(null);
  protected readonly payout = signal<ChemistPayoutAccount | null>(null);
  protected readonly activation = signal<ChemistActivation | null>(null);
  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);
  protected readonly forbidden = signal(false);

  protected readonly canManage = computed(() => this.capabilities.can('manageChemists'));
  protected readonly canHardDelete = computed(() => this.capabilities.can('hardDeleteChemist'));

  protected readonly owner = computed(() => {
    const row = this.chemist();
    return row ? chemistOwnerName(row) : '';
  });
  protected readonly address = computed(() => {
    const row = this.chemist();
    return row ? chemistAddress(row) : '—';
  });

  protected readonly payoutLabel = computed(() => {
    const account = this.payout();
    return account ? chemistPayoutStatusLabel(account.status) : 'Not onboarded';
  });

  protected readonly payoutTone = computed(() => {
    const account = this.payout();
    if (!account) {
      return 'neutral' as const;
    }
    switch (account.status) {
      case ChemistPayoutStatus.Active:
        return 'positive' as const;
      case ChemistPayoutStatus.Rejected:
      case ChemistPayoutStatus.Suspended:
        return 'danger' as const;
      case ChemistPayoutStatus.NotStarted:
        return 'neutral' as const;
      default:
        return 'warning' as const;
    }
  });

  protected readonly activationLabel = computed(() => {
    const record = this.activation();
    return record ? chemistActivationStatusLabel(record.status) : 'Not started';
  });

  constructor() {
    // An effect, not the constructor: route inputs are not bound yet when the constructor runs.
    // This also reloads if the user navigates straight from one chemist to another.
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
      const chemist = await firstValueFrom(this.api.get(id));
      this.chemist.set(chemist);

      // Payout and activation are optional extras — a chemist that never onboarded 404s here.
      const [payout, activation] = await Promise.all([
        firstValueFrom(this.api.payoutAccount(id)).catch(() => null),
        firstValueFrom(this.api.activation(id)).catch(() => null),
      ]);
      this.payout.set(payout);
      this.activation.set(activation);
    } catch (err) {
      const error = err as HttpErrorResponse;
      this.forbidden.set(error.status === 403);
      this.error.set(describeHttpError(error));
    } finally {
      this.loading.set(false);
    }
  }

  protected back(): void {
    void this.router.navigate(['/chemists']);
  }

  protected async edit(): Promise<void> {
    const chemist = this.chemist();
    if (!chemist) {
      return;
    }

    const ref = this.dialog.open<ChemistFormDialog, ChemistFormData, boolean>(ChemistFormDialog, {
      data: { chemist },
      width: '760px',
      maxWidth: '96vw',
    });

    if (await firstValueFrom(ref.afterClosed())) {
      await this.load();
    }
  }

  protected async setActive(active: boolean): Promise<void> {
    const chemist = this.chemist();
    if (!chemist) {
      return;
    }

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

  protected async remove(): Promise<void> {
    const chemist = this.chemist();
    if (!chemist) {
      return;
    }

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
      this.back();
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    }
  }

  protected async hardDelete(): Promise<void> {
    const chemist = this.chemist();
    if (!chemist) {
      return;
    }

    const confirmed = await this.confirm.ask({
      title: 'Permanently delete chemist?',
      message:
        `${chemist.medicalName} and its login will be erased from the database. ` +
        'This cannot be undone and may fail if the store has orders.',
      confirmLabel: 'Delete permanently',
      danger: true,
      typeToConfirm: chemist.medicalName,
    });

    if (!confirmed) {
      return;
    }

    try {
      await firstValueFrom(this.api.hardDelete(chemist.medicalStoreId));
      this.toast.success('Chemist permanently deleted.');
      this.back();
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    }
  }
}
