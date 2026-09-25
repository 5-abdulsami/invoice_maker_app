import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_art.dart';
import 'package:invoicemaker/services/pdf/pdf_fonts.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// A white till-receipt strip with torn edges on a grey desk, everything
/// centred and set in monospace, closed off with a barcode-style mark.
class ReceiptTemplate extends PdfTemplate {
  const ReceiptTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.receipt;

  @override
  PdfTypeface get typeface => PdfTypeface.mono;

  static const double _strip = 410;
  static const double _edge = 26;
  static const double _tooth = 10;
  static const _desk = PdfColor.fromInt(0xFFECEEF1);

  static double get _side => (kPageWidth - _strip) / 2 + 28;

  @override
  pw.Document build(PdfRenderData data) {
    final theme = PdfDocTheme.accented(
      fonts: data.fonts,
      accent: const PdfColor.fromInt(0xFF1F2328),
      accentSoft: const PdfColor.fromInt(0xFFF3F4F6),
      ink: const PdfColor.fromInt(0xFF1F2328),
      body: const PdfColor.fromInt(0xFF3B4048),
      muted: const PdfColor.fromInt(0xFF6E7781),
      hairline: const PdfColor.fromInt(0xFFC9CED6),
    );
    final document = data.document;
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfKit.pageTheme(
          theme,
          margin: pw.EdgeInsets.fromLTRB(_side, _edge + 30, _side, _edge + 24),
          background: (_) => pageArt(_paper),
        ),
        footer: (context) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 10),
          child: PdfKit.centered(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            theme.footerText,
          ),
        ),
        build: (context) => [
          if (data.hasLogo) ...[
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [PdfKit.logo(data, size: 42)],
            ),
            pw.SizedBox(height: 10),
          ],
          pw.SizedBox(
            width: double.infinity,
            child: PdfKit.partyBlock(
              label: '',
              showLabel: false,
              party: document.issuer,
              theme: theme,
              align: pw.CrossAxisAlignment.center,
              nameStyle: theme.styled(
                font: theme.fonts.bold,
                size: 17,
                letterSpacing: 2,
              ),
              textStyle: theme.caption.copyWith(color: theme.body),
            ),
          ),
          pw.SizedBox(height: 14),
          PdfKit.dashedRule(theme.muted),
          pw.SizedBox(height: 12),
          PdfKit.centered(
            '*  ${document.displayTitle}  *',
            theme.styled(font: theme.fonts.bold, size: 13, letterSpacing: 3),
          ),
          pw.SizedBox(height: 12),
          for (final row in data.metaRows)
            _keyValue(row.label, row.value, theme),
          pw.SizedBox(height: 10),
          PdfKit.dashedRule(theme.muted),
          pw.SizedBox(height: 12),
          PdfKit.partyBlock(
            label: 'Billed to',
            party: document.recipient,
            theme: theme,
          ),
          pw.SizedBox(height: 14),
          PdfKit.itemTable(
            data: data,
            theme: theme,
            spec: ItemTableSpec.resolve(data, showDescriptions: false),
            style: TableStyle.dashed,
          ),
          pw.SizedBox(height: 10),
          PdfKit.totalsRows(
            data: data,
            theme: theme,
            finish: TotalFinish.doubleRule,
          ),
          if (data.isSettledInvoice) ...[
            pw.SizedBox(height: 12),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [PdfKit.paidMarker(data, theme)],
            ),
          ],
          if (PdfKit.hasClosing(data)) ...[
            pw.SizedBox(height: 14),
            PdfKit.dashedRule(theme.muted),
            pw.SizedBox(height: 12),
            PdfKit.closingBlocks(data: data, theme: theme),
          ],
          if (data.hasSignature) ...[
            pw.SizedBox(height: 16),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [PdfKit.signatureBlock(data: data, theme: theme)],
            ),
          ],
          pw.SizedBox(height: 18),
          PdfKit.centered(
            'THANK YOU',
            theme.styled(
              font: theme.fonts.bold,
              size: 10,
              color: theme.muted,
              letterSpacing: 4,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [_barcode(document.number, theme)],
          ),
        ],
      ),
    );

    return pdf;
  }

  /// The grey desk, and the white strip with a saw-tooth tear at each end.
  static void _paper(ArtCanvas art) {
    final left = (art.width - _strip) / 2;
    final bottom = art.height - _edge;
    art
      ..rect(0, 0, art.width, art.height, _desk)
      ..rect(left, _edge, _strip, bottom - _edge, PdfColors.white);

    for (var x = left; x < left + _strip - 0.1; x += _tooth) {
      art
        ..polygon(
          [(x, _edge), (x + _tooth / 2, _edge - 5), (x + _tooth, _edge)],
          PdfColors.white,
        )
        ..polygon(
          [(x, bottom), (x + _tooth / 2, bottom + 5), (x + _tooth, bottom)],
          PdfColors.white,
        );
    }
  }

  static pw.Widget _keyValue(String label, String value, PdfDocTheme theme) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
      child: pw.Row(
        children: [
          pw.Text(label, style: theme.bodyText.copyWith(color: theme.muted)),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Text(
              value,
              style: theme.bodyStrong,
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  /// A decorative barcode derived from the document number, so each receipt
  /// carries its own pattern. It is ornament, not a scannable code.
  static pw.Widget _barcode(String seed, PdfDocTheme theme) {
    const width = 170.0;
    const height = 26.0;
    final codes = seed.codeUnits.isEmpty ? [7] : seed.codeUnits;

    return pageArtSized(width, height, (art) {
      var x = 0.0;
      var i = 0;
      while (x < width) {
        final code = codes[i % codes.length] + i * 7;
        final bar = 0.8 + (code % 3) * 0.9;
        final gap = 1.2 + (code % 2) * 1.1;
        if (x + bar > width) break;
        art.rect(x, 0, bar, height, theme.ink);
        x += bar + gap;
        i++;
      }
    });
  }
}
