/// Base for failures this app reports to the user.
///
/// [message] is always safe to show verbatim: it says what failed in plain
/// words and never contains a customer's details or a file path.
sealed class AppException implements Exception {
  const AppException(this.message, [this.cause]);

  final String message;

  /// The underlying error, kept for debugging and never shown to the user.
  final Object? cause;

  @override
  String toString() =>
      '$runtimeType: $message${cause == null ? '' : ' (cause: $cause)'}';
}

/// Reading or writing the local store failed.
class StorageException extends AppException {
  const StorageException([Object? cause])
      : super('Could not save your data. Please try again.', cause);
}

/// The stored data could not be understood.
class DataFormatException extends AppException {
  const DataFormatException(super.message, [super.cause]);
}

/// Building the PDF document failed.
class PdfGenerationException extends AppException {
  const PdfGenerationException([Object? cause])
      : super('Could not create the PDF. Please try again.', cause);
}

/// Writing, reading or opening a file failed.
class FileOperationException extends AppException {
  const FileOperationException(super.message, [super.cause]);
}

class ShareException extends AppException {
  const ShareException([Object? cause])
      : super('Could not share the document.', cause);
}

class PrintException extends AppException {
  const PrintException([Object? cause])
      : super('Could not open the print dialog.', cause);
}

class ImagePickException extends AppException {
  const ImagePickException([Object? cause])
      : super('Could not load the selected image.', cause);
}

class SignatureException extends AppException {
  const SignatureException([Object? cause])
      : super('Could not save the signature.', cause);
}

/// Exporting a backup failed.
class BackupExportException extends AppException {
  const BackupExportException([Object? cause])
      : super('Could not create the backup file.', cause);
}

/// The chosen file was not a backup this app can read.
class BackupImportException extends AppException {
  const BackupImportException([
    super.message = 'That file is not a valid Invoice Maker backup.',
    super.cause,
  ]);
}
