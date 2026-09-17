import { ChangeDetectionStrategy, Component, signal, viewChild } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { RouterLink } from '@angular/router';
import { ChemistRegisterForm, ChemistRegistered } from './chemist-register-form';

/**
 * Public chemist sign-up, reachable without signing in — the web counterpart of the mobile app's
 * self-registration screen, hitting the same [AllowAnonymous] endpoint.
 *
 * Deliberately does NOT navigate anywhere on success: an anonymous visitor has no session and no
 * access to the chemist detail page, so it shows what happens next instead.
 */
@Component({
  selector: 'app-chemist-register-page',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    RouterLink,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatProgressBarModule,
    ChemistRegisterForm,
  ],
  template: `
    <div class="page">
      <mat-card class="card">
        @if (!done()) {
          <mat-progress-bar
            [mode]="form()?.busy() ? 'indeterminate' : 'determinate'"
            [value]="0"
          />
        }

        <mat-card-content>
          <div class="brand">
            <h1><img src="logo.png" alt="Pharmaish" width="80" height="80" /></h1>
            <p>Register your pharmacy</p>
          </div>

          @if (done(); as registered) {
            <div class="done" role="status">
              <mat-icon>check_circle</mat-icon>
              <h2>{{ registered.medicalName }} registered</h2>
              <p>
                Your login is your mobile number, with the password you just chose.
              </p>
              <p class="next">
                Our team still has to verify your details and activate the account before you can
                receive orders. You will be contacted about the bank details and the one-time
                onboarding fee.
              </p>
              <a matButton="filled" routerLink="/login">Go to sign in</a>
            </div>
          } @else {
            <!-- A chemist signing themselves up should choose a password they will remember. -->
            <app-chemist-register-form
              [showGenerator]="false"
              (registered)="onRegistered($event)"
            />

            <div class="actions">
              <a routerLink="/login">Already registered? Sign in</a>
              <button matButton="filled" [disabled]="form()?.busy()" (click)="form()?.submit()">
                Register
              </button>
            </div>
          }
        </mat-card-content>
      </mat-card>
    </div>
  `,
  styles: `
    .page {
      display: grid;
      place-items: start center;
      min-height: 100dvh;
      padding: 24px 16px;
      background: var(--mat-sys-surface-container);
    }
    .card { width: min(760px, 100%); overflow: hidden; }

    .brand {
      display: flex;
      flex-direction: column;
      align-items: center;
      text-align: center;
      gap: 4px;
      margin-bottom: 20px;
    }
    h1 { margin: 0; line-height: 0; }
    h1 img { width: 80px; height: 80px; object-fit: contain; }
    .brand p {
      margin: 0;
      color: var(--mat-sys-on-surface-variant);
      font: var(--mat-sys-title-medium);
    }

    .actions {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 16px;
      flex-wrap: wrap;
      margin-top: 20px;
    }

    .done {
      display: flex;
      flex-direction: column;
      align-items: center;
      text-align: center;
      gap: 8px;
      padding: 16px 0 8px;
    }
    .done mat-icon {
      width: 48px;
      height: 48px;
      font-size: 48px;
      color: var(--mat-sys-primary);
    }
    .done h2 { margin: 4px 0 0; font: var(--mat-sys-headline-small); }
    .done p { margin: 0; color: var(--mat-sys-on-surface-variant); font: var(--mat-sys-body-medium); }
    .done .next { max-width: 46ch; }
    .done a { margin-top: 12px; }
  `,
})
export class ChemistRegisterPage {
  protected readonly form = viewChild(ChemistRegisterForm);
  protected readonly done = signal<ChemistRegistered | null>(null);

  protected onRegistered(result: ChemistRegistered): void {
    this.done.set(result);
  }
}
