import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_art.dart';
import 'package:invoicemaker/services/pdf/pdf_fonts.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// A print-shop halftone screen fades in from the top-right corner in warm
/// orange; the heading keeps to the clear space on the left.
class HalftoneTemplate extends PdfTemplate {
  const HalftoneTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.halftone;

  @override
  PdfTypeface get typeface => PdfTypeface.grotesk;

  static const _orange = PdfColor.fromInt(0xFFEA580C);
  static const _dots = PdfColor.fromInt(0xFFF7A26B);

  @override
  pw.Document build(PdfRenderData data) {
    final theme = PdfDocTheme.accented(
      fonts: data.fonts,
      accent: _orange,
      accentSoft: const PdfColor.fromInt(0xFFFFF1E6),
      ink: const PdfColor.fromInt(0xFF1C1917),
      hairline: const PdfColor.fromInt(0xFFEDE4DC),
    );
    final document = data.document;
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfKit.pageTheme(
          theme,
          background: (context) => pageArt((art) {
            final first = context.pageNumber == 1;
            final width = first ? 270.0 : 150.0;
            art
              ..rect(0, 0, art.width, 5, _orange)
              ..halftone(
                art.width - width,
                5,
                width,
                first ? 190 : 60,
                _dots,
                fadeLeft: true,
              );
          }),
        ),
        header: (context) =>
            context.pageNumber == 1 ? pw.SizedBox() : pw.SizedBox(height: 30),
        footer: (context) => PdfKit.pageFooter(context, data, theme),
        build: (context) => [
          pw.SizedBox(
            // Keeps the heading in the clear space left of the dots.
            width: 270,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (data.hasLogo) ...[
                  PdfKit.logo(data, size: 42),
                  pw.SizedBox(height: 12),
                ],
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      document.displayTitle,
                      style: theme.displayTitle.copyWith(fontSize: 38),
                    ),
                    pw.Container(
                      width: 9,
                      height: 9,
                      margin: const pw.EdgeInsets.only(left: 3, bottom: 8),
                      decoration: const pw.BoxDecoration(
                        color: _orange,
                        shape: pw.BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 2),
                pw.Text(document.number, style: theme.caption),
                pw.SizedBox(height: 16),
                PdfKit.partyBlock(
                  label: '',
                  showLabel: false,
                  party: document.issuer,
                  theme: theme,
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),
          PdfKit.metaStrip(
            data.metaRows,
            theme,
            topRuleColor: _orange,
            topRuleWidth: 2,
          ),
          pw.SizedBox(height: 26),
          PdfKit.partyBlock(
            label: 'Billed to',
            party: document.recipient,
            theme: theme,
            labelStyle: theme.sectionLabel.copyWith(color: _orange),
          ),
          pw.SizedBox(height: 24),
          PdfKit.itemTable(
            data: data,
            theme: theme,
            spec: ItemTableSpec.resolve(data),
            style: TableStyle.softHeader,
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
}
