import { ChangeDetectionStrategy, Component, Injectable, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MAT_DIALOG_DATA, MatDialog, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { firstValueFrom } from 'rxjs';

export interface ConfirmDialogData {
  title: string;
  message: string;
  confirmLabel?: string;
  cancelLabel?: string;
  danger?: boolean;
  /** When set, the user must type this exact text before confirming. */
  typeToConfirm?: string;
}

@Component({
  selector: 'app-confirm-dialog',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    MatDialogModule,
    MatButtonModule,
    MatFormFieldModule,
    MatInputModule,
    FormsModule,
  ],
  template: `
    <h2 mat-dialog-title>{{ data.title }}</h2>
    <mat-dialog-content>
      <p class="message">{{ data.message }}</p>

      @if (data.typeToConfirm) {
        <p class="type-hint">
          Type <strong>{{ data.typeToConfirm }}</strong> to confirm.
        </p>
        <mat-form-field appearance="outline" class="full">
          <mat-label>Confirmation</mat-label>
          <input matInput [(ngModel)]="typed" autocomplete="off" />
        </mat-form-field>
      }
    </mat-dialog-content>
    <mat-dialog-actions align="end">
      <button matButton mat-dialog-close>{{ data.cancelLabel ?? 'Cancel' }}</button>
      <button
        matButton="filled"
        [color]="data.danger ? 'warn' : 'primary'"
        [disabled]="!canConfirm()"
        (click)="confirm()"
      >
        {{ data.confirmLabel ?? 'Confirm' }}
      </button>
    </mat-dialog-actions>
  `,
  styles: `
    .message { margin: 0 0 8px; white-space: pre-line; }
    .type-hint { margin: 16px 0 8px; font: var(--mat-sys-body-small); }
    .full { width: 100%; }
  `,
})
export class ConfirmDialog {
  readonly data = inject<ConfirmDialogData>(MAT_DIALOG_DATA);
  private readonly ref = inject(MatDialogRef<ConfirmDialog, boolean>);

  protected typed = '';

  protected canConfirm(): boolean {
    return !this.data.typeToConfirm || this.typed.trim() === this.data.typeToConfirm;
  }

  protected confirm(): void {
    this.ref.close(true);
  }
}

@Injectable({ providedIn: 'root' })
export class ConfirmService {
  private readonly dialog = inject(MatDialog);

  async ask(data: ConfirmDialogData): Promise<boolean> {
    const ref = this.dialog.open<ConfirmDialog, ConfirmDialogData, boolean>(ConfirmDialog, {
      data,
      width: '440px',
      maxWidth: '92vw',
      autoFocus: 'dialog',
    });
    return (await firstValueFrom(ref.afterClosed())) === true;
  }
}
