import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/widgets.dart' as pw;

/// A formal, centred document: the business name sits above a ruled title,
/// the parties are boxed, and the table is a full grid that stays legible
/// across many pages.
class LedgerTemplate extends PdfTemplate {
  const LedgerTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.ledger;

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
          margin: const pw.EdgeInsets.fromLTRB(42, 40, 42, 30),
        ),
        footer: (context) => PdfKit.pageFooter(context, data, theme),
        build: (context) => [
          _maskhead(data, theme),
          pw.SizedBox(height: 18),
          _partyPanels(data, theme),
          pw.SizedBox(height: 18),
          PdfKit.itemTable(
            data: data,
            theme: theme,
            spec: ItemTableSpec.resolve(data, showIndex: true),
            style: TableStyle.fullGrid,
          ),
          pw.SizedBox(height: 14),
          _summary(data, theme),
          pw.SizedBox(height: 20),
          PdfKit.closingBlocks(data: data, theme: theme),
          if (data.hasSignature) ...[
            pw.SizedBox(height: 22),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: PdfKit.signatureBlock(data: data, theme: theme),
            ),
          ],
        ],
      ),
    );

    return pdf;
  }

  /// Centred business name, then the title between two rules.
  pw.Widget _maskhead(PdfRenderData data, PdfDocTheme theme) {
    final issuer = data.document.issuer;

    return pw.Column(
      children: [
        if (data.hasLogo) ...[
          PdfKit.logo(data, size: 44),
          pw.SizedBox(height: 8),
        ],
        pw.Text(
          issuer.name.trim().isEmpty ? ' ' : issuer.name.trim().toUpperCase(),
          style: pw.TextStyle(
            font: theme.fonts.bold,
            fontSize: 13,
            color: theme.ink,
            letterSpacing: 1.4,
          ),
          textAlign: pw.TextAlign.center,
        ),
        if (issuer.detailLines.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            issuer.detailLines.join('  ·  '),
            style: theme.caption,
            textAlign: pw.TextAlign.center,
          ),
        ],
        pw.SizedBox(height: 14),
        PdfKit.rule(theme, color: theme.ink),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          child: pw.Text(
            data.document.displayTitle,
            style: theme.displayTitle.copyWith(fontSize: 22),
          ),
        ),
        PdfKit.rule(theme, color: theme.ink),
      ],
    );
  }

  /// Recipient on the left, document meta on the right, each in a panel.
  pw.Widget _partyPanels(PdfRenderData data, PdfDocTheme theme) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: _panel(
            theme: theme,
            child: PdfKit.partyBlock(
              label: 'Billed to',
              party: data.document.recipient,
              theme: theme,
            ),
          ),
        ),
        pw.SizedBox(width: 14),
        pw.Expanded(
          child: _panel(
            theme: theme,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                PdfKit.sectionLabel('Details', theme),
                pw.SizedBox(height: 6),
                PdfKit.metaRows(
                  data.metaRows,
                  theme,
                  align: pw.CrossAxisAlignment.start,
                  labelWidth: 78,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _panel({required PdfDocTheme theme, required pw.Widget child}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: theme.hairline, width: 0.5),
      ),
      child: child,
    );
  }

  pw.Widget _summary(PdfRenderData data, PdfDocTheme theme) {
    return pw.Row(
      children: [
        if (data.isSettledInvoice) PdfKit.paidMarker(data, theme),
        pw.Spacer(),
        pw.SizedBox(
          width: 240,
          child: _panel(
            theme: theme,
            child: PdfKit.totalsRows(data: data, theme: theme),
          ),
        ),
      ],
    );
  }
}
