/// Base for errors this app reports to the user.
sealed class AppException implements Exception {
  const AppException(this.message, [this.cause]);

  /// Message safe to show in a snackbar.
  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message${cause == null ? '' : ' ($cause)'}';
}

class PdfGenerationException extends AppException {
  const PdfGenerationException([Object? cause])
      : super('Could not create the PDF. Please try again.', cause);
}

class FileOperationException extends AppException {
  const FileOperationException(super.message, [super.cause]);
}

class ShareException extends AppException {
  const ShareException([Object? cause])
      : super('Could not share the invoice.', cause);
}

class PrintException extends AppException {
  const PrintException([Object? cause])
      : super('Could not print the invoice.', cause);
}

class EmailException extends AppException {
  const EmailException([Object? cause])
      : super('Could not open your email app.', cause);
}

class ImagePickException extends AppException {
  const ImagePickException([Object? cause])
      : super('Could not load the selected image.', cause);
}

class SignatureException extends AppException {
  const SignatureException([Object? cause])
      : super('Could not capture the signature.', cause);
}

class DataFormatException extends AppException {
  const DataFormatException(super.message, [super.cause]);
}
