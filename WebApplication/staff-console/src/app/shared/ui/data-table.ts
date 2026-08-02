import { BreakpointObserver } from '@angular/cdk/layout';
import { HANDSET_QUERY } from './breakpoints';
import {
  ChangeDetectionStrategy,
  Component,
  booleanAttribute,
  computed,
  effect,
  inject,
  input,
  output,
  signal,
} from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatMenuModule } from '@angular/material/menu';
import { MatPaginatorModule, PageEvent } from '@angular/material/paginator';
import { map } from 'rxjs';
import { ChipTone, StatusChip } from './status-chip';
import { EmptyState, ErrorState, LoadingState } from './state-panels';

export interface TableColumn<T> {
  key: string;
  header: string;
  /** Text to show. Return '—' for blanks so cells never look broken. */
  value: (row: T) => string;
  /** When present the cell renders as a chip instead of plain text. */
  chip?: (row: T) => { label: string; tone: ChipTone };
  /** Defaults to the display text. Provide for numeric or date columns so sorting is correct. */
  sortValue?: (row: T) => string | number;
  sortable?: boolean;
  /** Dropped from the card layout on small screens (the table always shows every column). */
  hideOnMobile?: boolean;
  /** Used as the card title on small screens. Exactly one column should set this. */
  primary?: boolean;
}

export interface RowAction<T> {
  label: string;
  icon: string;
  danger?: boolean;
  hidden?: (row: T) => boolean;
  run: (row: T) => void;
}

type SortDirection = 'asc' | 'desc';

/**
 * Shared list surface: sortable columns, client-side paging, per-row action menu, and the four
 * states (loading / error / empty / data). Below 768px it renders stacked cards instead of a
 * table so the page never scrolls sideways.
 */
@Component({
  selector: 'app-data-table',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    MatIconModule,
    MatButtonModule,
    MatMenuModule,
    MatPaginatorModule,
    StatusChip,
    LoadingState,
    EmptyState,
    ErrorState,
  ],
  template: `
    @if (loading()) {
      <app-loading-state [message]="loadingMessage()" />
    } @else if (error()) {
      <app-error-state [message]="error()!" [forbidden]="forbidden()" (retry)="retry.emit()" />
    } @else if (!rows().length) {
      <app-empty-state
        [icon]="emptyIcon()"
        [title]="emptyTitle()"
        [message]="emptyMessage()"
        [actionLabel]="emptyActionLabel()"
        (action)="emptyAction.emit()"
      />
    } @else if (!pageRows().length) {
      <app-empty-state
        icon="search_off"
        title="No matches"
        message="No records match the current filters. Try clearing them."
      />
    } @else if (isHandset()) {
      <div class="cards">
        @for (row of pageRows(); track trackRow(row)) {
          <div
            class="card"
            [class.clickable]="clickable()"
            [attr.role]="clickable() ? 'button' : null"
            [attr.tabindex]="clickable() ? 0 : null"
            (click)="onRowClick(row)"
            (keydown.enter)="onRowClick(row)"
            (keydown.space)="onRowKeydown($event, row)"
          >
            <div class="card-head">
              <span class="card-title">{{ primaryValue(row) }}</span>
              @if (visibleActions(row).length) {
                <button
                  matIconButton
                  [matMenuTriggerFor]="menu"
                  aria-label="Actions"
                  (click)="$event.stopPropagation()"
                >
                  <mat-icon>more_vert</mat-icon>
                </button>
                <mat-menu #menu="matMenu">
                  @for (action of visibleActions(row); track action.label) {
                    <button mat-menu-item [class.danger]="action.danger" (click)="action.run(row)">
                      <mat-icon>{{ action.icon }}</mat-icon>
                      <span>{{ action.label }}</span>
                    </button>
                  }
                </mat-menu>
              }
            </div>

            <dl>
              @for (column of cardColumns(); track column.key) {
                <div class="pair">
                  <dt>{{ column.header }}</dt>
                  <dd>
                    @if (column.chip) {
                      <app-status-chip
                        [label]="column.chip(row).label"
                        [tone]="column.chip(row).tone"
                      />
                    } @else {
                      {{ column.value(row) }}
                    }
                  </dd>
                </div>
              }
            </dl>
          </div>
        }
      </div>
    } @else {
      <div class="table-wrap">
        <table>
          <thead>
            <tr>
              @for (column of columns(); track column.key) {
                <th
                  [class.sortable]="column.sortable !== false"
                  [attr.aria-sort]="ariaSort(column)"
                  (click)="toggleSort(column)"
                >
                  <span class="th-inner">
                    {{ column.header }}
                    @if (sortKey() === column.key) {
                      <mat-icon class="sort-icon">
                        {{ sortDir() === 'asc' ? 'arrow_upward' : 'arrow_downward' }}
                      </mat-icon>
                    }
                  </span>
                </th>
              }
              @if (actions().length) {
                <th class="actions-col"><span class="sr-only">Actions</span></th>
              }
            </tr>
          </thead>
          <tbody>
            @for (row of pageRows(); track trackRow(row)) {
              <tr [class.clickable]="clickable()" (click)="onRowClick(row)">
                @for (column of columns(); track column.key) {
                  <td>
                    @if (column.chip) {
                      <app-status-chip
                        [label]="column.chip(row).label"
                        [tone]="column.chip(row).tone"
                      />
                    } @else {
                      {{ column.value(row) }}
                    }
                  </td>
                }
                @if (actions().length) {
                  <td class="actions-col">
                    @if (visibleActions(row).length) {
                      <button
                        matIconButton
                        [matMenuTriggerFor]="rowMenu"
                        aria-label="Actions"
                        (click)="$event.stopPropagation()"
                      >
                        <mat-icon>more_vert</mat-icon>
                      </button>
                      <mat-menu #rowMenu="matMenu">
                        @for (action of visibleActions(row); track action.label) {
                          <button
                            mat-menu-item
                            [class.danger]="action.danger"
                            (click)="action.run(row)"
                          >
                            <mat-icon>{{ action.icon }}</mat-icon>
                            <span>{{ action.label }}</span>
                          </button>
                        }
                      </mat-menu>
                    }
                  </td>
                }
              </tr>
            }
          </tbody>
        </table>
      </div>
    }

    @if (!loading() && !error() && rows().length) {
      <mat-paginator
        [length]="rows().length"
        [pageSize]="pageSize()"
        [pageIndex]="pageIndex()"
        [pageSizeOptions]="[25, 50, 100]"
        (page)="onPage($event)"
      />
    }
  `,
  styles: `
    :host { display: block; }

    .table-wrap {
      overflow-x: auto;
      border: 1px solid var(--mat-sys-outline-variant);
      border-radius: 12px;
      background: var(--mat-sys-surface);
    }

    table { width: 100%; border-collapse: collapse; }

    th, td {
      padding: 12px 16px;
      text-align: left;
      border-bottom: 1px solid var(--mat-sys-outline-variant);
      font: var(--mat-sys-body-medium);
      white-space: nowrap;
    }

    th {
      position: sticky;
      top: 0;
      background: var(--mat-sys-surface-container-low);
      font: var(--mat-sys-title-small);
      z-index: 1;
    }

    th.sortable { cursor: pointer; user-select: none; }
    th.sortable:hover { background: var(--mat-sys-surface-container); }

    .th-inner { display: inline-flex; align-items: center; gap: 4px; }
    .sort-icon { font-size: 16px; width: 16px; height: 16px; }

    tbody tr:last-child td { border-bottom: none; }
    tbody tr.clickable { cursor: pointer; }
    tbody tr.clickable:hover { background: var(--mat-sys-surface-container-low); }

    .actions-col { width: 56px; text-align: right; }

    .cards { display: flex; flex-direction: column; gap: 12px; }

    .card {
      border: 1px solid var(--mat-sys-outline-variant);
      border-radius: 12px;
      padding: 14px 16px;
      background: var(--mat-sys-surface);
    }
    .card.clickable { cursor: pointer; }

    .card-head {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 8px;
      margin-bottom: 8px;
    }

    .card-title { font: var(--mat-sys-title-small); }

    dl { margin: 0; display: grid; gap: 6px; }
    .pair { display: flex; justify-content: space-between; gap: 16px; }
    dt { color: var(--mat-sys-on-surface-variant); font: var(--mat-sys-body-small); }
    dd { margin: 0; text-align: right; font: var(--mat-sys-body-medium); }

    .danger { color: var(--mat-sys-error); }

    .sr-only {
      position: absolute;
      width: 1px;
      height: 1px;
      overflow: hidden;
      clip: rect(0 0 0 0);
      white-space: nowrap;
    }
  `,
})
export class DataTable<T> {
  private readonly breakpoints = inject(BreakpointObserver);

  readonly rows = input.required<T[]>();
  readonly columns = input.required<TableColumn<T>[]>();
  readonly actions = input<RowAction<T>[]>([]);
  readonly trackBy = input<(row: T) => string | number>((row) => JSON.stringify(row));

  readonly loading = input(false);
  readonly loadingMessage = input('Loading…');
  readonly error = input<string | null>(null);
  readonly forbidden = input(false);

  readonly emptyIcon = input('inbox');
  readonly emptyTitle = input('Nothing here yet');
  readonly emptyMessage = input('');
  readonly emptyActionLabel = input('');

  readonly clickable = input(false, { transform: booleanAttribute });

  readonly rowClick = output<T>();
  readonly retry = output<void>();
  readonly emptyAction = output<void>();

  /** Matches the 768px card/table breakpoint documented in docs/FUNCTIONAL_SPEC.md §3.3. */
  protected readonly isHandset = toSignal(
    this.breakpoints.observe(HANDSET_QUERY).pipe(map((result) => result.matches)),
    { initialValue: false },
  );

  protected readonly sortKey = signal<string | null>(null);
  protected readonly sortDir = signal<SortDirection>('asc');
  protected readonly pageIndex = signal(0);
  protected readonly pageSize = signal(25);

  protected readonly cardColumns = computed(() =>
    this.columns().filter((column) => !column.primary && !column.hideOnMobile),
  );

  private readonly sortedRows = computed(() => {
    const key = this.sortKey();
    const rows = [...this.rows()];
    if (!key) {
      return rows;
    }

    const column = this.columns().find((c) => c.key === key);
    if (!column) {
      return rows;
    }

    const direction = this.sortDir() === 'asc' ? 1 : -1;
    const read = column.sortValue ?? ((row: T) => column.value(row));

    return rows.sort((a, b) => {
      const left = read(a);
      const right = read(b);
      if (typeof left === 'number' && typeof right === 'number') {
        return (left - right) * direction;
      }
      return String(left).localeCompare(String(right), undefined, { numeric: true }) * direction;
    });
  });

  protected readonly pageRows = computed(() => {
    const start = this.pageIndex() * this.pageSize();
    return this.sortedRows().slice(start, start + this.pageSize());
  });

  constructor() {
    // A filter change shortens the list; without this the user is stranded on a now-empty page.
    effect(() => {
      const lastPage = Math.max(0, Math.ceil(this.rows().length / this.pageSize()) - 1);
      if (this.pageIndex() > lastPage) {
        this.pageIndex.set(lastPage);
      }
    });
  }

  protected trackRow(row: T): string | number {
    return this.trackBy()(row);
  }

  protected primaryValue(row: T): string {
    const column = this.columns().find((c) => c.primary) ?? this.columns()[0];
    return column ? column.value(row) : '';
  }

  protected visibleActions(row: T): RowAction<T>[] {
    return this.actions().filter((action) => !action.hidden?.(row));
  }

  protected ariaSort(column: TableColumn<T>): string | null {
    if (this.sortKey() !== column.key) {
      return column.sortable === false ? null : 'none';
    }
    return this.sortDir() === 'asc' ? 'ascending' : 'descending';
  }

  protected toggleSort(column: TableColumn<T>): void {
    if (column.sortable === false) {
      return;
    }

    if (this.sortKey() === column.key) {
      this.sortDir.update((dir) => (dir === 'asc' ? 'desc' : 'asc'));
    } else {
      this.sortKey.set(column.key);
      this.sortDir.set('asc');
    }
    this.pageIndex.set(0);
  }

  protected onPage(event: PageEvent): void {
    this.pageIndex.set(event.pageIndex);
    this.pageSize.set(event.pageSize);
  }

  protected onRowClick(row: T): void {
    if (this.clickable()) {
      this.rowClick.emit(row);
    }
  }

  /** Space would scroll the page, so swallow it and treat it as activation. */
  protected onRowKeydown(event: Event, row: T): void {
    event.preventDefault();
    this.onRowClick(row);
  }
}
