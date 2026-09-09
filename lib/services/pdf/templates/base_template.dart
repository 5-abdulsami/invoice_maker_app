import 'dart:typed_data';

import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/data/models/business.dart';
import 'package:invoicemaker/data/models/client.dart';
import 'package:invoicemaker/data/models/invoice.dart';
import 'package:pdf/widgets.dart' as pw;

/// Everything a template needs to draw one invoice.
///
/// Assembled by `PdfService` so templates never touch providers, the file
/// system or a `BuildContext`.
class InvoiceDocumentData {
  const InvoiceDocumentData({
    required this.invoice,
    required this.business,
    required this.client,
    required this.signature,
    this.businessLogo,
  });

  final Invoice invoice;
  final Business business;
  final Client client;

  /// PNG bytes of the signature; a transparent pixel when none was drawn.
  final Uint8List signature;

  /// PNG/JPEG bytes of the business logo, or null when none is set.
  final Uint8List? businessLogo;
}

/// A PDF layout. Implementations describe the page and nothing else — saving,
/// sharing, printing and emailing live in [PdfActionHandler].
abstract class BaseTemplate {
  const BaseTemplate();

  /// Which enum value selects this template.
  InvoiceTemplate get id;

  /// Human readable name, shown in the template picker.
  String get label => id.label;

  /// Builds the document for [data]. Must not perform any I/O.
  Future<pw.Document> buildDocument(InvoiceDocumentData data);
}
