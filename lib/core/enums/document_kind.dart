/// The two kinds of document the app produces.
///
/// Invoices and estimates share one model, one store and one PDF pipeline;
/// this enum carries everything that differs between them.
enum DocumentKind {
  invoice(
    label: 'Invoice',
    plural: 'Invoices',
    printedTitle: 'INVOICE',
    numberPrefix: 'INV',
    issueDateLabel: 'Issue date',
    endDateLabel: 'Due date',
  ),
  estimate(
    label: 'Estimate',
    plural: 'Estimates',
    printedTitle: 'ESTIMATE',
    numberPrefix: 'EST',
    issueDateLabel: 'Issue date',
    endDateLabel: 'Valid until',
  );

  const DocumentKind({
    required this.label,
    required this.plural,
    required this.printedTitle,
    required this.numberPrefix,
    required this.issueDateLabel,
    required this.endDateLabel,
  });

  /// Singular name, e.g. `Invoice`.
  final String label;

  /// Plural name, used for list screens and counts.
  final String plural;

  /// Default heading printed on the document when no custom title is set.
  final String printedTitle;

  /// Prefix for generated numbers, e.g. `INV-0007`.
  final String numberPrefix;

  /// Caption for the creation date field.
  final String issueDateLabel;

  /// Caption for the due / valid-until date field.
  final String endDateLabel;

  bool get isInvoice => this == DocumentKind.invoice;

  static const DocumentKind fallback = DocumentKind.invoice;

  static DocumentKind fromName(String? name) {
    for (final kind in values) {
      if (kind.name == name) return kind;
    }
    return fallback;
  }
}
