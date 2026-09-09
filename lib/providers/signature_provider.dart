import 'package:flutter/foundation.dart';
import 'package:invoicemaker/core/utils/pdf_asset_loader.dart';

/// The signature drawn once and reused on every invoice.
class SignatureProvider extends ChangeNotifier {
  Uint8List _signature = PdfAssetLoader.transparentPixel;

  /// Always non-null: a transparent pixel stands in for "not signed yet".
  Uint8List get signature => _signature;

  /// True while the placeholder is in place.
  bool get hasSignature => _signature != PdfAssetLoader.transparentPixel;

  void saveSignature(Uint8List signature) {
    if (signature.isEmpty) return;
    _signature = signature;
    notifyListeners();
  }

  void clearSignature() {
    if (!hasSignature) return;
    _signature = PdfAssetLoader.transparentPixel;
    notifyListeners();
  }
}
