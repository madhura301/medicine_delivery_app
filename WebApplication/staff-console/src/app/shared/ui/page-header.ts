import { ChangeDetectionStrategy, Component, input, output } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';

@Component({
  selector: 'app-page-header',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [MatButtonModule, MatIconModule],
  template: `
    <header>
      <div class="titles">
        <h1>{{ title() }}</h1>
        @if (subtitle()) {
          <p>{{ subtitle() }}</p>
        }
      </div>

      <div class="actions">
        <ng-content select="[headerActions]" />
        @if (actionLabel()) {
          <button matButton="filled" (click)="action.emit()">
            <mat-icon>{{ actionIcon() }}</mat-icon>
            {{ actionLabel() }}
          </button>
        }
      </div>
    </header>
  `,
  styles: `
    :host { display: block; }

    header {
      display: flex;
      flex-wrap: wrap;
      align-items: flex-start;
      justify-content: space-between;
      gap: 12px;
      margin-bottom: 20px;
    }

    h1 {
      margin: 0;
      font: var(--mat-sys-headline-small);
    }

    p {
      margin: 4px 0 0;
      color: var(--mat-sys-on-surface-variant);
      font: var(--mat-sys-body-medium);
    }

    .actions { display: flex; gap: 8px; flex-wrap: wrap; }

    @media (max-width: 599px) {
      header { flex-direction: column; align-items: stretch; }
      .actions button { width: 100%; }
    }
  `,
})
export class PageHeader {
  readonly title = input.required<string>();
  readonly subtitle = input<string>('');
  readonly actionLabel = input<string>('');
  readonly actionIcon = input<string>('add');
  readonly action = output<void>();
}
