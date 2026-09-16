import 'package:flutter/foundation.dart';
import 'package:invoicemaker/core/enums/formats.dart';
import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/core/enums/pdf_action.dart';
import 'package:invoicemaker/core/exceptions/app_exception.dart';
import 'package:invoicemaker/core/utils/money.dart';
import 'package:invoicemaker/data/models/sales_document.dart';
import 'package:invoicemaker/services/file_vault.dart';
import 'package:invoicemaker/services/pdf/pdf_fonts.dart';
import 'package:invoicemaker/services/pdf/pdf_output.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_template_registry.dart';

/// Turns a document into a PDF and does something with it.
///
/// The only entry point the UI needs. It gathers the inputs, picks the
/// layout and delegates the side effects, so no screen knows how a PDF is
/// built and no template performs I/O.
class DocumentPdfService {
  const DocumentPdfService({
    required FileVault? vault,
    PdfOutput output = const PdfOutput(),
  })  : _vault = vault,
        _output = output;

  final FileVault? _vault;
  final PdfOutput _output;

  /// Renders [document] and runs [action] on the result.
  ///
  /// Returns PNG bytes for [PdfAction.preview] and null otherwise. Throws an
  /// [AppException] whose message is safe to show the user.
  ///
  /// The images come from the paths stored on the document, not from the
  /// current business profile, so reprinting an old invoice reproduces the
  /// logo and signature it was issued with.
  Future<Uint8List?> execute({
    required SalesDocument document,
    required PdfAction action,
    required NumberGroupingOption grouping,
    required DateFormatOption dateFormat,
    InvoiceTemplate? templateOverride,
  }) async {
    final fonts = await PdfFonts.load();

    final data = PdfRenderData(
      document: document,
      fonts: fonts,
      // Built from the document's own currency so a document billed in one
      // currency never prints another's symbol.
      moneyFormat: MoneyFormat(
        currency: document.currency,
        grouping: grouping,
      ),
      dateFormat: dateFormat,
      logoBytes: await _vault?.readBytes(document.issuerLogoPath),
      signatureBytes: await _vault?.readBytes(document.signaturePath),
    );

    final template = PdfTemplateRegistry.resolve(
      templateOverride ?? document.template,
    );

    final pdf = _guard(() => template.build(data));

    return _output.run(
      document: pdf,
      fileName: _fileName(document),
      action: action,
    );
  }

  /// e.g. `INV-0007 Acme Ltd`, so a shared file is recognisable.
  static String _fileName(SalesDocument document) {
    final recipient = document.recipient.name.trim();
    return recipient.isEmpty
        ? document.number
        : '${document.number} $recipient';
  }

  T _guard<T>(T Function() action) {
    try {
      return action();
    } on AppException {
      rethrow;
    } on Object catch (error) {
      throw PdfGenerationException(error);
    }
  }
}
