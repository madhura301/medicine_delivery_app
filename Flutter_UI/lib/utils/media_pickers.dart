import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

/// Media selection helpers that satisfy Google Play's "Use alternative system
/// pickers for photos/videos" policy.
///
/// Photos come from the Android System Photo Picker
/// (`ActivityResultContracts.PickVisualMedia`, used by image_picker when
/// [configureSystemPhotoPicker] has run) and documents come from the Storage
/// Access Framework (`ACTION_OPEN_DOCUMENT`, used by file_picker for non-image
/// MIME types). Neither needs READ_MEDIA_IMAGES, READ_MEDIA_VIDEO or
/// READ_EXTERNAL_STORAGE, so those permissions are no longer declared.

/// Routes every `ImageSource.gallery` pick through the Android System Photo
/// Picker instead of the legacy `ACTION_GET_CONTENT` + media-permission flow.
///
/// Must be called once at startup, after `WidgetsFlutterBinding
/// .ensureInitialized()`, so the Android implementation is registered. No-op on
/// other platforms (iOS already uses PHPickerViewController).
void configureSystemPhotoPicker() {
  final ImagePickerPlatform platform = ImagePickerPlatform.instance;
  if (platform is ImagePickerAndroid) {
    platform.useAndroidPhotoPicker = true;
  }
}

/// A file chosen by the user, with the metadata the upload screens display.
class PickedDocument {
  final File file;
  final String name;
  final String extension;

  const PickedDocument({
    required this.file,
    required this.name,
    required this.extension,
  });

  int get sizeInBytes => file.lengthSync();
  bool get isPdf => extension == 'pdf';
}

/// Picks a single image using the system photo picker. Returns null if the user
/// backs out without choosing.
Future<PickedDocument?> pickImageFromGallery({
  int imageQuality = 85,
  double maxWidth = 1920,
  double maxHeight = 1920,
}) async {
  final XFile? image = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    imageQuality: imageQuality,
    maxWidth: maxWidth,
    maxHeight: maxHeight,
  );
  if (image == null) return null;

  return PickedDocument(
    file: File(image.path),
    name: image.name,
    extension: _extensionOf(image.name.isNotEmpty ? image.name : image.path),
  );
}

/// Picks a single PDF using the system document picker (Storage Access
/// Framework on Android). Returns null if the user backs out without choosing.
Future<PickedDocument?> pickPdfDocument() async {
  final FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['pdf'],
    allowMultiple: false,
  );

  final path = result?.files.single.path;
  if (result == null || path == null) return null;

  final picked = result.files.single;
  return PickedDocument(
    file: File(path),
    name: picked.name,
    extension: (picked.extension ?? _extensionOf(picked.name)).toLowerCase(),
  );
}

String _extensionOf(String nameOrPath) {
  final dot = nameOrPath.lastIndexOf('.');
  if (dot == -1 || dot == nameOrPath.length - 1) return '';
  return nameOrPath.substring(dot + 1).toLowerCase();
}
