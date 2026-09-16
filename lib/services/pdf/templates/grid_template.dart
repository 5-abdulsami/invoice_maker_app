import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/widgets.dart' as pw;

/// Every section sits in its own outlined panel, so each block of
/// information is clearly bounded. Useful where a document is filed or
/// scanned and needs hard edges.
class GridTemplate extends PdfTemplate {
  const GridTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.grid;

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
        pageTheme: PdfKit.pageTheme(
          theme,
          margin: const pw.EdgeInsets.fromLTRB(32, 32, 32, 28),
        ),
        footer: (context) => PdfKit.pageFooter(context, data, theme),
        build: (context) => [
          _headerPanel(data, theme),
          pw.SizedBox(height: 10),
          _partyPanels(data, theme),
          pw.SizedBox(height: 10),
          // Not wrapped in a panel: a container cannot split across pages,
          // and the full grid already draws the box around the table.
          PdfKit.itemTable(
            data: data,
            theme: theme,
            spec: ItemTableSpec.resolve(data, showIndex: true),
            style: TableStyle.fullGrid,
          ),
          pw.SizedBox(height: 10),
          _bottomPanels(data, theme),
        ],
      ),
    );

    return pdf;
  }

  /// Title and meta in one banded panel.
  pw.Widget _headerPanel(PdfRenderData data, PdfDocTheme theme) {
    return _panel(
      theme: theme,
      padding: pw.EdgeInsets.zero,
      child: pw.Column(
        children: [
          pw.Container(
            width: double.infinity,
            color: theme.accent,
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(
                    data.document.displayTitle,
                    style: theme.displayTitleOnAccent.copyWith(fontSize: 20),
                  ),
                ),
                pw.Text(
                  data.document.number,
                  style: theme.bodyStrong.copyWith(color: theme.onAccent),
                ),
              ],
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        data.document.issuer.name.trim(),
                        style: theme.partyName,
                      ),
                      if (data.isSettledInvoice) ...[
                        pw.SizedBox(height: 8),
                        PdfKit.paidMarker(data, theme),
                      ],
                    ],
                  ),
                ),
                pw.SizedBox(width: 14),
                PdfKit.logo(data, size: 40),
                if (data.hasLogo) pw.SizedBox(width: 14),
                PdfKit.metaRows(data.metaRows, theme, labelWidth: 70),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _partyPanels(PdfRenderData data, PdfDocTheme theme) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: _panel(
            theme: theme,
            child: PdfKit.partyBlock(
              label: 'From',
              party: data.document.issuer,
              theme: theme,
            ),
          ),
        ),
        pw.SizedBox(width: 10),
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
      ],
    );
  }

  /// Notes on the left, totals on the right, each boxed.
  pw.Widget _bottomPanels(PdfRenderData data, PdfDocTheme theme) {
    final closing = PdfKit.closingBlocks(data: data, theme: theme);
    final hasClosing = data.document.notes.trim().isNotEmpty ||
        data.document.paymentTerms.trim().isNotEmpty ||
        data.document.paymentDetails.trim().isNotEmpty;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (hasClosing) ...[
          pw.Expanded(child: _panel(theme: theme, child: closing)),
          pw.SizedBox(width: 10),
        ] else
          pw.Spacer(),
        pw.SizedBox(
          width: 250,
          child: pw.Column(
            children: [
              _panel(
                theme: theme,
                child: PdfKit.totalsRows(data: data, theme: theme),
              ),
              if (data.hasSignature) ...[
                pw.SizedBox(height: 10),
                _panel(
                  theme: theme,
                  child: pw.Center(
                    child: PdfKit.signatureBlock(data: data, theme: theme),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _panel({
    required PdfDocTheme theme,
    required pw.Widget child,
    pw.EdgeInsets padding = const pw.EdgeInsets.all(12),
  }) {
    return pw.Container(
      padding: padding,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: theme.hairline, width: 0.5),
      ),
      child: child,
    );
  }
}
