import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/enums/pdf_action.dart';
import 'package:invoicemaker/core/exceptions/app_exception.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart' as px;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

/// Does something with a finished PDF: preview, save, share, email or print.
///
/// Every template used to carry its own copy of this logic; it now lives here
/// once, with the error handling the templates never had.
class PdfActionHandler {
  const PdfActionHandler();

  /// Runs [action] against [document].
  ///
  /// Returns preview image bytes for [PdfAction.preview], and null otherwise.
  /// Throws an [AppException] the UI can show verbatim.
  Future<Uint8List?> run({
    required pw.Document document,
    required String fileName,
    required PdfAction action,
  }) async {
    final Uint8List bytes;
    try {
      bytes = await document.save();
    } on Object catch (error) {
      throw PdfGenerationException(error);
    }

    return switch (action) {
      PdfAction.preview => _preview(bytes, fileName),
      PdfAction.save => _save(bytes, fileName),
      PdfAction.share => _share(bytes, fileName),
      PdfAction.email => _email(bytes, fileName),
      PdfAction.print => _print(bytes),
    };
  }

  /// Renders page one to a JPEG so it can be shown inside the app.
  Future<Uint8List?> _preview(Uint8List bytes, String fileName) async {
    px.PdfDocument? document;
    px.PdfPage? page;
    try {
      final file = await _writeTempFile(bytes, fileName);
      document = await px.PdfDocument.openFile(file.path);
      page = await document.getPage(1);
      final image = await page.render(
        width: page.width,
        height: page.height,
        format: px.PdfPageImageFormat.jpeg,
      );
      return image?.bytes;
    } on Object catch (error) {
      throw PdfGenerationException(error);
    } finally {
      await page?.close();
      await document?.close();
    }
  }

  /// Writes the PDF to disk and hands it to the platform viewer.
  Future<Uint8List?> _save(Uint8List bytes, String fileName) async {
    final file = await _writeTempFile(bytes, fileName);
    final result = await OpenFile.open(file.path);
    if (result.type != ResultType.done) {
      throw FileOperationException(
        'Saved to ${file.path}, but no app could open it.',
        result.message,
      );
    }
    return null;
  }

  Future<Uint8List?> _share(Uint8List bytes, String fileName) async {
    try {
      final file = await _writeTempFile(bytes, fileName);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        text: AppStrings.pdfShareText,
      );
      return null;
    } on AppException {
      rethrow;
    } on Object catch (error) {
      throw ShareException(error);
    }
  }

  Future<Uint8List?> _email(Uint8List bytes, String fileName) async {
    try {
      final file = await _writeTempFile(bytes, fileName);
      await FlutterEmailSender.send(
        Email(
          body: AppStrings.pdfShareText,
          subject: AppStrings.invoice,
          attachmentPaths: [file.path],
          isHTML: false,
        ),
      );
      return null;
    } on AppException {
      rethrow;
    } on Object catch (error) {
      throw EmailException(error);
    }
  }

  Future<Uint8List?> _print(Uint8List bytes) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
      );
      return null;
    } on Object catch (error) {
      throw PrintException(error);
    }
  }

  Future<File> _writeTempFile(Uint8List bytes, String fileName) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/${_sanitize(fileName)}.pdf');
      return await file.writeAsBytes(bytes, flush: true);
    } on Object catch (error) {
      throw FileOperationException('Could not write the PDF file.', error);
    }
  }

  /// Strips characters that are illegal in file names on some platforms.
  String _sanitize(String fileName) {
    final cleaned = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    return cleaned.isEmpty ? 'invoice' : cleaned;
  }
}
