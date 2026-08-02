import { HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, computed, inject, signal } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { firstValueFrom } from 'rxjs';
import { describeHttpError } from '../../../core/http/interceptors';
import { ServiceRegion } from '../../../core/models/api.models';
import { RegionType } from '../../../core/models/enums';
import { ToastService } from '../../../core/ui/toast.service';
import { LoadingState } from '../../../shared/ui/state-panels';
import { CustomerSupportApiService, agentFullName } from '../../customer-support/data/customer-support-api.service';
import { DeliveryBoysApiService, deliveryBoyName } from '../../delivery-boys/data/delivery-boys-api.service';
import { RegionsApiService } from '../data/regions-api.service';

export interface ManageAssignmentsData {
  region: ServiceRegion;
}

/** One row in either pane, flattened so the template does not care which kind it is. */
interface Candidate {
  id: string | number;
  name: string;
  subtitle: string;
  currentRegionId: number | null;
  currentRegionName: string | null;
}

/**
 * The bulk workbench: attach or detach many agents / delivery partners at once.
 * Moving someone who already belongs to another region silently reassigns them, so their current
 * region is shown on the row.
 */
@Component({
  selector: 'app-manage-assignments-dialog',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    MatDialogModule,
    MatButtonModule,
    MatCheckboxModule,
    MatIconModule,
    MatProgressBarModule,
    LoadingState,
  ],
  template: `
    <h2 mat-dialog-title>{{ title() }}</h2>
    @if (busy()) {
      <mat-progress-bar mode="indeterminate" />
    }

    <mat-dialog-content>
      @if (loading()) {
        <app-loading-state message="Loading people…" />
      } @else if (loadError()) {
        <p class="error">{{ loadError() }}</p>
      } @else {
        <div class="panes">
          <section>
            <h3>In this region ({{ assigned().length }})</h3>
            @if (!assigned().length) {
              <p class="hint">Nobody is assigned yet.</p>
            } @else {
              <ul>
                @for (row of assigned(); track row.id) {
                  <li>
                    <mat-checkbox
                      [checked]="isPicked(row)"
                      (change)="toggle(row)"
                    >
                      <span class="name">{{ row.name }}</span>
                      <span class="sub">{{ row.subtitle }}</span>
                    </mat-checkbox>
                  </li>
                }
              </ul>
              <button matButton [disabled]="!pickedIn().length" (click)="removeSelected()">
                <mat-icon>person_remove</mat-icon>
                Remove selected ({{ pickedIn().length }})
              </button>
            }
          </section>

          <section>
            <h3>Available ({{ available().length }})</h3>
            @if (!available().length) {
              <p class="hint">Everyone is already in this region.</p>
            } @else {
              <ul>
                @for (row of available(); track row.id) {
                  <li>
                    <mat-checkbox [checked]="isPicked(row)" (change)="toggle(row)">
                      <span class="name">{{ row.name }}</span>
                      <span class="sub">
                        {{ row.subtitle }}
                        @if (row.currentRegionName) {
                          — currently in {{ row.currentRegionName }}
                        }
                      </span>
                    </mat-checkbox>
                  </li>
                }
              </ul>
              <button
                matButton="filled"
                [disabled]="!pickedOut().length"
                (click)="assignSelected()"
              >
                <mat-icon>person_add</mat-icon>
                Assign selected ({{ pickedOut().length }})
              </button>
            }
          </section>
        </div>

        @if (movingCount()) {
          <p class="warn">
            <mat-icon>info</mat-icon>
            <span>
              {{ movingCount() }} of the selected people already belong to another region and will
              be moved.
            </span>
          </p>
        }
      }
    </mat-dialog-content>

    <mat-dialog-actions align="end">
      <button matButton [mat-dialog-close]="changed()">Done</button>
    </mat-dialog-actions>
  `,
  styles: `
    mat-dialog-content { min-width: min(760px, 86vw); }

    .panes {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 24px;
    }

    h3 { margin: 0 0 8px; font: var(--mat-sys-title-small); }

    ul {
      list-style: none;
      margin: 0 0 12px;
      padding: 0;
      max-height: 320px;
      overflow-y: auto;
      border: 1px solid var(--mat-sys-outline-variant);
      border-radius: 10px;
    }
    li { padding: 6px 12px; border-bottom: 1px solid var(--mat-sys-outline-variant); }
    li:last-child { border-bottom: none; }

    .name { display: block; font: var(--mat-sys-body-medium); }
    .sub { display: block; color: var(--mat-sys-on-surface-variant); font: var(--mat-sys-body-small); }

    .hint { color: var(--mat-sys-on-surface-variant); font: var(--mat-sys-body-small); }
    .error { color: var(--mat-sys-error); }

    .warn {
      display: flex;
      gap: 8px;
      align-items: flex-start;
      margin: 16px 0 0;
      color: var(--mat-sys-on-surface-variant);
      font: var(--mat-sys-body-small);
    }

    @media (max-width: 767px) {
      mat-dialog-content { min-width: 0; }
      .panes { grid-template-columns: 1fr; }
    }
  `,
})
export class ManageAssignmentsDialog {
  private readonly data = inject<ManageAssignmentsData>(MAT_DIALOG_DATA);
  private readonly regionsApi = inject(RegionsApiService);
  private readonly supportApi = inject(CustomerSupportApiService);
  private readonly deliveryApi = inject(DeliveryBoysApiService);
  private readonly toast = inject(ToastService);
  private readonly ref = inject(MatDialogRef<ManageAssignmentsDialog, boolean>);

  protected readonly loading = signal(true);
  protected readonly busy = signal(false);
  protected readonly loadError = signal<string | null>(null);
  protected readonly changed = signal(false);

  private readonly candidates = signal<Candidate[]>([]);
  private readonly picked = signal<Set<string>>(new Set());

  private readonly isSupport = this.data.region.regionType === RegionType.CustomerSupport;

  protected readonly title = computed(
    () =>
      `${this.isSupport ? 'Support agents' : 'Delivery partners'} in ${
        this.data.region.regionName || this.data.region.name
      }`,
  );

  protected readonly assigned = computed(() =>
    this.candidates().filter((c) => c.currentRegionId === this.data.region.id),
  );

  protected readonly available = computed(() =>
    this.candidates().filter((c) => c.currentRegionId !== this.data.region.id),
  );

  protected readonly pickedIn = computed(() => this.assigned().filter((c) => this.isPicked(c)));
  protected readonly pickedOut = computed(() => this.available().filter((c) => this.isPicked(c)));

  protected readonly movingCount = computed(
    () => this.pickedOut().filter((c) => c.currentRegionId !== null).length,
  );

  constructor() {
    void this.load();
  }

  private key(row: Candidate): string {
    return String(row.id);
  }

  protected isPicked(row: Candidate): boolean {
    return this.picked().has(this.key(row));
  }

  protected toggle(row: Candidate): void {
    this.picked.update((set) => {
      const next = new Set(set);
      const key = this.key(row);
      if (next.has(key)) {
        next.delete(key);
      } else {
        next.add(key);
      }
      return next;
    });
  }

  private async load(): Promise<void> {
    this.loading.set(true);
    this.loadError.set(null);

    try {
      const regions = await firstValueFrom(this.regionsApi.list()).catch(() => []);
      const regionNames = new Map(regions.map((r) => [r.id, r.regionName || r.name]));

      if (this.isSupport) {
        const agents = await firstValueFrom(this.supportApi.list());
        this.candidates.set(
          (agents ?? [])
            .filter((a) => !a.isDeleted && a.isActive)
            .map((a) => ({
              id: a.customerSupportId,
              name: agentFullName(a),
              subtitle: a.mobileNumber || a.emailId || '',
              currentRegionId: a.serviceRegionId,
              currentRegionName: a.serviceRegionId
                ? (regionNames.get(a.serviceRegionId) ?? null)
                : null,
            })),
        );
      } else {
        const partners = await firstValueFrom(this.deliveryApi.list());
        this.candidates.set(
          (partners ?? [])
            .filter((p) => !p.isDeleted && p.isActive)
            .map((p) => ({
              id: p.id,
              name: deliveryBoyName(p),
              subtitle: p.mobileNumber || '',
              currentRegionId: p.serviceRegionId,
              currentRegionName: p.serviceRegionId
                ? (regionNames.get(p.serviceRegionId) ?? null)
                : null,
            })),
        );
      }
    } catch (err) {
      this.loadError.set(describeHttpError(err as HttpErrorResponse));
    } finally {
      this.loading.set(false);
    }
  }

  protected async assignSelected(): Promise<void> {
    const rows = this.pickedOut();
    if (!rows.length) {
      return;
    }

    this.busy.set(true);

    try {
      if (this.isSupport) {
        await firstValueFrom(
          this.regionsApi.assignCustomerSupportBulk({
            serviceRegionId: this.data.region.id,
            customerSupportIds: rows.map((r) => String(r.id)),
          }),
        );
      } else {
        await firstValueFrom(
          this.regionsApi.assignDeliveryBulk({
            serviceRegionId: this.data.region.id,
            deliveryIds: rows.map((r) => Number(r.id)),
          }),
        );
      }

      this.toast.success(`Assigned ${rows.length} to this region.`);
      this.afterWrite();
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    } finally {
      this.busy.set(false);
    }
  }

  /** There is no bulk "unassign", so clear each one individually. */
  protected async removeSelected(): Promise<void> {
    const rows = this.pickedIn();
    if (!rows.length) {
      return;
    }

    this.busy.set(true);

    try {
      for (const row of rows) {
        if (this.isSupport) {
          await firstValueFrom(
            this.regionsApi.assignCustomerSupport({
              customerSupportId: String(row.id),
              serviceRegionId: null,
            }),
          );
        } else {
          await firstValueFrom(
            this.regionsApi.assignDelivery({ deliveryId: Number(row.id), serviceRegionId: null }),
          );
        }
      }

      this.toast.success(`Removed ${rows.length} from this region.`);
      this.afterWrite();
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    } finally {
      this.busy.set(false);
    }
  }

  private afterWrite(): void {
    this.changed.set(true);
    this.picked.set(new Set());
    void this.load();
  }

  protected close(): void {
    this.ref.close(this.changed());
  }
}
