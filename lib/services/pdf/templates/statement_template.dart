import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/widgets.dart' as pw;

/// Leads with the figure that matters: a panel at the top states the amount
/// due and the date it is due, and the breakdown follows underneath. Reads as
/// a payment request rather than a record.
class StatementTemplate extends PdfTemplate {
  const StatementTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.statement;

  @override
  pw.Document build(PdfRenderData data) {
    final theme = PdfDocTheme.accented(
      fonts: data.fonts,
      accent: PdfDocTheme.forestAccent,
      accentSoft: PdfDocTheme.forestSoft,
    );
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfKit.pageTheme(theme),
        footer: (context) => PdfKit.pageFooter(context, data, theme),
        build: (context) => [
          _topRow(data, theme),
          pw.SizedBox(height: 16),
          _hero(data, theme),
          pw.SizedBox(height: 20),
          _parties(data, theme),
          pw.SizedBox(height: 18),
          PdfKit.sectionLabel('Breakdown', theme),
          pw.SizedBox(height: 6),
          PdfKit.itemTable(
            data: data,
            theme: theme,
            spec: ItemTableSpec.resolve(data),
            style: TableStyle.stripedRows,
          ),
          pw.SizedBox(height: 14),
          _summary(data, theme),
          pw.SizedBox(height: 20),
          _closing(data, theme),
        ],
      ),
    );

    return pdf;
  }

  pw.Widget _topRow(PdfRenderData data, PdfDocTheme theme) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                data.document.issuer.name.trim(),
                style: theme.partyName.copyWith(fontSize: 13),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                data.document.displayTitle,
                style: theme.sectionLabel.copyWith(fontSize: 8.5),
              ),
            ],
          ),
        ),
        PdfKit.logo(data, size: 42),
      ],
    );
  }

  /// The amount-due panel: the one thing the reader must not miss.
  pw.Widget _hero(PdfRenderData data, PdfDocTheme theme) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      color: theme.accentSoft,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                PdfKit.sectionLabel(data.balanceLabel, theme),
                pw.SizedBox(height: 6),
                pw.Text(
                  data.money(data.balanceValue),
                  style: theme.heroAmount.copyWith(color: theme.accent),
                ),
                if (data.isSettledInvoice) ...[
                  pw.SizedBox(height: 8),
                  PdfKit.paidMarker(data, theme),
                ],
              ],
            ),
          ),
          pw.SizedBox(width: 20),
          PdfKit.metaRows(data.metaRows, theme),
        ],
      ),
    );
  }

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
        pw.SizedBox(width: 26),
        pw.Expanded(
          child: PdfKit.partyBlock(
            label: 'From',
            party: data.document.issuer,
            theme: theme,
          ),
        ),
      ],
    );
  }

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
        pw.Expanded(child: PdfKit.closingBlocks(data: data, theme: theme)),
        if (data.hasSignature) ...[
          pw.SizedBox(width: 24),
          PdfKit.signatureBlock(data: data, theme: theme),
        ],
      ],
    );
  }
}
