import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

/// The typefaces the PDF templates draw with.
///
/// The built-in PDF fonts are Latin-1 only, which is why the old templates
/// printed currency codes instead of symbols. Embedding the same fonts the UI
/// uses means the printed page matches the screen and can draw symbols such
/// as the euro, pound and rupee.
class PdfFonts {
  const PdfFonts({
    required this.regular,
    required this.medium,
    required this.bold,
    required this.italic,
    required this.narrowLight,
    required this.narrowRegular,
    required this.narrowBold,
  });

  final pw.Font regular;
  final pw.Font medium;
  final pw.Font bold;
  final pw.Font italic;
  final pw.Font narrowLight;
  final pw.Font narrowRegular;
  final pw.Font narrowBold;

  static PdfFonts? _cached;

  /// Loads and caches the bundled fonts.
  ///
  /// Parsing a font is not cheap, so the result is reused for the lifetime of
  /// the process; generating twenty PDFs loads them once.
  static Future<PdfFonts> load() async {
    final cached = _cached;
    if (cached != null) return cached;

    final fonts = PdfFonts(
      regular: await _font('roboto-regular'),
      medium: await _font('roboto-medium'),
      bold: await _font('roboto-bold'),
      italic: await _font('roboto-italic'),
      narrowLight: await _font('robotocondensed-light'),
      narrowRegular: await _font('robotocondensed-regular'),
      narrowBold: await _font('robotocondensed-bold'),
    );

    _cached = fonts;
    return fonts;
  }

  static Future<pw.Font> _font(String name) async {
    final data = await rootBundle.load('assets/fonts/$name.ttf');
    return pw.Font.ttf(data);
  }
}
