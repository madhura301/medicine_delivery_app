import { ChangeDetectionStrategy, Component, input, model, output, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';

/**
 * Search box plus a slot for screen-specific filters. On narrow screens the extra filters
 * collapse behind a toggle so the search field keeps the full width.
 */
@Component({
  selector: 'app-filter-bar',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [FormsModule, MatFormFieldModule, MatInputModule, MatIconModule, MatButtonModule],
  template: `
    <div class="bar">
      <mat-form-field appearance="outline" class="search" subscriptSizing="dynamic">
        <mat-icon matPrefix>search</mat-icon>
        <mat-label>{{ searchLabel() }}</mat-label>
        <input
          matInput
          type="search"
          [ngModel]="search()"
          (ngModelChange)="search.set($event)"
          [attr.aria-label]="searchLabel()"
        />
        @if (search()) {
          <button matIconButton matSuffix aria-label="Clear search" (click)="search.set('')">
            <mat-icon>close</mat-icon>
          </button>
        }
      </mat-form-field>

      <button matButton class="toggle" (click)="expanded.set(!expanded())">
        <mat-icon>tune</mat-icon>
        Filters
      </button>

      <div class="extras" [class.expanded]="expanded()">
        <ng-content />
        @if (showReset()) {
          <button matButton (click)="resetFilters.emit()">
            <mat-icon>restart_alt</mat-icon>
            Reset
          </button>
        }
      </div>
    </div>
  `,
  styles: `
    :host { display: block; margin-bottom: 16px; }

    .bar {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      gap: 12px;
    }

    .search { flex: 1 1 280px; min-width: 220px; }

    .extras {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      gap: 12px;
    }

    .toggle { display: none; }

    @media (max-width: 767px) {
      .toggle { display: inline-flex; }
      .extras { display: none; width: 100%; flex-direction: column; align-items: stretch; }
      .extras.expanded { display: flex; }
    }
  `,
})
export class FilterBar {
  readonly search = model<string>('');
  readonly searchLabel = input('Search');
  readonly showReset = input(true);
  readonly resetFilters = output<void>();

  protected readonly expanded = signal(false);
}
