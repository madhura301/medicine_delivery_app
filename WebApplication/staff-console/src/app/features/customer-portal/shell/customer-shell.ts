import { ChangeDetectionStrategy, Component, computed, inject, OnInit } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatMenuModule } from '@angular/material/menu';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { AuthStore } from '../../../core/auth/auth.store';
import { isPayable } from '../data/order-journey';
import { PortalStore } from '../data/portal.store';

/**
 * The customer's layout — deliberately nothing like the staff console. A top bar with three
 * destinations on desktop, a bottom tab bar on phones, and no sidebar: a customer has four
 * things to do, not forty.
 */
@Component({
  selector: 'app-customer-shell',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: { class: 'portal-theme' },
  imports: [RouterOutlet, RouterLink, RouterLinkActive, MatButtonModule, MatIconModule, MatMenuModule],
  template: `
    <a class="skip" href="#portal-main">Skip to content</a>

    <header class="bar">
      <div class="bar-inner">
        <a routerLink="/my" class="brand" aria-label="Pharmaish home">
          <img src="logo.png" alt="" width="36" height="36" />
          <span>Pharmaish</span>
        </a>

        <nav class="nav" aria-label="Main">
          <a routerLink="/my" [routerLinkActiveOptions]="{ exact: true }" routerLinkActive="on">Home</a>
          <a routerLink="/my/orders" routerLinkActive="on">
            My orders
            @if (attention() > 0) { <span class="badge" aria-label="needs attention">{{ attention() }}</span> }
          </a>
          <a routerLink="/my/addresses" routerLinkActive="on">Addresses</a>
        </nav>

        <div class="right">
          <a matButton="filled" class="pt-cta new" routerLink="/my/new-order">
            <mat-icon>add</mat-icon>
            New order
          </a>

          <button class="avatar" [matMenuTriggerFor]="account" aria-label="Your account">
            {{ initials() }}
          </button>
          <mat-menu #account="matMenu" xPosition="before" class="portal-theme">
            <div class="menu-who">
              <strong>{{ fullName() }}</strong>
              <span>{{ store.profile()?.mobileNumber }}</span>
            </div>
            <a mat-menu-item routerLink="/my/profile"><mat-icon>person</mat-icon>Profile</a>
            <a mat-menu-item routerLink="/my/change-password"><mat-icon>lock</mat-icon>Change password</a>
            <a mat-menu-item routerLink="/my/help"><mat-icon>support_agent</mat-icon>Help &amp; support</a>
            <button mat-menu-item (click)="signOut()"><mat-icon>logout</mat-icon>Sign out</button>
          </mat-menu>
        </div>
      </div>
    </header>

    <main id="portal-main" class="main">
      <router-outlet />
    </main>

    <nav class="tabs" aria-label="Main">
      <a routerLink="/my" [routerLinkActiveOptions]="{ exact: true }" routerLinkActive="on">
        <mat-icon>home</mat-icon><span>Home</span>
      </a>
      <a routerLink="/my/orders" routerLinkActive="on">
        <mat-icon>receipt_long</mat-icon><span>Orders</span>
        @if (attention() > 0) { <i class="pip"></i> }
      </a>
      <a routerLink="/my/new-order" class="tab-cta" aria-label="New order">
        <mat-icon>add</mat-icon>
      </a>
      <a routerLink="/my/addresses" routerLinkActive="on">
        <mat-icon>location_on</mat-icon><span>Addresses</span>
      </a>
      <a routerLink="/my/profile" routerLinkActive="on">
        <mat-icon>person</mat-icon><span>Profile</span>
      </a>
    </nav>
  `,
  styles: `
    :host { display: block; min-height: 100dvh; background: var(--pt-ground); }

    .skip {
      position: absolute; left: -9999px; top: 8px; z-index: 100;
      background: var(--pt-navy); color: #fff; padding: 10px 14px; border-radius: 8px;
    }
    .skip:focus { left: 8px; }

    .bar {
      position: sticky; top: 0; z-index: 20;
      background: rgba(255, 255, 255, 0.92);
      backdrop-filter: saturate(1.4) blur(10px);
      border-bottom: 1px solid var(--pt-line);
    }
    .bar-inner {
      max-width: 1120px; margin: 0 auto; padding: 0 24px; height: 68px;
      display: flex; align-items: center; gap: 32px;
    }
    .brand {
      display: flex; align-items: center; gap: 10px; text-decoration: none;
      color: var(--pt-navy-deep); font-weight: 800; font-size: 1.2rem; letter-spacing: -0.01em;
    }
    .brand img { border-radius: 10px; }

    .nav { display: flex; gap: 6px; }
    .nav a {
      position: relative; display: inline-flex; align-items: center; gap: 8px;
      padding: 9px 14px; border-radius: 999px; text-decoration: none;
      color: var(--pt-muted); font-weight: 600; font-size: 0.95rem;
    }
    .nav a:hover { color: var(--pt-ink); background: var(--pt-navy-soft); }
    .nav a.on { color: var(--pt-navy); background: var(--pt-navy-soft); }
    .nav a:focus-visible, .brand:focus-visible, .avatar:focus-visible, .tabs a:focus-visible {
      outline: 3px solid color-mix(in srgb, var(--pt-navy) 45%, transparent); outline-offset: 2px;
    }
    .badge {
      min-width: 20px; height: 20px; padding: 0 6px; border-radius: 999px;
      background: var(--pt-orange); color: #fff; font-size: 0.72rem; font-weight: 700;
      display: grid; place-items: center;
    }

    .right { margin-left: auto; display: flex; align-items: center; gap: 14px; }
    .avatar {
      width: 40px; height: 40px; border-radius: 50%; border: 0; cursor: pointer;
      background: var(--pt-navy); color: #fff; font: 700 0.95rem Figtree, sans-serif;
    }
    .menu-who { display: flex; flex-direction: column; padding: 10px 16px 12px; border-bottom: 1px solid var(--pt-line); margin-bottom: 4px; }
    .menu-who strong { font-weight: 700; }
    .menu-who span { color: var(--pt-muted); font-size: 0.85rem; }

    .main { max-width: 1120px; margin: 0 auto; padding: 32px 24px 64px; }

    .tabs { display: none; }

    @media (max-width: 760px) {
      .nav, .new { display: none; }
      .bar-inner { padding: 0 16px; height: 60px; }
      .main { padding: 20px 16px 104px; }

      .tabs {
        display: grid; grid-template-columns: repeat(5, 1fr); align-items: end;
        position: fixed; left: 0; right: 0; bottom: 0; z-index: 30;
        background: #fff; border-top: 1px solid var(--pt-line);
        padding: 6px 4px calc(8px + env(safe-area-inset-bottom));
      }
      .tabs a {
        position: relative; display: flex; flex-direction: column; align-items: center; gap: 2px;
        text-decoration: none; color: var(--pt-faint); font-size: 0.7rem; font-weight: 600; padding: 6px 0;
      }
      .tabs a.on { color: var(--pt-navy); }
      .tabs .pip { position: absolute; top: 4px; right: calc(50% - 16px); width: 8px; height: 8px; border-radius: 50%; background: var(--pt-orange); }
      .tab-cta {
        justify-self: center; width: 54px; height: 54px; border-radius: 50% !important;
        background: var(--pt-orange); color: #fff !important; margin-bottom: 6px;
        box-shadow: 0 6px 16px color-mix(in srgb, var(--pt-orange) 45%, transparent);
        display: grid !important; place-items: center; padding: 0 !important;
      }
    }
  `,
})
export class CustomerShell implements OnInit {
  protected readonly store = inject(PortalStore);
  private readonly auth = inject(AuthStore);

  protected readonly fullName = computed(() => {
    const p = this.store.profile();
    return p ? `${p.customerFirstName} ${p.customerLastName}`.trim() : 'Your account';
  });

  protected readonly initials = computed(() => {
    const p = this.store.profile();
    const letters = `${p?.customerFirstName?.[0] ?? ''}${p?.customerLastName?.[0] ?? ''}`;
    return letters.toUpperCase() || '·';
  });

  /** Orders waiting on the customer: a bill to pay. */
  protected readonly attention = computed(() => this.store.orders().filter(isPayable).length);

  ngOnInit(): void {
    void this.store.load();
  }

  protected signOut(): void {
    this.store.reset();
    this.auth.logout();
  }
}
