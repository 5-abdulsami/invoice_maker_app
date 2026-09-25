import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_art.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// The header is split edge to edge: a deep teal panel with the title on
/// the left, a pale panel with the details on the right, underlined by an
/// apricot stripe.
class DuoTemplate extends PdfTemplate {
  const DuoTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.duo;

  static const _teal = PdfColor.fromInt(0xFF0F4C5C);
  static const _pale = PdfColor.fromInt(0xFFE6EFF1);
  static const _apricot = PdfColor.fromInt(0xFFE09F3E);

  static const double _band = 162;
  static const double _top = 36;
  static const double _side = 36;

  /// Where the two panels meet, from the left edge of the paper.
  static const double _split = kPageWidth * 0.58;

  @override
  pw.Document build(PdfRenderData data) {
    final theme = PdfDocTheme.accented(
      fonts: data.fonts,
      accent: _teal,
      accentSoft: _pale,
      hairline: const PdfColor.fromInt(0xFFD7E1E4),
    );
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfKit.pageTheme(
          theme,
          background: (context) =>
              pageArt((art) => _panels(art, context.pageNumber == 1)),
        ),
        header: (context) =>
            context.pageNumber == 1 ? pw.SizedBox() : pw.SizedBox(height: 4),
        footer: (context) => PdfKit.pageFooter(context, data, theme),
        build: (context) => [
          _header(data, theme),
          pw.SizedBox(height: 40),
          PdfKit.parties(
            data,
            theme,
            alignSecondEnd: true,
            labelStyle: theme.sectionLabel.copyWith(color: _teal),
          ),
          pw.SizedBox(height: 24),
          PdfKit.itemTable(
            data: data,
            theme: theme,
            spec: ItemTableSpec.resolve(data),
            style: TableStyle.headerBand,
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

  static void _panels(ArtCanvas art, bool firstPage) {
    final height = firstPage ? _band : 12.0;
    art
      ..rect(0, 0, _split, height, _teal)
      ..rect(_split, 0, art.width - _split, height, _pale)
      ..rect(0, height, art.width, firstPage ? 4 : 2, _apricot);
  }

  pw.Widget _header(PdfRenderData data, PdfDocTheme theme) {
    final document = data.document;
    // Each half keeps a 24pt gutter either side of the split.
    const leftWidth = _split - _side - 24;

    return pw.SizedBox(
      height: _band - _top - 22,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.SizedBox(
            width: leftWidth,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      document.displayTitle,
                      style: theme.displayTitleOnAccent.copyWith(
                        fontSize: 32,
                        letterSpacing: 2,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      document.number,
                      style: theme.bodyStrong.copyWith(color: _apricot),
                    ),
                  ],
                ),
                pw.Text(
                  document.issuer.name.trim(),
                  style: theme.partyName.copyWith(color: PdfColors.white),
                  maxLines: 1,
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 48),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                if (data.hasLogo)
                  PdfKit.logo(data, size: 40)
                else
                  pw.SizedBox(),
                PdfKit.metaRows(
                  data.metaRows,
                  theme,
                  align: pw.CrossAxisAlignment.start,
                  labelWidth: 66,
                  labelColor: _teal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
