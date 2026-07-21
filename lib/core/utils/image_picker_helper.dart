import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  static final _picker = ImagePicker();

  static Future<({String base64, String mimeType})?> pickLogo() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (file == null) return null;

    final bytes = await File(file.path).readAsBytes();
    final mime = _mimeFromPath(file.path);
    return (base64: base64Encode(bytes), mimeType: mime);
  }

  static String _mimeFromPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }
}
