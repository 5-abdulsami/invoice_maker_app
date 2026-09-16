import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/widgets.dart' as pw;

/// Wide margins, a large condensed title and meta laid out as a horizontal
/// strip. The table is unruled and the total is stated as a headline figure.
class EditorialTemplate extends PdfTemplate {
  const EditorialTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.editorial;

  @override
  pw.Document build(PdfRenderData data) {
    final theme = PdfDocTheme.accented(
      fonts: data.fonts,
      accent: PdfDocTheme.amberAccent,
      accentSoft: PdfDocTheme.amberSoft,
    );
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfKit.pageTheme(
          theme,
          margin: const pw.EdgeInsets.fromLTRB(52, 52, 52, 34),
        ),
        footer: (context) => PdfKit.pageFooter(context, data, theme),
        build: (context) => [
          _title(data, theme),
          pw.SizedBox(height: 26),
          _metaStrip(data, theme),
          pw.SizedBox(height: 26),
          _parties(data, theme),
          pw.SizedBox(height: 26),
          PdfKit.itemTable(
            data: data,
            theme: theme,
            spec: ItemTableSpec.resolve(data),
            style: TableStyle.open,
          ),
          pw.SizedBox(height: 10),
          PdfKit.rule(theme, color: theme.ink),
          pw.SizedBox(height: 18),
          _summary(data, theme),
          pw.SizedBox(height: 28),
          _closing(data, theme),
        ],
      ),
    );

    return pdf;
  }

  pw.Widget _title(PdfRenderData data, PdfDocTheme theme) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Expanded(
          child: pw.Text(
            data.document.displayTitle,
            style: pw.TextStyle(
              font: theme.fonts.narrowLight,
              fontSize: 42,
              color: theme.ink,
              letterSpacing: 2.4,
            ),
          ),
        ),
        PdfKit.logo(data, size: 44),
      ],
    );
  }

  /// Meta as a single rule-topped strip of label/value pairs.
  pw.Widget _metaStrip(PdfRenderData data, PdfDocTheme theme) {
    final rows = data.metaRows;

    return pw.Column(
      children: [
        PdfKit.rule(theme, color: theme.ink),
        pw.SizedBox(height: 10),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < rows.length; i++)
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    PdfKit.sectionLabel(rows[i].label, theme),
                    pw.SizedBox(height: 3),
                    pw.Text(rows[i].value, style: theme.bodyStrong),
                  ],
                ),
              ),
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
        pw.SizedBox(width: 36),
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

  /// The headline figure, with the breakdown beside it.
  pw.Widget _summary(PdfRenderData data, PdfDocTheme theme) {
    return pw.Row(
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
                style: theme.heroAmount.copyWith(fontSize: 30),
              ),
              if (data.isSettledInvoice) ...[
                pw.SizedBox(height: 10),
                PdfKit.paidMarker(data, theme),
              ],
            ],
          ),
        ),
        pw.SizedBox(width: 30),
        pw.SizedBox(
          width: 230,
          child: PdfKit.totalsRows(
            data: data,
            theme: theme,
            emphasiseTotal: false,
          ),
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
          pw.SizedBox(width: 30),
          PdfKit.signatureBlock(data: data, theme: theme),
        ],
      ],
    );
  }
}
