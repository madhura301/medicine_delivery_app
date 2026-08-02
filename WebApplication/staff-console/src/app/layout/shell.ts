import { BreakpointObserver } from '@angular/cdk/layout';
import { ChangeDetectionStrategy, Component, computed, inject, signal } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { MatButtonModule } from '@angular/material/button';
import { MatDividerModule } from '@angular/material/divider';
import { MatIconModule } from '@angular/material/icon';
import { MatListModule } from '@angular/material/list';
import { MatMenuModule } from '@angular/material/menu';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatTooltipModule } from '@angular/material/tooltip';
import { Router, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { map } from 'rxjs';
import { AuthStore } from '../core/auth/auth.store';
import { MenuEntry, MenuGroup, MenuItem, isGroup, visibleMenu } from '../core/config/menu';
import { ROLE_LABELS } from '../core/models/enums';
import { HANDSET_QUERY } from '../shared/ui/breakpoints';

@Component({
  selector: 'app-shell',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    RouterOutlet,
    RouterLink,
    RouterLinkActive,
    MatSidenavModule,
    MatToolbarModule,
    MatIconModule,
    MatButtonModule,
    MatListModule,
    MatMenuModule,
    MatDividerModule,
    MatTooltipModule,
  ],
  template: `
    <mat-sidenav-container class="shell">
      <mat-sidenav
        #drawer
        class="sidenav"
        [mode]="isHandset() ? 'over' : 'side'"
        [opened]="!isHandset()"
        [fixedInViewport]="isHandset()"
      >
        <div class="brand">
          <mat-icon class="brand-icon">medical_services</mat-icon>
          <span class="brand-text">Pharmaish</span>
        </div>

        <mat-nav-list>
          @for (entry of menu(); track entry.label) {
            @if (asGroup(entry); as group) {
              <div class="group-label">{{ group.label }}</div>
              @for (child of group.children; track child.route) {
                <a
                  mat-list-item
                  [routerLink]="child.route"
                  routerLinkActive="active"
                  (click)="closeIfHandset(drawer)"
                >
                  <mat-icon matListItemIcon>{{ child.icon }}</mat-icon>
                  <span matListItemTitle>{{ child.label }}</span>
                </a>
              }
              <mat-divider />
            } @else if (asItem(entry); as item) {
              <a
                mat-list-item
                [routerLink]="item.route"
                routerLinkActive="active"
                (click)="closeIfHandset(drawer)"
              >
                <mat-icon matListItemIcon>{{ item.icon }}</mat-icon>
                <span matListItemTitle>{{ item.label }}</span>
              </a>
            }
          }
        </mat-nav-list>
      </mat-sidenav>

      <mat-sidenav-content>
        <mat-toolbar class="topbar">
          @if (isHandset()) {
            <button matIconButton aria-label="Open navigation" (click)="drawer.toggle()">
              <mat-icon>menu</mat-icon>
            </button>
          }

          <span class="topbar-title">{{ currentLabel() }}</span>
          <span class="spacer"></span>

          <button
            matIconButton
            [matMenuTriggerFor]="userMenu"
            [matTooltip]="auth.displayName()"
            aria-label="Account"
          >
            <span class="avatar">{{ auth.initials() }}</span>
          </button>
          <mat-menu #userMenu="matMenu">
            <div class="user-block">
              <strong>{{ auth.displayName() }}</strong>
              <small>{{ roleLabel() }}</small>
            </div>
            <mat-divider />
            <button mat-menu-item routerLink="/change-password">
              <mat-icon>lock_reset</mat-icon>
              <span>Change password</span>
            </button>
            <button mat-menu-item (click)="signOut()">
              <mat-icon>logout</mat-icon>
              <span>Sign out</span>
            </button>
          </mat-menu>
        </mat-toolbar>

        <main class="content">
          <router-outlet />
        </main>
      </mat-sidenav-content>
    </mat-sidenav-container>
  `,
  styles: `
    .shell { height: 100dvh; }

    .sidenav {
      width: 264px;
      border-right: 1px solid var(--mat-sys-outline-variant);
      background: var(--mat-sys-surface-container-low);
    }

    .brand {
      display: flex;
      align-items: center;
      gap: 10px;
      padding: 18px 20px;
    }
    .brand-icon { color: var(--mat-sys-primary); }
    .brand-text { font: var(--mat-sys-title-medium); }

    .group-label {
      padding: 14px 20px 6px;
      color: var(--mat-sys-on-surface-variant);
      font: var(--mat-sys-label-small);
      text-transform: uppercase;
      letter-spacing: 0.06em;
    }

    a.active {
      background: var(--mat-sys-secondary-container);
      color: var(--mat-sys-on-secondary-container);
    }
    a.active mat-icon { color: var(--mat-sys-on-secondary-container); }

    .topbar {
      position: sticky;
      top: 0;
      z-index: 5;
      background: var(--mat-sys-surface);
      border-bottom: 1px solid var(--mat-sys-outline-variant);
    }

    .topbar-title { font: var(--mat-sys-title-medium); }
    .spacer { flex: 1 1 auto; }

    .avatar {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      width: 34px;
      height: 34px;
      border-radius: 50%;
      background: var(--mat-sys-primary);
      color: var(--mat-sys-on-primary);
      font: var(--mat-sys-label-medium);
    }

    .user-block {
      display: flex;
      flex-direction: column;
      padding: 10px 16px;
    }
    .user-block small { color: var(--mat-sys-on-surface-variant); }

    .content {
      padding: 24px;
      max-width: 1440px;
    }

    @media (max-width: 599px) {
      .content { padding: 16px; }
    }
  `,
})
export class Shell {
  protected readonly auth = inject(AuthStore);
  private readonly router = inject(Router);
  private readonly breakpoints = inject(BreakpointObserver);

  protected readonly isHandset = toSignal(
    this.breakpoints.observe(HANDSET_QUERY).pipe(map((result) => result.matches)),
    { initialValue: false },
  );

  protected readonly menu = computed(() => visibleMenu(this.auth.role()));
  protected readonly roleLabel = computed(() => {
    const role = this.auth.role();
    return role ? ROLE_LABELS[role] : '';
  });

  private readonly url = signal(this.router.url);

  protected readonly currentLabel = computed(() => {
    const url = this.url();
    for (const entry of this.menu()) {
      if (isGroup(entry)) {
        const child = entry.children.find((c) => url.startsWith(c.route));
        if (child) {
          return child.label;
        }
      } else if (url.startsWith(entry.route)) {
        return entry.label;
      }
    }
    return 'Pharmaish Staff Console';
  });

  constructor() {
    this.router.events.subscribe(() => this.url.set(this.router.url));
  }

  protected asGroup(entry: MenuEntry): MenuGroup | null {
    return isGroup(entry) ? entry : null;
  }

  protected asItem(entry: MenuEntry): MenuItem | null {
    return isGroup(entry) ? null : entry;
  }

  protected closeIfHandset(drawer: { close: () => void }): void {
    if (this.isHandset()) {
      drawer.close();
    }
  }

  protected signOut(): void {
    this.auth.logout();
  }
}
