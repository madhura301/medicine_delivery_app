import { ChangeDetectionStrategy, Component, Injectable, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MAT_DIALOG_DATA, MatDialog, MatDialogModule } from '@angular/material/dialog';
import { MatIconModule } from '@angular/material/icon';
import { firstValueFrom } from 'rxjs';

export interface CredentialsNoticeData {
  title: string;
  /** The account's sign-in name — always the mobile number for staff accounts. */
  userName: string;
  password: string;
  note?: string;
}

/** The API creates staff logins with a fixed starter password; this is the documented default. */
export const DEFAULT_STAFF_PASSWORD = 'Pass@123';

/**
 * Shown once, right after a staff account is created. The password is never retrievable later,
 * so the dialog makes it easy to copy and states that it must be changed on first sign-in.
 */
@Component({
  selector: 'app-credentials-notice',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [MatDialogModule, MatButtonModule, MatIconModule],
  template: `
    <h2 mat-dialog-title>{{ data.title }}</h2>
    <mat-dialog-content>
      <p>They can sign in to the mobile app or this console with:</p>

      <dl>
        <dt>Mobile number</dt>
        <dd>
          <code>{{ data.userName }}</code>
        </dd>
        <dt>Temporary password</dt>
        <dd>
          <code>{{ data.password }}</code>
        </dd>
      </dl>

      <p class="warn">
        <mat-icon>info</mat-icon>
        <span>Ask them to change this password the first time they sign in.</span>
      </p>

      @if (data.note) {
        <p class="note">{{ data.note }}</p>
      }
    </mat-dialog-content>
    <mat-dialog-actions align="end">
      <button matButton (click)="copy()">
        <mat-icon>content_copy</mat-icon>
        Copy
      </button>
      <button matButton="filled" mat-dialog-close>Done</button>
    </mat-dialog-actions>
  `,
  styles: `
    dl {
      display: grid;
      grid-template-columns: auto 1fr;
      gap: 8px 16px;
      margin: 16px 0;
    }
    dt { color: var(--mat-sys-on-surface-variant); font: var(--mat-sys-body-small); }
    dd { margin: 0; }
    code {
      padding: 2px 8px;
      border-radius: 6px;
      background: var(--mat-sys-surface-container-highest);
      font-family: ui-monospace, Menlo, Consolas, monospace;
    }
    .warn {
      display: flex;
      gap: 8px;
      align-items: flex-start;
      margin: 0;
      color: var(--mat-sys-on-surface-variant);
      font: var(--mat-sys-body-small);
    }
    .note { margin-top: 12px; font: var(--mat-sys-body-small); }
  `,
})
export class CredentialsNotice {
  readonly data = inject<CredentialsNoticeData>(MAT_DIALOG_DATA);

  protected copy(): void {
    void navigator.clipboard?.writeText(`${this.data.userName} / ${this.data.password}`);
  }
}

@Injectable({ providedIn: 'root' })
export class CredentialsNoticeService {
  private readonly dialog = inject(MatDialog);

  async show(data: CredentialsNoticeData): Promise<void> {
    const ref = this.dialog.open<CredentialsNotice, CredentialsNoticeData>(CredentialsNotice, {
      data,
      width: '440px',
      maxWidth: '92vw',
    });
    await firstValueFrom(ref.afterClosed());
  }
}
