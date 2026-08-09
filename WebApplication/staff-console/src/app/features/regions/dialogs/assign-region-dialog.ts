import { HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatSelectModule } from '@angular/material/select';
import { firstValueFrom } from 'rxjs';
import { describeHttpError } from '../../../core/http/interceptors';
import { ServiceRegion } from '../../../core/models/api.models';
import { RegionType } from '../../../core/models/enums';
import { ToastService } from '../../../core/ui/toast.service';
import { LoadingState } from '../../../shared/ui/state-panels';
import { RegionsApiService, describeRegion } from '../data/regions-api.service';

export interface AssignRegionData {
  /** Which side of the assignment we are on — decides the endpoint and the region list. */
  kind: 'customer-support' | 'delivery';
  /** CustomerSupportId (guid) or DeliveryId (number). */
  subjectId: string | number;
  subjectName: string;
  currentRegionId: number | null;
}

/**
 * Assigns one agent or delivery partner to a single region.
 *
 * The dropdown only ever lists regions of the matching type: the API does not validate that a
 * support agent is given a support region, so the filtering here is what prevents a mismatch.
 */
@Component({
  selector: 'app-assign-region-dialog',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    FormsModule,
    MatDialogModule,
    MatFormFieldModule,
    MatSelectModule,
    MatButtonModule,
    MatIconModule,
    MatProgressBarModule,
    LoadingState,
  ],
  template: `
    <h2 mat-dialog-title>Assign region</h2>
    @if (saving()) {
      <mat-progress-bar mode="indeterminate" />
    }

    <mat-dialog-content>
      <p class="subject">{{ data.subjectName }}</p>

      @if (loading()) {
        <app-loading-state message="Loading regions…" />
      } @else if (loadError()) {
        <p class="error">{{ loadError() }}</p>
      } @else if (!regions().length) {
        <p class="error">
          No {{ typeLabel() }} regions exist yet. Create one first under Regions.
        </p>
      } @else {
        <mat-form-field appearance="outline" class="full">
          <mat-label>Region</mat-label>
          <mat-select [(ngModel)]="selected">
            <mat-option [value]="null">— Unassigned —</mat-option>
            @for (region of regions(); track region.id) {
              <mat-option [value]="region.id">{{ describe(region) }}</mat-option>
            }
          </mat-select>
          <mat-hint>{{ hint() }}</mat-hint>
        </mat-form-field>
      }
    </mat-dialog-content>

    <mat-dialog-actions align="end">
      <button matButton mat-dialog-close [disabled]="saving()">Cancel</button>
      <button
        matButton="filled"
        [disabled]="saving() || loading() || !changed()"
        (click)="save()"
      >
        Save
      </button>
    </mat-dialog-actions>
  `,
  styles: `
    .subject { margin: 0 0 16px; font: var(--mat-sys-title-small); }
    .full { width: 100%; }
    .error { color: var(--mat-sys-error); font: var(--mat-sys-body-medium); }
    mat-dialog-content { min-width: min(380px, 80vw); }
  `,
})
export class AssignRegionDialog {
  readonly data = inject<AssignRegionData>(MAT_DIALOG_DATA);
  private readonly api = inject(RegionsApiService);
  private readonly toast = inject(ToastService);
  private readonly ref = inject(MatDialogRef<AssignRegionDialog, boolean>);

  protected readonly regions = signal<ServiceRegion[]>([]);
  protected readonly loading = signal(true);
  protected readonly loadError = signal<string | null>(null);
  protected readonly saving = signal(false);
  protected selected: number | null = this.data.currentRegionId;

  protected readonly typeLabel = computed(() =>
    this.data.kind === 'customer-support' ? 'support' : 'delivery',
  );

  protected readonly describe = describeRegion;

  constructor() {
    void this.load();
  }

  protected hint(): string {
    return this.data.kind === 'customer-support'
      ? 'Rejected orders from this region’s pin codes are routed to its agents.'
      : 'Only partners in the order’s delivery region are eligible for it.';
  }

  protected changed(): boolean {
    return this.selected !== this.data.currentRegionId;
  }

  private async load(): Promise<void> {
    const type =
      this.data.kind === 'customer-support' ? RegionType.CustomerSupport : RegionType.DeliveryBoy;

    try {
      this.regions.set(await firstValueFrom(this.api.listByType(type)));
    } catch (err) {
      this.loadError.set(describeHttpError(err as HttpErrorResponse));
    } finally {
      this.loading.set(false);
    }
  }

  protected async save(): Promise<void> {
    this.saving.set(true);

    try {
      if (this.data.kind === 'customer-support') {
        await firstValueFrom(
          this.api.assignCustomerSupport({
            customerSupportId: this.data.subjectId as string,
            serviceRegionId: this.selected,
          }),
        );
      } else {
        await firstValueFrom(
          this.api.assignDelivery({
            deliveryId: this.data.subjectId as number,
            serviceRegionId: this.selected,
          }),
        );
      }

      this.toast.success(this.selected === null ? 'Region cleared.' : 'Region assigned.');
      this.ref.close(true);
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    } finally {
      this.saving.set(false);
    }
  }
}
