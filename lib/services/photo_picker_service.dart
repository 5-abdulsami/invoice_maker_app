import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:invoicemaker/core/exceptions/app_exception.dart';

/// Picks an image from the device gallery.
///
/// Gallery only, on purpose: the system photo picker needs no permission,
/// whereas offering the camera would mean declaring `CAMERA` and asking for
/// it, for a logo the user almost always already has as a file.
class PhotoPickerService {
  PhotoPickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Longest edge a picked logo is downscaled to, which keeps the copied
  /// file small and the PDF quick to build.
  static const double _maxDimension = 1024;

  /// Returns the picked file's path, or null when the user backed out.
  Future<String?> pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: _maxDimension,
        maxHeight: _maxDimension,
      );
      if (picked == null) return null;

      if (!await File(picked.path).exists()) {
        throw const ImagePickException();
      }
      return picked.path;
    } on AppException {
      rethrow;
    } on Object catch (error) {
      throw ImagePickException(error);
    }
  }
}
