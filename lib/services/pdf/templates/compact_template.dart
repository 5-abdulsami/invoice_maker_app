import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/widgets.dart' as pw;

/// Built to fit the most rows on a page: tight margins, a single-line
/// heading, condensed party details and an unruled table with no
/// descriptions. Suited to shop owners billing many small items.
class CompactTemplate extends PdfTemplate {
  const CompactTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.compact;

  @override
  pw.Document build(PdfRenderData data) {
    final theme = PdfDocTheme.accented(
      fonts: data.fonts,
      accent: PdfDocTheme.inkAccent,
      accentSoft: PdfDocTheme.inkSoft,
    );
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfKit.pageTheme(
          theme,
          margin: const pw.EdgeInsets.fromLTRB(26, 24, 26, 22),
        ),
        footer: (context) => PdfKit.pageFooter(context, data, theme),
        build: (context) => [
          _heading(data, theme),
          pw.SizedBox(height: 10),
          PdfKit.rule(theme, color: theme.ink),
          pw.SizedBox(height: 10),
          _parties(data, theme),
          pw.SizedBox(height: 12),
          PdfKit.itemTable(
            data: data,
            theme: theme,
            // Descriptions are dropped here: the point of this layout is row
            // density, and a wrapped description doubles a row's height.
            spec: ItemTableSpec.resolve(data, showDescriptions: false),
            style: TableStyle.open,
          ),
          pw.SizedBox(height: 10),
          PdfKit.rule(theme),
          pw.SizedBox(height: 8),
          _summary(data, theme),
          pw.SizedBox(height: 14),
          PdfKit.closingBlocks(data: data, theme: theme),
        ],
      ),
    );

    return pdf;
  }

  /// Everything identifying the document on one line, wrapping if needed.
  pw.Widget _heading(PdfRenderData data, PdfDocTheme theme) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                data.document.displayTitle,
                style: theme.displayTitle.copyWith(fontSize: 18),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                data.document.issuer.name.trim(),
                style: theme.bodyStrong,
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 12),
        PdfKit.metaRows(data.metaRows, theme, labelWidth: 66),
      ],
    );
  }

  /// Both parties on one row, condensed to their essential lines.
  pw.Widget _parties(PdfRenderData data, PdfDocTheme theme) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: PdfKit.partyBlock(
            label: 'Billed to',
            party: data.document.recipient,
            theme: theme,
          ),
        ),
        pw.SizedBox(width: 18),
        if (data.isSettledInvoice) PdfKit.paidMarker(data, theme),
      ],
    );
  }

  pw.Widget _summary(PdfRenderData data, PdfDocTheme theme) {
    return pw.Row(
      children: [
        pw.Spacer(),
        pw.SizedBox(
          width: 210,
          child: PdfKit.totalsRows(data: data, theme: theme),
        ),
      ],
    );
  }
}
