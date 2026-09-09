import 'package:flutter/services.dart';
import 'package:invoicemaker/core/constants/app_assets.dart';

/// Loads and caches the bundled images the PDF templates draw with.
///
/// Replaces the mutable top-level `Uint8List?` globals the templates used to
/// read, so callers always get bytes rather than a possibly-null global.
class PdfAssetLoader {
  PdfAssetLoader._();

  static final PdfAssetLoader instance = PdfAssetLoader._();

  final Map<String, Uint8List> _cache = {};

  /// A 1x1 transparent PNG, used wherever an image is optional.
  static final Uint8List transparentPixel = Uint8List.fromList(const [
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
    0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
    0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
    0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
    0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
    0x42, 0x60, 0x82,
  ]);

  /// Returns the asset bytes, or [transparentPixel] if the asset is missing.
  Future<Uint8List> load(String assetPath) async {
    final cached = _cache[assetPath];
    if (cached != null) return cached;

    try {
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      _cache[assetPath] = bytes;
      return bytes;
    } on Object {
      return transparentPixel;
    }
  }

  Future<Uint8List> get logo => load(AppAssets.logo);
  Future<Uint8List> get topImage => load(AppAssets.topImage);
  Future<Uint8List> get bottomImage => load(AppAssets.bottomImage);
  Future<Uint8List> get phone => load(AppAssets.phone);
  Future<Uint8List> get mail => load(AppAssets.mail);
  Future<Uint8List> get web => load(AppAssets.web);
}
