import { ChangeDetectionStrategy, Component } from '@angular/core';
import { MatIconModule } from '@angular/material/icon';
import { RouterLink } from '@angular/router';

/** Same contact addresses the mobile app lists. */
@Component({
  selector: 'app-portal-help',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [MatIconModule, RouterLink],
  template: `
    <header>
      <h1>Help &amp; support</h1>
      <p>We're here to help with orders, payments and your account.</p>
    </header>

    <div class="grid">
      <a class="card" href="mailto:support@pharmaish.com">
        <span class="i"><mat-icon>support_agent</mat-icon></span>
        <strong>Orders &amp; deliveries</strong>
        <span>A delayed, missing or incorrect order.</span>
        <em>support&#64;pharmaish.com</em>
      </a>
      <a class="card" href="mailto:accounts@pharmaish.com">
        <span class="i"><mat-icon>receipt</mat-icon></span>
        <strong>Payments &amp; refunds</strong>
        <span>A charge you don't recognise, or a refund.</span>
        <em>accounts&#64;pharmaish.com</em>
      </a>
      <a class="card" href="mailto:grievance@pharmaish.com">
        <span class="i"><mat-icon>gavel</mat-icon></span>
        <strong>Grievances</strong>
        <span>Raise a formal complaint with our grievance officer.</span>
        <em>grievance&#64;pharmaish.com</em>
      </a>
    </div>

    <section class="tips">
      <h2>Before you write in</h2>
      <ul>
        <li><strong>Quote your order number</strong> — it's at the top of every order page, and it lets us find your order straight away.</li>
        <li><strong>Waiting on a chemist?</strong> If the first chemist can't fulfil an order we place it with another automatically. You don't need to reorder.</li>
        <li><strong>Paid but the order still says "bill ready"?</strong> Payments can take a minute to confirm. Refresh <a routerLink="/my/orders">My orders</a> before paying again.</li>
      </ul>
    </section>
  `,
  styles: `
    :host { display: flex; flex-direction: column; gap: 22px; }
    h1 { margin: 0; font-size: clamp(1.7rem, 3vw, 2.2rem); font-weight: 800; letter-spacing: -0.025em; color: var(--pt-navy-deep); }
    header p { margin: 4px 0 0; color: var(--pt-muted); }
    .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 16px; }
    .card { display: flex; flex-direction: column; gap: 6px; padding: 22px; background: var(--pt-card); border: 1px solid var(--pt-line); border-radius: var(--pt-radius); text-decoration: none; color: var(--pt-ink); }
    .card:hover { border-color: color-mix(in srgb, var(--pt-navy) 30%, transparent); box-shadow: var(--pt-shadow); }
    .card:focus-visible { outline: 3px solid color-mix(in srgb, var(--pt-navy) 40%, transparent); outline-offset: 2px; }
    .i { width: 46px; height: 46px; border-radius: 14px; display: grid; place-items: center; background: var(--pt-navy-soft); color: var(--pt-navy); margin-bottom: 6px; }
    .card strong { font-weight: 700; font-size: 1.05rem; }
    .card span { color: var(--pt-muted); font-size: 0.9rem; line-height: 1.45; }
    .card em { font-style: normal; color: var(--pt-navy); font-weight: 700; margin-top: 6px; }
    .tips { background: var(--pt-card); border: 1px solid var(--pt-line); border-radius: var(--pt-radius); padding: 22px; }
    .tips h2 { margin: 0 0 12px; font-size: 1.1rem; font-weight: 700; }
    ul { margin: 0; padding-left: 1.2em; display: flex; flex-direction: column; gap: 10px; color: var(--pt-muted); line-height: 1.55; }
    li strong { color: var(--pt-ink); }
    a { color: var(--pt-navy); font-weight: 600; }
  `,
})
export class PortalHelp {}
