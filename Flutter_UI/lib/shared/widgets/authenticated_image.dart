import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/storage.dart';

/// Builds the download URL for an order's prescription input file.
String getOrderInputFileUrl(String orderId) {
  return '${AppConstants.apiBaseUrl}/Orders/$orderId/download-input-file';
}

/// Builds the download URL for an order's bill file.
String getOrderBillFileUrl(String orderId) {
  return '${AppConstants.apiBaseUrl}/Orders/$orderId/download-bill';
}

/// Extracts the file name from a prescription file URL/path.
String extractFileName(String? fileUrl) {
  if (fileUrl == null || fileUrl.isEmpty) return '';
  // Handle both forward and back slashes
  final normalized = fileUrl.replaceAll('\\', '/');
  return normalized.split('/').last;
}

/// Downloads a file from an authenticated API endpoint to the device.
/// Shows snackbar feedback via the provided [context].
Future<void> _downloadAuthFile(
  BuildContext context, {
  required String url,
  required String fallbackName,
  String? fileUrl,
}) async {
  try {
    // Request storage permission on Android
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission is required to download')),
          );
        }
        return;
      }
    }

    final token = await StorageService.getAuthToken();
    final fileName = extractFileName(fileUrl);
    final saveName = fileName.isNotEmpty ? fileName : fallbackName;

    final dir = Platform.isAndroid
        ? Directory('/storage/emulated/0/Download')
        : await getApplicationDocumentsDirectory();

    final savePath = '${dir.path}/$saveName';

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloading...')),
      );
    }

    await Dio().download(
      url,
      savePath,
      options: Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      ),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to $savePath')),
      );
    }
  } catch (e) {
    AppLogger.error('Download failed: $url', e);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to download file')),
      );
    }
  }
}

/// Downloads the prescription image for the given order to the device.
Future<void> downloadPrescriptionImage(
  BuildContext context, {
  required String orderId,
  String? prescriptionFileUrl,
}) {
  return _downloadAuthFile(
    context,
    url: getOrderInputFileUrl(orderId),
    fallbackName: 'prescription_$orderId.png',
    fileUrl: prescriptionFileUrl,
  );
}

/// Downloads the bill file for the given order to the device.
Future<void> downloadBillFile(
  BuildContext context, {
  required String orderId,
  String? billFileUrl,
}) {
  return _downloadAuthFile(
    context,
    url: getOrderBillFileUrl(orderId),
    fallbackName: 'bill_$orderId.png',
    fileUrl: billFileUrl,
  );
}

/// A network image widget that automatically attaches the JWT auth header.
class AuthNetworkImage extends StatefulWidget {
  final String url;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder;

  const AuthNetworkImage({
    super.key,
    required this.url,
    this.fit,
    this.width,
    this.height,
    this.errorBuilder,
    this.loadingBuilder,
  });

  @override
  State<AuthNetworkImage> createState() => _AuthNetworkImageState();
}

class _AuthNetworkImageState extends State<AuthNetworkImage> {
  String? _token;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await StorageService.getAuthToken();
    if (mounted) {
      setState(() {
        _token = token;
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return widget.loadingBuilder?.call(context, const SizedBox(), null) ??
          const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
    }

    final headers = <String, String>{};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return Image.network(
      widget.url,
      headers: headers,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      errorBuilder: widget.errorBuilder,
      loadingBuilder: widget.loadingBuilder,
    );
  }
}
