import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_fonts.dart';
import 'package:invoicemaker/services/pdf/pdf_kit.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Company stationery: the business name is centred at the head under its
/// logo, and its contact details run along the foot of every page, the way
/// printed letterhead carries them.
class LetterheadTemplate extends PdfTemplate {
  const LetterheadTemplate();

  @override
  InvoiceTemplate get id => InvoiceTemplate.letterhead;

  @override
  PdfTypeface get typeface => PdfTypeface.humanist;

  static const _navy = PdfColor.fromInt(0xFF1E3A5F);

  @override
  pw.Document build(PdfRenderData data) {
    final theme = PdfDocTheme.accented(
      fonts: data.fonts,
      accent: _navy,
      accentSoft: const PdfColor.fromInt(0xFFE9EEF4),
    );
    final document = data.document;
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfKit.pageTheme(
          theme,
          margin: const pw.EdgeInsets.fromLTRB(44, 40, 44, 28),
        ),
        footer: (context) => _footer(context, data, theme),
        build: (context) => [
          if (data.hasLogo) ...[
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [PdfKit.logo(data, size: 46)],
            ),
            pw.SizedBox(height: 10),
          ],
          PdfKit.centered(
            document.issuer.name.trim().toUpperCase(),
            theme.styled(
              font: theme.fonts.bold,
              size: 17,
              color: _navy,
              letterSpacing: 4,
            ),
          ),
          pw.SizedBox(height: 14),
          pw.Container(height: 1.2, color: _navy),
          pw.SizedBox(height: 2),
          pw.Container(height: 0.4, color: _navy),
          pw.SizedBox(height: 22),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      document.displayTitle,
                      style: theme.displayTitle.copyWith(
                        color: _navy,
                        fontSize: 20,
                        letterSpacing: 3,
                      ),
                    ),
                    pw.SizedBox(height: 14),
                    PdfKit.partyBlock(
                      label: 'Billed to',
                      party: document.recipient,
                      theme: theme,
                    ),
                  ],
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
          ),
          pw.SizedBox(height: 16),
          PdfKit.summary(data, theme),
          pw.SizedBox(height: 26),
          PdfKit.closing(data, theme),
        ],
      ),
    );

    return pdf;
  }

  static pw.Widget _footer(
    pw.Context context,
    PdfRenderData data,
    PdfDocTheme theme,
  ) {
    final contact = PdfKit.contactLine(data.document.issuer);

    return pw.Column(
      children: [
        pw.Container(height: 0.6, color: _navy),
        pw.SizedBox(height: 7),
        if (contact.isNotEmpty) ...[
          PdfKit.centered(contact, theme.caption.copyWith(color: _navy)),
          pw.SizedBox(height: 3),
        ],
        PdfKit.centered(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          theme.footerText,
        ),
      ],
    );
  }
}
