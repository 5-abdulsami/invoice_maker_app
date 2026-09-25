import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_art.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Engineering graph paper in pale blue, with the document laid out in
/// white panels like the title block of a technical drawing.
class BlueprintTemplate extends PdfTemplate {
  const BlueprintTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.blueprint;

  static const _blue = PdfColor.fromInt(0xFF1D4E89);
  static const _paper = PdfColor.fromInt(0xFFF5F9FE);
  static const _minor = PdfColor.fromInt(0xFFE0EBF7);
  static const _major = PdfColor.fromInt(0xFFC6D9EF);

  @override
  pw.Document build(PdfRenderData data) {
    final theme = PdfDocTheme.accented(
      fonts: data.fonts,
      accent: _blue,
      accentSoft: const PdfColor.fromInt(0xFFE3EDF9),
      ink: const PdfColor.fromInt(0xFF12294A),
      body: const PdfColor.fromInt(0xFF2F4668),
      muted: const PdfColor.fromInt(0xFF6A7F9C),
      hairline: const PdfColor.fromInt(0xFFA9C1DE),
    );
    final label = theme.styled(
      font: theme.fonts.narrowBold,
      size: 7.5,
      color: _blue,
      letterSpacing: 1.4,
    );
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfKit.pageTheme(
          theme,
          background: (_) => pageArt(
            (art) => art
              ..rect(0, 0, art.width, art.height, _paper)
              ..grid(
                0,
                0,
                art.width,
                art.height,
                cell: 12,
                minor: _minor,
                major: _major,
              ),
          ),
        ),
        footer: (context) => _panel(
          PdfKit.pageFooter(context, data, theme),
          padding: const pw.EdgeInsets.fromLTRB(10, 0, 10, 6),
          bordered: false,
        ),
        build: (context) => [
          _titleBlock(data, theme, label),
          pw.SizedBox(height: 14),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _panel(
                  PdfKit.partyBlock(
                    label: 'Billed to',
                    party: data.document.recipient,
                    theme: theme,
                    labelStyle: label,
                  ),
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: _panel(
                  PdfKit.partyBlock(
                    label: 'From',
                    party: data.document.issuer,
                    theme: theme,
                    labelStyle: label,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          PdfKit.itemTable(
            data: data,
            theme: theme,
            spec: ItemTableSpec.resolve(data, showIndex: true),
            style: TableStyle.fullGrid,
            rowFill: PdfColors.white,
          ),
          pw.SizedBox(height: 14),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (data.isSettledInvoice) _panel(PdfKit.paidMarker(data, theme)),
              pw.Spacer(),
              pw.SizedBox(
                width: 262,
                child: _panel(
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
            pw.SizedBox(height: 14),
            _panel(PdfKit.closing(data, theme)),
          ],
        ],
      ),
    );

    return pdf;
  }

  /// A white panel ruled in blue, lifting text off the grid.
  static pw.Widget _panel(
    pw.Widget child, {
    pw.EdgeInsets padding = const pw.EdgeInsets.all(10),
    bool bordered = true,
  }) {
    return pw.Container(
      padding: padding,
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: bordered ? pw.Border.all(color: _blue, width: 0.8) : null,
      ),
      child: child,
    );
  }

  /// The drawing's title block: title and logo, then one cell per meta row.
  pw.Widget _titleBlock(
    PdfRenderData data,
    PdfDocTheme theme,
    pw.TextStyle label,
  ) {
    final rows = data.metaRows;
    final border = pw.TableBorder.all(color: _blue, width: 0.8);
    const cellPadding = pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8);
    const white = pw.BoxDecoration(color: PdfColors.white);

    return pw.Column(
      children: [
        pw.Table(
          border: border,
          columnWidths: const {
            0: pw.FlexColumnWidth(3),
            1: pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: white,
              verticalAlignment: pw.TableCellVerticalAlignment.middle,
              children: [
                pw.Padding(
                  padding: cellPadding,
                  child: pw.Row(
                    children: [
                      if (data.hasLogo) ...[
                        PdfKit.logo(data, size: 36),
                        pw.SizedBox(width: 10),
                      ],
                      pw.Expanded(
                        child: pw.Text(
                          data.document.displayTitle,
                          style: theme.displayTitle.copyWith(
                            color: _blue,
                            fontSize: 24,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Padding(
                  padding: cellPadding,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('ISSUED BY', style: label),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        data.document.issuer.name.trim(),
                        style: theme.partyName,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        // Shares the outer border with the table above.
        pw.Table(
          border: pw.TableBorder(
            left: border.left,
            right: border.right,
            bottom: border.bottom,
            verticalInside: border.verticalInside,
          ),
          children: [
            pw.TableRow(
              decoration: white,
              children: [
                for (final row in rows)
                  pw.Padding(
                    padding: cellPadding,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(row.label.toUpperCase(), style: label),
                        pw.SizedBox(height: 4),
                        pw.Text(row.value, style: theme.bodyStrong),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
