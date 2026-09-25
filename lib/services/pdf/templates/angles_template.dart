import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_art.dart';
import 'package:invoicemaker/services/pdf/pdf_fonts.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Overlapping coral and navy triangles bite into the top-right and
/// bottom-left corners; the content keeps clear of them on the left.
class AnglesTemplate extends PdfTemplate {
  const AnglesTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.angles;

  @override
  PdfTypeface get typeface => PdfTypeface.grotesk;

  static const _navy = PdfColor.fromInt(0xFF1D3557);
  static const _coral = PdfColor.fromInt(0xFFE85D5A);

  @override
  pw.Document build(PdfRenderData data) {
    final theme = PdfDocTheme.accented(
      fonts: data.fonts,
      accent: _navy,
      accentSoft: const PdfColor.fromInt(0xFFE8EDF4),
      ink: const PdfColor.fromInt(0xFF14213D),
      hairline: const PdfColor.fromInt(0xFFDDE2EA),
    );
    final labelStyle = theme.sectionLabel.copyWith(color: _coral);
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfKit.pageTheme(
          theme,
          background: (context) =>
              pageArt((art) => _corners(art, context.pageNumber == 1)),
        ),
        // Drops continued pages below the smaller corner triangles.
        header: (context) =>
            context.pageNumber == 1 ? pw.SizedBox() : pw.SizedBox(height: 30),
        // Indented past the bottom-left triangle.
        footer: (context) => pw.Padding(
          padding: const pw.EdgeInsets.only(left: 84),
          child: PdfKit.pageFooter(context, data, theme),
        ),
        build: (context) => [
          _heading(data, theme),
          pw.SizedBox(height: 22),
          pw.SizedBox(
            // Narrower than the page so it stays clear of the corner art.
            width: 380,
            child: PdfKit.metaStrip(
              data.metaRows,
              theme,
              topRuleColor: _coral,
            ),
          ),
          pw.SizedBox(height: 28),
          PdfKit.parties(data, theme, labelStyle: labelStyle),
          pw.SizedBox(height: 24),
          PdfKit.itemTable(
            data: data,
            theme: theme,
            spec: ItemTableSpec.resolve(data),
            style: TableStyle.headerBand,
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

  static void _corners(ArtCanvas art, bool firstPage) {
    final w = art.width;
    final h = art.height;
    if (firstPage) {
      art
        ..polygon([(w - 250, 0), (w, 0), (w, 170)], _navy)
        ..polygon([(w - 130, 0), (w, 0), (w, 235)], _coral);
    } else {
      art
        ..polygon([(w - 120, 0), (w, 0), (w, 80)], _navy)
        ..polygon([(w - 60, 0), (w, 0), (w, 110)], _coral);
    }
    art
      ..polygon([(0, h - 110), (0, h), (150, h)], _coral)
      ..polygon([(0, h - 58), (0, h), (82, h)], _navy);
  }

  pw.Widget _heading(PdfRenderData data, PdfDocTheme theme) {
    return pw.Row(
      children: [
        if (data.hasLogo) ...[
          PdfKit.logo(data, size: 46),
          pw.SizedBox(width: 14),
        ],
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              data.document.displayTitle,
              style: theme.displayTitle.copyWith(
                color: _navy,
                fontSize: 32,
                letterSpacing: 1.5,
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              data.document.number,
              style: theme.bodyStrong.copyWith(color: _coral, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }
}
