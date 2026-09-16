import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/widgets.dart' as pw;

/// An accent rail runs down the left of the heading, with the two parties
/// side by side and a quietly ruled table.
class SlateTemplate extends PdfTemplate {
  const SlateTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.slate;

  @override
  pw.Document build(PdfRenderData data) {
    final theme = PdfDocTheme.accented(
      fonts: data.fonts,
      accent: PdfDocTheme.tealAccent,
      accentSoft: PdfDocTheme.tealSoft,
    );
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfKit.pageTheme(theme),
        footer: (context) => PdfKit.pageFooter(context, data, theme),
        build: (context) => [
          _heading(data, theme),
          pw.SizedBox(height: 22),
          _parties(data, theme),
          pw.SizedBox(height: 20),
          PdfKit.itemTable(
            data: data,
            theme: theme,
            spec: ItemTableSpec.resolve(data),
          ),
          pw.SizedBox(height: 16),
          _summary(data, theme),
          pw.SizedBox(height: 22),
          _closing(data, theme),
        ],
      ),
    );

    return pdf;
  }

  /// Title and meta, fronted by the vertical accent rail.
  pw.Widget _heading(PdfRenderData data, PdfDocTheme theme) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(width: 3, height: 54, color: theme.accent),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(data.document.displayTitle, style: theme.displayTitle),
              pw.SizedBox(height: 4),
              if (data.isSettledInvoice) PdfKit.paidMarker(data, theme),
            ],
          ),
        ),
        pw.SizedBox(width: 16),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            PdfKit.logo(data, size: 46),
            if (data.hasLogo) pw.SizedBox(height: 8),
            PdfKit.metaRows(data.metaRows, theme),
          ],
        ),
      ],
    );
  }

  pw.Widget _parties(PdfRenderData data, PdfDocTheme theme) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: PdfKit.partyBlock(
            label: 'From',
            party: data.document.issuer,
            theme: theme,
          ),
        ),
        pw.SizedBox(width: 28),
        pw.Expanded(
          child: PdfKit.partyBlock(
            label: 'Billed to',
            party: data.document.recipient,
            theme: theme,
          ),
        ),
      ],
    );
  }

  /// Totals held to the right, at a readable width on any page size.
  pw.Widget _summary(PdfRenderData data, PdfDocTheme theme) {
    return pw.Row(
      children: [
        pw.Spacer(),
        pw.SizedBox(
          width: 250,
          child: PdfKit.totalsRows(data: data, theme: theme),
        ),
      ],
    );
  }

  pw.Widget _closing(PdfRenderData data, PdfDocTheme theme) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: PdfKit.closingBlocks(data: data, theme: theme),
        ),
        if (data.hasSignature) ...[
          pw.SizedBox(width: 24),
          PdfKit.signatureBlock(data: data, theme: theme),
        ],
      ],
    );
  }
}
