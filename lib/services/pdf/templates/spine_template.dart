import 'dart:math' as math;

import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_art.dart';
import 'package:invoicemaker/services/pdf/pdf_fonts.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// A charcoal spine runs the full height of every page with the title set
/// up it in tall condensed capitals, like the spine of a bound report.
class SpineTemplate extends PdfTemplate {
  const SpineTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.spine;

  @override
  PdfTypeface get typeface => PdfTypeface.poster;

  static const _charcoal = PdfColor.fromInt(0xFF1C1F26);
  static const _amber = PdfColor.fromInt(0xFFF59E0B);
  static const _amberInk = PdfColor.fromInt(0xFFB45309);
  static const _spineText = PdfColor.fromInt(0xFF3A404C);

  static const double _spine = 72;

  @override
  pw.Document build(PdfRenderData data) {
    final theme = PdfDocTheme.accented(
      fonts: data.fonts,
      accent: _amberInk,
      accentSoft: const PdfColor.fromInt(0xFFFEF3C7),
    );
    final document = data.document;
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfKit.pageTheme(
          theme,
          margin: const pw.EdgeInsets.fromLTRB(_spine + 32, 36, 36, 30),
          background: (_) => _spineArt(document.displayTitle, theme),
        ),
        footer: (context) => PdfKit.pageFooter(context, data, theme),
        build: (context) => [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: PdfKit.partyBlock(
                  label: '',
                  showLabel: false,
                  party: document.issuer,
                  theme: theme,
                  nameStyle: theme.displayTitle.copyWith(
                    fontSize: 24,
                    letterSpacing: 1,
                  ),
                  textStyle: theme.caption.copyWith(color: theme.body),
                ),
              ),
              if (data.hasLogo) ...[
                pw.SizedBox(width: 16),
                PdfKit.logo(data, size: 50),
              ],
            ],
          ),
          pw.SizedBox(height: 24),
          PdfKit.metaStrip(
            data.metaRows,
            theme,
            topRuleColor: _amber,
            topRuleWidth: 2.5,
          ),
          pw.SizedBox(height: 26),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: PdfKit.partyBlock(
                  label: 'Billed to',
                  party: document.recipient,
                  theme: theme,
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  PdfKit.sectionLabel(data.balanceLabel, theme),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    data.money(data.balanceValue),
                    style: theme.displayTitle.copyWith(
                      color: _amberInk,
                      fontSize: 26,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 24),
          PdfKit.itemTable(
            data: data,
            theme: theme,
            spec: ItemTableSpec.resolve(data),
            style: TableStyle.headerBand,
            headerFill: _charcoal,
            headerText: PdfColors.white,
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

  static pw.Widget _spineArt(String title, PdfDocTheme theme) {
    return pw.Stack(
      children: [
        pw.Positioned(
          left: 0,
          top: 0,
          child: pw.Container(
            width: _spine,
            height: kPageHeight,
            color: _charcoal,
            child: pw.Column(
              children: [
                pw.SizedBox(height: 36),
                pw.Container(width: 16, height: 16, color: _amber),
                pw.Expanded(
                  child: pw.Center(
                    child: pw.Transform.rotateBox(
                      angle: math.pi / 2,
                      // Laid out before rotating, so the title must not be
                      // squeezed to the spine's width.
                      unconstrained: true,
                      child: pw.Text(
                        title,
                        style: theme.displayTitle.copyWith(
                          color: _spineText,
                          fontSize: 54,
                          letterSpacing: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
