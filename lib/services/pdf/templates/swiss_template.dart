import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_fonts.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// International Typographic Style: black on white, one red square, an
/// oversized document number and three columns each hung from a heavy rule.
class SwissTemplate extends PdfTemplate {
  const SwissTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.swiss;

  @override
  PdfTypeface get typeface => PdfTypeface.grotesk;

  static const _red = PdfColor.fromInt(0xFFE30613);
  static const _black = PdfColor.fromInt(0xFF111111);

  @override
  pw.Document build(PdfRenderData data) {
    final theme = PdfDocTheme.accented(
      fonts: data.fonts,
      accent: _black,
      accentSoft: const PdfColor.fromInt(0xFFF2F2F2),
      ink: _black,
      body: const PdfColor.fromInt(0xFF333333),
      muted: const PdfColor.fromInt(0xFF777777),
      hairline: const PdfColor.fromInt(0xFFD4D4D4),
    );
    final label = theme.sectionLabel.copyWith(color: _black);
    final document = data.document;
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfKit.pageTheme(
          theme,
          margin: const pw.EdgeInsets.fromLTRB(40, 40, 40, 30),
        ),
        footer: (context) => PdfKit.pageFooter(context, data, theme),
        build: (context) => [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(width: 22, height: 22, color: _red),
              pw.Spacer(),
              PdfKit.logo(data, size: 44),
            ],
          ),
          pw.SizedBox(height: 22),
          pw.Text(
            document.displayTitle,
            style: theme.styled(
              font: theme.fonts.bold,
              size: 10,
              color: _red,
              letterSpacing: 3,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            document.number,
            style: theme.displayTitle.copyWith(fontSize: 46, letterSpacing: -1),
          ),
          pw.SizedBox(height: 26),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _hung(
                  PdfKit.partyBlock(
                    label: 'From',
                    party: document.issuer,
                    theme: theme,
                    labelStyle: label,
                  ),
                ),
              ),
              pw.SizedBox(width: 18),
              pw.Expanded(
                child: _hung(
                  PdfKit.partyBlock(
                    label: 'Billed to',
                    party: document.recipient,
                    theme: theme,
                    labelStyle: label,
                  ),
                ),
              ),
              pw.SizedBox(width: 18),
              pw.Expanded(
                child: _hung(
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      for (final row in data.metaRows) ...[
                        pw.Text(row.label.toUpperCase(), style: label),
                        pw.SizedBox(height: 2),
                        pw.Text(row.value, style: theme.bodyText),
                        pw.SizedBox(height: 6),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 28),
          PdfKit.itemTable(
            data: data,
            theme: theme,
            spec: ItemTableSpec.resolve(data),
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

  /// Hangs [child] from a heavy black rule, the Swiss column head.
  static pw.Widget _hung(pw.Widget child) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _black, width: 2)),
      ),
      child: child,
    );
  }
}
