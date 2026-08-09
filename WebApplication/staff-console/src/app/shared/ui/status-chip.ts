import { ChangeDetectionStrategy, Component, input } from '@angular/core';

export type ChipTone = 'neutral' | 'positive' | 'warning' | 'danger' | 'info';

@Component({
  selector: 'app-status-chip',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    '[class]': '"tone-" + tone()',
  },
  template: `{{ label() }}`,
  styles: `
    :host {
      display: inline-block;
      padding: 2px 10px;
      border-radius: 999px;
      font: var(--mat-sys-label-small);
      line-height: 20px;
      white-space: nowrap;
    }
    :host.tone-neutral {
      background: var(--mat-sys-surface-container-highest);
      color: var(--mat-sys-on-surface-variant);
    }
    :host.tone-positive { background: #d8f3dc; color: #17663a; }
    :host.tone-warning  { background: #fff0d4; color: #8a5300; }
    :host.tone-danger   { background: #fbdad7; color: #9b2226; }
    :host.tone-info     { background: #dbe7ff; color: #1e40af; }

    @media (prefers-color-scheme: dark) {
      :host.tone-positive { background: #14532d; color: #b7f0c8; }
      :host.tone-warning  { background: #573600; color: #ffdfa6; }
      :host.tone-danger   { background: #641b1f; color: #ffd2ce; }
      :host.tone-info     { background: #1e3a8a; color: #d3e0ff; }
    }
  `,
})
export class StatusChip {
  readonly label = input.required<string>();
  readonly tone = input<ChipTone>('neutral');
}
