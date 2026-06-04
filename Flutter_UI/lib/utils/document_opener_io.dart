import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

/// Mobile/desktop: write the downloaded bytes to a temp file and open it with
/// the system's default PDF viewer (open_filex uses Android's FileProvider /
/// iOS document interaction under the hood, which `launchUrl(file://)` can't).
Future<void> openPdfBytes(Uint8List bytes, String fileName) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes, flush: true);

  final result = await OpenFilex.open(file.path, type: 'application/pdf');
  if (result.type != ResultType.done) {
    throw Exception('Could not open document: ${result.message}');
  }
}
