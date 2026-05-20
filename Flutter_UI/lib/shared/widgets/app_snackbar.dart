import 'package:flutter/material.dart';

/// Convenience helpers for the success / error snackbars used throughout the app.
///
/// Use these for plain text + colored-background snackbars. For snackbars
/// with custom widget content (e.g. Row + Icon), keep using
/// `ScaffoldMessenger` directly.
class AppSnackBar {
  AppSnackBar._();

  static void success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    _show(context, message, Colors.green, duration);
  }

  static void error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(context, message, Colors.red, duration);
  }

  static void warning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(context, message, Colors.orange, duration);
  }

  static void _show(
    BuildContext context,
    String message,
    Color backgroundColor,
    Duration duration,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );
  }
}
