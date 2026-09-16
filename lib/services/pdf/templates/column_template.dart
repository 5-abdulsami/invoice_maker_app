import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/widgets.dart' as pw;

/// A narrow side column holds the logo, the issuer and the payment details,
/// leaving the wide column for the table. The contact details stay out of the
/// way of the numbers.
class ColumnTemplate extends PdfTemplate {
  const ColumnTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.column;

  static const double _sidebarWidth = 150;

  @override
  pw.Document build(PdfRenderData data) {
    final theme = PdfDocTheme.accented(
      fonts: data.fonts,
      accent: PdfDocTheme.claretAccent,
      accentSoft: PdfDocTheme.claretSoft,
    );
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfKit.pageTheme(theme),
        footer: (context) => PdfKit.pageFooter(context, data, theme),
        build: (context) => [
          // The sidebar is part of the first flow block rather than a page
          // decoration, so a table that runs onto page two gets the full
          // width instead of an empty column beside it.
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                width: _sidebarWidth,
                child: _sidebar(data, theme),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(child: _mainHead(data, theme)),
            ],
          ),
          pw.SizedBox(height: 20),
          PdfKit.itemTable(
            data: data,
            theme: theme,
            spec: ItemTableSpec.resolve(data),
          ),
          pw.SizedBox(height: 16),
          _summary(data, theme),
          if (data.hasSignature) ...[
            pw.SizedBox(height: 24),
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

  pw.Widget _sidebar(PdfRenderData data, PdfDocTheme theme) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      color: theme.accentSoft,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (data.hasLogo) ...[
            PdfKit.logo(data, size: 48),
            pw.SizedBox(height: 12),
          ],
          PdfKit.partyBlock(
            label: 'From',
            party: data.document.issuer,
            theme: theme,
          ),
          if (data.document.paymentDetails.trim().isNotEmpty) ...[
            pw.SizedBox(height: 14),
            PdfKit.textBlock(
              label: 'Payment details',
              body: data.document.paymentDetails,
              theme: theme,
            ),
          ],
          if (data.document.paymentTerms.trim().isNotEmpty) ...[
            pw.SizedBox(height: 14),
            PdfKit.textBlock(
              label: 'Terms',
              body: data.document.paymentTerms,
              theme: theme,
            ),
          ],
          if (data.document.notes.trim().isNotEmpty) ...[
            pw.SizedBox(height: 14),
            PdfKit.textBlock(
              label: 'Notes',
              body: data.document.notes,
              theme: theme,
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _mainHead(PdfRenderData data, PdfDocTheme theme) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          data.document.displayTitle,
          style: theme.displayTitle.copyWith(color: theme.accent),
        ),
        pw.SizedBox(height: 12),
        PdfKit.metaRows(
          data.metaRows,
          theme,
          align: pw.CrossAxisAlignment.start,
          labelWidth: 80,
        ),
        pw.SizedBox(height: 16),
        PdfKit.rule(theme),
        pw.SizedBox(height: 12),
        PdfKit.partyBlock(
          label: 'Billed to',
          party: data.document.recipient,
          theme: theme,
        ),
        if (data.isSettledInvoice) ...[
          pw.SizedBox(height: 10),
          PdfKit.paidMarker(data, theme),
        ],
      ],
    );
  }

  pw.Widget _summary(PdfRenderData data, PdfDocTheme theme) {
    return pw.Row(
      children: [
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
}
