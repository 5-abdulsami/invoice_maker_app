import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

/// A family of typefaces a template can be set in.
///
/// Each template names one, and only that set is read from the bundle, so a
/// template never pays to load fonts it does not draw with.
enum PdfTypeface {
  /// Roboto, with Roboto Condensed for figures and headings.
  standard,

  /// A bookish serif throughout, figures included.
  serif,

  /// The serif body under a high-contrast display face for titles.
  elegant,

  /// Libre Franklin, a crisp newspaper grotesque.
  grotesk,

  /// Rubik, soft and rounded.
  rounded,

  /// Lato, warm and open.
  humanist,

  /// A monospaced body, like a till receipt, with condensed figures so
  /// amounts fit narrow columns.
  mono,

  /// Roboto body under tall condensed Oswald headings.
  poster,
}

/// The typefaces the PDF templates draw with.
///
/// The built-in PDF fonts are Latin-1 only, which is why the old templates
/// printed currency codes instead of symbols. Embedding real fonts means the
/// printed page can draw symbols such as the euro, pound and rupee; a face
/// that lacks one falls back to Roboto for that glyph.
class PdfFonts {
  const PdfFonts({
    required this.regular,
    required this.medium,
    required this.bold,
    required this.italic,
    required this.narrowLight,
    required this.narrowRegular,
    required this.narrowBold,
    pw.Font? display,
    this.fallback = const [],
  }) : _display = display;

  final pw.Font regular;
  final pw.Font medium;
  final pw.Font bold;
  final pw.Font italic;
  final pw.Font narrowLight;
  final pw.Font narrowRegular;
  final pw.Font narrowBold;
  final pw.Font? _display;

  /// Fonts tried, in order, for any glyph the main face cannot draw.
  final List<pw.Font> fallback;

  /// The face for the document title and other display text.
  pw.Font get display => _display ?? narrowBold;

  static final Map<PdfTypeface, Future<PdfFonts>> _sets = {};
  static final Map<String, Future<pw.Font>> _files = {};

  /// Loads and caches the fonts for [typeface].
  ///
  /// Parsing a font is not cheap, so each file is parsed once for the
  /// lifetime of the process and shared between the sets that use it. The
  /// load itself is shared too, so previews that start together do not each
  /// parse the same fonts.
  static Future<PdfFonts> load([PdfTypeface typeface = PdfTypeface.standard]) {
    return _sets[typeface] ??= _loadSet(typeface);
  }

  static Future<PdfFonts> _loadSet(PdfTypeface typeface) async {
    try {
      return await _build(typeface);
    } catch (_) {
      // A failed load is not cached, so the next attempt tries again.
      _sets.removeWhere((key, _) => key == typeface);
      rethrow;
    }
  }

  static Future<PdfFonts> _build(PdfTypeface typeface) async {
    final roboto = await _font('roboto-regular');
    final fallback = [roboto];

    switch (typeface) {
      case PdfTypeface.standard:
        return PdfFonts(
          regular: roboto,
          medium: await _font('roboto-medium'),
          bold: await _font('roboto-bold'),
          italic: await _font('roboto-italic'),
          narrowLight: await _font('robotocondensed-light'),
          narrowRegular: await _font('robotocondensed-regular'),
          narrowBold: await _font('robotocondensed-bold'),
        );

      case PdfTypeface.serif:
      case PdfTypeface.elegant:
        final regular = await _font('serif-regular');
        final bold = await _font('serif-bold');
        return PdfFonts(
          regular: regular,
          medium: bold,
          bold: bold,
          italic: await _font('serif-italic'),
          narrowLight: regular,
          narrowRegular: regular,
          narrowBold: bold,
          display: typeface == PdfTypeface.elegant
              ? await _font('abrilfatface-regular')
              : bold,
          fallback: fallback,
        );

      case PdfTypeface.grotesk:
        final regular = await _font('librefranklin-regular');
        final bold = await _font('librefranklin-bold');
        return PdfFonts(
          regular: regular,
          medium: await _font('librefranklin-medium'),
          bold: bold,
          italic: await _font('roboto-italic'),
          narrowLight: regular,
          narrowRegular: regular,
          narrowBold: bold,
          display: bold,
          fallback: fallback,
        );

      case PdfTypeface.rounded:
        final regular = await _font('rubik-regular');
        final bold = await _font('rubik-bold');
        return PdfFonts(
          regular: regular,
          medium: await _font('rubik-medium'),
          bold: bold,
          italic: await _font('roboto-italic'),
          narrowLight: regular,
          narrowRegular: regular,
          narrowBold: bold,
          display: bold,
          fallback: fallback,
        );

      case PdfTypeface.humanist:
        final regular = await _font('lato-regular');
        final bold = await _font('lato-bold');
        return PdfFonts(
          regular: regular,
          medium: bold,
          bold: bold,
          italic: await _font('lato-italic'),
          narrowLight: regular,
          narrowRegular: regular,
          narrowBold: bold,
          display: bold,
          fallback: fallback,
        );

      case PdfTypeface.mono:
        final mono = await _font('robotomono-regular');
        final figures = await _font('robotocondensed-regular');
        final bold = await _font('robotocondensed-bold');
        return PdfFonts(
          regular: mono,
          medium: mono,
          bold: bold,
          italic: mono,
          narrowLight: figures,
          narrowRegular: figures,
          narrowBold: bold,
          display: bold,
          fallback: fallback,
        );

      case PdfTypeface.poster:
        return PdfFonts(
          regular: roboto,
          medium: await _font('roboto-medium'),
          bold: await _font('roboto-bold'),
          italic: await _font('roboto-italic'),
          narrowLight: await _font('robotocondensed-light'),
          narrowRegular: await _font('robotocondensed-regular'),
          narrowBold: await _font('oswald-medium'),
          display: await _font('oswald-semibold'),
          fallback: fallback,
        );
    }
  }

  static Future<pw.Font> _font(String name) {
    return _files[name] ??= _readFont(name);
  }

  static Future<pw.Font> _readFont(String name) async {
    try {
      final data = await rootBundle.load('assets/fonts/$name.ttf');
      return pw.Font.ttf(data);
    } catch (_) {
      _files.removeWhere((key, _) => key == name);
      rethrow;
    }
  }
}
