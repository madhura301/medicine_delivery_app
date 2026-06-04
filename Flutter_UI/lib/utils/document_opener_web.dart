import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Web: wrap the downloaded bytes in a Blob and open them in a new browser tab.
/// The new tab shows the PDF in the browser's built-in viewer (from which the
/// user can save it), so the document is fetched once (with auth) and then
/// displayed without another unauthenticated network request.
Future<void> openPdfBytes(Uint8List bytes, String fileName) async {
  final blob = web.Blob(
    <JSAny>[bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'application/pdf'),
  );
  final objectUrl = web.URL.createObjectURL(blob);

  // An anchor click is more popup-blocker friendly than window.open(). No
  // `download` attribute: we want the new tab to *display* the PDF rather than
  // force a save (the browser viewer still offers a save button).
  final anchor = web.HTMLAnchorElement()
    ..href = objectUrl
    ..target = '_blank'
    ..rel = 'noopener noreferrer';
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();

  // Give the new tab time to load before releasing the object URL.
  Future.delayed(const Duration(seconds: 60), () {
    web.URL.revokeObjectURL(objectUrl);
  });
}
