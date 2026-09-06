import { HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectionStrategy, Component, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MatDialog } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatSelectModule } from '@angular/material/select';
import { firstValueFrom } from 'rxjs';
import { CapabilityService } from '../../../core/config/capabilities';
import { describeHttpError } from '../../../core/http/interceptors';
import { DataTable, RowAction, TableColumn } from '../../../shared/ui/data-table';
import { FilterBar } from '../../../shared/ui/filter-bar';
import { PageHeader } from '../../../shared/ui/page-header';
import { ChangeUserNameDialog, ChangeUserNameDialogData } from '../dialogs/change-username-dialog';
import { ResetPasswordDialog, ResetPasswordDialogData } from '../dialogs/reset-password-dialog';
import { UserAccount, UserAccountsApiService, userAccountFullName } from '../data/user-accounts-api.service';

type RoleFilter = 'all' | string;

@Component({
  selector: 'app-user-accounts-list',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [FormsModule, MatFormFieldModule, MatSelectModule, PageHeader, FilterBar, DataTable],
  template: `
    <app-page-header
      title="User Accounts"
      subtitle="Change a user's login username or reset their password."
    />

    <app-filter-bar
      [(search)]="search"
      searchLabel="Search username or name"
      (resetFilters)="resetFilters()"
    >
      <mat-form-field appearance="outline" subscriptSizing="dynamic">
        <mat-label>Role</mat-label>
        <mat-select [(ngModel)]="role">
          <mat-option value="all">All roles</mat-option>
          @for (r of roles(); track r) {
            <mat-option [value]="r">{{ r }}</mat-option>
          }
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
      emptyTitle="No user accounts"
      emptyMessage="No accounts matched your filters."
      (retry)="load()"
    />
  `,
  styles: `
    :host { display: block; }
    mat-form-field { min-width: 180px; }
  `,
})
export class UserAccountsList {
  private readonly api = inject(UserAccountsApiService);
  private readonly dialog = inject(MatDialog);
  private readonly capabilities = inject(CapabilityService);

  protected readonly users = signal<UserAccount[]>([]);
  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);
  protected readonly forbidden = signal(false);

  protected readonly search = signal('');
  protected readonly role = signal<RoleFilter>('all');

  protected readonly canManage = computed(() => this.capabilities.can('manageUserAccounts'));
  protected readonly trackBy = (row: UserAccount) => row.id;

  /** Roles actually present in the data, so the filter never offers an empty option. */
  protected readonly roles = computed(() =>
    [...new Set(this.users().map((u) => u.roleName).filter((r): r is string => !!r))].sort(),
  );

  protected readonly columns: TableColumn<UserAccount>[] = [
    {
      key: 'mobileNumber',
      header: 'Username',
      primary: true,
      value: (row) => row.mobileNumber || '—',
    },
    { key: 'roleName', header: 'Role', value: (row) => row.roleName || '—' },
    { key: 'name', header: 'Name', value: (row) => userAccountFullName(row) || '—' },
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

  protected readonly actions = computed<RowAction<UserAccount>[]>(() => {
    if (!this.canManage()) {
      return [];
    }
    return [
      {
        label: 'Change username',
        icon: 'badge',
        run: (row) => void this.changeUserName(row),
      },
      {
        label: 'Reset password',
        icon: 'key',
        run: (row) => void this.resetPassword(row),
      },
    ];
  });

  protected readonly filtered = computed(() => {
    const term = this.search().trim().toLowerCase();
    const role = this.role();

    return this.users().filter((user) => {
      if (role !== 'all' && user.roleName !== role) {
        return false;
      }
      if (!term) {
        return true;
      }
      return [user.mobileNumber, userAccountFullName(user), user.roleName]
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
      this.users.set((await firstValueFrom(this.api.list())) ?? []);
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
    this.role.set('all');
  }

  private async changeUserName(user: UserAccount): Promise<void> {
    const ref = this.dialog.open<ChangeUserNameDialog, ChangeUserNameDialogData, boolean>(
      ChangeUserNameDialog,
      { data: { user } },
    );
    // Reload on success so the list shows the new username immediately.
    if (await firstValueFrom(ref.afterClosed())) {
      await this.load();
    }
  }

  private async resetPassword(user: UserAccount): Promise<void> {
    const ref = this.dialog.open<ResetPasswordDialog, ResetPasswordDialogData, boolean>(
      ResetPasswordDialog,
      { data: { user } },
    );
    await firstValueFrom(ref.afterClosed());
  }
}
