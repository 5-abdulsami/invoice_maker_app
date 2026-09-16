import 'package:flutter/foundation.dart';
import 'package:invoicemaker/core/enums/formats.dart';
import 'package:invoicemaker/core/extensions/date_ext.dart';
import 'package:invoicemaker/core/utils/money.dart';
import 'package:invoicemaker/data/models/sales_document.dart';
import 'package:invoicemaker/domain/document_totals.dart';
import 'package:invoicemaker/services/pdf/pdf_fonts.dart';

/// Everything a template needs to draw one document.
///
/// Assembled by the PDF service, so a template never touches storage, a
/// controller or a `BuildContext`, and can be rendered in a test.
@immutable
class PdfRenderData {
  PdfRenderData({
    required this.document,
    required this.fonts,
    required this.moneyFormat,
    required this.dateFormat,
    this.logoBytes,
    this.signatureBytes,
  }) : totals = document.totals;

  final SalesDocument document;
  final DocumentTotals totals;
  final PdfFonts fonts;
  final MoneyFormat moneyFormat;
  final DateFormatOption dateFormat;

  /// Business logo, or null when none is set or the file has gone.
  final Uint8List? logoBytes;

  /// Drawn signature, or null when none was captured.
  final Uint8List? signatureBytes;

  bool get hasLogo => logoBytes != null;
  bool get hasSignature => signatureBytes != null;

  /// Formats an amount in the document's currency.
  String money(num value) => moneyFormat.format(value);

  /// Formats a deduction, e.g. `-$40.00`.
  String moneyNegated(num value) => moneyFormat.formatNegated(value);

  String percent(num value) => moneyFormat.percent(value);

  String date(DateTime value) => value.formatWith(dateFormat);

  /// The meta rows every template shows, in a consistent order.
  List<({String label, String value})> get metaRows => [
        (label: '${document.kind.label} No.', value: document.number),
        (label: document.kind.issueDateLabel, value: date(document.issueDate)),
        (label: document.kind.endDateLabel, value: date(document.endDate)),
        if (document.reference.trim().isNotEmpty)
          (label: 'Reference', value: document.reference.trim()),
      ];

  /// Whether a "paid" marker should be printed.
  bool get isSettledInvoice => document.isInvoice && totals.balanceDue <= 0 && totals.total > 0;

  /// The single line a template prints to state what is still owed.
  String get balanceLabel =>
      document.isInvoice ? 'Balance due' : 'Estimate total';

  double get balanceValue =>
      document.isInvoice ? totals.balanceDue : totals.total;
}
