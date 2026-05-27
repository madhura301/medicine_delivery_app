import 'package:flutter/material.dart';

/// Canonical [ButtonStyle]s used across the app.
///
/// Use these only when a button is a plain colored fill with no extra
/// padding/shape/elevation overrides. Buttons with custom geometry (taller
/// bottom-action bars, dialog action sizing, etc.) should keep their inline
/// `ElevatedButton.styleFrom(...)` so the per-screen visual choice is preserved.
class AppButton {
  AppButton._();

  /// Red destructive action: Reject, Delete, Logout-confirm.
  static ButtonStyle danger() => ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      );

  /// Green confirmatory action: Accept, Submit.
  static ButtonStyle success() => ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      );

  /// Primary (black) action button.
  static ButtonStyle primary() => ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      );
}
