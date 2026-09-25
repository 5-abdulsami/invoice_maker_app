import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_art.dart';
import 'package:invoicemaker/services/pdf/pdf_fonts.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Loud and graphic: a signal-yellow block runs off the top of the page with
/// the title in huge condensed capitals, cut off by a heavy black bar.
class PosterTemplate extends PdfTemplate {
  const PosterTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.poster;

  @override
  PdfTypeface get typeface => PdfTypeface.poster;

  static const _yellow = PdfColor.fromInt(0xFFFFD60A);
  static const _black = PdfColor.fromInt(0xFF111111);
  static const _olive = PdfColor.fromInt(0xFF5C5000);

  static const double _block = 222;
  static const double _top = 36;

  @override
  pw.Document build(PdfRenderData data) {
    final theme = PdfDocTheme.accented(
      fonts: data.fonts,
      accent: _black,
      accentSoft: const PdfColor.fromInt(0xFFFFF7CC),
      onAccent: _yellow,
      ink: _black,
    );
    final label = theme.styled(
      font: theme.fonts.narrowBold,
      size: 9,
      letterSpacing: 2,
    );
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfKit.pageTheme(
          theme,
          background: (context) => pageArt((art) {
            final first = context.pageNumber == 1;
            final height = first ? _block : 14.0;
            art
              ..rect(0, 0, art.width, height, _yellow)
              ..rect(0, height, art.width, first ? 8 : 3, _black);
          }),
        ),
        header: (context) =>
            context.pageNumber == 1 ? pw.SizedBox() : pw.SizedBox(height: 6),
        footer: (context) => PdfKit.pageFooter(context, data, theme),
        build: (context) => [
          _header(data, theme),
          pw.SizedBox(height: 42),
          PdfKit.parties(
            data,
            theme,
            alignSecondEnd: true,
            labelStyle: label,
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

  pw.Widget _header(PdfRenderData data, PdfDocTheme theme) {
    final document = data.document;

    return pw.SizedBox(
      height: _block - _top - 16,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Text(
                  document.issuer.name.trim().toUpperCase(),
                  style: theme.styled(
                    font: theme.fonts.narrowBold,
                    size: 13,
                    letterSpacing: 2,
                  ),
                  maxLines: 1,
                ),
              ),
              PdfKit.logo(data, size: 44),
            ],
          ),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Expanded(
                child: pw.SizedBox(
                  // Bounded so a long custom title scales down to fit.
                  height: 96,
                  child: pw.FittedBox(
                    alignment: pw.Alignment.bottomLeft,
                    fit: pw.BoxFit.scaleDown,
                    child: pw.Text(
                      document.displayTitle,
                      style: theme.displayTitle.copyWith(
                        color: _black,
                        fontSize: 84,
                      ),
                    ),
                  ),
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 10),
                child: PdfKit.metaRows(
                  data.metaRows,
                  theme,
                  labelColor: _olive,
                  valueColor: _black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
