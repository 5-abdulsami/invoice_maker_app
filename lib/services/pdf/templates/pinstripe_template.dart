import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_art.dart';
import 'package:invoicemaker/services/pdf/pdf_fonts.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Tailored: a charcoal header woven with fine diagonal pinstripes, trimmed
/// in mint, over a quietly striped table.
class PinstripeTemplate extends PdfTemplate {
  const PinstripeTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.pinstripe;

  @override
  PdfTypeface get typeface => PdfTypeface.humanist;

  static const _charcoal = PdfColor.fromInt(0xFF2F3E46);
  static const _stripe = PdfColor.fromInt(0xFF3B4C55);
  static const _mint = PdfColor.fromInt(0xFF52B69A);
  static const _mintInk = PdfColor.fromInt(0xFF2A8A6E);

  static const double _band = 152;
  static const double _top = 36;

  @override
  pw.Document build(PdfRenderData data) {
    final theme = PdfDocTheme.accented(
      fonts: data.fonts,
      accent: _charcoal,
      accentSoft: const PdfColor.fromInt(0xFFE7F5F0),
      ink: const PdfColor.fromInt(0xFF1E2A30),
      hairline: const PdfColor.fromInt(0xFFDCE3E6),
    );
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfKit.pageTheme(
          theme,
          background: (context) => pageArt((art) {
            final height = context.pageNumber == 1 ? _band : 16.0;
            art
              ..rect(0, 0, art.width, height, _charcoal)
              ..diagonalStripes(0, 0, art.width, height, _stripe, spacing: 8)
              ..rect(0, height, art.width, 3, _mint);
          }),
        ),
        header: (context) =>
            context.pageNumber == 1 ? pw.SizedBox() : pw.SizedBox(height: 4),
        footer: (context) => PdfKit.pageFooter(context, data, theme),
        build: (context) => [
          _header(data, theme),
          pw.SizedBox(height: 38),
          PdfKit.parties(
            data,
            theme,
            alignSecondEnd: true,
            labelStyle: theme.sectionLabel.copyWith(color: _mintInk),
          ),
          pw.SizedBox(height: 24),
          PdfKit.itemTable(
            data: data,
            theme: theme,
            spec: ItemTableSpec.resolve(data),
            style: TableStyle.stripedRows,
            stripeFill: const PdfColor.fromInt(0xFFF2F5F6),
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

    return pw.SizedBox(
      height: _band - _top - 20,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  document.displayTitle,
                  style: theme.displayTitleOnAccent.copyWith(
                    fontSize: 30,
                    letterSpacing: 4,
                  ),
                ),
                pw.Text(
                  document.issuer.name.trim(),
                  style: theme.partyName.copyWith(color: PdfColors.white),
                  maxLines: 1,
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 16),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              if (data.hasLogo)
                pw.Container(
                  padding: const pw.EdgeInsets.all(3),
                  color: PdfColors.white,
                  child: PdfKit.logo(data, size: 34),
                )
              else
                pw.SizedBox(),
              PdfKit.metaRows(
                data.metaRows,
                theme,
                labelColor: _mint,
                valueColor: PdfColors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
