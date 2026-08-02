import { ChangeDetectionStrategy, Component, input, output } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';

@Component({
  selector: 'app-loading-state',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [MatProgressSpinnerModule],
  template: `
    <div class="panel" role="status" aria-live="polite">
      <mat-spinner diameter="36" />
      <p>{{ message() }}</p>
    </div>
  `,
  styles: `
    .panel {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 16px;
      padding: 56px 16px;
      color: var(--mat-sys-on-surface-variant);
    }
    p { margin: 0; font: var(--mat-sys-body-medium); }
  `,
})
export class LoadingState {
  readonly message = input('Loading…');
}

@Component({
  selector: 'app-empty-state',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [MatIconModule, MatButtonModule],
  template: `
    <div class="panel">
      <mat-icon>{{ icon() }}</mat-icon>
      <h2>{{ title() }}</h2>
      @if (message()) {
        <p>{{ message() }}</p>
      }
      @if (actionLabel()) {
        <button matButton="filled" (click)="action.emit()">{{ actionLabel() }}</button>
      }
    </div>
  `,
  styles: `
    .panel {
      display: flex;
      flex-direction: column;
      align-items: center;
      text-align: center;
      gap: 8px;
      padding: 56px 16px;
      color: var(--mat-sys-on-surface-variant);
    }
    mat-icon {
      width: 48px;
      height: 48px;
      font-size: 48px;
      opacity: 0.45;
    }
    h2 { margin: 8px 0 0; font: var(--mat-sys-title-medium); color: var(--mat-sys-on-surface); }
    p { margin: 0; max-width: 42ch; font: var(--mat-sys-body-medium); }
    button { margin-top: 12px; }
  `,
})
export class EmptyState {
  readonly icon = input('inbox');
  readonly title = input.required<string>();
  readonly message = input('');
  readonly actionLabel = input('');
  readonly action = output<void>();
}

@Component({
  selector: 'app-error-state',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [MatIconModule, MatButtonModule],
  template: `
    <div class="panel" role="alert">
      <mat-icon>{{ forbidden() ? 'lock' : 'error_outline' }}</mat-icon>
      <h2>{{ forbidden() ? 'Not permitted' : 'Could not load this' }}</h2>
      <p>{{ message() }}</p>
      @if (!forbidden()) {
        <button matButton="filled" (click)="retry.emit()">Try again</button>
      }
    </div>
  `,
  styles: `
    .panel {
      display: flex;
      flex-direction: column;
      align-items: center;
      text-align: center;
      gap: 8px;
      padding: 56px 16px;
      color: var(--mat-sys-on-surface-variant);
    }
    mat-icon {
      width: 48px;
      height: 48px;
      font-size: 48px;
      color: var(--mat-sys-error);
    }
    h2 { margin: 8px 0 0; font: var(--mat-sys-title-medium); color: var(--mat-sys-on-surface); }
    p { margin: 0; max-width: 48ch; font: var(--mat-sys-body-medium); }
    button { margin-top: 12px; }
  `,
})
export class ErrorState {
  readonly message = input('Something went wrong.');
  readonly forbidden = input(false);
  readonly retry = output<void>();
}
