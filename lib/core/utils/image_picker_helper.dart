import 'dart:io';

import 'package:image_picker/image_picker.dart';

class PickedImageFile {
  const PickedImageFile({
    required this.file,
    required this.mimeType,
  });

  final File file;
  final String mimeType;

  String get path => file.path;
  String get filename => path.split(RegExp(r'[\\/]')).last;
}

class ImagePickerHelper {
  static final _picker = ImagePicker();

  static Future<PickedImageFile?> pickImage({
    int maxWidth = 512,
    int maxHeight = 512,
    int imageQuality = 85,
  }) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxWidth.toDouble(),
      maxHeight: maxHeight.toDouble(),
      imageQuality: imageQuality,
    );
    if (picked == null) return null;

    final file = File(picked.path);
    final length = await file.length();
    if (length > 5 * 1024 * 1024) {
      throw Exception('Image must be under 5MB');
    }

    return PickedImageFile(
      file: file,
      mimeType: mimeFromPath(picked.path),
    );
  }

  /// Backward-compatible alias used by older call sites.
  static Future<PickedImageFile?> pickLogo() => pickImage();

  static String mimeFromPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }
}
