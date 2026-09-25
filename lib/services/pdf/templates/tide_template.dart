import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_art.dart';
import 'package:invoicemaker/services/pdf/pdf_fonts.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Three layered waves roll across the top of page one, a lower pair along
/// every foot. The title rides the deepest wave in white.
class TideTemplate extends PdfTemplate {
  const TideTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.tide;

  @override
  PdfTypeface get typeface => PdfTypeface.rounded;

  static const _deep = PdfColor.fromInt(0xFF0B4F6C);
  static const _mid = PdfColor.fromInt(0xFF3A8FB0);
  static const _light = PdfColor.fromInt(0xFFCBE9F3);
  static const _foam = PdfColor.fromInt(0xFFEAF6FA);

  @override
  pw.Document build(PdfRenderData data) {
    final theme = PdfDocTheme.accented(
      fonts: data.fonts,
      accent: _deep,
      accentSoft: _foam,
      ink: const PdfColor.fromInt(0xFF102A36),
      hairline: const PdfColor.fromInt(0xFFD6E6EC),
    );
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfKit.pageTheme(
          theme,
          // The deep bottom margin keeps the footer above the waves.
          margin: const pw.EdgeInsets.fromLTRB(36, 36, 36, 58),
          background: (context) =>
              pageArt((art) => _waves(art, context.pageNumber == 1)),
        ),
        header: (context) =>
            context.pageNumber == 1 ? pw.SizedBox() : pw.SizedBox(height: 8),
        footer: (context) => PdfKit.pageFooter(context, data, theme),
        build: (context) => [
          _header(data, theme),
          // Clears the lowest crest of the waves.
          pw.SizedBox(height: 82),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: pw.BoxDecoration(
              color: _foam,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: PdfKit.metaStrip(
              data.metaRows,
              theme,
              labelColor: _mid,
              dividerColor: _light,
            ),
          ),
          pw.SizedBox(height: 24),
          PdfKit.parties(data, theme),
          pw.SizedBox(height: 24),
          PdfKit.itemTable(
            data: data,
            theme: theme,
            spec: ItemTableSpec.resolve(data),
            style: TableStyle.stripedRows,
          ),
          pw.SizedBox(height: 16),
          PdfKit.summary(data, theme, finish: TotalFinish.soft),
          pw.SizedBox(height: 24),
          PdfKit.closing(data, theme),
        ],
      ),
    );

    return pdf;
  }

  static void _waves(ArtCanvas art, bool firstPage) {
    if (firstPage) {
      art
        ..wave(
          baseline: 150,
          amplitude: 10,
          waves: 1.1,
          phase: 0.6,
          color: _light,
        )
        ..wave(
          baseline: 132,
          amplitude: 9,
          waves: 1.4,
          phase: 2,
          color: _mid,
        )
        ..wave(
          baseline: 114,
          amplitude: 8,
          waves: 0.9,
          phase: 3.6,
          color: _deep,
        );
    } else {
      art.wave(baseline: 16, amplitude: 5, waves: 1, color: _deep);
    }
    art
      ..wave(
        baseline: art.height - 40,
        amplitude: 7,
        waves: 1.2,
        color: _light,
        fromBottom: true,
      )
      ..wave(
        baseline: art.height - 22,
        amplitude: 5,
        waves: 0.8,
        phase: 1,
        color: _deep,
        fromBottom: true,
      );
  }

  pw.Widget _header(PdfRenderData data, PdfDocTheme theme) {
    final white = theme.onAccent;

    return pw.SizedBox(
      height: 62,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  data.document.displayTitle,
                  style: theme.displayTitle.copyWith(
                    color: white,
                    fontSize: 26,
                    letterSpacing: 2,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '${data.document.issuer.name.trim()}  ·  '
                  '${data.document.number}',
                  style: theme.bodyStrong.copyWith(color: _light),
                  maxLines: 1,
                ),
              ],
            ),
          ),
          if (data.hasLogo)
            pw.Container(
              width: 50,
              height: 50,
              padding: const pw.EdgeInsets.all(8),
              decoration: const pw.BoxDecoration(
                color: PdfColors.white,
                shape: pw.BoxShape.circle,
              ),
              child: PdfKit.logo(data, size: 34),
            ),
        ],
      ),
    );
  }
}
