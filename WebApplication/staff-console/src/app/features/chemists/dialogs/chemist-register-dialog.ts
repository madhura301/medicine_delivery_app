import { ChangeDetectionStrategy, Component, inject, viewChild } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { ToastService } from '../../../core/ui/toast.service';
import { ChemistRegisterForm, ChemistRegistered } from '../register/chemist-register-form';

/** The dialog resolves with the new store's id so the caller can open its detail page. */
export type ChemistRegisterResult = { medicalStoreId: string } | undefined;

/**
 * Staff-side chemist registration. Shares its form with the public sign-up page — see
 * {@link ChemistRegisterForm}, which owns validation and the API call.
 */
@Component({
  selector: 'app-chemist-register-dialog',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [MatDialogModule, MatButtonModule, MatProgressBarModule, ChemistRegisterForm],
  template: `
    <h2 mat-dialog-title>Register chemist</h2>
    @if (form().busy()) {
      <mat-progress-bar mode="indeterminate" />
    }

    <mat-dialog-content>
      <app-chemist-register-form (registered)="onRegistered($event)" />
    </mat-dialog-content>

    <mat-dialog-actions align="end">
      <button matButton mat-dialog-close [disabled]="form().busy()">Cancel</button>
      <button matButton="filled" [disabled]="form().busy()" (click)="form().submit()">
        Register chemist
      </button>
    </mat-dialog-actions>
  `,
})
export class ChemistRegisterDialog {
  private readonly toast = inject(ToastService);
  private readonly ref = inject(MatDialogRef<ChemistRegisterDialog, ChemistRegisterResult>);

  protected readonly form = viewChild.required(ChemistRegisterForm);

  protected onRegistered(result: ChemistRegistered): void {
    this.toast.success(`${result.medicalName} registered.`);
    this.ref.close({ medicalStoreId: result.medicalStoreId });
  }
}
