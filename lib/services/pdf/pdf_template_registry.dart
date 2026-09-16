import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/templates/banner_template.dart';
import 'package:invoicemaker/services/pdf/templates/column_template.dart';
import 'package:invoicemaker/services/pdf/templates/compact_template.dart';
import 'package:invoicemaker/services/pdf/templates/editorial_template.dart';
import 'package:invoicemaker/services/pdf/templates/grid_template.dart';
import 'package:invoicemaker/services/pdf/templates/ledger_template.dart';
import 'package:invoicemaker/services/pdf/templates/slate_template.dart';
import 'package:invoicemaker/services/pdf/templates/statement_template.dart';

/// Maps a chosen template to the layout that draws it.
sealed class PdfTemplateRegistry {
  static const Map<InvoiceTemplate, PdfTemplate> _templates = {
    InvoiceTemplate.slate: SlateTemplate(),
    InvoiceTemplate.ledger: LedgerTemplate(),
    InvoiceTemplate.banner: BannerTemplate(),
    InvoiceTemplate.compact: CompactTemplate(),
    InvoiceTemplate.statement: StatementTemplate(),
    InvoiceTemplate.column: ColumnTemplate(),
    InvoiceTemplate.editorial: EditorialTemplate(),
    InvoiceTemplate.grid: GridTemplate(),
  };

  /// Every layout, in picker order.
  static List<PdfTemplate> get all =>
      InvoiceTemplate.values.map(resolve).toList(growable: false);

  /// The layout for [template], falling back to the default.
  static PdfTemplate resolve(InvoiceTemplate template) =>
      _templates[template] ?? const SlateTemplate();
}
