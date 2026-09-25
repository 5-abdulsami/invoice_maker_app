import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_fonts.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// App-like and friendly: each section sits on its own rounded grey card,
/// and the title is a violet pill.
class CardsTemplate extends PdfTemplate {
  const CardsTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.cards;

  @override
  PdfTypeface get typeface => PdfTypeface.rounded;

  static const _violet = PdfColor.fromInt(0xFF6D28D9);
  static const _card = PdfColor.fromInt(0xFFF4F3F8);

  @override
  pw.Document build(PdfRenderData data) {
    final theme = PdfDocTheme.accented(
      fonts: data.fonts,
      accent: _violet,
      accentSoft: const PdfColor.fromInt(0xFFF1EBFE),
      ink: const PdfColor.fromInt(0xFF1E1B2E),
      body: const PdfColor.fromInt(0xFF45425A),
      muted: const PdfColor.fromInt(0xFF7C7891),
      hairline: const PdfColor.fromInt(0xFFE4E1EE),
    );
    final labelStyle = theme.sectionLabel.copyWith(color: _violet);
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfKit.pageTheme(theme),
        footer: (context) => PdfKit.pageFooter(context, data, theme),
        build: (context) => [
          _heading(data, theme),
          pw.SizedBox(height: 22),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _cardBox(
                  PdfKit.partyBlock(
                    label: 'Billed to',
                    party: data.document.recipient,
                    theme: theme,
                    labelStyle: labelStyle,
                  ),
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: _cardBox(
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('DETAILS', style: labelStyle),
                      pw.SizedBox(height: 6),
                      PdfKit.metaRows(
                        data.metaRows,
                        theme,
                        align: pw.CrossAxisAlignment.start,
                        labelWidth: 70,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 22),
          PdfKit.itemTable(
            data: data,
            theme: theme,
            spec: ItemTableSpec.resolve(data),
            style: TableStyle.softHeader,
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (data.isSettledInvoice) PdfKit.paidMarker(data, theme),
              pw.Spacer(),
              pw.SizedBox(
                width: 262,
                child: _cardBox(
                  PdfKit.totalsRows(
                    data: data,
                    theme: theme,
                    finish: TotalFinish.accentBar,
                  ),
                ),
              ),
            ],
          ),
          if (PdfKit.hasClosing(data) || data.hasSignature) ...[
            pw.SizedBox(height: 18),
            _cardBox(PdfKit.closing(data, theme)),
          ],
        ],
      ),
    );

    return pdf;
  }

  static pw.Widget _cardBox(pw.Widget child) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _card,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  pw.Widget _heading(PdfRenderData data, PdfDocTheme theme) {
    final document = data.document;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (data.hasLogo) ...[
          pw.ClipRRect(
            horizontalRadius: 10,
            verticalRadius: 10,
            child: PdfKit.logo(data, size: 50, fit: pw.BoxFit.cover),
          ),
          pw.SizedBox(width: 14),
        ],
        pw.Expanded(
          child: PdfKit.partyBlock(
            label: '',
            showLabel: false,
            party: document.issuer,
            theme: theme,
            nameStyle: theme.partyName.copyWith(fontSize: 15),
            textStyle: theme.caption.copyWith(color: theme.body),
          ),
        ),
        pw.SizedBox(width: 20),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 7,
              ),
              decoration: pw.BoxDecoration(
                color: _violet,
                borderRadius: pw.BorderRadius.circular(13),
              ),
              child: pw.Text(
                document.displayTitle,
                style: theme.styled(
                  font: theme.fonts.bold,
                  size: 12,
                  color: PdfColors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(document.number, style: theme.bodyStrong),
          ],
        ),
      ],
    );
  }
}
