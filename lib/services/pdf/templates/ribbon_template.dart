import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_art.dart';
import 'package:invoicemaker/services/pdf/pdf_fonts.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// A rose ribbon bookmark hangs from the top edge of page one and carries
/// the amount due, so the figure is the first thing the reader finds.
class RibbonTemplate extends PdfTemplate {
  const RibbonTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.ribbon;

  @override
  PdfTypeface get typeface => PdfTypeface.humanist;

  static const _rose = PdfColor.fromInt(0xFF9F1239);
  static const _blush = PdfColor.fromInt(0xFFFECDD3);

  static const double _left = 36;
  static const double _width = 116;
  static const double _length = 156;
  static const double _notch = 18;
  static const double _top = 36;

  @override
  pw.Document build(PdfRenderData data) {
    final theme = PdfDocTheme.accented(
      fonts: data.fonts,
      accent: _rose,
      accentSoft: const PdfColor.fromInt(0xFFFFF1F2),
      hairline: const PdfColor.fromInt(0xFFEBDDE0),
    );
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfKit.pageTheme(
          theme,
          background: (context) => context.pageNumber == 1
              ? pageArt(
                  (art) => art.polygon(
                    [
                      (_left, 0),
                      (_left + _width, 0),
                      (_left + _width, _length),
                      (_left + _width / 2, _length - _notch),
                      (_left, _length),
                    ],
                    _rose,
                  ),
                )
              : pw.SizedBox(),
        ),
        footer: (context) => PdfKit.pageFooter(context, data, theme),
        build: (context) => [
          _header(data, theme),
          pw.SizedBox(height: 28),
          PdfKit.metaStrip(
            data.metaRows,
            theme,
            labelColor: _rose,
            dividerColor: theme.hairline,
          ),
          pw.SizedBox(height: 24),
          PdfKit.parties(data, theme, alignSecondEnd: true),
          pw.SizedBox(height: 24),
          PdfKit.itemTable(
            data: data,
            theme: theme,
            spec: ItemTableSpec.resolve(data),
            style: TableStyle.underlineHeader,
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

  pw.Widget _header(PdfRenderData data, PdfDocTheme theme) {
    final document = data.document;

    return pw.SizedBox(
      // Ends just above the ribbon's notch.
      height: _length - _notch - _top - 6,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.SizedBox(
            width: _width,
            child: pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    data.balanceLabel.toUpperCase(),
                    style: theme.sectionLabel.copyWith(color: _blush),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 6),
                  pw.FittedBox(
                    fit: pw.BoxFit.scaleDown,
                    child: pw.Text(
                      data.money(data.balanceValue),
                      style: theme.heroAmount.copyWith(
                        color: PdfColors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'by ${data.date(document.endDate)}',
                    style: theme.caption.copyWith(color: _blush),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          pw.SizedBox(width: 26),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  document.displayTitle,
                  style: theme.displayTitle.copyWith(
                    color: _rose,
                    fontSize: 30,
                    letterSpacing: 2,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(document.number, style: theme.caption),
                pw.SizedBox(height: 12),
                pw.Text(
                  document.issuer.name.trim(),
                  style: theme.partyName.copyWith(fontSize: 13),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          if (data.hasLogo) ...[
            pw.SizedBox(width: 16),
            pw.Center(child: PdfKit.logo(data, size: 54)),
          ],
        ],
      ),
    );
  }
}
