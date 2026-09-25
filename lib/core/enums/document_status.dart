import 'package:flutter/foundation.dart';
import 'package:invoicemaker/core/design/palette.dart';
import 'package:invoicemaker/core/enums/document_kind.dart';
import 'package:invoicemaker/core/extensions/date_ext.dart';

/// The state stored on a document.
///
/// "Overdue" and "expired" are deliberately not stored: they depend on today's
/// date and are derived when the document is displayed, so a record can never
/// go stale in storage.
enum DocumentStatus {
  unpaid('Unpaid', AppStatusTone.neutral, DocumentKind.invoice),
  partiallyPaid('Part paid', AppStatusTone.accent, DocumentKind.invoice),
  paid('Paid', AppStatusTone.positive, DocumentKind.invoice),
  pending('Pending', AppStatusTone.neutral, DocumentKind.estimate),
  approved('Approved', AppStatusTone.positive, DocumentKind.estimate),
  declined('Declined', AppStatusTone.critical, DocumentKind.estimate);

  const DocumentStatus(this.label, this.tone, this.kind);

  final String label;
  final AppStatusTone tone;

  /// Which document kind this status belongs to.
  final DocumentKind kind;

  /// Whether the document no longer needs chasing.
  bool get isSettled =>
      this == DocumentStatus.paid ||
      this == DocumentStatus.approved ||
      this == DocumentStatus.declined;

  /// Whether a part-payment amount applies.
  bool get tracksPartialPayment => this == DocumentStatus.partiallyPaid;

  /// The statuses a user may choose for [kind].
  static List<DocumentStatus> forKind(DocumentKind kind) =>
      values.where((status) => status.kind == kind).toList(growable: false);

  /// The status a new document of [kind] starts in.
  static DocumentStatus initialFor(DocumentKind kind) =>
      kind.isInvoice ? DocumentStatus.unpaid : DocumentStatus.pending;

  /// Resolves a stored name, repairing a value that belongs to the other kind.
  static DocumentStatus resolve(String? name, DocumentKind kind) {
    for (final status in values) {
      if (status.name == name && status.kind == kind) return status;
    }
    return initialFor(kind);
  }
}

/// How a document's state should be labelled right now, including the
/// date-derived overdue and expired cases.
@immutable
class DocumentStatusPresentation {
  const DocumentStatusPresentation({required this.label, required this.tone});

  final String label;
  final AppStatusTone tone;

  /// The line describing a document's end date, in the words that fit its
  /// kind: an invoice falls due (`Due in 7 days`, `3 days overdue`), an
  /// estimate stays valid (`Valid for 7 days`, `Expired yesterday`).
  ///
  /// A closed document no longer counts down, so it says what happens next
  /// instead of repeating its status badge.
  static String endDateLabel(DocumentStatus status, DateTime endDate) {
    return switch (status) {
      DocumentStatus.paid => 'Settled',
      DocumentStatus.unpaid ||
      DocumentStatus.partiallyPaid =>
        DueDateLabel.describe(endDate, isSettled: false),
      DocumentStatus.pending => DueDateLabel.describeValidity(endDate),
      DocumentStatus.approved => 'Ready to invoice',
      DocumentStatus.declined => 'Closed',
    };
  }

  /// Builds the badge for a document.
  ///
  /// [isPastEndDate] is true once the due date (invoice) or valid-until date
  /// (estimate) has passed.
  factory DocumentStatusPresentation.of(
    DocumentStatus status, {
    required bool isPastEndDate,
  }) {
    if (!isPastEndDate || status.isSettled) {
      return DocumentStatusPresentation(label: status.label, tone: status.tone);
    }

    return status.kind.isInvoice
        ? const DocumentStatusPresentation(
            label: 'Overdue',
            tone: AppStatusTone.critical,
          )
        : const DocumentStatusPresentation(
            label: 'Expired',
            tone: AppStatusTone.caution,
          );
  }
}
