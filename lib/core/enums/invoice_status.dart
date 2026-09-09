/// Payment state of an invoice.
enum InvoiceStatus {
  unpaid('Unpaid'),
  paid('Paid'),
  partiallyPaid('Partially Paid'),
  overdue('Overdue');

  const InvoiceStatus(this.label);

  final String label;

  /// Statuses a user may pick manually. [overdue] is derived from the due date.
  static const List<InvoiceStatus> selectable = [unpaid, paid, partiallyPaid];

  static InvoiceStatus fromLabel(String label) => values.firstWhere(
        (status) => status.label == label,
        orElse: () => InvoiceStatus.unpaid,
      );
}
