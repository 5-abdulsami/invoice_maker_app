import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_art.dart';
import 'package:invoicemaker/services/pdf/pdf_fonts.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// A solid terracotta border wraps the edge of every page, with a fine inner
/// line, framing the document like a print.
class FrameTemplate extends PdfTemplate {
  const FrameTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.frame;

  @override
  PdfTypeface get typeface => PdfTypeface.humanist;

  static const _terracotta = PdfColor.fromInt(0xFFC2553A);
  static const _clay = PdfColor.fromInt(0xFFEBC3B5);

  static const double _border = 12;

  @override
  pw.Document build(PdfRenderData data) {
    final theme = PdfDocTheme.accented(
      fonts: data.fonts,
      accent: _terracotta,
      accentSoft: const PdfColor.fromInt(0xFFFBEDE8),
      ink: const PdfColor.fromInt(0xFF2A1F1B),
      hairline: const PdfColor.fromInt(0xFFEFE2DD),
    );
    final document = data.document;
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfKit.pageTheme(
          theme,
          margin: const pw.EdgeInsets.fromLTRB(50, 50, 50, 42),
          background: (_) => pageArt((art) {
            final w = art.width;
            final h = art.height;
            art
              ..rect(0, 0, w, _border, _terracotta)
              ..rect(0, h - _border, w, _border, _terracotta)
              ..rect(0, 0, _border, h, _terracotta)
              ..rect(w - _border, 0, _border, h, _terracotta)
              ..strokeRect(22, 22, w - 44, h - 44, _clay, lineWidth: 0.6);
          }),
        ),
        footer: (context) => PdfKit.pageFooter(context, data, theme),
        build: (context) => [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      document.displayTitle,
                      style: theme.displayTitle.copyWith(
                        color: _terracotta,
                        fontSize: 32,
                        letterSpacing: 2,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(document.number, style: theme.caption),
                  ],
                ),
              ),
              pw.SizedBox(width: 20),
              pw.SizedBox(
                width: 220,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    if (data.hasLogo) ...[
                      PdfKit.logo(data, size: 44),
                      pw.SizedBox(height: 10),
                    ],
                    PdfKit.partyBlock(
                      label: '',
                      showLabel: false,
                      party: document.issuer,
                      theme: theme,
                      align: pw.CrossAxisAlignment.end,
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Container(height: 0.8, color: _clay),
          pw.SizedBox(height: 18),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: PdfKit.partyBlock(
                  label: 'Billed to',
                  party: document.recipient,
                  theme: theme,
                  labelStyle: theme.sectionLabel.copyWith(color: _terracotta),
                ),
              ),
              pw.SizedBox(width: 24),
              PdfKit.metaRows(data.metaRows, theme),
            ],
          ),
          pw.SizedBox(height: 24),
          PdfKit.itemTable(
            data: data,
            theme: theme,
            spec: ItemTableSpec.resolve(data),
            style: TableStyle.headerBand,
          ),
          pw.SizedBox(height: 16),
          PdfKit.summary(data, theme, finish: TotalFinish.outlined),
          pw.SizedBox(height: 24),
          PdfKit.closing(data, theme),
        ],
      ),
    );

    return pdf;
  }
}
