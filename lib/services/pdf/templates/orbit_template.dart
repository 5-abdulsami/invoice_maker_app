import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_art.dart';
import 'package:invoicemaker/services/pdf/pdf_fonts.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Overlapping plum and rose circles drift off the top-right corner, with a
/// pale echo in the bottom-left; soft, modern and a little playful.
class OrbitTemplate extends PdfTemplate {
  const OrbitTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.orbit;

  @override
  PdfTypeface get typeface => PdfTypeface.rounded;

  static const _plum = PdfColor.fromInt(0xFF6B2D5C);
  static const _rose = PdfColor.fromInt(0xFFE8839F);
  static const _blush = PdfColor.fromInt(0xFFF8D7E1);
  static const _mist = PdfColor.fromInt(0xFFFBEFF4);
  static const _roseInk = PdfColor.fromInt(0xFFB4476A);

  @override
  pw.Document build(PdfRenderData data) {
    final theme = PdfDocTheme.accented(
      fonts: data.fonts,
      accent: _plum,
      accentSoft: _mist,
      ink: const PdfColor.fromInt(0xFF2A1426),
      hairline: const PdfColor.fromInt(0xFFEFDFE7),
    );
    final document = data.document;
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfKit.pageTheme(
          theme,
          background: (context) =>
              pageArt((art) => _circles(art, context.pageNumber == 1)),
        ),
        // Drops continued pages below the smaller corner circles.
        header: (context) =>
            context.pageNumber == 1 ? pw.SizedBox() : pw.SizedBox(height: 30),
        footer: (context) => PdfKit.pageFooter(context, data, theme),
        build: (context) => [
          pw.SizedBox(
            // Keeps the heading clear of the circles.
            width: 320,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    if (data.hasLogo) ...[
                      PdfKit.logo(data, size: 44),
                      pw.SizedBox(width: 12),
                    ],
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            document.displayTitle,
                            style: theme.displayTitle.copyWith(
                              color: _plum,
                              fontSize: 32,
                              letterSpacing: 1.5,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            document.number,
                            style: theme.bodyStrong.copyWith(color: _roseInk),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                PdfKit.partyBlock(
                  label: '',
                  showLabel: false,
                  party: document.issuer,
                  theme: theme,
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 26),
          PdfKit.metaStrip(
            data.metaRows,
            theme,
            labelColor: _roseInk,
            dividerColor: _blush,
          ),
          pw.SizedBox(height: 24),
          PdfKit.partyBlock(
            label: 'Billed to',
            party: document.recipient,
            theme: theme,
            labelStyle: theme.sectionLabel.copyWith(color: _roseInk),
          ),
          pw.SizedBox(height: 24),
          PdfKit.itemTable(
            data: data,
            theme: theme,
            spec: ItemTableSpec.resolve(data),
            style: TableStyle.softHeader,
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

  static void _circles(ArtCanvas art, bool firstPage) {
    final w = art.width;
    if (firstPage) {
      art
        ..circle(w - 30, 30, 130, _plum)
        ..circle(w - 168, -18, 84, _rose)
        ..circle(w - 118, 128, 30, _blush);
    } else {
      art
        ..circle(w - 12, 8, 52, _plum)
        ..circle(w - 72, -8, 30, _rose);
    }
    // Pale enough that the footer reads clearly across it.
    art.circle(12, art.height - 8, 70, _mist);
  }
}
