import 'dart:typed_data';

import 'package:invoicemaker/core/exceptions/app_exception.dart';
import 'package:invoicemaker/core/utils/pdf_asset_loader.dart';
import 'package:signature/signature.dart';

/// Turns a signature pad into PNG bytes.
class SignatureService {
  const SignatureService();

  /// Exports the drawing, or the transparent placeholder when the pad is empty.
  Future<Uint8List> export(SignatureController controller) async {
    if (controller.isEmpty) return PdfAssetLoader.transparentPixel;

    try {
      final bytes = await controller.toPngBytes();
      if (bytes == null || bytes.isEmpty) throw const SignatureException();
      return bytes;
    } on AppException {
      rethrow;
    } on Object catch (error) {
      throw SignatureException(error);
    }
  }

  /// True when [bytes] hold no actual signature.
  bool isBlank(Uint8List? bytes) =>
      bytes == null ||
      bytes.isEmpty ||
      bytes.length == PdfAssetLoader.transparentPixel.length;
}
