import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_art.dart';
import 'package:invoicemaker/services/pdf/pdf_fonts.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Black and gold inside a fine double frame. Page one opens on a black
/// panel with the title in a display serif.
class LuxeTemplate extends PdfTemplate {
  const LuxeTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.luxe;

  @override
  PdfTypeface get typeface => PdfTypeface.elegant;

  static const _black = PdfColor.fromInt(0xFF121212);
  static const _gold = PdfColor.fromInt(0xFFC9A55C);
  static const _goldInk = PdfColor.fromInt(0xFF96763A);
  static const _stone = PdfColor.fromInt(0xFFA8A29E);

  /// Inset of the black panel from the paper's edges.
  static const double _panelInset = 26;
  static const double _panelBottom = 178;
  static const double _top = 44;

  @override
  pw.Document build(PdfRenderData data) {
    final theme = PdfDocTheme.accented(
      fonts: data.fonts,
      accent: _black,
      accentSoft: const PdfColor.fromInt(0xFFF7F2E8),
      onAccent: _gold,
      hairline: const PdfColor.fromInt(0xFFE6DFD1),
    );
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfKit.pageTheme(
          theme,
          margin: const pw.EdgeInsets.fromLTRB(48, _top, 48, 44),
          background: (context) =>
              pageArt((art) => _frame(art, context.pageNumber == 1)),
        ),
        footer: (context) => PdfKit.pageFooter(context, data, theme),
        build: (context) => [
          _header(data, theme),
          pw.SizedBox(height: 36),
          PdfKit.parties(
            data,
            theme,
            alignSecondEnd: true,
            labelStyle: theme.sectionLabel.copyWith(color: _goldInk),
          ),
          pw.SizedBox(height: 24),
          PdfKit.itemTable(
            data: data,
            theme: theme,
            spec: ItemTableSpec.resolve(data),
            style: TableStyle.headerBand,
            headerText: _gold,
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

  static void _frame(ArtCanvas art, bool firstPage) {
    final w = art.width;
    final h = art.height;
    art
      ..strokeRect(14, 14, w - 28, h - 28, _gold, lineWidth: 1.4)
      ..strokeRect(19, 19, w - 38, h - 38, _gold, lineWidth: 0.4);
    if (firstPage) {
      art.rect(
        _panelInset,
        _panelInset,
        w - _panelInset * 2,
        _panelBottom - _panelInset,
        _black,
      );
    }
  }

  pw.Widget _header(PdfRenderData data, PdfDocTheme theme) {
    final document = data.document;

    return pw.SizedBox(
      height: _panelBottom - _top - 18,
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
                  style: theme.displayTitle.copyWith(
                    color: _gold,
                    fontSize: 34,
                    letterSpacing: 3,
                  ),
                ),
                pw.Text(
                  document.issuer.name.trim().toUpperCase(),
                  style: theme.styled(
                    font: theme.fonts.bold,
                    size: 10,
                    color: PdfColors.white,
                    letterSpacing: 3,
                  ),
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
                  child: PdfKit.logo(data, size: 36),
                )
              else
                pw.SizedBox(),
              PdfKit.metaRows(
                data.metaRows,
                theme,
                labelColor: _stone,
                valueColor: PdfColors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
