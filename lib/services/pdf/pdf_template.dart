import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_fonts.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:pdf/widgets.dart' as pw;

/// One page layout.
///
/// Implementations describe the page and nothing else: saving, sharing and
/// printing live in `PdfOutput`, and the arithmetic lives in
/// `DocumentTotals`, so a template cannot disagree with the app about a total.
abstract class PdfTemplate {
  const PdfTemplate();

  /// Which enum value selects this layout.
  InvoiceTemplate get id;

  String get label => id.label;

  /// The type family this layout is set in; its fonts arrive in the render
  /// data, loaded before [build] runs.
  PdfTypeface get typeface => PdfTypeface.standard;

  /// Builds the document. Must not perform I/O.
  pw.Document build(PdfRenderData data);
}
