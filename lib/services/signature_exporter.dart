import 'package:flutter/foundation.dart';
import 'package:invoicemaker/core/exceptions/app_exception.dart';
import 'package:signature/signature.dart';

/// Turns a signature pad into PNG bytes.
class SignatureExporter {
  const SignatureExporter();

  /// Exports the drawing, or null when nothing was drawn.
  Future<Uint8List?> export(SignatureController controller) async {
    if (controller.isEmpty) return null;

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
}
