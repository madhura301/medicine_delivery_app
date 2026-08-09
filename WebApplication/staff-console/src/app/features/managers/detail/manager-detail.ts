import { HttpErrorResponse } from '@angular/common/http';
import { DatePipe } from '@angular/common';
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
import { Manager } from '../../../core/models/api.models';
import { ConfirmService } from '../../../core/ui/confirm-dialog';
import { ToastService } from '../../../core/ui/toast.service';
import { PageHeader } from '../../../shared/ui/page-header';
import { LoadingState, ErrorState } from '../../../shared/ui/state-panels';
import { StatusChip } from '../../../shared/ui/status-chip';
import { ManagersApiService } from '../data/managers-api.service';
import { ManagerFormDialog, ManagerFormData } from '../dialogs/manager-form-dialog';
import { fullName } from '../list/managers-list';

@Component({
  selector: 'app-manager-detail',
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
  ],
  template: `
    @if (loading()) {
      <app-loading-state message="Loading manager…" />
    } @else if (error()) {
      <app-error-state [message]="error()!" [forbidden]="forbidden()" (retry)="load()" />
    } @else if (manager(); as row) {
      <app-page-header [title]="name()" [subtitle]="'Employee ID ' + (row.employeeId || '—')">
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
            <button matButton (click)="photoInput.click()">
              <mat-icon>photo_camera</mat-icon>
              Photo
            </button>
            <button matButton (click)="remove()">
              <mat-icon>delete</mat-icon>
              Delete
            </button>
          }
        </div>
      </app-page-header>

      <input
        #photoInput
        type="file"
        accept="image/*"
        hidden
        (change)="uploadPhoto($event)"
      />

      <div class="cards">
        <mat-card appearance="outlined">
          <mat-card-header><mat-card-title>Contact</mat-card-title></mat-card-header>
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
              <dt>Address</dt>
              <dd>{{ address() }}</dd>
            </dl>
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
              <dt>Photo</dt>
              <dd>{{ row.managerPhoto || 'Not uploaded' }}</dd>
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
    dd { margin: 0; font: var(--mat-sys-body-medium); text-align: right; }
    [headerActions] { display: flex; gap: 8px; flex-wrap: wrap; }
  `,
})
export class ManagerDetail {
  /** Bound from the :id route parameter via withComponentInputBinding(). */
  readonly id = input.required<string>();

  private readonly api = inject(ManagersApiService);
  private readonly dialog = inject(MatDialog);
  private readonly confirm = inject(ConfirmService);
  private readonly toast = inject(ToastService);
  private readonly router = inject(Router);
  private readonly capabilities = inject(CapabilityService);

  protected readonly manager = signal<Manager | null>(null);
  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);
  protected readonly forbidden = signal(false);

  protected readonly canManage = computed(() => this.capabilities.can('manageManagers'));
  protected readonly name = computed(() => {
    const row = this.manager();
    return row ? fullName(row) : '';
  });
  protected readonly address = computed(() => {
    const row = this.manager();
    if (!row) {
      return '—';
    }
    return [row.address, row.city, row.state].filter(Boolean).join(', ') || '—';
  });

  constructor() {
    // An effect, not the constructor: route inputs are not bound yet when the constructor runs.
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
      this.manager.set(await firstValueFrom(this.api.get(id)));
    } catch (err) {
      const error = err as HttpErrorResponse;
      this.forbidden.set(error.status === 403);
      this.error.set(describeHttpError(error));
    } finally {
      this.loading.set(false);
    }
  }

  protected back(): void {
    void this.router.navigate(['/managers']);
  }

  protected async edit(): Promise<void> {
    const manager = this.manager();
    if (!manager) {
      return;
    }

    const ref = this.dialog.open<ManagerFormDialog, ManagerFormData, boolean>(ManagerFormDialog, {
      data: { manager },
      width: '640px',
      maxWidth: '96vw',
    });

    if (await firstValueFrom(ref.afterClosed())) {
      await this.load();
    }
  }

  protected async uploadPhoto(event: Event): Promise<void> {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0];
    input.value = '';

    if (!file) {
      return;
    }

    try {
      await firstValueFrom(this.api.uploadPhoto(this.id(), file));
      this.toast.success('Photo uploaded.');
      await this.load();
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    }
  }

  protected async remove(): Promise<void> {
    const manager = this.manager();
    if (!manager) {
      return;
    }

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
      this.back();
    } catch (err) {
      this.toast.error(describeHttpError(err as HttpErrorResponse));
    }
  }
}
