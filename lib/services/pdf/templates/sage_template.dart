import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_art.dart';
import 'package:invoicemaker/services/pdf/pdf_fonts.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Warm cream stock, sage green and a bookish serif: reads like a letter
/// from an independent studio. A sage edge runs along the top of each page.
class SageTemplate extends PdfTemplate {
  const SageTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.sage;

  @override
  PdfTypeface get typeface => PdfTypeface.serif;

  static const _sage = PdfColor.fromInt(0xFF4F7A5A);
  static const _cream = PdfColor.fromInt(0xFFFBF8F1);

  @override
  pw.Document build(PdfRenderData data) {
    final theme = PdfDocTheme.accented(
      fonts: data.fonts,
      accent: _sage,
      accentSoft: const PdfColor.fromInt(0xFFE7EEE3),
      ink: const PdfColor.fromInt(0xFF2B2B26),
      body: const PdfColor.fromInt(0xFF45443D),
      muted: const PdfColor.fromInt(0xFF7C7A6E),
      hairline: const PdfColor.fromInt(0xFFDDD6C8),
    );
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfKit.pageTheme(
          theme,
          margin: const pw.EdgeInsets.fromLTRB(40, 44, 40, 32),
          background: (_) => pageArt(
            (art) => art
              ..rect(0, 0, art.width, art.height, _cream)
              ..rect(0, 0, art.width, 6, _sage),
          ),
        ),
        footer: (context) => PdfKit.pageFooter(context, data, theme),
        build: (context) => [
          _heading(data, theme),
          pw.SizedBox(height: 16),
          pw.Container(height: 1.4, color: _sage),
          pw.SizedBox(height: 2),
          pw.Container(height: 0.5, color: _sage),
          pw.SizedBox(height: 22),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: PdfKit.partyBlock(
                  label: 'Billed to',
                  party: data.document.recipient,
                  theme: theme,
                  labelStyle: theme.sectionLabel.copyWith(color: _sage),
                ),
              ),
              pw.SizedBox(width: 24),
              PdfKit.metaRows(data.metaRows, theme),
            ],
          ),
          pw.SizedBox(height: 26),
          PdfKit.itemTable(
            data: data,
            theme: theme,
            spec: ItemTableSpec.resolve(data),
            style: TableStyle.underlineHeader,
          ),
          pw.SizedBox(height: 16),
          PdfKit.summary(data, theme, finish: TotalFinish.doubleRule),
          pw.SizedBox(height: 26),
          PdfKit.closing(data, theme),
        ],
      ),
    );

    return pdf;
  }

  pw.Widget _heading(PdfRenderData data, PdfDocTheme theme) {
    final issuer = data.document.issuer;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        if (data.hasLogo) ...[
          PdfKit.logo(data, size: 48),
          pw.SizedBox(width: 14),
        ],
        pw.Expanded(
          child: PdfKit.partyBlock(
            label: '',
            showLabel: false,
            party: issuer,
            theme: theme,
            nameStyle: theme.partyName.copyWith(fontSize: 16),
            textStyle: theme.caption.copyWith(color: theme.body),
          ),
        ),
        pw.SizedBox(width: 20),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              data.document.displayTitle,
              style: theme.displayTitle.copyWith(
                color: _sage,
                fontSize: 30,
                letterSpacing: 3,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(data.document.number, style: theme.caption),
          ],
        ),
      ],
    );
  }
}
