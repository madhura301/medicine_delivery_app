import 'dart:typed_data';

/// Fallback used when neither web nor dart:io is available. Never expected to
/// run in practice — the conditional import picks a real implementation.
Future<void> openPdfBytes(Uint8List bytes, String fileName) async {
  throw UnsupportedError('Opening documents is not supported on this platform.');
}
