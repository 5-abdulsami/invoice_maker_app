import 'package:invoicemaker/services/pdf/pdf_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// The page palette and type scale one template draws with.
///
/// Templates choose an accent and a neutral ramp; everything else is shared,
/// so every layout keeps the same typographic rhythm and print-safe contrast.
class PdfDocTheme {
  const PdfDocTheme({
    required this.fonts,
    required this.accent,
    required this.accentSoft,
    required this.onAccent,
    this.ink = const PdfColor.fromInt(0xFF1A1A1A),
    this.body = const PdfColor.fromInt(0xFF3D3D3D),
    this.muted = const PdfColor.fromInt(0xFF757575),
    this.hairline = const PdfColor.fromInt(0xFFDCDCDC),
    this.surface = const PdfColor.fromInt(0xFFF7F7F5),
  });

  final PdfFonts fonts;

  /// The one strong colour on the page.
  final PdfColor accent;

  /// A pale wash of the accent, for table headers and panels.
  final PdfColor accentSoft;

  /// Text drawn on top of [accent].
  final PdfColor onAccent;

  final PdfColor ink;
  final PdfColor body;
  final PdfColor muted;
  final PdfColor hairline;
  final PdfColor surface;

  /// The document heading, e.g. `INVOICE`.
  pw.TextStyle get displayTitle => pw.TextStyle(
        font: fonts.narrowBold,
        fontSize: 30,
        color: ink,
        letterSpacing: 1.2,
      );

  pw.TextStyle get displayTitleOnAccent =>
      displayTitle.copyWith(color: onAccent);

  /// Large figure, used by the statement and editorial layouts.
  pw.TextStyle get heroAmount => pw.TextStyle(
        font: fonts.narrowBold,
        fontSize: 26,
        color: ink,
      );

  pw.TextStyle get sectionLabel => pw.TextStyle(
        font: fonts.bold,
        fontSize: 7.5,
        color: muted,
        letterSpacing: 1,
      );

  pw.TextStyle get partyName => pw.TextStyle(
        font: fonts.bold,
        fontSize: 11,
        color: ink,
      );

  pw.TextStyle get bodyText => pw.TextStyle(
        font: fonts.regular,
        fontSize: 9,
        color: body,
        lineSpacing: 1.6,
      );

  pw.TextStyle get bodyStrong => pw.TextStyle(
        font: fonts.medium,
        fontSize: 9,
        color: ink,
      );

  pw.TextStyle get caption => pw.TextStyle(
        font: fonts.regular,
        fontSize: 8,
        color: muted,
        lineSpacing: 1.4,
      );

  /// Table column heading.
  pw.TextStyle get tableHeader => pw.TextStyle(
        font: fonts.narrowBold,
        fontSize: 8,
        color: ink,
        letterSpacing: 0.6,
      );

  pw.TextStyle get tableHeaderOnAccent => tableHeader.copyWith(color: onAccent);

  /// Item name in a table row.
  pw.TextStyle get tableCell => pw.TextStyle(
        font: fonts.regular,
        fontSize: 9,
        color: ink,
      );

  /// Row description, printed under the name.
  pw.TextStyle get tableCellMuted => pw.TextStyle(
        font: fonts.regular,
        fontSize: 8,
        color: muted,
        lineSpacing: 1.3,
      );

  /// A figure in a table row.
  pw.TextStyle get tableNumber => pw.TextStyle(
        font: fonts.narrowRegular,
        fontSize: 9.5,
        color: ink,
      );

  pw.TextStyle get tableNumberStrong => pw.TextStyle(
        font: fonts.narrowBold,
        fontSize: 9.5,
        color: ink,
      );

  pw.TextStyle get totalsLabel => pw.TextStyle(
        font: fonts.regular,
        fontSize: 9,
        color: body,
      );

  pw.TextStyle get totalsValue => pw.TextStyle(
        font: fonts.narrowRegular,
        fontSize: 9.5,
        color: ink,
      );

  pw.TextStyle get grandTotalLabel => pw.TextStyle(
        font: fonts.bold,
        fontSize: 11,
        color: ink,
      );

  pw.TextStyle get grandTotalValue => pw.TextStyle(
        font: fonts.narrowBold,
        fontSize: 15,
        color: ink,
      );

  pw.TextStyle get footerText => pw.TextStyle(
        font: fonts.regular,
        fontSize: 7.5,
        color: muted,
      );

  /// Base theme applied to the page, so any unstyled text is still readable.
  pw.ThemeData get pageTheme => pw.ThemeData.withFont(
        base: fonts.regular,
        bold: fonts.bold,
        italic: fonts.italic,
      ).copyWith(defaultTextStyle: bodyText);

  /// Accent ramps the templates pick from.
  ///
  /// Each is a considered pairing rather than a hue rotation: the soft tone is
  /// light enough to print legibly behind black text.
  static const PdfColor tealAccent = PdfColor.fromInt(0xFF0E6F76);
  static const PdfColor tealSoft = PdfColor.fromInt(0xFFE4F1F2);

  static const PdfColor inkAccent = PdfColor.fromInt(0xFF23272B);
  static const PdfColor inkSoft = PdfColor.fromInt(0xFFEDEEEF);

  static const PdfColor indigoAccent = PdfColor.fromInt(0xFF34407B);
  static const PdfColor indigoSoft = PdfColor.fromInt(0xFFE8EAF4);

  static const PdfColor claretAccent = PdfColor.fromInt(0xFF8C2F39);
  static const PdfColor claretSoft = PdfColor.fromInt(0xFFF6E7E8);

  static const PdfColor forestAccent = PdfColor.fromInt(0xFF2C5F44);
  static const PdfColor forestSoft = PdfColor.fromInt(0xFFE6F0EA);

  static const PdfColor amberAccent = PdfColor.fromInt(0xFF8A5A17);
  static const PdfColor amberSoft = PdfColor.fromInt(0xFFF8EEDC);

  static const PdfColor white = PdfColors.white;

  /// Builds a theme for [accent] and its pale companion.
  factory PdfDocTheme.accented({
    required PdfFonts fonts,
    required PdfColor accent,
    required PdfColor accentSoft,
    PdfColor onAccent = PdfColors.white,
  }) {
    return PdfDocTheme(
      fonts: fonts,
      accent: accent,
      accentSoft: accentSoft,
      onAccent: onAccent,
    );
  }
}
