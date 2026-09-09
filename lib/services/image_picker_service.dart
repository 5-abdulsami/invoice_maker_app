import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:invoicemaker/core/exceptions/app_exception.dart';

/// Picks an image from the gallery or camera.
///
/// Returns the file path of the chosen image, or null when the user backs out.
/// Throws an [ImagePickException] if the platform picker fails.
class ImagePickerService {
  ImagePickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Largest edge, in pixels, a picked logo is downscaled to.
  static const double _maxDimension = 1024;

  Future<String?> pickFromGallery() => _pick(ImageSource.gallery);

  Future<String?> pickFromCamera() => _pick(ImageSource.camera);

  Future<String?> _pick(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: _maxDimension,
        maxHeight: _maxDimension,
      );
      if (picked == null) return null;

      final file = File(picked.path);
      if (!await file.exists()) throw const ImagePickException();
      return picked.path;
    } on AppException {
      rethrow;
    } on Object catch (error) {
      throw ImagePickException(error);
    }
  }
}
