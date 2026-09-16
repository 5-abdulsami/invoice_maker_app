import 'package:flutter/foundation.dart';
import 'package:invoicemaker/core/enums/pdf_action.dart';
import 'package:invoicemaker/core/exceptions/app_exception.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Does something with a finished PDF.
///
/// Every template used to carry its own copy of this logic. It lives here
/// once, and each path reports a failure the UI can show verbatim instead of
/// failing silently.
class PdfOutput {
  const PdfOutput();

  /// Resolution the in-app preview is rasterised at.
  ///
  /// High enough to read the item table on a phone, low enough to stay quick
  /// when the template picker renders several pages.
  static const double _previewDpi = 96;

  /// Runs [action] against [document].
  ///
  /// Returns PNG bytes for [PdfAction.preview] and null for the rest.
  Future<Uint8List?> run({
    required pw.Document document,
    required String fileName,
    required PdfAction action,
  }) async {
    final bytes = await _save(document);

    return switch (action) {
      PdfAction.preview => _rasterFirstPage(bytes),
      PdfAction.share => _share(bytes, fileName),
      PdfAction.print => _print(bytes, fileName),
    };
  }

  Future<Uint8List> _save(pw.Document document) async {
    try {
      return await document.save();
    } on Object catch (error) {
      throw PdfGenerationException(error);
    }
  }

  /// Renders page one to an image for the in-app preview.
  Future<Uint8List?> _rasterFirstPage(Uint8List bytes) async {
    try {
      final pages = Printing.raster(bytes, pages: [0], dpi: _previewDpi);
      final page = await pages.first;
      return await page.toPng();
    } on Object catch (error) {
      throw PdfGenerationException(error);
    }
  }

  /// Opens the platform share sheet, which is also where the user saves the
  /// file to their device.
  Future<Uint8List?> _share(Uint8List bytes, String fileName) async {
    try {
      await Printing.sharePdf(bytes: bytes, filename: _pdfName(fileName));
      return null;
    } on Object catch (error) {
      throw ShareException(error);
    }
  }

  Future<Uint8List?> _print(Uint8List bytes, String fileName) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: _pdfName(fileName),
      );
      return null;
    } on Object catch (error) {
      throw PrintException(error);
    }
  }

  /// A file name that is safe on every platform.
  static String _pdfName(String fileName) {
    final cleaned = fileName
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '-')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return '${cleaned.isEmpty ? 'document' : cleaned}.pdf';
  }
}
