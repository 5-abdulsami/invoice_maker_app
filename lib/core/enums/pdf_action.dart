/// What to do with a generated document.
///
/// There is no separate "save to file": the platform share sheet already
/// offers saving to Files or Drive, so exposing both would be two buttons for
/// one outcome and a second code path that can fail.
enum PdfAction {
  /// Rasterise the first page for the in-app preview.
  preview,

  /// Hand the PDF to the system share sheet.
  share,

  /// Send it to the platform print dialog.
  print,
}
