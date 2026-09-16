import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// A solid colour band carries the logo, title and meta, reversed out of the
/// accent. Later pages get a slim version of the band, so a long document
/// still reads as one piece.
class BannerTemplate extends PdfTemplate {
  const BannerTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.banner;

  @override
  pw.Document build(PdfRenderData data) {
    final theme = PdfDocTheme.accented(
      fonts: data.fonts,
      accent: PdfDocTheme.indigoAccent,
      accentSoft: PdfDocTheme.indigoSoft,
    );
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfKit.pageTheme(theme),
        // The band repeats in slim form from page two, where the full one
        // would just push the continued table down.
        header: (context) =>
            context.pageNumber == 1 ? pw.SizedBox() : _slimBand(data, theme),
        footer: (context) => PdfKit.pageFooter(context, data, theme),
        // Each block is a separate top-level child: a MultiPage can only
        // break a table across pages when the table is one of these, not
        // when it is nested inside a column or a padded container.
        build: (context) => [
          _fullBand(data, theme),
          pw.SizedBox(height: 20),
          _parties(data, theme),
          pw.SizedBox(height: 20),
          PdfKit.itemTable(
            data: data,
            theme: theme,
            spec: ItemTableSpec.resolve(data),
            style: TableStyle.headerBand,
          ),
          pw.SizedBox(height: 16),
          _summary(data, theme),
          pw.SizedBox(height: 20),
          _closing(data, theme),
        ],
      ),
    );

    return pdf;
  }

  /// The page-one band: title and logo above the document meta.
  pw.Widget _fullBand(PdfRenderData data, PdfDocTheme theme) {
    return pw.Container(
      width: double.infinity,
      color: theme.accent,
      padding: const pw.EdgeInsets.all(20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Text(
                  data.document.displayTitle,
                  style: theme.displayTitleOnAccent,
                ),
              ),
              if (data.hasLogo)
                pw.Container(
                  padding: const pw.EdgeInsets.all(5),
                  color: PdfColors.white,
                  child: PdfKit.logo(data, size: 40),
                ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Expanded(
                child: pw.Text(
                  data.document.issuer.name.trim(),
                  style: theme.partyName.copyWith(color: theme.onAccent),
                ),
              ),
              pw.SizedBox(width: 16),
              PdfKit.metaRows(data.metaRows, theme, onAccent: true),
            ],
          ),
        ],
      ),
    );
  }

  /// Continuation pages: one thin strip, with no repeated meta.
  pw.Widget _slimBand(PdfRenderData data, PdfDocTheme theme) {
    return pw.Container(
      width: double.infinity,
      color: theme.accent,
      margin: const pw.EdgeInsets.only(bottom: 14),
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            data.document.displayTitle,
            style: pw.TextStyle(
              font: theme.fonts.narrowBold,
              fontSize: 12,
              color: theme.onAccent,
              letterSpacing: 1,
            ),
          ),
          pw.Text(
            data.document.number,
            style: theme.bodyStrong.copyWith(color: theme.onAccent),
          ),
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
        pw.SizedBox(width: 24),
        pw.Expanded(
          child: PdfKit.partyBlock(
            label: 'From',
            party: data.document.issuer,
            theme: theme,
            align: pw.CrossAxisAlignment.end,
          ),
        ),
      ],
    );
  }

  pw.Widget _summary(PdfRenderData data, PdfDocTheme theme) {
    return pw.Row(
      children: [
        if (data.isSettledInvoice) PdfKit.paidMarker(data, theme),
        pw.Spacer(),
        pw.SizedBox(
          width: 250,
          child: PdfKit.totalsRows(
            data: data,
            theme: theme,
            totalOnAccent: true,
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
          pw.SizedBox(width: 24),
          PdfKit.signatureBlock(data: data, theme: theme),
        ],
      ],
    );
  }
}
