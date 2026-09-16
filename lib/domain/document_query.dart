import 'package:flutter/foundation.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/enums/document_kind.dart';
import 'package:invoicemaker/core/enums/document_status.dart';
import 'package:invoicemaker/data/models/sales_document.dart';

/// Orderings offered on the document list.
enum DocumentSort {
  newest(AppStrings.newestFirst),
  oldest(AppStrings.oldestFirst),
  dueSoonest(AppStrings.dueSoonest),
  highestAmount(AppStrings.highestAmount),
  lowestAmount(AppStrings.lowestAmount);

  const DocumentSort(this.label);

  final String label;

  static const DocumentSort fallback = DocumentSort.newest;

  /// Comparator for this ordering.
  int compare(SalesDocument a, SalesDocument b) => switch (this) {
        DocumentSort.newest => b.issueDate.compareTo(a.issueDate),
        DocumentSort.oldest => a.issueDate.compareTo(b.issueDate),
        DocumentSort.dueSoonest => a.endDate.compareTo(b.endDate),
        DocumentSort.highestAmount =>
          b.totals.total.compareTo(a.totals.total),
        DocumentSort.lowestAmount =>
          a.totals.total.compareTo(b.totals.total),
      };
}

/// One chip on the document list's filter bar.
@immutable
class DocumentFilter {
  const DocumentFilter({
    required this.label,
    this.status,
    this.pastDueOnly = false,
  });

  final String label;

  /// The status this chip selects; null with [pastDueOnly] false means "all".
  final DocumentStatus? status;

  /// Selects documents past their due or valid-until date instead of by
  /// stored status, since overdue is derived rather than stored.
  final bool pastDueOnly;

  bool get isAll => status == null && !pastDueOnly;

  bool matches(SalesDocument document) {
    if (pastDueOnly) return document.isPastEndDate;
    final wanted = status;
    if (wanted == null) return true;

    // An overdue invoice is still stored as unpaid, so the "Unpaid" chip
    // would otherwise also list documents the "Overdue" chip covers.
    if (wanted == DocumentStatus.unpaid && document.isPastEndDate) {
      return false;
    }
    return document.status == wanted;
  }

  /// The chips for [kind]: all, each status, then the date-derived one.
  static List<DocumentFilter> forKind(DocumentKind kind) {
    return [
      const DocumentFilter(label: AppStrings.all),
      for (final status in DocumentStatus.forKind(kind))
        DocumentFilter(label: status.label, status: status),
      DocumentFilter(
        label: kind.isInvoice ? AppStrings.overdue : 'Expired',
        pastDueOnly: true,
      ),
    ];
  }

  @override
  bool operator ==(Object other) =>
      other is DocumentFilter &&
      other.label == label &&
      other.status == status &&
      other.pastDueOnly == pastDueOnly;

  @override
  int get hashCode => Object.hash(label, status, pastDueOnly);
}

/// Applies the list screen's filter, search and ordering.
sealed class DocumentQuery {
  static List<SalesDocument> apply(
    List<SalesDocument> documents, {
    required DocumentKind kind,
    DocumentFilter? filter,
    DocumentSort sort = DocumentSort.fallback,
    String query = '',
  }) {
    final results = documents
        .where(
          (document) =>
              document.kind == kind &&
              (filter?.matches(document) ?? true) &&
              document.matches(query),
        )
        .toList();

    results.sort(sort.compare);
    return List.unmodifiable(results);
  }
}
