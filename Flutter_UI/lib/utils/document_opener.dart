import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pharmaish/core/services/dio_client.dart';
import 'package:pharmaish/shared/widgets/app_snackbar.dart';
import 'package:pharmaish/utils/app_logger.dart';

// Platform-specific implementation is selected at compile time.
import 'document_opener_stub.dart'
    if (dart.library.html) 'document_opener_web.dart'
    if (dart.library.io) 'document_opener_io.dart' as opener;

/// Downloads a document from an authenticated [url] and opens it.
///
/// A plain new-tab navigation to the API cannot carry the JWT, so we fetch the
/// bytes here (with the auth header) and then hand them to the browser/OS:
/// - On web the downloaded bytes are opened in a new tab (browser PDF viewer).
/// - On mobile/desktop the file is saved to a temp location and opened with the
///   system viewer.
///
/// Shows a snackbar on failure using the provided [context].
Future<void> openAuthenticatedDocument(
  BuildContext context, {
  required String url,
  String? fileName,
}) async {
  final name = (fileName != null && fileName.isNotEmpty)
      ? fileName
      : _nameFromUrl(url);

  try {
    if (context.mounted) {
      AppSnackBar.success(context, 'Opening document...',
          duration: const Duration(seconds: 1));
    }

    // DioClient attaches the auth token via interceptor. The url is absolute,
    // so it overrides the client's base URL.
    final response = await DioClient.instance.get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );

    final bytes = _asBytes(response.data);
    if (bytes.isEmpty) {
      throw Exception('Downloaded document was empty');
    }

    await opener.openPdfBytes(bytes, name);
  } on DioException catch (e) {
    AppLogger.error(
        'Failed to download document: $url '
        '(status ${e.response?.statusCode})',
        e);
    if (context.mounted) {
      final status = e.response?.statusCode;
      AppSnackBar.error(
        context,
        status != null
            ? 'Unable to open document (error $status)'
            : 'Unable to open document. Check your connection.',
      );
    }
  } catch (e) {
    AppLogger.error('Failed to open document: $url', e);
    if (context.mounted) {
      AppSnackBar.error(context, 'Unable to open document: $e');
    }
  }
}

/// Normalises Dio's `ResponseType.bytes` payload (which varies by platform —
/// Uint8List, List<int>, or ByteBuffer) into a [Uint8List].
Uint8List _asBytes(dynamic data) {
  if (data is Uint8List) return data;
  if (data is ByteBuffer) return data.asUint8List();
  if (data is List<int>) return Uint8List.fromList(data);
  throw Exception('Unexpected document response type: ${data.runtimeType}');
}

String _nameFromUrl(String url) {
  try {
    final segments = Uri.parse(url).pathSegments;
    if (segments.isNotEmpty && segments.last.isNotEmpty) {
      return segments.last;
    }
  } catch (_) {
    // ignore — fall through to default
  }
  return 'document.pdf';
}
