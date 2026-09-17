import { ChangeDetectionStrategy, Component, computed, input } from '@angular/core';
import { MatIconModule } from '@angular/material/icon';
import { Order } from '../../../core/models/api.models';
import { JOURNEY_STAGES, journeyOf } from '../data/order-journey';

/**
 * Where an order has got to, in the six stages a customer recognises.
 *
 * `full` draws every stage with its label — the order page. `compact` draws a thin segmented bar
 * with just the current stage named — lists, where six labels per row would be noise.
 */
@Component({
  selector: 'app-order-tracker',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [MatIconModule],
  template: `
    @if (variant() === 'full') {
      <ol class="full" [class.stopped]="journey().cancelled" [attr.aria-label]="ariaLabel()">
        @for (stage of stages; track stage.key; let i = $index) {
          <li
            [class.done]="!journey().cancelled && i < journey().stage"
            [class.now]="!journey().cancelled && i === journey().stage"
            [attr.aria-current]="i === journey().stage ? 'step' : null"
          >
            <span class="dot">
              @if (!journey().cancelled && i < journey().stage) {
                <mat-icon>check</mat-icon>
              } @else {
                <mat-icon>{{ stage.icon }}</mat-icon>
              }
            </span>
            <span class="label">{{ stage.label }}</span>
          </li>
        }
      </ol>
    } @else {
      <div class="compact" [class.stopped]="journey().cancelled" [attr.aria-label]="ariaLabel()">
        @for (stage of stages; track stage.key; let i = $index) {
          <span
            class="seg"
            [class.done]="!journey().cancelled && i < journey().stage"
            [class.now]="!journey().cancelled && i === journey().stage"
          ></span>
        }
      </div>
    }
  `,
  styles: `
    :host { display: block; }

    /* ---- full ---- */
    .full {
      list-style: none; margin: 0; padding: 0;
      display: grid; grid-template-columns: repeat(6, 1fr);
      position: relative;
    }
    .full li {
      position: relative;
      display: flex; flex-direction: column; align-items: center; gap: 10px;
      text-align: center;
    }
    /* connector to the previous stage */
    .full li + li::before {
      content: ""; position: absolute; top: 19px; right: 50%; width: 100%; height: 3px;
      background: var(--pt-line); z-index: 0;
    }
    .full li.done::before, .full li.now::before { background: var(--pt-navy); }
    .dot {
      position: relative; z-index: 1;
      width: 40px; height: 40px; border-radius: 50%;
      display: grid; place-items: center;
      background: var(--pt-card); color: var(--pt-faint);
      border: 2px solid var(--pt-line);
      transition: background 200ms ease, border-color 200ms ease;
    }
    .dot mat-icon { font-size: 20px; width: 20px; height: 20px; }
    li.done .dot { background: var(--pt-navy); border-color: var(--pt-navy); color: #fff; }
    li.now .dot {
      background: var(--pt-orange-soft); border-color: var(--pt-orange); color: var(--pt-orange-deep);
      box-shadow: 0 0 0 5px color-mix(in srgb, var(--pt-orange) 16%, transparent);
    }
    .label { font-size: 0.8rem; line-height: 1.25; color: var(--pt-muted); font-weight: 500; }
    li.done .label { color: var(--pt-ink); }
    li.now .label { color: var(--pt-ink); font-weight: 700; }
    .full.stopped .dot { opacity: 0.45; }
    .full.stopped li::before { background: var(--pt-line) !important; }

    @media (max-width: 640px) {
      .full { grid-template-columns: 1fr; gap: 0; }
      .full li { flex-direction: row; gap: 14px; text-align: left; padding: 0 0 18px; }
      .full li + li::before { top: -18px; left: 19px; right: auto; width: 3px; height: 18px; }
    }

    /* ---- compact ---- */
    .compact { display: grid; grid-template-columns: repeat(6, 1fr); gap: 4px; }
    .seg { height: 6px; border-radius: 3px; background: var(--pt-line); }
    .seg.done { background: var(--pt-navy); }
    .seg.now { background: var(--pt-orange); }
    .compact.stopped .seg { background: var(--pt-line); }

    @media (prefers-reduced-motion: reduce) { .dot { transition: none; } }
  `,
})
export class OrderTracker {
  readonly order = input.required<Order>();
  readonly variant = input<'full' | 'compact'>('full');

  protected readonly stages = JOURNEY_STAGES;
  protected readonly journey = computed(() => journeyOf(this.order()));
  protected readonly ariaLabel = computed(() => {
    const j = this.journey();
    return j.cancelled
      ? 'Order cancelled'
      : `Stage ${j.stage + 1} of ${this.stages.length}: ${this.stages[j.stage].label}`;
  });
}
