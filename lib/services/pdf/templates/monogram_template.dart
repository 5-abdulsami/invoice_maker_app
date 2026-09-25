import 'dart:math' as math;

import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_fonts.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Symmetrical and formal: a navy seal carrying the issuer's initials, gold
/// rules with a diamond, and a display-serif title, like fine stationery.
class MonogramTemplate extends PdfTemplate {
  const MonogramTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.monogram;

  @override
  PdfTypeface get typeface => PdfTypeface.elegant;

  static const _navy = PdfColor.fromInt(0xFF1F2A44);
  static const _gold = PdfColor.fromInt(0xFFA8834A);
  static const _cream = PdfColor.fromInt(0xFFF6F1E7);

  @override
  pw.Document build(PdfRenderData data) {
    final theme = PdfDocTheme.accented(
      fonts: data.fonts,
      accent: _navy,
      accentSoft: _cream,
      ink: const PdfColor.fromInt(0xFF1B2236),
      hairline: const PdfColor.fromInt(0xFFE3DCCD),
    );
    final document = data.document;
    final contact = PdfKit.contactLine(document.issuer);
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfKit.pageTheme(
          theme,
          margin: const pw.EdgeInsets.fromLTRB(44, 36, 44, 30),
        ),
        footer: (context) => PdfKit.pageFooter(context, data, theme),
        build: (context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [_seal(data, theme)],
          ),
          pw.SizedBox(height: 10),
          PdfKit.centered(
            document.issuer.name.trim().toUpperCase(),
            theme.styled(
              font: theme.fonts.bold,
              size: 12,
              color: _navy,
              letterSpacing: 3,
            ),
          ),
          if (contact.isNotEmpty) ...[
            pw.SizedBox(height: 5),
            PdfKit.centered(contact, theme.caption),
          ],
          pw.SizedBox(height: 16),
          _ornament(),
          pw.SizedBox(height: 14),
          PdfKit.centered(
            document.displayTitle,
            theme.displayTitle.copyWith(
              color: _navy,
              fontSize: 30,
              letterSpacing: 2,
            ),
          ),
          pw.SizedBox(height: 14),
          PdfKit.metaStrip(
            data.metaRows,
            theme,
            labelColor: _gold,
            dividerColor: _gold,
            centered: true,
          ),
          pw.SizedBox(height: 24),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: PdfKit.partyBlock(
                  label: 'Billed to',
                  party: document.recipient,
                  theme: theme,
                  labelStyle: theme.sectionLabel.copyWith(color: _gold),
                ),
              ),
              pw.SizedBox(width: 24),
              _amountDue(data, theme),
            ],
          ),
          pw.SizedBox(height: 24),
          PdfKit.itemTable(
            data: data,
            theme: theme,
            spec: ItemTableSpec.resolve(data),
            style: TableStyle.underlineHeader,
          ),
          pw.SizedBox(height: 16),
          PdfKit.summary(data, theme, finish: TotalFinish.doubleRule),
          pw.SizedBox(height: 24),
          PdfKit.closing(data, theme),
        ],
      ),
    );

    return pdf;
  }

  pw.Widget _seal(PdfRenderData data, PdfDocTheme theme) {
    return pw.Container(
      width: 58,
      height: 58,
      alignment: pw.Alignment.center,
      decoration: pw.BoxDecoration(
        color: _navy,
        shape: pw.BoxShape.circle,
        border: pw.Border.all(color: _gold, width: 1.6),
      ),
      child: pw.Text(
        PdfKit.initials(data.document.issuer.name),
        style: theme.displayTitle.copyWith(
          color: PdfColors.white,
          fontSize: 21,
          letterSpacing: 1,
        ),
      ),
    );
  }

  /// A gold hairline broken by a small diamond.
  pw.Widget _ornament() {
    return pw.Row(
      children: [
        pw.Expanded(child: pw.Container(height: 0.6, color: _gold)),
        pw.SizedBox(width: 8),
        pw.Transform.rotateBox(
          angle: math.pi / 4,
          child: pw.Container(width: 6, height: 6, color: _gold),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(child: pw.Container(height: 0.6, color: _gold)),
      ],
    );
  }

  pw.Widget _amountDue(PdfRenderData data, PdfDocTheme theme) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: pw.BoxDecoration(
        color: _cream,
        border: pw.Border.all(color: _gold, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(
            data.balanceLabel.toUpperCase(),
            style: theme.sectionLabel.copyWith(color: _gold),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            data.money(data.balanceValue),
            style: theme.heroAmount.copyWith(color: _navy, fontSize: 20),
          ),
        ],
      ),
    );
  }
}
