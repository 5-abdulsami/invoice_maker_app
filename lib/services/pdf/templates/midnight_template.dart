import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_art.dart';
import 'package:invoicemaker/services/pdf/pdf_fonts.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// A deep midnight header runs off the top of the page with the amount due
/// glowing in electric cyan, like a dark-mode dashboard.
class MidnightTemplate extends PdfTemplate {
  const MidnightTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.midnight;

  @override
  PdfTypeface get typeface => PdfTypeface.grotesk;

  static const _night = PdfColor.fromInt(0xFF0B1120);
  static const _cyan = PdfColor.fromInt(0xFF22D3EE);
  static const _slate = PdfColor.fromInt(0xFF94A3B8);

  static const double _band = 196;
  static const double _top = 36;

  @override
  pw.Document build(PdfRenderData data) {
    final theme = PdfDocTheme.accented(
      fonts: data.fonts,
      accent: _night,
      accentSoft: const PdfColor.fromInt(0xFFE6F7FB),
      onAccent: _cyan,
      ink: const PdfColor.fromInt(0xFF0F172A),
      body: const PdfColor.fromInt(0xFF334155),
      muted: const PdfColor.fromInt(0xFF64748B),
      hairline: const PdfColor.fromInt(0xFFE2E8F0),
    );
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfKit.pageTheme(
          theme,
          background: (context) => pageArt((art) {
            final height = context.pageNumber == 1 ? _band : 18.0;
            art
              ..rect(0, 0, art.width, height, _night)
              ..rect(0, height, art.width, 1.5, _cyan);
          }),
        ),
        header: (context) =>
            context.pageNumber == 1 ? pw.SizedBox() : pw.SizedBox(height: 6),
        footer: (context) => PdfKit.pageFooter(context, data, theme),
        build: (context) => [
          _header(data, theme),
          pw.SizedBox(height: 42),
          PdfKit.metaStrip(
            data.metaRows,
            theme,
            dividerColor: theme.hairline,
          ),
          pw.SizedBox(height: 24),
          PdfKit.parties(data, theme, alignSecondEnd: true),
          pw.SizedBox(height: 24),
          PdfKit.itemTable(
            data: data,
            theme: theme,
            spec: ItemTableSpec.resolve(data),
            style: TableStyle.headerBand,
            headerText: PdfColors.white,
          ),
          pw.SizedBox(height: 16),
          PdfKit.summary(data, theme, finish: TotalFinish.accentBar),
          pw.SizedBox(height: 24),
          PdfKit.closing(data, theme),
        ],
      ),
    );

    return pdf;
  }

  pw.Widget _header(PdfRenderData data, PdfDocTheme theme) {
    final document = data.document;
    final contact = PdfKit.contactLine(document.issuer);

    return pw.SizedBox(
      height: _band - _top - 22,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      document.displayTitle,
                      style: theme.displayTitle.copyWith(
                        color: PdfColors.white,
                        fontSize: 28,
                        letterSpacing: 3,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      document.number,
                      style: theme.bodyStrong.copyWith(color: _slate),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      document.issuer.name.trim(),
                      style: theme.partyName.copyWith(color: PdfColors.white),
                      maxLines: 1,
                    ),
                    if (contact.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        contact,
                        style: theme.caption.copyWith(color: _slate),
                        maxLines: 2,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 20),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              if (data.hasLogo)
                pw.Container(
                  padding: const pw.EdgeInsets.all(3),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: PdfKit.logo(data, size: 36),
                )
              else
                pw.SizedBox(),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    data.balanceLabel.toUpperCase(),
                    style: theme.sectionLabel.copyWith(color: _slate),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    data.money(data.balanceValue),
                    style: theme.heroAmount.copyWith(
                      color: _cyan,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
