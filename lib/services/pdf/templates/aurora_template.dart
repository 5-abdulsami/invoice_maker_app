import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_art.dart';
import 'package:invoicemaker/services/pdf/pdf_fonts.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// A teal-to-indigo gradient runs off the top of the page and carries the
/// title, issuer and meta in white. Later pages keep a thin gradient edge.
class AuroraTemplate extends PdfTemplate {
  const AuroraTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.aurora;

  @override
  PdfTypeface get typeface => PdfTypeface.grotesk;

  static const _teal = PdfColor.fromInt(0xFF0F766E);
  static const _indigo = PdfColor.fromInt(0xFF4338CA);
  static const _haze = PdfColor.fromInt(0xFFC7D2FE);

  /// Height of the page-one band, from the paper's top edge.
  static const double _band = 178;
  static const double _top = 36;

  @override
  pw.Document build(PdfRenderData data) {
    final theme = PdfDocTheme.accented(
      fonts: data.fonts,
      accent: _indigo,
      accentSoft: const PdfColor.fromInt(0xFFEEF0FD),
      ink: const PdfColor.fromInt(0xFF111827),
      body: const PdfColor.fromInt(0xFF374151),
      muted: const PdfColor.fromInt(0xFF6B7280),
      hairline: const PdfColor.fromInt(0xFFE5E7EB),
    );
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfKit.pageTheme(
          theme,
          background: (context) => _background(context.pageNumber == 1),
        ),
        header: (context) =>
            context.pageNumber == 1 ? pw.SizedBox() : pw.SizedBox(height: 10),
        footer: (context) => PdfKit.pageFooter(context, data, theme),
        build: (context) => [
          _header(data, theme),
          pw.SizedBox(height: 30),
          PdfKit.parties(data, theme, alignSecondEnd: true),
          pw.SizedBox(height: 24),
          PdfKit.itemTable(
            data: data,
            theme: theme,
            spec: ItemTableSpec.resolve(data),
            style: TableStyle.softHeader,
          ),
          pw.SizedBox(height: 16),
          PdfKit.summary(data, theme, finish: TotalFinish.accentBar),
          pw.SizedBox(height: 24),
          PdfKit.closing(data, theme),
        ],
      ),
    );

    return pdf;
  }

  pw.Widget _background(bool firstPage) {
    final height = firstPage ? _band : 8.0;
    return pw.Stack(
      children: [
        pw.Positioned(
          left: 0,
          top: 0,
          child: pw.Container(
            width: kPageWidth,
            height: height,
            decoration: const pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [_teal, _indigo],
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
              ),
            ),
          ),
        ),
        if (firstPage)
          pw.Positioned(
            left: 0,
            top: 0,
            child: pageArtSized(
              kPageWidth,
              _band,
              (art) {
                // Two faint rings drift off the right edge, catching the
                // light like the aurora the layout is named after.
                const ring = PdfColor.fromInt(0xFF6D6BE0);
                art
                  ..ring(kPageWidth - 30, 20, 120, ring, lineWidth: 0.8)
                  ..ring(kPageWidth - 30, 20, 82, ring, lineWidth: 0.8);
              },
            ),
          ),
      ],
    );
  }

  pw.Widget _header(PdfRenderData data, PdfDocTheme theme) {
    final document = data.document;
    final white = theme.onAccent;

    return pw.SizedBox(
      // Fills the band exactly, less the top margin and a bottom inset.
      height: _band - _top - 22,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      document.displayTitle,
                      style: theme.displayTitle.copyWith(
                        color: white,
                        fontSize: 28,
                        letterSpacing: 2,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      document.number,
                      style: theme.bodyStrong.copyWith(color: _haze),
                    ),
                  ],
                ),
                pw.Text(
                  document.issuer.name.trim(),
                  style: theme.partyName.copyWith(color: white, fontSize: 12),
                  maxLines: 1,
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 16),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              if (data.hasLogo)
                pw.Container(
                  padding: const pw.EdgeInsets.all(4),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: PdfKit.logo(data, size: 38),
                )
              else
                pw.SizedBox(),
              PdfKit.metaRows(
                data.metaRows,
                theme,
                labelColor: _haze,
                valueColor: white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
