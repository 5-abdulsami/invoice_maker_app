import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/pdf_template.dart';
import 'package:invoicemaker/services/pdf/templates/angles_template.dart';
import 'package:invoicemaker/services/pdf/templates/arrow_template.dart';
import 'package:invoicemaker/services/pdf/templates/aurora_template.dart';
import 'package:invoicemaker/services/pdf/templates/banner_template.dart';
import 'package:invoicemaker/services/pdf/templates/blueprint_template.dart';
import 'package:invoicemaker/services/pdf/templates/cards_template.dart';
import 'package:invoicemaker/services/pdf/templates/column_template.dart';
import 'package:invoicemaker/services/pdf/templates/compact_template.dart';
import 'package:invoicemaker/services/pdf/templates/duo_template.dart';
import 'package:invoicemaker/services/pdf/templates/editorial_template.dart';
import 'package:invoicemaker/services/pdf/templates/frame_template.dart';
import 'package:invoicemaker/services/pdf/templates/grid_template.dart';
import 'package:invoicemaker/services/pdf/templates/halftone_template.dart';
import 'package:invoicemaker/services/pdf/templates/ledger_template.dart';
import 'package:invoicemaker/services/pdf/templates/letterhead_template.dart';
import 'package:invoicemaker/services/pdf/templates/luxe_template.dart';
import 'package:invoicemaker/services/pdf/templates/midnight_template.dart';
import 'package:invoicemaker/services/pdf/templates/monogram_template.dart';
import 'package:invoicemaker/services/pdf/templates/orbit_template.dart';
import 'package:invoicemaker/services/pdf/templates/pinstripe_template.dart';
import 'package:invoicemaker/services/pdf/templates/poster_template.dart';
import 'package:invoicemaker/services/pdf/templates/receipt_template.dart';
import 'package:invoicemaker/services/pdf/templates/ribbon_template.dart';
import 'package:invoicemaker/services/pdf/templates/sage_template.dart';
import 'package:invoicemaker/services/pdf/templates/sheet_template.dart';
import 'package:invoicemaker/services/pdf/templates/slate_template.dart';
import 'package:invoicemaker/services/pdf/templates/spine_template.dart';
import 'package:invoicemaker/services/pdf/templates/statement_template.dart';
import 'package:invoicemaker/services/pdf/templates/swiss_template.dart';
import 'package:invoicemaker/services/pdf/templates/tide_template.dart';

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
    InvoiceTemplate.aurora: AuroraTemplate(),
    InvoiceTemplate.receipt: ReceiptTemplate(),
    InvoiceTemplate.angles: AnglesTemplate(),
    InvoiceTemplate.tide: TideTemplate(),
    InvoiceTemplate.sage: SageTemplate(),
    InvoiceTemplate.cards: CardsTemplate(),
    InvoiceTemplate.duo: DuoTemplate(),
    InvoiceTemplate.letterhead: LetterheadTemplate(),
    InvoiceTemplate.monogram: MonogramTemplate(),
    InvoiceTemplate.blueprint: BlueprintTemplate(),
    InvoiceTemplate.spine: SpineTemplate(),
    InvoiceTemplate.swiss: SwissTemplate(),
    InvoiceTemplate.luxe: LuxeTemplate(),
    InvoiceTemplate.poster: PosterTemplate(),
    InvoiceTemplate.ribbon: RibbonTemplate(),
    InvoiceTemplate.halftone: HalftoneTemplate(),
    InvoiceTemplate.pinstripe: PinstripeTemplate(),
    InvoiceTemplate.sheet: SheetTemplate(),
    InvoiceTemplate.midnight: MidnightTemplate(),
    InvoiceTemplate.frame: FrameTemplate(),
    InvoiceTemplate.orbit: OrbitTemplate(),
    InvoiceTemplate.arrow: ArrowTemplate(),
  };

  /// Every layout, in picker order.
  static List<PdfTemplate> get all =>
      InvoiceTemplate.values.map(resolve).toList(growable: false);

  /// The layout for [template], falling back to the default.
  static PdfTemplate resolve(InvoiceTemplate template) =>
      _templates[template] ?? const SlateTemplate();
}
