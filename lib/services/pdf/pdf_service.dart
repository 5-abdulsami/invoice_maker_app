import 'dart:io';
import 'dart:typed_data';

import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/core/enums/pdf_action.dart';
import 'package:invoicemaker/core/exceptions/app_exception.dart';
import 'package:invoicemaker/core/utils/pdf_asset_loader.dart';
import 'package:invoicemaker/data/models/business.dart';
import 'package:invoicemaker/data/models/client.dart';
import 'package:invoicemaker/data/models/invoice.dart';
import 'package:invoicemaker/services/pdf/pdf_action_handler.dart';
import 'package:invoicemaker/services/pdf/templates/base_template.dart';
import 'package:invoicemaker/services/pdf/templates/template_registry.dart';

/// Turns an [Invoice] into a PDF and runs an action on it.
///
/// This is the only entry point the UI needs: it gathers the template inputs,
/// asks the registry for the layout, and delegates the side effects to
/// [PdfActionHandler].
class PdfService {
  const PdfService({PdfActionHandler handler = const PdfActionHandler()})
      : _handler = handler;

  final PdfActionHandler _handler;

  /// Generates [invoice] with its selected template and performs [action].
  ///
  /// Returns preview image bytes for [PdfAction.preview], null otherwise.
  /// Throws an [AppException] whose message is safe to show to the user.
  Future<Uint8List?> execute({
    required Invoice invoice,
    required Business business,
    required Client client,
    required Uint8List signature,
    required PdfAction action,
    InvoiceTemplate? templateOverride,
  }) async {
    final data = await buildData(
      invoice: invoice,
      business: business,
      client: client,
      signature: signature,
    );

    final template =
        TemplateRegistry.resolve(templateOverride ?? invoice.template);

    final document = await _guard(() => template.buildDocument(data));

    return _handler.run(
      document: document,
      fileName: invoice.invoiceNumber,
      action: action,
    );
  }

  /// Collects everything a template draws with, resolving the logo bytes.
  Future<InvoiceDocumentData> buildData({
    required Invoice invoice,
    required Business business,
    required Client client,
    required Uint8List signature,
  }) async {
    return InvoiceDocumentData(
      invoice: invoice,
      business: business,
      client: client,
      signature: signature.isEmpty
          ? PdfAssetLoader.transparentPixel
          : signature,
      businessLogo: await _readLogo(business),
    );
  }

  /// Reads the logo file, treating a missing or unreadable file as "no logo".
  Future<Uint8List?> _readLogo(Business business) async {
    if (!business.hasLogo) return null;
    try {
      final file = File(business.logoPath!);
      return await file.exists() ? await file.readAsBytes() : null;
    } on Object {
      return null;
    }
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppException {
      rethrow;
    } on Object catch (error) {
      throw PdfGenerationException(error);
    }
  }
}
