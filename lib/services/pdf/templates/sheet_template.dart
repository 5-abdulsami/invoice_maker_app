import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/data/models/party_snapshot.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Laid out like a spreadsheet: a formula bar states the amount due, the
/// details sit in labelled cells, and the items fill a numbered grid.
class SheetTemplate extends PdfTemplate {
  const SheetTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.sheet;

  static const _green = PdfColor.fromInt(0xFF217346);
  static const _grid = PdfColor.fromInt(0xFFD0D7DE);
  static const _cellGrey = PdfColor.fromInt(0xFFF3F4F6);

  static const _cellPadding = pw.EdgeInsets.symmetric(
    horizontal: 7,
    vertical: 5,
  );

  @override
  pw.Document build(PdfRenderData data) {
    final theme = PdfDocTheme.accented(
      fonts: data.fonts,
      accent: _green,
      accentSoft: const PdfColor.fromInt(0xFFE8F3EC),
      ink: const PdfColor.fromInt(0xFF1F2328),
      hairline: _grid,
    );
    final document = data.document;
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfKit.pageTheme(theme),
        footer: (context) => PdfKit.pageFooter(context, data, theme),
        build: (context) => [
          pw.Row(
            children: [
              _sheetIcon(),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: document.displayTitle,
                        style: theme.partyName.copyWith(fontSize: 15),
                      ),
                      pw.TextSpan(
                        text: '   ${document.number}',
                        style: theme.bodyText.copyWith(color: theme.muted),
                      ),
                    ],
                  ),
                ),
              ),
              PdfKit.logo(data, size: 36),
            ],
          ),
          pw.SizedBox(height: 12),
          _formulaBar(data, theme),
          pw.SizedBox(height: 14),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _cells(
                  [
                    for (final row in data.metaRows)
                      (
                        row.label,
                        pw.Text(row.value, style: theme.bodyStrong),
                      ),
                  ],
                  theme,
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: _cells(
                  [
                    ('Bill to', _party(document.recipient, theme)),
                    ('From', _party(document.issuer, theme)),
                  ],
                  theme,
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
            headerFill: _cellGrey,
            headerText: theme.ink,
          ),
          pw.SizedBox(height: 14),
          PdfKit.summary(data, theme, finish: TotalFinish.accentBar),
          pw.SizedBox(height: 24),
          PdfKit.closing(data, theme),
        ],
      ),
    );

    return pdf;
  }

  /// A small green tile ruled into four cells.
  static pw.Widget _sheetIcon() {
    return pw.Container(
      width: 20,
      height: 20,
      padding: const pw.EdgeInsets.all(4),
      decoration: pw.BoxDecoration(
        color: _green,
        borderRadius: pw.BorderRadius.circular(3),
      ),
      child: pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.white, width: 0.8),
        ),
        child: pw.Column(
          children: [
            pw.Expanded(
              child: pw.Container(
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.white, width: 0.8),
                  ),
                ),
              ),
            ),
            pw.Expanded(child: pw.SizedBox()),
          ],
        ),
      ),
    );
  }

  static pw.Widget _formulaBar(PdfRenderData data, PdfDocTheme theme) {
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(color: _grid)),
      child: pw.Row(
        children: [
          pw.Container(
            padding: _cellPadding,
            decoration: const pw.BoxDecoration(
              color: _cellGrey,
              border: pw.Border(right: pw.BorderSide(color: _grid)),
            ),
            child: pw.Text(
              'fx',
              style: theme.styled(
                font: theme.fonts.italic,
                size: 9,
                color: theme.muted,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Padding(
              padding: _cellPadding,
              child: pw.Text(
                '= ${data.balanceLabel.toUpperCase()}   '
                '${data.money(data.balanceValue)}',
                style: theme.tableNumberStrong.copyWith(color: _green),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _party(PartySnapshot party, PdfDocTheme theme) {
    return PdfKit.partyBlock(
      label: '',
      showLabel: false,
      party: party,
      theme: theme,
      nameStyle: theme.bodyStrong,
    );
  }

  /// Label cells down the left, values beside them, ruled like a sheet.
  static pw.Widget _cells(
    List<(String, pw.Widget)> rows,
    PdfDocTheme theme,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: _grid, width: 0.6),
      columnWidths: const {
        0: pw.FixedColumnWidth(70),
        1: pw.FlexColumnWidth(),
      },
      children: [
        for (final (label, value) in rows)
          pw.TableRow(
            // Stretches the grey label cell to the height of its value.
            verticalAlignment: pw.TableCellVerticalAlignment.full,
            children: [
              pw.Container(
                color: _cellGrey,
                padding: _cellPadding,
                child: pw.Text(
                  label,
                  style: theme.bodyText.copyWith(color: theme.muted),
                ),
              ),
              pw.Padding(padding: _cellPadding, child: value),
            ],
          ),
      ],
    );
  }
}
