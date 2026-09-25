import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_art.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// A green arrow tab runs in from the left edge carrying the title, and a
/// row of chevrons walks from the issue date to the amount due.
class ArrowTemplate extends PdfTemplate {
  const ArrowTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.arrow;

  static const _green = PdfColor.fromInt(0xFF15803D);
  static const _leaf = PdfColor.fromInt(0xFFBBF7D0);
  static const _pale = PdfColor.fromInt(0xFFDCFCE7);

  static const double _tabTop = 40;
  static const double _tabBottom = 130;
  static const double _tabEnd = 318;

  @override
  pw.Document build(PdfRenderData data) {
    final theme = PdfDocTheme.accented(
      fonts: data.fonts,
      accent: _green,
      accentSoft: const PdfColor.fromInt(0xFFF0FDF4),
      hairline: const PdfColor.fromInt(0xFFE0E7E2),
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
                      (0, _tabTop),
                      (_tabEnd - 34, _tabTop),
                      (_tabEnd, (_tabTop + _tabBottom) / 2),
                      (_tabEnd - 34, _tabBottom),
                      (0, _tabBottom),
                    ],
                    _green,
                  ),
                )
              : pw.SizedBox(),
        ),
        footer: (context) => PdfKit.pageFooter(context, data, theme),
        build: (context) => [
          _header(data, theme),
          pw.SizedBox(height: 26),
          _steps(data, theme),
          pw.SizedBox(height: 26),
          PdfKit.parties(
            data,
            theme,
            alignSecondEnd: true,
            labelStyle: theme.sectionLabel.copyWith(color: _green),
          ),
          pw.SizedBox(height: 24),
          PdfKit.itemTable(
            data: data,
            theme: theme,
            spec: ItemTableSpec.resolve(data),
            style: TableStyle.underlineHeader,
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
      // From the top margin to just below the tab.
      height: _tabBottom - 36 + 8,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: _tabEnd - 36 - 50,
            child: pw.Padding(
              padding: const pw.EdgeInsets.only(top: 20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    document.displayTitle,
                    style: theme.displayTitleOnAccent.copyWith(
                      fontSize: 28,
                      letterSpacing: 2,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    document.number,
                    style: theme.bodyStrong.copyWith(color: _leaf),
                  ),
                ],
              ),
            ),
          ),
          pw.SizedBox(width: 60),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                if (data.hasLogo) ...[
                  PdfKit.logo(data, size: 40),
                  pw.SizedBox(height: 8),
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
    );
  }

  /// Issued, then due, then the amount: each chevron darker than the last.
  pw.Widget _steps(PdfRenderData data, PdfDocTheme theme) {
    final document = data.document;
    final steps = [
      (document.kind.issueDateLabel, data.date(document.issueDate), _pale),
      (document.kind.endDateLabel, data.date(document.endDate), _leaf),
      (data.balanceLabel, data.money(data.balanceValue), _green),
    ];

    return pw.Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0) pw.SizedBox(width: 3),
          pw.Expanded(
            child: _chevron(
              label: steps[i].$1,
              value: steps[i].$2,
              fill: steps[i].$3,
              onFill: i == steps.length - 1 ? PdfColors.white : _green,
              first: i == 0,
              theme: theme,
            ),
          ),
        ],
      ],
    );
  }

  static pw.Widget _chevron({
    required String label,
    required String value,
    required PdfColor fill,
    required PdfColor onFill,
    required bool first,
    required PdfDocTheme theme,
  }) {
    const point = 12.0;

    return pw.CustomPaint(
      painter: (canvas, size) {
        final art = ArtCanvas(canvas, size);
        final w = size.x;
        final h = size.y;
        art.polygon(
          [
            (0, 0),
            (w - point, 0),
            (w, h / 2),
            (w - point, h),
            (0, h),
            if (!first) (point, h / 2),
          ],
          fill,
        );
      },
      child: pw.Padding(
        padding: pw.EdgeInsets.fromLTRB(first ? 12 : 22, 8, 18, 8),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label.toUpperCase(),
              style: theme.sectionLabel.copyWith(color: onFill),
              maxLines: 1,
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              value,
              style: theme.bodyStrong.copyWith(color: onFill),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
