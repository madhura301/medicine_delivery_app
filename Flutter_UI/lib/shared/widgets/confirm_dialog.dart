import 'package:flutter/material.dart';
import 'package:pharmaish/shared/widgets/app_button.dart';

/// Show a generic confirm-action dialog with title, plain-text message, and
/// Cancel/Confirm buttons. Returns `true` if the user confirmed.
///
/// The confirm button defaults to [AppButton.danger] since most callers are
/// destructive operations (Delete, Remove, Unassign, Logout). Pass
/// [confirmStyle] to override (e.g. with [AppButton.primary] for a non-destructive
/// confirmation).
///
/// For dialogs whose body is more than plain text (RichText, Column, TextField,
/// etc.), build the dialog inline rather than calling this helper.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  ButtonStyle? confirmStyle,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(cancelLabel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: confirmStyle ?? AppButton.danger(),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed == true;
}

/// Show the standard "Are you sure you want to logout?" dialog.
Future<bool> confirmLogout(BuildContext context) => confirmAction(
      context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmLabel: 'Logout',
    );
